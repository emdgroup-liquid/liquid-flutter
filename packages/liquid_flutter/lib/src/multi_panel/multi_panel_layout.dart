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

  /// One-time seed for panel width in pixels. Mutually exclusive with [initialPanelFraction].
  final double? initialPanelWidth;

  /// One-time seed for panel width as a fraction of total width. Mutually exclusive
  /// with [initialPanelWidth].
  final double? initialPanelFraction;

  /// Minimum panel width when resizing.
  final double minPanelWidth;

  /// One-time seed for panel visibility. Null means the internal default (false).
  final bool? initialPanelVisible;

  /// Reactive visibility override. When non-null, controls visibility externally.
  final bool? panelVisible;

  /// Called when the panel's visibility changes.
  final void Function(bool visible)? onPanelVisibilityChanged;

  /// Controlled panel width. When non-null, this value is used directly (no spring for width).
  final double? panelWidth;

  /// Called when the panel width changes during a resize drag.
  final void Function(double width)? onPanelWidthChanged;

  /// Spring mass.
  final double mass;

  /// Spring constant.
  final double springConstant;

  /// Spring damping coefficient.
  final double dampingCoefficient;

  /// Whether to enable scaling effect in stacked mode.
  final bool enableScaling;

  const LdMultiPanelLayout({
    super.key,
    this.mode = LdMultiPanelLayoutMode.sideBySide,
    required this.body,
    required this.panel,
    this.panelPosition = LdPanelPosition.left,
    this.allowResize = false,
    this.initialPanelWidth,
    this.initialPanelFraction,
    this.minPanelWidth = 80,
    this.initialPanelVisible,
    this.panelVisible,
    this.onPanelVisibilityChanged,
    this.panelWidth,
    this.onPanelWidthChanged,
    this.mass = 5,
    this.springConstant = 3,
    this.dampingCoefficient = 9,
    this.enableScaling = true,
  }) : assert(
          initialPanelWidth == null || initialPanelFraction == null,
          'initialPanelWidth and initialPanelFraction are mutually exclusive',
        );

  @override
  State<LdMultiPanelLayout> createState() => _LdMultiPanelLayoutState();
}

class _LdMultiPanelLayoutState extends State<LdMultiPanelLayout> {
  /// Current panel width in uncontrolled mode.
  late double _internalPanelWidth;

  /// Current visibility state (internal).
  late bool _panelVisible;

  /// Whether a resize gesture is active.
  bool _isResizing = false;

  /// Swipe drag offset in stacked mode (for show/hide gesture).
  double _swipeDragOffset = 0;

  /// Total layout width from the most recent LayoutBuilder frame.
  double _totalWidth = 0;

  /// Guard to defer fraction-based width calculation to first layout frame.
  bool _fractionApplied = false;

  @override
  void initState() {
    super.initState();
    // panelVisible (controlled prop) takes priority as the initial seed so that
    // callers who set it in their own initState (e.g. LdDrawerLayout opening on
    // desktop) don't get ignored. Falls back to initialPanelVisible, then false.
    _panelVisible = widget.panelVisible ?? widget.initialPanelVisible ?? false;
    _internalPanelWidth = widget.initialPanelWidth ?? 300;
    // If fraction is specified we can't resolve it yet — deferred to first build.
  }

