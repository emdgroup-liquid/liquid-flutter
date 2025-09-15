import 'dart:io';
import 'dart:math';
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

  Offset? _getTriggerPosition() {
    _triggerBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    return _triggerBox?.localToGlobal(Offset.zero);
  }

  Size? _getTriggerSize() {
    _triggerBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    return _triggerBox?.size;
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

    Navigator.of(context, rootNavigator: true).push(
      ContextMenuRoute(
        menuBuilder: (ctx, onDismiss) => widget.menuBuilder(ctx, onDismiss),
        effectivePositionMode: _effectivePositionMode,
        triggerKey: _triggerKey,
        cursorPosition: _cursorPosition,
        triggerPosition: _getTriggerPosition() ?? Offset.zero,
        triggerSize: _getTriggerSize() ?? Size.zero,
        shouldBlur: _shouldBlur,
        shouldZoom: _shouldZoom,
        backgroundColor: null,
        providers: widget.menuProviders?.call(context),
        triggerBuilder: (context, isShuttle, trigger, child) => widget.builder(
          context,
          isShuttle,
          trigger,
          child,
        ),
        child: widget.child,
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
      child: Hero(
        tag: "context-menu-trigger-${_triggerKey.hashCode}",
        child: widget.builder(
          context,
          false,
          () {
            _open();
          },
          widget.child,
        ),
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

  final Offset triggerPosition;
  final GlobalKey triggerKey;
  final Size triggerSize;
  final bool shouldBlur;
  final LdContextPositionMode effectivePositionMode;
  final Offset? cursorPosition;
  final bool shouldZoom;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;
  final List<SingleChildWidget>? providers;
  final Widget Function(BuildContext, bool, VoidCallback, Widget?) triggerBuilder;
  final Widget? child;

  final ValueNotifier<Size> _menuSizeNotifier = ValueNotifier(Size.zero);

  /// [providers] allows you to inject providers into the context menu route.
  ContextMenuRoute({
    required this.menuBuilder,
    required this.effectivePositionMode,
    this.cursorPosition,
    this.shouldBlur = false,
    this.shouldZoom = false,
    this.backgroundColor,
    this.onDismiss,
    required this.triggerPosition,
    required this.triggerSize,
    this.providers,
    required this.triggerKey,
    required this.triggerBuilder,
    required this.child,
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

  (Rect, Alignment) _resizeMenuToScreen(
    BuildContext context,
    Size menuSize,
  ) {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;

    var mediaQuery = MediaQuery.of(context);

    if (view != null) {
      mediaQuery = MediaQueryData.fromView(view);
    }

    Offset triggerPosition;
    Size triggerSize;

    if (effectivePositionMode == LdContextPositionMode.relativeTrigger || cursorPosition == null) {
      triggerPosition = this.triggerPosition;
      triggerSize = Size(this.triggerSize.width + 10, this.triggerSize.height + 10);
    } else {
      triggerPosition = cursorPosition ?? Offset.zero;
      triggerSize = const Size(10, 10);
    }

    final viewInsets = mediaQuery.viewInsets + LdTheme.of(context).pad(size: LdSize.m);

    final screenSize = mediaQuery.size;

    final menuWidth = menuSize.width;
    final menuHeight = menuSize.height;

    final availableWidth = screenSize.width - viewInsets.right - viewInsets.left;
    final availableHeight = screenSize.height - viewInsets.bottom - viewInsets.top;

    final overflowX = min(
      0,
      availableWidth - (triggerPosition.dx) - menuWidth,
    );

    final overflowY = min(
      0,
      availableHeight - (triggerPosition.dy) - menuHeight - triggerSize.height,
    );

    final baseRect = Rect.fromLTWH(
      triggerPosition.dx + overflowX,
      triggerPosition.dy + overflowY + triggerSize.height,
      menuSize.width,
      menuSize.height,
    );

    final isLeftOfTrigger = baseRect.left < triggerPosition.dx;
    final isAboveTrigger = baseRect.top < triggerPosition.dy;

    return switch ((isLeftOfTrigger, isAboveTrigger)) {
      (true, true) => (baseRect, Alignment.bottomRight),
      (true, false) => (baseRect, Alignment.topRight),
      (false, true) => (baseRect, Alignment.bottomLeft),
      (false, false) => (baseRect, Alignment.topLeft),
    };
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return ValueListenableBuilder<Size>(
        valueListenable: _menuSizeNotifier,
        builder: (context, size, child) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).maybePop();
                },
                behavior: HitTestBehavior.opaque,
              ),
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

    return LdWrapConditional(
      condition: shouldBlur,
      builder: (context, child) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10 * animation.value, sigmaY: 10 * animation.value),
        child: child,
      ),
      child: Stack(
        children: [
          if (shouldZoom)
            Positioned(
              left: triggerPosition.dx,
              top: triggerPosition.dy,
              width: triggerSize.width,
              height: triggerSize.height,
              child: Transform.scale(
                scale: 1 + 0.05 * animation.value,
                child: _wrapWithProviders(
                  context,
                  (context2) => triggerBuilder(
                    context2,
                    false,
                    () {},
                    this.child,
                  ),
                ),
              ),
            ),
          _buildAnimatedMenuTransition(context, _menuSizeNotifier.value, animation),
        ],
      ),
    );
  }

  Widget _buildOffstageMenuForMeasurement(BuildContext context) {
    return Offstage(
      child: MeasureSize(
        sizeNotifier: _menuSizeNotifier,
        child: Stack(
          children: [
            _buildAnimatedMenuTransition(context, _menuSizeNotifier.value, null),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuTransition(BuildContext context, Size menuSize, Animation<double>? animation) {
    final (endRect, alignment) = _resizeMenuToScreen(context, menuSize);

    return Positioned(
      left: endRect.left,
      top: endRect.top,
      child: NotificationListener<LdContextMenuDissmissNotification>(
        onNotification: (notification) {
          Navigator.of(context).maybePop();
          return true;
        },
        child: LdWrapConditional(
          condition: animation != null,
          builder: (context, child) => FadeTransition(
            opacity: animation!,
            child: ScaleTransition(
              alignment: alignment,
              scale: animation,
              child: child,
            ),
          ),
          child: _wrapWithProviders(
            context,
            (context2) => _wrapMenu(
              context2,
              menuBuilder(context2, onDismiss ?? () {}),
              alignment,
            ),
          ),
        ),
      ),
    );
  }

  Offset _getMenuOffset(Alignment alignment) {
    return switch (alignment) {
      Alignment.bottomRight => const Offset(-100, -100),
      Alignment.topRight => const Offset(100, -100),
      Alignment.bottomLeft => const Offset(-100, 100),
      Alignment.topLeft => const Offset(-100, -100),
      _ => Offset.zero,
    };
  }

  Widget _wrapMenu(BuildContext context, Widget menu, Alignment alignment) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: LdTheme.of(context).surface,
          borderRadius: LdTheme.of(context).radius(LdSize.m),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 12)],
          border: Border.all(color: LdTheme.of(context).border, width: LdTheme.of(context).borderWidth),
        ),
        child: LdSpring(
          mass: 15,
          springConstant: 10,
          dampingCoefficient: 15,
          initialPosition: 1.0,
          position: 0,
          builder: (context, state, child) {
            return Opacity(
              opacity: (1 - state.position.clamp(0, 1)),
              child: Transform.translate(
                offset: _getMenuOffset(alignment) * state.position,
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            child: MeasureSize(
              sizeNotifier: _menuSizeNotifier,
              child: menu,
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapWithProviders(BuildContext context, Widget Function(BuildContext context) builder) {
    return providers != null && providers!.isNotEmpty
        ? MultiProvider(
            providers: providers!,
            builder: (context, child) => builder(context),
          )
        : builder(context);
  }

  @override
  bool get opaque => false;
}
