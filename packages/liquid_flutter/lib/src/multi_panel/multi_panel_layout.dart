import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// A layout widget that displays a [body] and a [panel] side-by-side or stacked.
///
/// In [LdMultiPanelLayoutMode.sideBySide] mode, the [panel] and [body] are shown
/// next to each other. In [LdMultiPanelLayoutMode.stacked] mode, the [panel]
/// slides over the [body] from the edge.
class LdMultiPanelLayout extends StatefulWidget {
  /// The layout mode.
  final LdMultiPanelLayoutMode mode;

  /// The main body content, filling the remaining space.
  final Widget body;

  /// The side panel.
  final Widget panel;

  /// Which side the panel appears on.
  final LdPanelPosition panelPosition;

  /// When true, a drag handle is shown between panel and body in sideBySide mode.
  final bool allowResize;

  /// One-time seed for panel width as a fraction of total width.
  final double? initialPanelFraction;

  /// Minimum panel width when resizing.
  final double minPanelWidth;

  /// One-time seed for panel visibility. Null means the internal default (false).
  final bool? initialPanelVisible;

  /// Reactive visibility override. When non-null, controls visibility externally.
  final bool? panelVisible;

  /// Called when the panel's visibility changes.
  final void Function(bool visible)? onPanelVisibilityChanged;

  /// Controlled panel width. When non-null, this value is used directly and updates
  /// reactively when changed (e.g. parent layout constraints).
  final double? panelWidth;

  final double? minBodyWidth;

  /// Called when the panel width changes during a resize drag.
  final void Function(double width)? onPanelWidthChanged;

  /// Spring mass.
  final double mass;

  /// Spring constant.
  final double springConstant;

  /// Spring damping coefficient.
  final double dampingCoefficient;

  /// Whether to enable scaling effect in stacked mode.
  // TODO(enableScaling): implement body-scale effect
  final bool enableScaling;

  /// Whether to inset the body when the panel is visible.
  final bool insetBody;

  const LdMultiPanelLayout({
    super.key,
    this.mode = LdMultiPanelLayoutMode.sideBySide,
    required this.body,
    required this.panel,
    this.panelPosition = LdPanelPosition.left,
    this.allowResize = false,
    this.initialPanelFraction,
    this.minPanelWidth = 80,
    this.minBodyWidth,
    this.initialPanelVisible,
    this.panelVisible,
    this.onPanelVisibilityChanged,
    this.panelWidth,
    this.onPanelWidthChanged,
    this.mass = 5,
    this.springConstant = 3,
    this.dampingCoefficient = 5,
    this.enableScaling = true,
    this.insetBody = false,
  });

  @override
  State<LdMultiPanelLayout> createState() => _LdMultiPanelLayoutState();
}

class _LdMultiPanelLayoutState extends State<LdMultiPanelLayout> {
  /// Current panel width in uncontrolled mode.
  late double _internalPanelWidth;

  /// Current visibility state (internal).
  late bool _panelVisible;

  double _internalPanelFraction = 0;

  /// Whether a resize gesture is active (kept for cursor / UX feedback only;
  /// does NOT gate spring tree construction in [_buildSideBySide]).
  bool _isResizing = false;

  /// Cumulative resize delta (in pixels) accumulated during the current resize
  /// drag. Positive = panel has grown. Reset to 0 on drag end after the stable
  /// width is committed to [_internalPanelWidth].
  double _resizeDelta = 0;

  /// Swipe drag offset in stacked mode (for show/hide gesture).
  double _swipeDragOffset = 0;

  /// Total layout width from the most recent LayoutBuilder frame.
  double _totalWidth = 0;

  /// Guard to defer fraction-based width calculation to first layout frame.
  bool _fractionApplied = false;

  bool _appliedPanelWidth = false;

  @override
  void initState() {
    super.initState();
    // panelVisible (controlled prop) takes priority as the initial seed so that
    // callers who set it in their own initState (e.g. LdDrawerLayout opening on
    // desktop) don't get ignored. Falls back to initialPanelVisible, then false.
    _panelVisible = widget.panelVisible ?? widget.initialPanelVisible ?? false;
    _internalPanelWidth = widget.panelWidth ?? 300;
    // If fraction is specified we can't resolve it yet — deferred to first build.
  }

