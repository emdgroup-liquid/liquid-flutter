import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';

enum LdContextMenuBlurMode {
  /// Blur on mobile
  mobileOnly,

  /// Always blur
  always,

  /// Never blur
  never,
}

enum LdContextZoomMode {
  /// Zoom on mobile
  mobileOnly,

  /// Always zoom
  always,

  /// Never zoom
  never,
}

enum LdContextPositionMode {
  /// Automatically position the menu uses [relativeTrigger] on mobile and [relativeCursor] on desktop
  auto,

  /// Position relative to the trigger
  relativeTrigger,

  /// Position relative to the cursor
  relativeCursor,
}

class LdContextMenuDissmissNotification extends Notification {}

class LdContextMenu extends StatefulWidget {
  const LdContextMenu({
    super.key,
    required this.builder,
    required this.menuBuilder,
    this.dismissOnOutsideTap = true,
    this.scaleFromTrigger = false,
    this.blurMode = LdContextMenuBlurMode.mobileOnly,
    this.zoomMode = LdContextZoomMode.mobileOnly,
    this.listenForTaps = true,
    this.visible,
    this.disabled = false,
    this.positionMode = LdContextPositionMode.auto,
    this.child,
    this.triggerColor,
    this.menuProviders,
  });

  final bool? visible;

  final bool disabled;

  final bool dismissOnOutsideTap;

  final LdColor? triggerColor;

  final bool listenForTaps;

  final bool scaleFromTrigger;

  final List<SingleChildWidget>? Function(BuildContext context)? menuProviders;

  final LdContextMenuBlurMode blurMode;
  final LdContextZoomMode zoomMode;
  final LdContextPositionMode positionMode;

  final Widget? child;

  final Widget Function(BuildContext context, bool isShuttle, VoidCallback trigger, Widget? child) builder;

  final Widget Function(
    BuildContext context,
    VoidCallback onDismiss,
  ) menuBuilder;

  @override
  State<LdContextMenu> createState() => _LdContextMenuState();
}

class _LdContextMenuState extends State<LdContextMenu> {
  final GlobalKey _triggerKey = GlobalKey(debugLabel: "Trigger Key");

  RenderBox? _triggerBox;

  final GlobalKey _menuKey = GlobalKey(debugLabel: "Menu Key");

  Offset? _cursorPosition;

  final ValueNotifier<Size> _menuSizeNotifier = ValueNotifier(Size.zero);

  bool get _mobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void dispose() {
    _menuSizeNotifier.dispose();
    super.dispose();
  }

  bool get _shouldBlur {
    return switch (widget.blurMode) {
      (LdContextMenuBlurMode.mobileOnly) => _mobile,
      (LdContextMenuBlurMode.always) => true,
      (LdContextMenuBlurMode.never) => false,
    };
  }

  bool get _shouldZoom {
    return switch (widget.zoomMode) {
      (LdContextZoomMode.mobileOnly) => _mobile,
      (LdContextZoomMode.always) => true,
      (LdContextZoomMode.never) => false,
    };
  }

  LdContextPositionMode get _effectivePositionMode {
    if (widget.positionMode == LdContextPositionMode.auto) {
      return _mobile ? LdContextPositionMode.relativeTrigger : LdContextPositionMode.relativeCursor;
    }
    return widget.positionMode;
  }