  @override
  void didUpdateWidget(LdMultiPanelLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Sync visibility from controlled prop.
    if (widget.panelVisible != null && widget.panelVisible != oldWidget.panelVisible) {
      setState(() {
        _panelVisible = widget.panelVisible!;
      });
    }

    // Sync width from controlled prop.
    if (widget.panelWidth != null && widget.panelWidth != oldWidget.panelWidth) {
      setState(() {
        _internalPanelWidth = widget.panelWidth!;
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

  void _setVisibility(bool visible) {
    if (_panelVisible == visible) return;
    setState(() {
      _panelVisible = visible;
    });
    widget.onPanelVisibilityChanged?.call(visible);
  }

  // ---------------------------------------------------------------------------
  // Side-by-side layout
  // ---------------------------------------------------------------------------

  Widget _buildSideBySide(BoxConstraints constraints) {
    _totalWidth = constraints.maxWidth;
    final panelW = _effectivePanelWidth(_totalWidth).clamp(
      widget.minPanelWidth,
      _totalWidth - widget.minPanelWidth,
    );
    final isLeft = widget.panelPosition == LdPanelPosition.left;

    // Panel slides off the left/right edge when hidden.
    // Translation target: 0 when visible, ±panelW when hidden.
    final panelTranslation = _panelVisible ? 0.0 : (isLeft ? -panelW : panelW);

    // Body left/right offset when panel is visible.
    final bodyLeftWhenVisible = isLeft ? panelW : 0.0;
    final bodyRightWhenVisible = isLeft ? 0.0 : panelW;
    final bodyLeft = _panelVisible ? bodyLeftWhenVisible : 0.0;
    final bodyRight = _panelVisible ? bodyRightWhenVisible : 0.0;

    // Resize handle position (boundary between panel and body).
    final double resizeHandleLeft = isLeft
        ? (_panelVisible ? panelW - 4 : -4)
        : (_panelVisible ? _totalWidth - panelW - 4 : _totalWidth - 4);

    // During a resize drag, bypass spring animations so the panel tracks
    // the pointer 1:1 with no lag or overshoot.
    Widget buildBody({required double left, required double right}) {
      return Positioned(
        left: left,
        right: right,
        top: 0,
        bottom: 0,
        child: Provider.value(
          value: LdMultiPanelChildState(
            left: left,
            width: _totalWidth - left - right,
            onScreen: true,
            isDragging: _isResizing,
            dragOffset: 0,
            role: LdPanelRole.body,
          ),
          child: widget.body,
        ),
      );
    }

    Widget buildPanel({required double panelLeft}) {
      return Positioned(
        left: panelLeft,
        top: 0,
        bottom: 0,
        width: panelW,
        child: Provider.value(
          value: LdMultiPanelChildState(
            left: panelLeft,
            width: panelW,
            onScreen: _panelVisible,
            isDragging: _isResizing,
            dragOffset: 0,
            role: LdPanelRole.panel,
          ),
          child: widget.panel,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Body
        if (_isResizing)
          buildBody(left: bodyLeft, right: bodyRight)
        else
          LdSpring(
            key: const Key('body_left'),
            mass: widget.mass,
            springConstant: widget.springConstant,
            dampingCoefficient: widget.dampingCoefficient,
            initialPosition: bodyLeft,
            position: bodyLeft,
            builder: (context, leftState, child) {
              return LdSpring(
                key: const Key('body_right'),
                mass: widget.mass,
                springConstant: widget.springConstant,
                dampingCoefficient: widget.dampingCoefficient,
                initialPosition: bodyRight,
                position: bodyRight,
                builder: (context, rightState, child) {
                  return buildBody(
                    left: leftState.position,
                    right: rightState.position,
                  );
                },
                child: widget.body,
              );
            },
            child: widget.body,
          ),
        // Panel
        if (_isResizing)
          buildPanel(
            panelLeft: isLeft ? 0.0 : (_totalWidth - panelW),
          )
        else
          LdSpring(
            key: const Key('panel_translation'),
            mass: widget.mass,
            springConstant: widget.springConstant,
            dampingCoefficient: widget.dampingCoefficient,
            initialPosition: panelTranslation,
            position: panelTranslation,
            builder: (context, transState, child) {
              // For left panel: transState.position slides from 0 (visible) to -panelW (hidden).
              // For right panel: transState.position slides from 0 (visible) to +panelW (hidden).
              final double panelActualLeft = isLeft
                  ? transState.position
                  : (_totalWidth - panelW + transState.position);
              return buildPanel(panelLeft: panelActualLeft);
            },
            child: widget.panel,
          ),
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
                if (widget.panelWidth != null) {
                  // Controlled mode: only fire callback
                  final newWidth = (widget.panelWidth! + (isLeft ? delta : -delta)).clamp(
                    widget.minPanelWidth,
                    _totalWidth - widget.minPanelWidth,
                  );
                  widget.onPanelWidthChanged?.call(newWidth);
                } else {
                  setState(() {
                    _isResizing = true;
                    _internalPanelWidth = (_internalPanelWidth + (isLeft ? delta : -delta)).clamp(
                      widget.minPanelWidth,
                      _totalWidth - widget.minPanelWidth,
                    );
                  });
                  widget.onPanelWidthChanged?.call(_internalPanelWidth);
                }
              },
              onDragEnd: () {
                setState(() {
                  _isResizing = false;
                });
              },
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Stacked layout
  // ---------------------------------------------------------------------------

  Widget _buildStacked(BoxConstraints constraints) {
    _totalWidth = constraints.maxWidth;
    final isLeft = widget.panelPosition == LdPanelPosition.left;
    final panelW = _effectivePanelWidth(_totalWidth).clamp(
      widget.minPanelWidth,
      _totalWidth,
    );

    // Clamp swipe offset so panel cannot go further than its width.
    final effectiveOffset = _panelVisible
        ? _swipeDragOffset.clamp(-panelW, 0.0) // closing swipe
        : _swipeDragOffset.clamp(0.0, panelW); // opening swipe

    // Panel target translation: 0 = fully visible, ±panelW = fully off-screen.
    final panelTarget = _panelVisible ? effectiveOffset : (isLeft ? -panelW + effectiveOffset : panelW + effectiveOffset);

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
        // Panel.
        LdSpring(
          key: const Key('stacked_panel'),
          mass: widget.mass,
          springConstant: widget.springConstant,
          dampingCoefficient: widget.dampingCoefficient,
          initialPosition: panelTarget,
          position: panelTarget,
          builder: (context, state, child) {
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
                  isDragging: _swipeDragOffset != 0,
                  dragOffset: _swipeDragOffset,
                  role: LdPanelRole.panel,
                ),
                child: child!,
              ),
            );
          },
          child: widget.panel,
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
