import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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
    this.positionMode = LdContextPositionMode.auto,
  });

  final bool? visible;

  final bool dismissOnOutsideTap;

  final bool listenForTaps;

  final LdContextMenuBlurMode blurMode;
  final LdContextZoomMode zoomMode;
  final LdContextPositionMode positionMode;

  final Widget Function(
      BuildContext context, bool isShuttle, VoidCallback trigger) builder;

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

  bool get _mobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

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
      return _mobile
          ? LdContextPositionMode.relativeTrigger
          : LdContextPositionMode.relativeCursor;
    }
    return widget.positionMode;
  }

  void _dismiss() {
    setState(() {
      _visible = false;
    });
  }

  (Rect, Alignment) _resizeMenuToScreen(
    BuildContext context,
    Size menuSize,
  ) {
    final mediaQuery = MediaQuery.of(
      Scaffold.maybeOf(context)?.context ?? context,
    );

    final viewInsets = mediaQuery.viewInsets + const EdgeInsets.all(10);

    final screenSize = mediaQuery.size;

    final menuWidth = menuSize.width;
    final menuHeight = menuSize.height;

    Offset triggerOffset;
    Size triggerSize;

    if (_effectivePositionMode == LdContextPositionMode.relativeTrigger) {
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
      screenSize.width - viewInsets.right - (triggerOffset.dx) - menuWidth,
    );

    final overflowY = min(
      0,
      screenSize.height -
          viewInsets.bottom -
          (triggerOffset.dy + triggerSize.height) -
          menuHeight,
    );

    final baseRect = Rect.fromLTWH(
      triggerOffset.dx + overflowX,
      triggerOffset.dy + overflowY,
      screenSize.width - viewInsets.right - (triggerOffset.dx) - overflowX,
      screenSize.height -
          viewInsets.bottom -
          (triggerOffset.dy + triggerSize.height) -
          overflowY,
    );

    return (baseRect, Alignment.topLeft);
  }

  void _open({Offset? globalPosition}) async {
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
        HapticFeedback.heavyImpact();
        _open(globalPosition: details.globalPosition);
      },
      child: widget.builder(context, false, ({Offset? position}) {
        if (position == null) {
          if (_triggerBox != null) {
            _open(
              globalPosition: Offset(
                _triggerBox!.localToGlobal(Offset.zero).dx,
                _triggerBox!.localToGlobal(Offset.zero).dy +
                    _triggerBox!.size.height,
              ),
            );
          } else {
            _open();
          }
        } else {
          _open(globalPosition: position);
        }
      }),
    );
  }

  Widget _buildZoom(BuildContext context, Widget child) {
    if (_shouldZoom) {
      return LdSpring(
        initialPosition: 1,
        position: _visible ? 1.1 : 1,
        builder: (context, state) {
          return Transform.scale(
            scale: state.position,
            child: child,
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
      builder: (context, state) {
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
      overlayChildBuilder: (context) =>
          LayoutBuilder(builder: (context, constraints) {
        final menu = LdSpring(
          initialPosition: 0,
          mass: 8,
          springConstant: 15,
          dampingCoefficient: 15,
          position: _visible ? 1 : 0,
          onAnimationEnd: (context, state) {
            if (state.position == 0) {
              _overlayPortalController.hide();
            }
          },
          builder: (context, state) {
            final triggerBox =
                _triggerKey.currentContext?.findRenderObject() as RenderBox?;
            final menuBox =
                _menuKey.currentContext?.findRenderObject() as RenderBox?;

            if (triggerBox == null ||
                menuBox == null ||
                !menuBox.hasSize ||
                !triggerBox.hasSize) {
              return const SizedBox.shrink();
            }

            final (rect, alignment) = _resizeMenuToScreen(
              context,
              menuBox.size,
            );

            return Positioned.fromRect(
              rect: rect,
              child: Opacity(
                opacity: state.position.clamp(0, 1),
                child: Align(
                  alignment: alignment,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: rect.width,
                      maxHeight: rect.height,
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
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
                          color:
                              theme.palette.neutral.shades.last.withAlpha(51),
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      child: Align(
                        alignment: Alignment.topLeft,
                        widthFactor: 1,
                        heightFactor: state.position.clamp(0, double.infinity),
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            scrollbars: true,
                          ),
                          child: widget.menuBuilder(context, _dismiss),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            Offstage(
              child: Center(
                  child: KeyedSubtree(
                key: _menuKey,
                child: widget.menuBuilder(context, _dismiss),
              )),
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
                    widget.builder(context, true, _open),
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
      child: _buildZoom(
        context,
        _buildTriggerDetector(context),
      ),
    );
  }
}

class _PostFrameCallback extends StatefulWidget {
  const _PostFrameCallback({
    required this.child,
    required this.postFrameCallback,
  });

  final Widget child;

  final void Function(GlobalKey key) postFrameCallback;

  @override
  State<_PostFrameCallback> createState() => _PostFrameCallbackState();
}

class _PostFrameCallbackState extends State<_PostFrameCallback> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.postFrameCallback(_key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