  void _dismiss() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).maybePop();
  }

  Offset? _getTriggerPosition() {
    _triggerBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    return _triggerBox?.localToGlobal(Offset.zero);
  }

  Size? _getTriggerSize() {
    _triggerBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    return _triggerBox?.size;
  }

  Offset _getMenuPosition() {
    _triggerBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (_effectivePositionMode == LdContextPositionMode.relativeTrigger || _cursorPosition == null) {
      if (_triggerBox != null) {
        final triggerOffset = _getTriggerPosition() ?? Offset.zero;
        final triggerSize = _getTriggerSize() ?? Size.zero;
        return Offset(triggerOffset.dx, triggerOffset.dy + triggerSize.height);
      }
      return Offset.zero;
    } else {
      return _cursorPosition ?? Offset.zero;
    }
  }

  void _open({Offset? globalPosition}) async {
    if (widget.disabled) {
      return;
    }
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    _cursorPosition = globalPosition;
    final position = _getMenuPosition();
    Navigator.of(context).push(
      ContextMenuRoute(
        menuBuilder: (ctx, onDismiss) => widget.menuBuilder(ctx, onDismiss),
        position: position,
        triggerPosition: _getTriggerPosition() ?? Offset.zero,
        triggerSize: _getTriggerSize() ?? Size.zero,
        shouldBlur: _shouldBlur,
        shouldZoom: _shouldZoom,
        backgroundColor: null,
        onDismiss: _dismiss,
        providers: widget.menuProviders?.call(context),
      ),
    );
  }

  Widget _buildTriggerDetector(BuildContext context) {
    return GestureDetector(
      key: _triggerKey,
      onSecondaryTapDown: (details) {
        _open(globalPosition: details.globalPosition);
      },
      onLongPressStart: (details) {
        if (!_mobile) {
          return;
        }
        LdHaptics.vibrate(HapticsType.heavy);
        _open(globalPosition: details.globalPosition);
      },
      child: widget.builder(
        context,
        false,
        () {
          _open();
        },
        widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTriggerDetector(context);
  }
}

/// A modal route for displaying a context menu, supporting custom positioning, blur, and zoom.
class ContextMenuRoute extends ModalRoute<void> {
  final Widget Function(BuildContext, VoidCallback) menuBuilder;
  final Offset position;
  final Offset triggerPosition;
  final Size triggerSize;
  final bool shouldBlur;
  final bool shouldZoom;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;
  final List<SingleChildWidget>? providers;

  final ValueNotifier<Size> _menuSizeNotifier = ValueNotifier(Size.zero);

  /// [providers] allows you to inject providers into the context menu route.
  ContextMenuRoute({
    required this.menuBuilder,
    required this.position,
    this.shouldBlur = false,
    this.shouldZoom = false,
    this.backgroundColor,
    this.onDismiss,
    required this.triggerPosition,
    required this.triggerSize,
    this.providers,
  });

  @override
  void dispose() {
    _menuSizeNotifier.dispose();
    super.dispose();
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => backgroundColor ?? Colors.transparent;

  @override
  String? get barrierLabel => 'ContextMenu';

  @override
  bool get maintainState => true;

  @override
  void didComplete(result) {
    super.didComplete(result);
    onDismiss?.call();
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return ValueListenableBuilder<Size>(
        valueListenable: _menuSizeNotifier,
        builder: (context, size, child) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
              ),
              if (size == Size.zero) _buildOffstageMenuForMeasurement(context),
            ],
          );
        });
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_menuSizeNotifier.value == Size.zero) {
      return Stack(
        children: [
          _buildOffstageMenuForMeasurement(context),
        ],
      );
    }
    return Stack(
      children: [
        _buildAnimatedMenuTransition(context, animation, _menuSizeNotifier.value),
      ],
    );
  }

  Widget _buildOffstageMenuForMeasurement(BuildContext context) {
    return Offstage(
      child: MeasureSize(
        sizeNotifier: _menuSizeNotifier,
        child: _buildMenuContent(context),
      ),
    );
  }

  Widget _buildAnimatedMenuTransition(BuildContext context, Animation<double> animation, Size menuSize) {
    final startRect = Rect.fromLTWH(
      triggerPosition.dx,
      triggerPosition.dy,
      triggerSize.width,
      triggerSize.height,
    );
    final endRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      menuSize.width,
      menuSize.height,
    );
    final rectTween = RectTween(begin: startRect, end: endRect);
    final rect = rectTween.evaluate(animation)!;
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: shouldBlur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10 * animation.value, sigmaY: 10 * animation.value),
              child: _buildMenuTransitionContent(context, animation),
            )
          : _buildMenuTransitionContent(context, animation),
    );
  }

  Widget _buildMenuTransitionContent(BuildContext context, Animation<double> animation) {
    return Transform.scale(
      scale: shouldZoom ? (0.95 + 0.05 * animation.value) : 1.0,
      child: FadeTransition(
        opacity: animation,
        child: _buildMenuContent(context),
      ),
    );
  }

  Widget _wrapMenu(BuildContext context, Widget menu) {
    return Container(
      decoration: BoxDecoration(
        color: LdTheme.of(context).surface,
        borderRadius: LdTheme.of(context).radius(LdSize.m),
        boxShadow: [ldShadowSticky],
        border: Border.all(color: LdTheme.of(context).border, width: LdTheme.of(context).borderWidth),
      ),
      child: menu,
    );
  }

  Widget _buildMenuContent(BuildContext context) {
    return MeasureSize(
      sizeNotifier: _menuSizeNotifier,
      child: providers != null && providers!.isNotEmpty
          ? MultiProvider(
              providers: providers!,
              child: Builder(builder: (context) {
                return _wrapMenu(context, menuBuilder(context, onDismiss ?? () {}));
              }),
            )
          : _wrapMenu(context, menuBuilder(context, onDismiss ?? () {})),
    );
  }

  @override
  bool get opaque => false;
}
