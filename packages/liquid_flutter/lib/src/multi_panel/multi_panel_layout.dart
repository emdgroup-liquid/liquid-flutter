import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMultiPanelLayout extends StatefulWidget {
  final List<Widget> children;
  final List<PanelWidth> widths;
  final LdMultiPanelLayoutMode mode;
  final int visibleStartIndex;
  final int visibleEndIndex;
  final void Function(int startIndex, int endIndex)? onVisibleRangeChanged;
  final bool enableBorders;
  final double mass;
  final double springConstant;
  final double dampingCoefficient;
  final double spacing;
  final bool enableScaling;

  const LdMultiPanelLayout({
    super.key,
    required this.children,
    required this.widths,
    this.mode = LdMultiPanelLayoutMode.sideBySide,
    this.visibleStartIndex = 0,
    this.enableBorders = false,
    this.visibleEndIndex = 1,
    this.onVisibleRangeChanged,
    this.mass = 5,
    this.springConstant = 3,
    this.spacing = 0,
    this.dampingCoefficient = 9,
    this.enableScaling = true,
  })  : assert(
          children.length == widths.length,
          'Children and widths lists must have the same length',
        ),
        assert(
          visibleStartIndex >= 0 && visibleStartIndex < children.length,
          'visibleStartIndex must be valid',
        ),
        assert(
          visibleEndIndex >= visibleStartIndex && visibleEndIndex <= children.length,
          'visibleEndIndex must be greater than visibleStartIndex and <= children.length',
        );

  @override
  State<LdMultiPanelLayout> createState() => _LdMultiPanelLayoutState();
}

class _LdMultiPanelLayoutState extends State<LdMultiPanelLayout> {
  List<double> _positions = [];
  bool _isDragging = false;

  double _dragStartX = 0;
  double _dragOffset = 0;
  double _totalWidth = 0;

