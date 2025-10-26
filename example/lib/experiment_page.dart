import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
/*
enum PaddingType {
  viewPadding,
  padding,
  viewInsets,
  all,
}

class ExperimentPage extends StatefulWidget {
  const ExperimentPage({super.key});

  @override
  State<ExperimentPage> createState() => _ExperimentPageState();
}

class _ExperimentPageState extends State<ExperimentPage> {
  double virtualRadius = 0;

  final StreamController<double> _virtualRadiusStream =
      StreamController<double>.broadcast();

  EdgeInsets viewPadding = EdgeInsets.zero;

  EdgeInsets viewInsets = EdgeInsets.zero;

  void _addViewPadding(EdgeInsets padding) {
    setState(() {
      viewPadding = padding;
    });
  }

  void _addViewInsets(EdgeInsets insets) {
    setState(() {
      viewInsets = insets;
    });
  }

  void _setVirtualRadius(double radius) {
    setState(() {
      virtualRadius = radius;
    });
    _virtualRadiusStream.add(radius);
  }

  Alignment _testAlignment = Alignment.topLeft;
  PaddingType _paddingType = PaddingType.viewPadding;

  void _setTestAlignment(Alignment alignment) {
    setState(() {
      _testAlignment = alignment;
    });
  }

  void _setPaddingType(PaddingType paddingType) {
    setState(() {
      _paddingType = paddingType;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return LdThemeProvider(
      screenRadiusStream: _virtualRadiusStream.stream,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: viewPadding,
          viewPadding: viewPadding,
          viewInsets: viewInsets,
        ),
        child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: LdTheme.of(context).border, width: 1),
              color: LdTheme.of(context).background,
              borderRadius: BorderRadius.circular(virtualRadius),
            ),
            child: OverlayCoordinator(
              child: Stack(
                children: [
                  Positioned(
                    top: viewPadding.top,
                    left: viewPadding.left,
                    right: viewPadding.right,
                    bottom: viewPadding.bottom,
                    child: Container(
                      color: LdTheme.of(context).surface,
                    ),
                  ),
                  Positioned.fill(
                      child: _PositionAwareInset(
                    priority: 2,
                    applyAsMediaQueryPadding: true,
                    child: Builder(builder: (context) {
                      return ListView.builder(
                        padding: MediaQuery.of(context).padding,
                        itemCount: 100,
                        itemBuilder: (context, index) {
                          return LdListItem(
                            title: Text("Item $index"),
                            subtitle: Text("Subtitle $index"),
                            trailing: Text("Trailing $index"),
                          );
                        },
                      );
                    }),
                  )),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    width: viewInsets.left,
                    child: Container(
                      color: LdTheme.of(context).warningColor.withAlpha(10),
                    ),
                  ),
                  // For the right viewInset
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: viewInsets.right,
                    child: Container(
                      color: LdTheme.of(context).warningColor.withAlpha(10),
                    ),
                  ),
                  // For the top viewInset
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: viewInsets.top,
                    child: Container(
                      color: LdTheme.of(context).warningColor.withAlpha(10),
                    ),
                  ),
                  // For the bottom viewInset
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: viewInsets.bottom,
                    child: Container(
                      color: LdTheme.of(context).warningColor.withAlpha(10),
                    ),
                  ),
                  Center(
                    child: LdAutoSpace(children: [
                      LdSwitch(
                        label: "View Padding",
                        children: {
                          EdgeInsets.all(0): Text("0"),
                          EdgeInsets.all(16): Text("16"),
                          EdgeInsets.all(32): Text("32"),
                          MediaQuery.of(context).viewPadding:
                              Text("Media Query"),
                        },
                        value: viewPadding,
                        onChanged: (value) {
                          _addViewPadding(value);
                        },
                      ),
                      LdSwitch(
                        label: "View Insets",
                        children: {
                          EdgeInsets.all(0): Text("0"),
                          EdgeInsets.all(64): Text("64"),
                          EdgeInsets.only(bottom: 250): Text("Keyboard"),
                          MediaQuery.of(context).viewInsets:
                              Text("Media Query"),
                        },
                        value: viewInsets,
                        onChanged: (value) {
                          _addViewInsets(value);
                        },
                      ),
                      LdSwitch<double>(
                        label: "Virtual Radius",
                        children: {
                          0: Text("0"),
                          32: Text("32"),
                          64: Text("64"),
                          theme.screenRadius: Text("Theme"),
                        },
                        value: virtualRadius,
                        onChanged: (value) {
                          _setVirtualRadius(value);
                        },
                      ),
                      LdSwitch<Alignment>(
                        label: "Test Alignment",
                        children: {
                          Alignment.center: Text("Center"),
                          Alignment.topLeft: Text("Top Left"),
                          Alignment.topRight: Text("Top Right"),
                          Alignment.bottomLeft: Text("Bottom Left"),
                          Alignment.bottomRight: Text("Bottom Right"),
                        },
                        value: _testAlignment,
                        onChanged: (value) {
                          _setTestAlignment(value);
                        },
                      ),
                      LdSwitch<PaddingType>(
                        label: "Padding Type",
                        children: {
                          PaddingType.viewPadding: Text("View Padding"),
                          PaddingType.padding: Text("Padding"),
                          PaddingType.viewInsets: Text("View Insets"),
                          PaddingType.all: Text("All"),
                        },
                        value: _paddingType,
                        onChanged: (value) {
                          _setPaddingType(value);
                        },
                      ),
                    ]),
                  ),

                  Align(
                    alignment: _testAlignment,
                    child: _PositionAwareInset(
                      priority: 0,
                      decoration: BoxDecoration(
                        color: LdTheme.of(context).primaryColor.withAlpha(50),
                      ),
                      applyInnerRadius: true,
                      minInnerRadius: LdTheme.of(context).radius(LdSize.m),
                      useMinRadius: true,
                      minOuterPadding: LdTheme.of(context).pad(size: LdSize.m),
                      innerDecoration: BoxDecoration(
                        color: LdTheme.of(context).surface,
                        border: Border.all(
                            color: LdTheme.of(context).border, width: 1),
                      ),
                      paddingType: _paddingType,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  LdButton(
                                    onPressed: () {},
                                    child: Text("Hello"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: _testAlignment,
                    child: _PositionAwareInset(
                      priority: 1,
                      decoration: BoxDecoration(
                        color: LdTheme.of(context).primaryColor.withAlpha(50),
                      ),
                      applyInnerRadius: true,
                      minInnerRadius: LdTheme.of(context).radius(LdSize.m),
                      useMinRadius: true,
                      minOuterPadding: LdTheme.of(context).pad(size: LdSize.m),
                      innerDecoration: BoxDecoration(
                        color: LdTheme.of(context).surface,
                        border: Border.all(
                            color: LdTheme.of(context).border, width: 1),
                      ),
                      paddingType: _paddingType,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: LdInput(
                            hint: "Hello",
                            onChanged: (value) {
                              print(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class _PositionAwareInset extends StatefulWidget {
  const _PositionAwareInset({
    required this.child,
    required this.priority,
    this.paddingType = PaddingType.viewPadding,
    this.decoration,
    this.innerDecoration,
    this.applyInnerRadius = false,
    this.minOuterPadding = EdgeInsets.zero,
    this.minInnerRadius = BorderRadius.zero,
    this.useMinRadius = true,
    this.applyAsMediaQueryPadding = false,
  });

  final int priority;
  final bool applyAsMediaQueryPadding;
  final Widget child;
  final BoxDecoration? decoration;
  final PaddingType paddingType;
  final BoxDecoration? innerDecoration;
  final bool applyInnerRadius;
  final bool useMinRadius;
  final EdgeInsets? minOuterPadding;
  final BorderRadius? minInnerRadius;

  @override
  State<_PositionAwareInset> createState() => _PositionAwareInsetState();
}

class _PositionAwareInsetState extends State<_PositionAwareInset> {
  EdgeInsets padding = EdgeInsets.zero;

  final GlobalKey _containerKey = GlobalKey();
  final GlobalKey _childKey = GlobalKey();

  BorderRadius _borderRadius = BorderRadius.zero;

  Rect _lastGlobalPosition = Rect.zero;
  Rect _lastChildGlobalPosition = Rect.zero;
  EdgeInsets _lastSourcePadding = EdgeInsets.zero;

  bool _dirty = false;

  StreamSubscription<Iterable<OverlayItem>>? _overlayItemSubscription;

  Iterable<OverlayItem> _otherItems = [];

  @override
  void initState() {
    super.initState();
    _overlayItemSubscription = OverlayCoordinatorState.maybeOf(context)
        ?.streamHigherPriorityItems(widget.priority)
        .listen((items) {
      _otherItems = items;
      _dirty = true;
      _updatePadding();
      print("otherItems: ${_otherItems.length}");
    });
  }

  void _updateCoordinatorEntry() {
    print("updating coordinator entry: ${widget.priority}");
    OverlayCoordinatorState.maybeOf(context)?.updateOverlayItem(
      _containerKey,
      OverlayItem(
          priority: widget.priority,
          outerRect: _lastGlobalPosition,
          innerRect: _lastChildGlobalPosition),
    );
  }

  /// Calculates padding needed to avoid overlapping with other overlay items
  EdgeInsets _calculateOverlapPadding({
    required Rect currentRect,
    required Iterable<OverlayItem> otherItems,
    required Size screenSize,
  }) {
    double topPadding = 0;
    double leftPadding = 0;
    double rightPadding = 0;
    double bottomPadding = 0;

    for (final otherItem in otherItems) {
      final otherOuterRect = otherItem.outerRect;

      // Check if the current rect overlaps with the other rect
      if (currentRect.overlaps(otherOuterRect)) {
        // Calculate the overlap
        print("overlap found");

        final cornerDistances =
            currentRect.cornerDistances(MediaQuery.of(context).screenRect);

        final smallestAlignment = cornerDistances._smallestAlignment;

        print("smallestAlignment: $smallestAlignment");

        switch (smallestAlignment) {
          case Alignment.topLeft:
            topPadding = max(topPadding, otherOuterRect.bottomLeft.dy);

            break;
          case Alignment.topRight:
            topPadding = max(topPadding, otherOuterRect.bottomRight.dy);

            break;
          case Alignment.bottomLeft:
            bottomPadding = max(
              bottomPadding,
              screenSize.height - otherOuterRect.topLeft.dy,
            );

            break;
          case Alignment.bottomRight:
            bottomPadding = max(
              bottomPadding,
              screenSize.height - otherOuterRect.topRight.dy,
            );

            break;
          default:
            break;
        }
      }
    }

    return EdgeInsets.only(
      top: topPadding,
      left: leftPadding,
      right: rightPadding,
      bottom: bottomPadding,
    );
  }

  void _updatePadding() {
    // Get the global position using the key
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;

    final childRenderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;

    final childGlobalPosition = childRenderBox?.rect;

    final globalPosition = renderBox?.rect;

    // Check if either global position or source padding has changed
    final positionChanged = globalPosition != _lastGlobalPosition;
    final childPositionChanged =
        childGlobalPosition != _lastChildGlobalPosition;

    if (childPositionChanged || positionChanged) {
      _dirty = true;
    }

    if (!_dirty || globalPosition == null || childGlobalPosition == null) {
      return;
    }

    _dirty = false;

    _lastGlobalPosition = globalPosition;
    _lastChildGlobalPosition = childGlobalPosition;

    renderBox!;
    // Get the appropriate padding based on the selected type
    EdgeInsets currentSourcePadding;
    switch (widget.paddingType) {
      case PaddingType.viewPadding:
        currentSourcePadding = MediaQuery.of(context).viewPadding;
        break;
      case PaddingType.padding:
        currentSourcePadding = MediaQuery.of(context).padding;
        break;
      case PaddingType.viewInsets:
        currentSourcePadding = MediaQuery.of(context).viewInsets;
        break;
      case PaddingType.all:
        currentSourcePadding = EdgeInsets.only(
          top: max3(
              MediaQuery.of(context).padding.top,
              MediaQuery.of(context).viewPadding.top,
              MediaQuery.of(context).viewInsets.top),
          left: max3(
              MediaQuery.of(context).padding.left,
              MediaQuery.of(context).viewPadding.left,
              MediaQuery.of(context).viewInsets.left),
          right: max3(
              MediaQuery.of(context).padding.right,
              MediaQuery.of(context).viewPadding.right,
              MediaQuery.of(context).viewInsets.right),
          bottom: max3(
              MediaQuery.of(context).padding.bottom,
              MediaQuery.of(context).viewPadding.bottom,
              MediaQuery.of(context).viewInsets.bottom),
        );
        break;
    }

    _lastGlobalPosition = globalPosition;
    _lastSourcePadding = currentSourcePadding;

    setState(() {
      final screenSize = MediaQuery.of(context).size;
      final renderBoxSize = renderBox.size;

      final otherItems = _otherItems;

      final outerPosition = renderBox.localToGlobal(Offset(0, 0));

      // Calculate base padding from source padding
      EdgeInsets basePadding = EdgeInsets.only(
        top: max(currentSourcePadding.top - outerPosition.dy, 0),
        left: max(currentSourcePadding.left - outerPosition.dx, 0),
        right: max(
          currentSourcePadding.right -
              (screenSize.width - outerPosition.dx - renderBoxSize.width),
          0,
        ),
        bottom: max(
          currentSourcePadding.bottom -
              (screenSize.height - outerPosition.dy - renderBoxSize.height),
          0,
        ),
      );

      // Calculate additional padding to avoid overlapping with other items
      EdgeInsets overlapPadding = _calculateOverlapPadding(
        currentRect: globalPosition,
        otherItems: otherItems,
        screenSize: screenSize,
      ).round();

      print("overlapPadding: ${overlapPadding.toStringR()}");

      // Combine base padding with overlap padding
      padding = EdgeInsets.only(
        top: max(basePadding.top, overlapPadding.top),
        left: max(basePadding.left, overlapPadding.left),
        right: max(basePadding.right, overlapPadding.right),
        bottom: max(basePadding.bottom, overlapPadding.bottom),
      );

      if (widget.minOuterPadding != null) {
        padding = padding.atLeast(widget.minOuterPadding!);
      }
    });

    if (childRenderBox != null) {
      final screenRadius = LdTheme.of(context).screenRadius;

      final screenRect = MediaQuery.of(context).screenRect;

      final cornerDistances = screenRect.cornerDistances(childRenderBox.rect);

      setState(() {
        if (widget.useMinRadius) {
          final minDistance = cornerDistances.minDistance();

          _borderRadius = BorderRadius.circular(
            screenRadius - minDistance / 2,
          );
        } else {
          _borderRadius = cornerDistances.insetRadius(screenRadius);
        }
      });
    }

    _updateCoordinatorEntry();
  }

  @override
  void didUpdateWidget(_PositionAwareInset oldWidget) {
    super.didUpdateWidget(oldWidget);
    _dirty = true;
  }

  /// Calculates the radus for a specific corner based on the distance to that corner
  /// The radius should increase as we get closer to the corner (concentric effect)

  @override
  Widget build(BuildContext context) {
    MediaQuery.paddingOf(context);
    MediaQuery.viewPaddingOf(context);
    MediaQuery.viewInsetsOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePadding();
    });

    if (widget.applyAsMediaQueryPadding) {
      return MediaQuery(
        key: _containerKey,
        data: MediaQuery.of(context).copyWith(padding: padding),
        child: KeyedSubtree(key: _childKey, child: widget.child),
      );
    }

    return Container(
      key: _containerKey,
      decoration: (widget.decoration ?? BoxDecoration()).copyWith(),
      padding: padding,
      child: Container(
        key: _childKey,
        decoration: (widget.innerDecoration ?? BoxDecoration()).copyWith(
          borderRadius: widget.applyInnerRadius
              ? _borderRadius
                  .atLeast(widget.minInnerRadius ?? BorderRadius.zero)
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}

extension GetRect on RenderBox {
  Rect get rect {
    return Rect.fromLTWH(
      localToGlobal(Offset.zero).dx,
      localToGlobal(Offset.zero).dy,
      size.width,
      size.height,
    );
  }
}

extension ScreenRect on MediaQueryData {
  Rect get screenRect {
    return Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );
  }
}

extension on EdgeInsets {
  String toStringR() {
    return 'EdgeInsets(top: $top, left: $left, right: $right, bottom: $bottom)';
  }
}

extension on Offset {
  double distanceTo(Offset other) {
    return (this - other).distance;
  }
}

double max3(double a, double b, double c) {
  return max(max(a, b), c);
}

extension CornerDistance on Rect {
  CornerDistances cornerDistances(Rect other) {
    return CornerDistances(
      topLeft: topLeft.distanceTo(other.topLeft),
      topRight: topRight.distanceTo(other.topRight),
      bottomLeft: bottomLeft.distanceTo(other.bottomLeft),
      bottomRight: bottomRight.distanceTo(other.bottomRight),
    );
  }
}

class CornerDistances {
  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  CornerDistances({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
  });

  double maxDistance() {
    return max(max(topLeft, topRight), max(bottomLeft, bottomRight));
  }

  double minDistance() {
    return min(min(topLeft, topRight), min(bottomLeft, bottomRight));
  }

  Alignment get _smallestAlignment {
    final sidesToAlignment = {
      topLeft: Alignment.topLeft,
      topRight: Alignment.topRight,
      bottomLeft: Alignment.bottomLeft,
      bottomRight: Alignment.bottomRight,
    };

    return sidesToAlignment.smallestKey();
  }

  BorderRadius insetRadius(double screenRadius) {
    return BorderRadius.only(
      topLeft: Radius.circular(screenRadius - topLeft / 2),
      topRight: Radius.circular(screenRadius - topRight / 2),
      bottomLeft: Radius.circular(screenRadius - bottomLeft / 2),
      bottomRight: Radius.circular(screenRadius - bottomRight / 2),
    );
  }
}

class OverlayCoordinator extends StatefulWidget {
  const OverlayCoordinator({super.key, required this.child});

  final Widget child;

  @override
  State<OverlayCoordinator> createState() => OverlayCoordinatorState();
}

class OverlayItem {
  final int priority;
  final Rect outerRect;
  final Rect innerRect;

  OverlayItem({
    required this.priority,
    required this.outerRect,
    required this.innerRect,
  });

  @override
  bool operator ==(Object other) {
    if (other is OverlayItem) {
      return priority == other.priority &&
          outerRect == other.outerRect &&
          innerRect == other.innerRect;
    }
    return false;
  }

  @override
  int get hashCode =>
      priority.hashCode ^ outerRect.hashCode ^ innerRect.hashCode;
}

class OverlayCoordinatorState extends State<OverlayCoordinator> {
  final Map<GlobalKey, OverlayItem> _overlayItems = {};

  Stream<Iterable<OverlayItem>> streamHigherPriorityItems(int priority) {
    return _overlayItemStreamController.stream
        .where((updatedItem) => updatedItem.priority < priority)
        .map(
          (updatedItem) =>
              _overlayItems.values.where((item) => item.priority < priority),
        );
  }

  final StreamController<OverlayItem> _overlayItemStreamController =
      StreamController<OverlayItem>.broadcast();

  void updateOverlayItem(GlobalKey key, OverlayItem overlayItem) {
    if (overlayItem == _overlayItems[key]) {
      print("overlayItem already exists and is up to date");
      return;
    }
    setState(() {
      _overlayItems[key] = overlayItem;
    });
    print("updatedItem: ${overlayItem.priority}");
    _overlayItemStreamController.add(overlayItem);
  }

  void removeOverlayItem(GlobalKey key) {
    setState(() {
      _overlayItems.remove(key);
    });
  }

  static OverlayCoordinatorState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<OverlayCoordinatorState>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

extension on Map<num, Alignment> {
  Alignment smallestKey() {
    num smallestKey = keys.first;
    for (final key in keys) {
      if (key < smallestKey) {
        smallestKey = key;
      }
    }
    return this[smallestKey]!;
  }
}

extension Round on EdgeInsets {
  EdgeInsets round() {
    return EdgeInsets.only(
      top: top.roundToDouble(),
      left: left.roundToDouble(),
      right: right.roundToDouble(),
      bottom: bottom.roundToDouble(),
    );
  }
}
*/