  @override
  void didUpdateWidget(LdMultiPanelLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sync visibility from controlled prop (also heals desync after gestures).
    if (widget.panelVisible != null && _panelVisible != widget.panelVisible) {
      setState(() {
        _panelVisible = widget.panelVisible!;
        _swipeDragOffset = 0;
      });
    }

    if (widget.panelWidth != null && widget.panelWidth != oldWidget.panelWidth) {
      setState(() {
        _appliedPanelWidth = false;
      });
    }
  }

  /// Returns the effective panel width to use for layout.
  double _effectivePanelWidth(double totalWidth) {
    if (widget.panelWidth != null) return widget.panelWidth!;
    if (widget.initialPanelFraction != null && !_fractionApplied && totalWidth > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _internalPanelWidth = widget.initialPanelFraction! * totalWidth;
          _fractionApplied = true;
        });
      });
      return widget.initialPanelFraction! * totalWidth;
    }
    return _internalPanelWidth;
  }

  /// Clamps [width] to valid panel bounds for the current [totalWidth].
  ///
  /// Avoids [double.clamp] throwing when [totalWidth] is still zero or smaller
  /// than [minPanelWidth] during the first layout pass.
  double _clampPanelWidth(
    double width,
    double totalWidth, {
    required bool stacked,
  }) {
    if (totalWidth <= 0) return width;
    final maxWidth = stacked ? totalWidth : totalWidth - widget.minPanelWidth;
    if (maxWidth < widget.minPanelWidth) {
      return width.clamp(0, totalWidth);
    }
    return width.clamp(widget.minPanelWidth, maxWidth);
  }

  void _setVisibility(bool visible) {
    if (_panelVisible == visible) return;
    setState(() {
      _panelVisible = visible;
    });
    widget.onPanelVisibilityChanged?.call(visible);
  }

  // ---------------------------------------------------------------------------
  // Shared spring helpers
  // ---------------------------------------------------------------------------

  /// Builds the panel [LdSpring] with a stable [Key('panel')] so that the
  /// underlying [State] is reused across `sideBySide` ↔ `stacked` mode
  /// switches, preventing teardown flicker.
  Widget _buildPanelSpring({
    required double position,
    required double initialPosition,
    required Widget Function(BuildContext context, LdSpringState state) builder,
    bool overriden = false,
  }) {
    return LdSpring(
      key: const Key('panel'),
      mass: widget.mass,
      springConstant: widget.springConstant,
      dampingCoefficient: widget.dampingCoefficient,
      initialPosition: initialPosition,
      position: position,
      overriden: overriden,
      builder: (context, state, child) => builder(context, state),
      child: widget.panel,
    );
  }

  // ---------------  ------------------------------------------------------------
  // Side-by-side layout
  // ---------------------------------------------------------------------------

  BorderSide get _bodyBorderSide => BorderSide(
        color: LdTheme.of(context).border,
        width: LdTheme.of(context).borderWidth,
      );

  bool get _panelIsLeft => widget.panelPosition == LdPanelPosition.left;
  bool get _insetBody => widget.insetBody;

  Decoration get _bodyDecoration => switch (_insetBody) {
        true => BoxDecoration(
            boxShadow: [ldShadowSticky],
            color: LdTheme.of(context).background,
            borderRadius: LdTheme.of(context).radius(LdSize.m),
            border: Border.all(
              color: LdTheme.of(context).border,
              width: LdTheme.of(context).borderWidth,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
        false => BoxDecoration(
              border: Border(
            right: _panelIsLeft ? BorderSide.none : _bodyBorderSide,
            left: _panelIsLeft ? _bodyBorderSide : BorderSide.none,
          )),
      };

  EdgeInsets get _insetPadding => LdTheme.of(context).pad(size: LdSize.m);

  EdgeInsets get _bodyMargin => switch (_insetBody) {
        true => switch (_panelVisible) {
            true => _insetPadding,
            false => EdgeInsets.zero,
          },
        false => EdgeInsets.zero,
      };
  EdgeInsets get _additionalDrawerPadding => switch (_insetBody) {
        true => _insetPadding.copyWith(
            left: _panelIsLeft ? null : 0,
            right: _panelIsLeft ? 0 : null,
          ),
        false => EdgeInsets.zero,
      };

  Widget _buildSideBySide(BoxConstraints constraints) {
    _totalWidth = max(1, constraints.maxWidth);

    final minPanelFraction = widget.minPanelWidth / _totalWidth;
    final maxPanelFraction = 1 - ((widget.minBodyWidth ?? 1) / _totalWidth);

    if (_internalPanelFraction == 0 && widget.initialPanelFraction != null) {
      _internalPanelFraction = widget.initialPanelFraction!;
    } else if (_internalPanelFraction == 0 && _totalWidth > 1) {
      _internalPanelFraction = (widget.panelWidth ?? widget.minPanelWidth) / _totalWidth;
    }

    double effectivePanelFraction = _internalPanelFraction;

    if (widget.panelWidth != null && !_appliedPanelWidth && !_isResizing) {
      effectivePanelFraction = widget.panelWidth! / _totalWidth;
      _appliedPanelWidth = true;
    }

    if (_isResizing) {
      effectivePanelFraction = effectivePanelFraction + (_resizeDelta / _totalWidth);
    }

    // Not using clamp to avoid crashes when totalWidth is not settled yet
    effectivePanelFraction = min(maxPanelFraction, effectivePanelFraction);
    effectivePanelFraction = max(minPanelFraction, effectivePanelFraction);

    // Instead of storing the panel width / visible translation as pixels, we use fractions. This
    // enables the widget to scale properly when the parent constraints change without requiring the springs to
    // re-evaluate their targets.

    final isLeft = _panelIsLeft;

    Widget buildPanel({
      required double panelLeft,
      required double panelWidth,
      required double panelVisibility,
    }) {
      final mediaQuery = MediaQuery.of(context);
      final bodyWidth = _totalWidth - panelWidth;
      final padding = EdgeInsets.only(
        right: isLeft ? _totalWidth - (_totalWidth - bodyWidth) : 0,
        left: isLeft ? 0 : _totalWidth - panelWidth,
      );

      final metrics = context.watch<LdAppBarMetrics?>();

      return Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        right: 0,
        child: Provider.value(
          value: LdMultiPanelChildState(
            left: panelLeft,
            width: panelWidth,
            onScreen: _panelVisible,
            isDragging: _isResizing,
            dragOffset: 0,
            role: LdPanelRole.panel,
          ),
          child: MediaQuery(
            data: mediaQuery.copyWith(
              padding: padding.atLeast(mediaQuery.padding),
            ),
            child: Provider.value(
              value: metrics?.copyWith(
                appbarLayerMediaQuery: metrics.appbarLayerMediaQuery.copyWith(
                  padding: padding.atLeast(metrics.appbarLayerMediaQuery.padding),
                ),
              ),
              child: Builder(
                builder: (context) {
                  final data = MediaQuery.of(context);
                  return LdWrapConditional(
                    condition: _insetBody,
                    builder: (context, child) => MediaQuery(
                      data: data.copyWith(
                        padding: (data.padding + (_additionalDrawerPadding * panelVisibility)).atLeast(EdgeInsets.zero),
                      ),
                      child: child,
                    ),
                    child: widget.panel,
                  );
                },
              ),
            ),
          ),
        ),
      );
    }

    Widget buildBody({required double left, required double right}) {
      final mediaQuery = MediaQuery.of(context);
      return Positioned.fill(
        child: MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding.copyWith(
              left: max(0, mediaQuery.padding.left - left),
              right: max(0, mediaQuery.padding.right - right),
            ),
          ),
          child: Provider.value(
            value: LdMultiPanelChildState(
              left: left,
              width: _totalWidth - left - right,
              onScreen: true,
              isDragging: _isResizing,
              dragOffset: 0,
              role: LdPanelRole.body,
            ),
            child: Builder(
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: left.clamp(0, _totalWidth),
                    right: right.clamp(0, _totalWidth),
                  ),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: _bodyMargin,
                    clipBehavior: Clip.hardEdge,
                    decoration: _bodyDecoration,
                    child: widget.body,
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return LdSpring(
      key: const Key('offset_spring'),
      mass: widget.mass,
      springConstant: widget.springConstant,
      dampingCoefficient: widget.dampingCoefficient,
      initialPosition: _panelVisible ? 1 : 0,
      position: _panelVisible ? 1 : 0,
      overriden: _isResizing,
      builder: (context, state, child) {
        final panelVisibility = state.position.clamp(0.0, 1.0);
        return LdSpring(
          key: const Key('ratio_spring'),
          mass: widget.mass,
          springConstant: widget.springConstant,
          dampingCoefficient: widget.dampingCoefficient,
          initialPosition: effectivePanelFraction,
          position: effectivePanelFraction,
          overriden: _isResizing,
          builder: (context, state, child) {
            final panelFraction = state.position.clamp(0.0, 1.0);
            final effectiveBodyWidth = (1 - (panelFraction * panelVisibility)) * _totalWidth;
            // Panel remains the same width but gets translated
            final effectivePanelWidth = panelFraction * _totalWidth;

            final panelLeft = isLeft
                ? -effectivePanelWidth * (1 - panelVisibility)
                : _totalWidth - (effectivePanelWidth * (panelVisibility));

            final bodyLeft = isLeft ? effectivePanelWidth * panelVisibility : 0.0;
            final bodyRight =
                isLeft ? _totalWidth - bodyLeft - effectiveBodyWidth : effectivePanelWidth * panelVisibility;

            final resizeHandleLeft = isLeft ? bodyLeft : bodyLeft + effectiveBodyWidth;

            final parentMetrics = ldAppBarParentMetrics(context);

            return Provider.value(
              value:
                  parentMetrics != null ? LdAppBarMetrics.reset(context).copyWith(parentMetrics: parentMetrics) : null,
              child: Stack(
                children: [
                  buildPanel(panelLeft: panelLeft, panelWidth: effectivePanelWidth, panelVisibility: panelVisibility),
                  buildBody(left: bodyLeft, right: bodyRight),

                  // Resize handle overlay
                  if (widget.allowResize && _panelVisible)
                    Positioned(
                      left: resizeHandleLeft,
                      top: 0,
                      bottom: 0,
                      width: 8,
                      child: _LdPanelResizeHandle(
                        isLeft: isLeft,
                        onDragUpdate: (delta) {
                          setState(() {
                            _isResizing = true;
                            // Accumulate the resize delta; do NOT update _internalPanelWidth
                            // here so that the spring targets remain stable during the drag.
                            // Clamping is enforced in [effectivePanelW] above.
                            _resizeDelta += (isLeft ? delta : -delta);
                          });
                          // Notify with the clamped effective width.
                          widget.onPanelWidthChanged?.call(effectivePanelWidth);
                        },
                        onDragEnd: () {
                          setState(() {
                            // Commit the accumulated delta into the stable width and reset.
                            _internalPanelWidth = effectivePanelWidth;

                            _internalPanelFraction = effectivePanelWidth / _totalWidth;

                            _resizeDelta = 0;
                            _isResizing = false;
                          });
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Stacked layout
  // ---------------------------------------------------------------------------

  Widget _buildStacked(BoxConstraints constraints) {
    _totalWidth = constraints.maxWidth;
    final isLeft = widget.panelPosition == LdPanelPosition.left;
    final panelW = _clampPanelWidth(
      _effectivePanelWidth(_totalWidth),
      _totalWidth,
      stacked: true,
    );

    // Clamp swipe offset so panel cannot go further than its width.
    final effectiveOffset = _panelVisible
        ? _swipeDragOffset.clamp(-panelW, 0.0) // closing swipe
        : _swipeDragOffset.clamp(0.0, panelW); // opening swipe

    // Spring target: the snapped value (where the panel should rest).
    // During a drag, overriden=true forces the spring to track position 1:1.
    // After drag ends, overriden=false and the spring animates from the
    // mid-drag position back to the snapped target.
    final panelTarget = _panelVisible ? 0.0 : (isLeft ? -panelW : panelW);

    // The spring's reported position equals the drag-adjusted visual position
    // while dragging, and the snapped target when at rest.
    final panelSpringPosition = panelTarget + effectiveOffset;
    final isDragging = _swipeDragOffset != 0;

    // Scrim opacity: 0 = no scrim, 0.5 = fully visible panel.
    final scrimOpacity = _panelVisible
        ? (1.0 - (effectiveOffset.abs() / panelW)).clamp(0.0, 1.0) * 0.5
        : (effectiveOffset.abs() / panelW).clamp(0.0, 1.0) * 0.5;

    // Edge hit zone — which side to put it on.
    final edgeLeft = isLeft ? 0.0 : null;
    final edgeRight = isLeft ? null : 0.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Body fills entire space.
        Positioned.fill(
          child: Provider.value(
            value: LdMultiPanelChildState(
              left: 0,
              width: _totalWidth,
              onScreen: true,
              isDragging: false,
              dragOffset: 0,
              role: LdPanelRole.body,
            ),
            child: widget.body,
          ),
        ),
        // Scrim / modal barrier.
        // ModalBarrier is used directly (dismissible: true) so it absorbs taps
        // and calls onDismiss — a wrapping GestureDetector would be swallowed
        // by the barrier's own hit-test before reaching onTap.
        if (scrimOpacity > 0)
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: scrimOpacity,
              duration: Duration.zero,
              child: ModalBarrier(
                dismissible: true,
                onDismiss: () => _setVisibility(false),
                color: Colors.black,
              ),
            ),
          ),
        // Panel — overriden=true during a drag so the spring tracks the finger
        // 1:1 with no physics lag. When the finger lifts, overriden goes false
        // and the spring animates from the mid-drag position to panelTarget.
        _buildPanelSpring(
          initialPosition: panelSpringPosition,
          position: panelSpringPosition,
          overriden: isDragging,
          builder: (context, state) {
            final left = isLeft ? state.position : (_totalWidth - panelW + state.position);
            return Positioned(
              left: left,
              top: 0,
              bottom: 0,
              width: panelW,
              child: Provider.value(
                value: LdMultiPanelChildState(
                  left: left,
                  width: panelW,
                  onScreen: _panelVisible,
                  isDragging: isDragging,
                  dragOffset: effectiveOffset,
                  role: LdPanelRole.panel,
                ),
                child: widget.panel,
              ),
            );
          },
        ),
        // 20px edge swipe zone — show panel.
        if (!_panelVisible)
          Positioned(
            left: edgeLeft,
            right: edgeRight,
            top: 0,
            bottom: 0,
            width: 20,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  if (isLeft) {
                    _swipeDragOffset = max(0, _swipeDragOffset + details.delta.dx);
                  } else {
                    _swipeDragOffset = min(0, _swipeDragOffset + details.delta.dx);
                  }
                });
              },
              onHorizontalDragEnd: (details) {
                final threshold = panelW * 0.3;
                if (_swipeDragOffset.abs() > threshold) {
                  _setVisibility(true);
                }
                setState(() {
                  _swipeDragOffset = 0;
                });
              },
            ),
          ),
        // Swipe to close — drag on the panel itself when visible.
        if (_panelVisible)
          Positioned(
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            top: 0,
            bottom: 0,
            width: panelW,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                setState(() {
                  if (isLeft) {
                    _swipeDragOffset = min(0, _swipeDragOffset + details.delta.dx);
                  } else {
                    _swipeDragOffset = max(0, _swipeDragOffset + details.delta.dx);
                  }
                });
              },
              onHorizontalDragEnd: (details) {
                final threshold = panelW * 0.3;
                if (_swipeDragOffset.abs() > threshold) {
                  _setVisibility(false);
                }
                setState(() {
                  _swipeDragOffset = 0;
                });
              },
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        LdTheme.of(context, listen: true);
        if (widget.mode == LdMultiPanelLayoutMode.sideBySide) {
          return _buildSideBySide(constraints);
        } else {
          return _buildStacked(constraints);
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Private resize handle widget
// ---------------------------------------------------------------------------

class _LdPanelResizeHandle extends StatelessWidget {
  final bool isLeft;
  final void Function(double delta) onDragUpdate;
  final VoidCallback onDragEnd;

  const _LdPanelResizeHandle({
    required this.isLeft,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          onDragUpdate(details.delta.dx);
        },
        onHorizontalDragEnd: (_) {
          onDragEnd();
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Child state injected into both panel and body subtrees
// ---------------------------------------------------------------------------

class LdMultiPanelChildState {
  final double left;
  final double width;
  final bool onScreen;
  final bool isDragging;
  final double dragOffset;
  final LdPanelRole role;

  LdMultiPanelChildState({
    required this.left,
    required this.width,
    required this.onScreen,
    required this.isDragging,
    required this.dragOffset,
    this.role = LdPanelRole.body,
  });

  LdMultiPanelChildState copyWith({
    double? left,
    double? width,
    bool? onScreen,
    bool? isDragging,
    double? dragOffset,
    LdPanelRole? role,
  }) {
    return LdMultiPanelChildState(
      left: left ?? this.left,
      width: width ?? this.width,
      onScreen: onScreen ?? this.onScreen,
      isDragging: isDragging ?? this.isDragging,
      dragOffset: dragOffset ?? this.dragOffset,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LdMultiPanelChildState &&
        other.left == left &&
        other.width == width &&
        other.onScreen == onScreen &&
        other.isDragging == isDragging &&
        other.dragOffset == dragOffset &&
        other.role == role;
  }

  @override
  int get hashCode => Object.hash(left, width, onScreen, isDragging, dragOffset, role);

  static LdMultiPanelChildState of(BuildContext context) {
    return context.read<LdMultiPanelChildState>();
  }

  static LdMultiPanelChildState watch(BuildContext context) {
    return context.watch<LdMultiPanelChildState>();
  }
}
