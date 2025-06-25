import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/haptics.dart';
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
    this.blurMode = LdContextMenuBlurMode.mobileOnly,
    this.zoomMode = LdContextZoomMode.mobileOnly,
    this.listenForTaps = true,
    this.visible,
    this.disabled = false,
    this.positionMode = LdContextPositionMode.auto,
    this.child,
  });

  final bool? visible;

  final bool disabled;

  final bool dismissOnOutsideTap;

  final bool listenForTaps;

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
  final GlobalKey _triggerKey = GlobalKey();

  final _overlayPortalController = OverlayPortalController();

  RenderBox? _triggerBox;

  final GlobalKey _menuKey = GlobalKey();

  late bool _visible = widget.visible ?? false;
  Offset? _cursorPosition;

  final _menuSizeNotifier = ValueNotifier<Size>(Size.zero);

  bool get _mobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void initState() {
    super.initState();
  }

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

  @override
  didUpdateWidget(LdContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != null && widget.visible != oldWidget.visible) {
      if (widget.visible!) {
        _overlayPortalController.show();
      } else {
        _overlayPortalController.hide();
      }
    }
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

  Future<void> _dismiss() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    setState(() {
      _visible = false;
    });
  }

  (Rect, Alignment) _resizeMenuToScreen(
    BuildContext context,
    Size menuSize,
  ) {
    if (_triggerBox == null) {
      return (Rect.zero, Alignment.topLeft);
    }
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;

    var mediaQuery = MediaQuery.of(context);

    if (view != null) {
      mediaQuery = MediaQueryData.fromView(view);
    }

    final viewInsets = mediaQuery.viewInsets + const EdgeInsets.all(10);

    final screenSize = mediaQuery.size;

    final menuWidth = menuSize.width;
    final menuHeight = menuSize.height;

    Offset triggerOffset;
    Size triggerSize;

    if (_effectivePositionMode == LdContextPositionMode.relativeTrigger || _cursorPosition == null) {
      triggerSize = _triggerBox!.size;
      triggerOffset = Offset(
        _triggerBox!.localToGlobal(Offset.zero).dx,
        _triggerBox!.localToGlobal(Offset.zero).dy + triggerSize.height,
      );
    } else {
      triggerOffset = _cursorPosition ?? Offset.zero;
      // Place the cursor right on the first menu item
      triggerOffset = Offset(
        triggerOffset.dx - LdTheme.of(context).sizingConfig.radiusM,
        triggerOffset.dy - LdTheme.of(context).sizingConfig.radiusM,
      );
      triggerSize = Size.zero;
    }

    final overflowX = min(
          0,
          screenSize.width - viewInsets.right - viewInsets.left - (triggerOffset.dx) - menuWidth,
        ) +
        10;

    final overflowY = min(
          0,
          screenSize.height - viewInsets.bottom - viewInsets.top - (triggerOffset.dy + triggerSize.height) - menuHeight,
        ) +
        10;

    final baseRect = Rect.fromLTWH(
      triggerOffset.dx + overflowX,
      triggerOffset.dy + overflowY,
      menuSize.width,
      menuSize.height,
    );

    final isLeftOfTrigger = baseRect.left < triggerOffset.dx;
    final isAboveTrigger = baseRect.top < triggerOffset.dy;

    return switch ((isLeftOfTrigger, isAboveTrigger)) {
      (true, true) => (baseRect, Alignment.bottomRight),
      (true, false) => (baseRect, Alignment.topRight),
      (false, true) => (baseRect, Alignment.bottomLeft),
      (false, false) => (baseRect, Alignment.topLeft),
    };
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

    _triggerBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;

    _overlayPortalController.show();
    setState(() {
      _visible = true;
    });
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
        ({Offset? position}) {
          if (position == null) {
            if (_triggerBox != null) {
              _open(
                globalPosition: Offset(
                  _triggerBox!.localToGlobal(Offset.zero).dx,
                  _triggerBox!.localToGlobal(Offset.zero).dy + _triggerBox!.size.height,
                ),
              );
            } else {
              _open();
            }
          } else {
            _open(globalPosition: position);
          }
        },
        widget.child,
      ),
    );
  }

  Widget _buildZoom(BuildContext context, Widget child) {
    if (_shouldZoom) {
      return LdSpring(
        initialPosition: 0,
        position: _visible ? 1 : 0,
        child: child,
        builder: (context, state, child) {
          return Opacity(
            opacity: state.position.clamp(0, 1),
            child: Transform.scale(
              scale: max(0, state.position * 0.01 + 1),
              child: child,
            ),
          );
        },
      );
    }
    return child;
  }

  Widget _buildBlur(BuildContext context, Widget child) {
    if (!_shouldBlur) {
      return const SizedBox.shrink();
    }
    return LdSpring(
      initialPosition: 0,
      position: _visible ? 1 : 0,
      child: child,
      builder: (context, state, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10 * state.position.clamp(0, 1),
            sigmaY: 10 * state.position.clamp(0, 1),
          ),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return OverlayPortal.targetsRootOverlay(
      overlayChildBuilder: (context) => Builder(builder: (context) {
        final menu = Builder(builder: (context) {
          return LdSpring(
            initialPosition: 0,
            //mass: 8,
            //springConstant: 15,
            //dampingCoefficient: 15,
            position: _visible ? 1 : 0,
            onAnimationEnd: (context, state) async {
              await Future.delayed(Duration.zero);
              if (state.position == 0 && mounted) {
                _overlayPortalController.hide();
              }
            },
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: true,
              ),
              child: NotificationListener<LdContextMenuDissmissNotification>(
                onNotification: (notification) {
                  _dismiss();
                  return true;
                },
                child: Builder(builder: (context) {
                  return widget.menuBuilder(context, _dismiss);
                }),
              ),
            ),
            builder: (context, state, child) {
              final (rect, alignment) = _resizeMenuToScreen(
                context,
                _menuSizeNotifier.value,
              );

              return Positioned.fromRect(
                rect: rect,
                child: Opacity(
                  opacity: state.position.clamp(0, 1),
                  child: Align(
                    alignment: alignment,
                    child: Transform.scale(
                      alignment: alignment,
                      scale: max(0, state.position),
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: rect.width,
                          maxHeight: max(0, rect.height),
                        ),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: theme.surface,
                          border: Border.all(
                            color: theme.border,
                            strokeAlign: BorderSide.strokeAlignOutside,
                            width: theme.borderWidth,
                          ),
                          borderRadius: theme.radius(LdSize.m),
                          boxShadow: [
                            BoxShadow(
                              color: theme.palette.neutral.shades.last.withAlpha(51),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            )
                          ],
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          widthFactor: 1,
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        });
        return Stack(
          fit: StackFit.expand,
          children: [
            Offstage(
              child: Center(
                child: KeyedSubtree(
                  key: _menuKey,
                  child: MeasureSize(
                    sizeNotifier: _menuSizeNotifier,
                    child: widget.menuBuilder(context, _dismiss),
                  ),
                ),
              ),
            ),
            if (_shouldBlur) ...[
              _buildBlur(
                context,
                Container(
                  color: Colors.black.withAlpha(51),
                ),
              ),
              if (_triggerBox != null)
                Positioned(
                  left: _triggerBox!.localToGlobal(Offset.zero).dx,
                  top: _triggerBox!.localToGlobal(Offset.zero).dy,
                  width: _triggerBox!.size.width,
                  height: _triggerBox!.size.height,
                  child: _buildZoom(
                    context,
                    widget.builder(context, true, _open, widget.child),
                  ),
                ),
            ],
            ModalBarrier(
              onDismiss: _dismiss,
            ),
            menu,
          ],
        );
      }),
      controller: _overlayPortalController,
      child: _buildTriggerDetector(context),
    );
  }
}