  List<double> _widths = [];
  final GlobalKey _layoutKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializePositions();
  }

  void _initializePositions() {
    _positions = List.filled(widget.children.length, 0.0);
    setState(() {});
  }

  @override
  void didUpdateWidget(LdMultiPanelLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length ||
        oldWidget.widths.length != widget.widths.length ||
        oldWidget.visibleStartIndex != widget.visibleStartIndex ||
        oldWidget.visibleEndIndex != widget.visibleEndIndex ||
        oldWidget.spacing != widget.spacing) {
      _initializePositions();
      // Update gesture exclusion rects when visible range changes
    }
  }

  bool _dragFromLeft = false;
  bool _dragFromRight = false;

  bool _nearNr(double position, double value, double threshold) {
    return position > value - threshold && position < value + threshold;
  }

  void _onDragStart(DragStartDetails details) {
    if (widget.onVisibleRangeChanged == null) {
      return;
    }

    final firstPanelRight = _positions[widget.visibleStartIndex] + _widths[widget.visibleStartIndex];
    final firstPanelLeft = _positions[widget.visibleStartIndex];
    final lastPanelLeft = _positions[widget.visibleEndIndex];
    final lastPanelRight = _positions[widget.visibleEndIndex] + _widths[widget.visibleEndIndex];

    // If the drag is not around the first or last panel we simply ignore it.

    const threshold = 50.0;

    final isDraggingNearFirstPanelRight = _nearNr(details.localPosition.dx, firstPanelRight, threshold);
    final isDraggingNearFirstPanelLeft = _nearNr(details.localPosition.dx, firstPanelLeft, threshold);
    final isDraggingNearLastPanelLeft = _nearNr(details.localPosition.dx, lastPanelLeft, threshold);
    final isDraggingNearLastPanelRight = _nearNr(details.localPosition.dx, lastPanelRight, threshold);

    if (!isDraggingNearFirstPanelRight &&
        !isDraggingNearFirstPanelLeft &&
        !isDraggingNearLastPanelLeft &&
        !isDraggingNearLastPanelRight) {
      return;
    }

    _dragFromLeft = isDraggingNearFirstPanelRight || isDraggingNearFirstPanelLeft;
    _dragFromRight = isDraggingNearLastPanelRight || isDraggingNearLastPanelLeft;

    _isDragging = true;
    _dragStartX = details.globalPosition.dx;

    _dragOffset = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    _dragOffset = details.globalPosition.dx - _dragStartX;
    setState(() {});
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    _isDragging = false;

    int newStartIndex = _positions.length;
    int newEndIndex = 0;

    for (var i = 0; i < _positions.length; i++) {
      final width = _widths[i];
      final position = _positions[i];

      if (position > -(width / 2)) {
        newStartIndex = min(newStartIndex, i);
      }

      if ((position + width) <= (_totalWidth + (width / 2))) {
        newEndIndex = max(newEndIndex, i);
      }
    }

    newStartIndex = newStartIndex.clamp(0, widget.children.length - 1);
    newEndIndex = newEndIndex.clamp(newStartIndex, widget.children.length);

    if (newStartIndex != widget.visibleStartIndex || newEndIndex != widget.visibleEndIndex) {
      widget.onVisibleRangeChanged?.call(newStartIndex, newEndIndex);
    }

    _dragOffset = 0;
    setState(() {});
  }

  ({List<double> positions, List<double> widths}) _calculateLayout(
    double availableWidth, {
    required double dragOffset,
  }) {
    // Calculate widths for visible panels (with fill logic
    final theme = LdTheme.of(context);

    final spacing = widget.spacing + (widget.enableBorders ? theme.borderWidth : 0);

    final (widths, remainingWidth) = PanelWidth.calculateSideBySideWidths(
      widths: widget.widths,
      availableWidth: availableWidth,
      visibleStartIndex: widget.visibleStartIndex,
      dragFromLeft: _dragFromLeft,
      visibleEndIndex: widget.visibleEndIndex,
      dragOffset: dragOffset,
      spacing: spacing,
    );

    var positions = List<double>.filled(widget.children.length, 0.0);

    // Calculate base positions
    double currentLeft = -widths.sublist(0, widget.visibleStartIndex).sum - spacing * widget.visibleStartIndex;

    if (currentLeft == 0 && dragOffset > 0 && _dragFromLeft) {
      dragOffset = 0;
    }

    for (var i = 0; i < widget.children.length; i++) {
      positions[i] = currentLeft;

      currentLeft += widths[i];

      currentLeft += spacing;
    }

    if (currentLeft <= availableWidth && dragOffset < 0 && _dragFromRight) {
      dragOffset = 0;
    }
    final hasFlexiblePanels = widget.widths.any((e) => e.isFill);

    if (!_dragFromRight && hasFlexiblePanels) {
      positions = positions.map((e) => e + dragOffset).toList();
    }

    return (positions: positions, widths: widths);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          _totalWidth = availableWidth;

          Widget layoutWidget;
          if (widget.mode == LdMultiPanelLayoutMode.sideBySide) {
            final layout = _calculateLayout(
              availableWidth,
              dragOffset: _isDragging ? _dragOffset : 0,
            );
            _positions = layout.positions;
            _widths = layout.widths;
            layoutWidget = _buildSideBySide(layout.positions, layout.widths, availableWidth);
          } else {
            layoutWidget = _buildStacked(availableWidth);
          }

          return Container(
            key: _layoutKey,
            child: layoutWidget,
          );
        },
      ),
    );
  }

  Widget _buildSideBySide(
    List<double> targetPositions,
    List<double> widths,
    double availableWidth,
  ) {
    final theme = LdTheme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Stack(
      children: [
        for (var i = 0; i < widget.children.length; i++)
          LdSpring(
            key: Key(i.toString()),
            mass: widget.mass,
            springConstant: widget.springConstant,
            dampingCoefficient: widget.dampingCoefficient,
            initialPosition: targetPositions[i],
            position: targetPositions[i],
            onAnimationEnd: (context, state) {},
            builder: (context, state, child) {
              final left = state.position.clamp(-widths[i], availableWidth);
              final right = availableWidth - (targetPositions[i] + widths[i]);

              final rightPadding = max(0.0, mediaQuery.viewPadding.right - right);
              final leftPadding = max(0.0, mediaQuery.viewPadding.left - left);

              return Provider.value(
                value: LdMultiPanelChildState(
                  left: left,
                  width: widths[i],
                  onScreen: true,
                  isDragging: _isDragging,
                  dragOffset: _dragOffset,
                ),
                child: Positioned(
                  left: left,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: theme.border,
                          width: theme.borderWidth,
                        ),
                      ),
                    ),
                    child: MediaQuery(
                        data: mediaQuery.copyWith(
                            viewPadding: mediaQuery.viewPadding.copyWith(
                          left: leftPadding,
                          right: rightPadding,
                        )),
                        child: child!),
                  ),
                ),
              );
            },
            child: LdSpring(
              initialPosition: widths[i],
              position: widths[i],
              mass: widget.mass,
              springConstant: widget.springConstant,
              dampingCoefficient: widget.dampingCoefficient,
              builder: (context, state, child) {
                return SizedBox(
                  width: max(state.position, 0),
                  child: child!,
                );
              },
              child: widget.children[i],
            ),
          ),
      ],
    );
  }

  Widget _buildStacked(
    double availableWidth,
  ) {
    // We need to find the first and last flexible panel.

    int firstFlexiblePanelIndex = -1;
    int lastFlexiblePanelIndex = -1;

    for (var i = 0; i < widget.children.length; i++) {
      if (widget.widths[i].isFill) {
        firstFlexiblePanelIndex = i;
        break;
      }
    }

    for (var i = widget.children.length - 1; i >= 0; i--) {
      if (widget.widths[i].isFill) {
        lastFlexiblePanelIndex = i;
        break;
      }
    }

    double totalFlex = 0;

    var remainingWidth = availableWidth;

    final widths = List<double>.filled(widget.children.length, 0.0);
    final positions = List<double>.filled(widget.children.length, 0.0);
    final scales = List<double>.filled(widget.children.length, 1.0);

    for (var i = 0; i < widget.children.length; i++) {
      final width = widget.widths[i].calculateWidth(availableWidth);
      if (width != null) {
        widths[i] = width;
      }
    }

    for (var i = firstFlexiblePanelIndex; i <= lastFlexiblePanelIndex; i++) {
      if (widget.widths[i].isFill) {
        totalFlex += widget.widths[i].fillFlex;
      } else {
        final width = widget.widths[i].calculateWidth(availableWidth);
        if (width != null) {
          widths[i] = width;
          remainingWidth -= width;
        }
      }
    }

    if (totalFlex > 0) {
      for (var i = firstFlexiblePanelIndex; i <= lastFlexiblePanelIndex; i++) {
        if (widget.widths[i].isFill) {
          widths[i] = remainingWidth * (widget.widths[i].fillFlex / totalFlex);
        }
      }
    }

    double currentLeft = 0;

    if (firstFlexiblePanelIndex > widget.visibleStartIndex) {
      currentLeft += widths.sublist(widget.visibleStartIndex, firstFlexiblePanelIndex).sum;
    }

    if (widget.visibleEndIndex > lastFlexiblePanelIndex) {
      currentLeft -= widths.sublist(lastFlexiblePanelIndex + 1, widget.visibleEndIndex + 1).sum;
    }

    for (var i = 0; i < widget.children.length; i++) {
      if (i < firstFlexiblePanelIndex) {
        if (i >= widget.visibleStartIndex) {
          positions[i] = widths.sublist(widget.visibleStartIndex, i).sum;
        } else {
          positions[i] = -widths[i];
        }
      } else if (i > lastFlexiblePanelIndex) {
        if (i <= widget.visibleEndIndex) {
          positions[i] = availableWidth - widths[i];
        } else {
          positions[i] = availableWidth;
        }
      } else {
        positions[i] = currentLeft;
        currentLeft += widths[i];
        currentLeft += widget.spacing;
      }

      // Calculate scale for the panels

      if (i < firstFlexiblePanelIndex && i >= widget.visibleStartIndex) {
        final distanceToVisible = i - widget.visibleStartIndex;

        scales[i] = 1 - distanceToVisible * 0.2;
      }

      if (i > lastFlexiblePanelIndex && i <= widget.visibleEndIndex) {
        final distanceToVisible = widget.visibleEndIndex - i;

        scales[i] = 1 - distanceToVisible * 0.2;
      }
    }

    if (_isDragging && _dragFromLeft) {
      int affectedPanel = widget.visibleStartIndex;

      if (_dragOffset > 0) {
        affectedPanel--;
      }

      if (affectedPanel >= 0 && affectedPanel != firstFlexiblePanelIndex) {
        positions[affectedPanel] = positions[affectedPanel] + min(widths[affectedPanel], _dragOffset);
      }

      if (affectedPanel == firstFlexiblePanelIndex - 1) {
        // Move the flexible panel back
        for (var i = firstFlexiblePanelIndex; i < widget.children.length; i++) {
          positions[i] += _dragOffset;
        }
      }
    }

    if (_isDragging && _dragFromRight) {
      int affectedPanel = widget.visibleEndIndex;

      if (_dragOffset < 0) {
        affectedPanel++;
      }

      if (affectedPanel < widget.children.length && affectedPanel != lastFlexiblePanelIndex) {
        positions[affectedPanel] = positions[affectedPanel] + max(-widths[affectedPanel], _dragOffset);
      }
    }

    // Calculate center scale.

    final panelsLeft = firstFlexiblePanelIndex - widget.visibleStartIndex;
    final panelsRight = widget.visibleEndIndex - lastFlexiblePanelIndex;

    final effectivePanels = max(panelsLeft, panelsRight);

    final centerScale = 1 - effectivePanels * 0.2;

    for (var i = firstFlexiblePanelIndex; i <= lastFlexiblePanelIndex; i++) {
      scales[i] = centerScale;
    }

    // Calculate back drop opacity.

    double distanceLeft = positions[firstFlexiblePanelIndex];
    double distanceRight = availableWidth - positions[lastFlexiblePanelIndex] - widths[lastFlexiblePanelIndex];

    final maxDistanceLeft = max(1, widths.sublist(0, firstFlexiblePanelIndex).sum);
    final maxDistanceRight = max(1, widths.sublist(lastFlexiblePanelIndex + 1, widget.children.length).sum);

    double backDropOpacity = max(distanceLeft / maxDistanceLeft, distanceRight / maxDistanceRight).clamp(0, 1) * 0.5;

    _positions = positions;
    _widths = widths;

    return Stack(
      fit: StackFit.expand,
      children: [
        Stack(
          fit: StackFit.expand,
          children: [
            for (var i = firstFlexiblePanelIndex; i <= lastFlexiblePanelIndex; i++)
              LdSpring(
                key: Key('flexible_$i'),
                mass: widget.mass,
                springConstant: widget.springConstant,
                dampingCoefficient: widget.dampingCoefficient,
                initialPosition: positions[i],
                position: positions[i],
                onAnimationEnd: (context, state) {},
                builder: (context, leftState, child) {
                  return Positioned(
                    left: leftState.position,
                    top: 0,
                    bottom: 0,
                    child: LdSpring(
                      initialPosition: widths[i],
                      position: widths[i],
                      mass: widget.mass,
                      springConstant: widget.springConstant,
                      dampingCoefficient: widget.dampingCoefficient,
                      builder: (context, widthState, child) {
                        return SizedBox(
                          width: max(widthState.position, 0),
                          child: LdWrapConditional(
                            condition: widget.enableScaling,
                            builder: (context, child) {
                              return LdSpring(
                                initialPosition: scales[i],
                                position: scales[i],
                                mass: widget.mass,
                                springConstant: widget.springConstant,
                                dampingCoefficient: widget.dampingCoefficient,
                                builder: (context, scaleState, child) {
                                  return Transform.scale(
                                    scale: scaleState.position,
                                    child: Provider.value(
                                      value: LdMultiPanelChildState(
                                        left: widths.sublist(firstFlexiblePanelIndex, i).sum,
                                        width: widths[i],
                                        onScreen: true,
                                        isDragging: _isDragging,
                                        dragOffset: _dragOffset,
                                      ),
                                      child: child!,
                                    ),
                                  );
                                },
                                child: child,
                              );
                            },
                            child: Provider.value(
                              value: LdMultiPanelChildState(
                                left: widths.sublist(firstFlexiblePanelIndex, i).sum,
                                width: widths[i],
                                onScreen: true,
                                isDragging: _isDragging,
                                dragOffset: _dragOffset,
                              ),
                              child: child!,
                            ),
                          ),
                        );
                      },
                      child: child,
                    ),
                  );
                },
                child: widget.children[i],
              ),
            if (backDropOpacity > 0.0) ...[
              Positioned.fill(
                child: ModalBarrier(color: Colors.black.withValues(alpha: backDropOpacity)),
              ),
            ],
          ],
        ),
        for (var i = firstFlexiblePanelIndex - 1; i >= 0; i--) ...[
          LdSpring(
            key: Key('left_$i'),
            mass: widget.mass,
            springConstant: widget.springConstant,
            dampingCoefficient: widget.dampingCoefficient,
            initialPosition: positions[i],
            position: positions[i],
            onAnimationEnd: (context, state) {},
            builder: (context, leftState, child) {
              return Positioned(
                left: leftState.position,
                top: 0,
                bottom: 0,
                child: LdSpring(
                  initialPosition: widths[i],
                  position: widths[i],
                  mass: widget.mass,
                  springConstant: widget.springConstant,
                  dampingCoefficient: widget.dampingCoefficient,
                  builder: (context, widthState, child) {
                    return SizedBox(
                      width: max(widthState.position, 0),
                      child: LdWrapConditional(
                        condition: widget.enableScaling,
                        builder: (context, child) {
                          return LdSpring(
                            initialPosition: scales[i],
                            position: scales[i],
                            mass: widget.mass,
                            springConstant: widget.springConstant,
                            dampingCoefficient: widget.dampingCoefficient,
                            builder: (context, scaleState, child) {
                              return Transform.scale(
                                scale: scaleState.position,
                                child: Provider.value(
                                  value: LdMultiPanelChildState(
                                    left: positions[i],
                                    width: widths[i],
                                    onScreen: true,
                                    isDragging: _isDragging,
                                    dragOffset: _dragOffset,
                                  ),
                                  child: child!,
                                ),
                              );
                            },
                            child: child,
                          );
                        },
                        child: Provider.value(
                          value: LdMultiPanelChildState(
                            left: positions[i],
                            width: widths[i],
                            onScreen: true,
                            isDragging: _isDragging,
                            dragOffset: _dragOffset,
                          ),
                          child: child!,
                        ),
                      ),
                    );
                  },
                  child: child,
                ),
              );
            },
            child: widget.children[i],
          ),
        ],
        for (var i = lastFlexiblePanelIndex + 1; i < widget.children.length; i++) ...[
          LdSpring(
            key: Key('right_$i'),
            mass: widget.mass,
            springConstant: widget.springConstant,
            dampingCoefficient: widget.dampingCoefficient,
            initialPosition: positions[i],
            position: positions[i],
            onAnimationEnd: (context, state) {},
            builder: (context, leftState, child) {
              return Positioned(
                left: leftState.position,
                top: 0,
                bottom: 0,
                child: LdSpring(
                  initialPosition: widths[i],
                  position: widths[i],
                  mass: widget.mass,
                  springConstant: widget.springConstant,
                  dampingCoefficient: widget.dampingCoefficient,
                  builder: (context, widthState, child) {
                    return SizedBox(
                      width: max(widthState.position, 0),
                      child: LdWrapConditional(
                        condition: widget.enableScaling,
                        builder: (context, child) {
                          return LdSpring(
                            initialPosition: scales[i],
                            position: scales[i],
                            mass: widget.mass,
                            springConstant: widget.springConstant,
                            dampingCoefficient: widget.dampingCoefficient,
                            builder: (context, scaleState, child) {
                              return Transform.scale(
                                scale: scaleState.position,
                                child: Provider.value(
                                  value: LdMultiPanelChildState(
                                    left: availableWidth - widths[i],
                                    width: widths[i],
                                    onScreen: true,
                                    isDragging: _isDragging,
                                    dragOffset: _dragOffset,
                                  ),
                                  child: child!,
                                ),
                              );
                            },
                            child: child,
                          );
                        },
                        child: Provider.value(
                          value: LdMultiPanelChildState(
                            left: availableWidth - widths[i],
                            width: widths[i],
                            onScreen: true,
                            isDragging: _isDragging,
                            dragOffset: _dragOffset,
                          ),
                          child: child!,
                        ),
                      ),
                    );
                  },
                  child: child,
                ),
              );
            },
            child: widget.children[i],
          ),
        ],
      ],
    );
  }
}

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
