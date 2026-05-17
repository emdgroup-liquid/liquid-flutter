import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

/// Parent data for use with [RenderOverflowView].
class LdOverflowViewParentData extends ContainerBoxParentData<RenderBox> {
  bool? offstage;
  int? consumeRemainder;
}

class LdRenderOverflowView extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, LdOverflowViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, LdOverflowViewParentData> {
  MainAxisAlignment _mainAxisAlignment;
  CrossAxisAlignment _crossAxisAlignment;
  Axis _direction;
  double _spacing;

  bool _isHorizontal;

  bool _hasOverflow = false;

  // Cache for overflow indicator size calculations
  Map<int, double>? _cachedIndicatorSizes;
  int? _lastIndicatorOverflowCount;
  BoxConstraints? _lastIndicatorConstraints;
  LdRenderOverflowView({
    List<RenderBox>? children,
    required Axis direction,
    required double spacing,
    required MainAxisAlignment mainAxisAlignment,
    required CrossAxisAlignment crossAxisAlignment,
  })  : assert(
          mainAxisAlignment != MainAxisAlignment.spaceBetween &&
              mainAxisAlignment != MainAxisAlignment.spaceAround &&
              mainAxisAlignment != MainAxisAlignment.spaceEvenly,
          "mainAxisAlignment must not be spaceBetween, spaceAround or spaceEvenly (current not supported)",
        ),
        assert(
          crossAxisAlignment != CrossAxisAlignment.baseline && crossAxisAlignment != CrossAxisAlignment.stretch,
          "crossAxisAlignment must not be baseline or stretch (current not supported)",
        ),
        _direction = direction,
        _spacing = spacing,
        _mainAxisAlignment = mainAxisAlignment,
        _crossAxisAlignment = crossAxisAlignment,
        _isHorizontal = direction == Axis.horizontal {
    addAll(children);
  }
  CrossAxisAlignment get crossAxisAlignment => _crossAxisAlignment;

  set crossAxisAlignment(CrossAxisAlignment value) {
    if (_crossAxisAlignment != value) {
      _crossAxisAlignment = value;
      markNeedsLayout();
    }
  }

  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      _isHorizontal = direction == Axis.horizontal;
      markNeedsLayout();
    }
  }

  MainAxisAlignment get mainAxisAlignment => _mainAxisAlignment;
  set mainAxisAlignment(MainAxisAlignment value) {
    if (_mainAxisAlignment != value) {
      _mainAxisAlignment = value;
      markNeedsLayout();
    }
  }

  double get maxCrossExtent => _isHorizontal ? constraints.maxHeight : constraints.maxWidth;
  double get maxMainExtent => _isHorizontal ? constraints.maxWidth : constraints.maxHeight;

  double get spacing => _spacing;

  set spacing(double value) {
    assert(value > double.negativeInfinity && value < double.infinity);
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  /// The available extent is the maximum extent in the main axis.
  double get _availableExtent {
    if (_isHorizontal) {
      return constraints.maxWidth;
    } else {
      return constraints.maxHeight;
    }
  }

  List<RenderBox> get _children {
    final List<RenderBox> children = <RenderBox>[];
    var child = firstChild!;
    while (child != lastChild) {
      children.add(child);
      child = (child.parentData as LdOverflowViewParentData).nextSibling!;
    }
    return children;
  }

  double getCrossSize(Size size) {
    return _isHorizontal ? size.height : size.width;
  }

  double getMainSize(Size size) {
    return _isHorizontal ? size.width : size.height;
  }

  /// Checks if constraints have changed significantly (more than 1 pixel difference)
  bool _constraintsChangedSignificantly(BoxConstraints newConstraints) {
    if (_lastIndicatorConstraints == null) {
      return true;
    }

    const epsilon = 1.0;
    return (newConstraints.maxWidth - _lastIndicatorConstraints!.maxWidth).abs() > epsilon ||
        (newConstraints.maxHeight - _lastIndicatorConstraints!.maxHeight).abs() > epsilon ||
        (newConstraints.minWidth - _lastIndicatorConstraints!.minWidth).abs() > epsilon ||
        (newConstraints.minHeight - _lastIndicatorConstraints!.minHeight).abs() > epsilon;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    visitOnlyOnStageChildren((renderObject) {
      final RenderBox child = renderObject as RenderBox;
      final LdOverflowViewParentData childParentData = child.parentData as LdOverflowViewParentData;
      result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
    });

    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    void paintChild(RenderObject child) {
      final LdOverflowViewParentData childParentData = child.parentData as LdOverflowViewParentData;
      if (childParentData.offstage == false) {
        context.paintChild(child, childParentData.offset + offset);
      } else {
        // We paint it outside the box.
        context.paintChild(child, size.bottomRight(Offset.zero));
      }
    }

    void defaultPaint(PaintingContext context, Offset offset) {
      visitOnlyOnStageChildren(paintChild);
    }

    if (_hasOverflow) {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
        clipBehavior: Clip.hardEdge,
      );
    } else {
      defaultPaint(context, offset);
    }
  }

  @override
  void performLayout() {
    _hasOverflow = false;
    assert(firstChild != null);
    resetOffstage();

    // Invalidate indicator cache if constraints changed significantly
    // (intrinsic sizes cache is handled in _getChildrenIntrinsicSizes)
    if (_constraintsChangedSignificantly(constraints)) {
      _cachedIndicatorSizes = null;
      _lastIndicatorOverflowCount = null;
      _lastIndicatorConstraints = null;
    }

    _performFlexibleLayout();
  }

  void resetOffstage() {
    visitChildren((child) {
      final LdOverflowViewParentData childParentData = child.parentData as LdOverflowViewParentData;
      childParentData.offstage = null;
    });
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! LdOverflowViewParentData) {
      child.parentData = LdOverflowViewParentData();
    }
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitOnlyOnStageChildren(visitor);
  }

  void visitOnlyOnStageChildren(RenderObjectVisitor visitor) {
    visitChildren((child) {
      if (child.isOnstage) {
        visitor(child);
      }
    });
  }

  BoxConstraints _childConstraints(double overflowIndicatorSize) {
    // We only allow the  child to grow up to main extent minus
    // the overflow indicator size.

    final reservedExtent = maxMainExtent - overflowIndicatorSize - spacing;

    //final double reservedExtent = double.infinity;

    if (!_isHorizontal) {
      return BoxConstraints.loose(
        Size(maxCrossExtent, math.max(0, reservedExtent)),
      );
    } else {
      return BoxConstraints.loose(
        Size(math.max(0, reservedExtent), maxCrossExtent),
      );
    }
  }

  Iterable<double> _getChildrenMinMainSizes(List<RenderBox> children) {
    // Calculate intrinsic sizes directly without caching
    // Check if the child is a FlexibleChild

    return children.map((child) {
      final parentData = child.parentData as LdOverflowViewParentData;
      if (parentData.consumeRemainder != null && parentData.consumeRemainder! > 0) {
        return 0;
      }
      final mainSize = _isHorizontal
          ? child.getMinIntrinsicWidth(constraints.maxHeight)
          : child.getMinIntrinsicHeight(constraints.maxWidth);
      return mainSize;
    });
  }

  double _getCrossSizeOfRenderBox(RenderBox child) {
    return getCrossSize(child.size);
  }

  double _getIndicatorSize(RenderBox overflowIndicator) {
    final parentData = overflowIndicator.parentData as LdOverflowViewParentData;
    parentData.offstage = false;
    return _getMainSizeOfRenderBox(overflowIndicator);
  }

  double _getMainSizeOfRenderBox(RenderBox child) {
    return getMainSize(child.size);
  }

  /// Since the overflow indicator might change size depending on
  /// [overflowCount], we need to layout to determine its size.
  RenderBox _layoutOverflowIndicator(int overflowCount) {
    final overflowIndicator = lastChild!;

    // Initialize indicator cache if needed
    _cachedIndicatorSizes ??= <int, double>{};

    final indicatorConstraints = _childConstraints(0);
    final overflowIndicatorConstraints = BoxValueConstraints<int>(
      value: overflowCount,
      constraints: indicatorConstraints,
    );

    // Check if we can skip layout: same overflow count and constraints haven't changed
    final canSkipLayout = _lastIndicatorOverflowCount == overflowCount &&
        _lastIndicatorConstraints != null &&
        !_constraintsChangedSignificantly(_lastIndicatorConstraints!);

    if (canSkipLayout && _cachedIndicatorSizes!.containsKey(overflowCount)) {
      // We've already laid out with this overflow count and constraints,
      // and we have a cached size, so we can skip the layout
      return overflowIndicator;
    }

    // Perform layout
    overflowIndicator.layout(
      overflowIndicatorConstraints,
      parentUsesSize: true,
    );

    // Cache the main size for this overflow count
    final indicatorSize = _getMainSizeOfRenderBox(overflowIndicator);
    _cachedIndicatorSizes![overflowCount] = indicatorSize;
    _lastIndicatorOverflowCount = overflowCount;
    _lastIndicatorConstraints = indicatorConstraints;

    return overflowIndicator;
  }

  void _performFlexibleLayout() {
    if (firstChild == null) {
      return;
    }

    double availableExtent = _availableExtent;

    bool showOverflowIndicator = false;

    // |_______| availableExtent
    // □ □ □ □ □ □
    //           ^overflowing child
    // <-------> fitting children (count)

    // Calculate overflow indicator size once for flexible layout
    final overflowIndicator = _layoutOverflowIndicator(0);

    // First we retrieve the size of all the children. We pass null as
    //the overflow indicator size, this causes the children to be laid
    //out with no restriction in the main axis.
    final childrenSizes = _getChildrenMinMainSizes(_children);

    // Keep track of the total size of the children that are already on stage
    double filledExtent = 0;

    int fittingChildren = 0;

    for (final childSize in childrenSizes) {
      final newExtent = filledExtent + childSize + _spacingExtent(fittingChildren + 1);

      // Check if the filled space is less than the available extent.
      if (newExtent <= availableExtent) {
        filledExtent += childSize;
        fittingChildren++;
      } else {
        showOverflowIndicator = true;
        break;
      }
    }

    final renderedChildren = _children.sublist(0, fittingChildren);

    int overflowCount = childCount - fittingChildren - 1;

    if (showOverflowIndicator) {
      // We need to place the overflow indicator.
      // We start by determining its size, by passing the value of already
      // overflowing children.
      final overflowIndicator = _layoutOverflowIndicator(overflowCount);
      final indicatorSize = _getIndicatorSize(overflowIndicator);

      filledExtent += indicatorSize;

      // Remove children until we can fit the overflow indicator fits.
      while (filledExtent + _spacingExtent(fittingChildren + 1) > availableExtent && fittingChildren > 1) {
        final RenderBox lastChild = renderedChildren.last;
        final parentData = lastChild.parentData as LdOverflowViewParentData;
        parentData.offstage = true;

        renderedChildren.removeLast();
        fittingChildren--;
        overflowCount++;

        filledExtent -= (childrenSizes.elementAt(fittingChildren));
      }

      // Layout the overflow indicator again to pass the correct count to the overflow indicator.

      _layoutOverflowIndicator(overflowCount);

      renderedChildren.add(overflowIndicator);

      // Now that we know the final count of fitting children we
      // layout again to pass the correct count to the overflow indicator.
    } else {
      final overflowIndicatorParentData = overflowIndicator.parentData as LdOverflowViewParentData;
      overflowIndicatorParentData.offstage = true;
    }
    final indicatorCrossSize = getCrossSize(overflowIndicator.size);

    // Calculate the actual total space used by children including spacing
    double totalUsedSpace = filledExtent + _spacingExtent(renderedChildren.length);
    double remainder = availableExtent - totalUsedSpace;

    // Handle Expanded widgets by distributing the remaining space based on flex ratios.
    // Compute this BEFORE the per-child layout pass so that flexible children can be
    // laid out with their final dimensions in a single layout call, avoiding a double
    // layout that would cause AnimatedSize (and similar) to restart their animations
    // every frame and never settle.
    final expandedChildren = <MapEntry<int, RenderBox>>[];
    int totalFlex = 0;

    for (var i = 0; i < renderedChildren.length; i++) {
      final child = renderedChildren[i];
      final parentData = child.parentData as LdOverflowViewParentData;
      if (parentData.consumeRemainder != null && parentData.consumeRemainder! > 0) {
        expandedChildren.add(MapEntry(i, child));
        totalFlex += parentData.consumeRemainder!;
      }
    }

    // Pre-compute final widths for flexible children so they are laid out only once.
    final Map<int, double> flexChildFinalWidths = {};
    if (expandedChildren.isNotEmpty && remainder > 0) {
      for (final entry in expandedChildren) {
        final i = entry.key;
        final parentData = entry.value.parentData as LdOverflowViewParentData;
        final flex = parentData.consumeRemainder!;
        final childMainSize = childrenSizes.elementAt(i);
        final flexRatio = flex / totalFlex;
        final additionalSpace = remainder * flexRatio;
        flexChildFinalWidths[i] = childMainSize + additionalSpace;
      }
      remainder = 0;
    }

    for (var i = 0; i < renderedChildren.length; i++) {
      final child = renderedChildren[i];
      final finalFlexWidth = flexChildFinalWidths[i];
      if (finalFlexWidth != null) {
        // Flexible child: lay out once with its final dimensions.
        if (_isHorizontal) {
          child.layout(
            BoxValueConstraints<int>(
              value: overflowCount,
              constraints: BoxConstraints(
                maxWidth: finalFlexWidth,
                minWidth: finalFlexWidth,
                maxHeight: constraints.maxHeight,
              ),
            ),
            parentUsesSize: true,
          );
        } else {
          child.layout(
            BoxValueConstraints<int>(
              value: overflowCount,
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
                minHeight: finalFlexWidth,
                maxHeight: finalFlexWidth,
              ),
            ),
            parentUsesSize: true,
          );
        }
      } else {
        // Non-flexible child: lay out with its intrinsic (minimum) size.
        child.layout(
          BoxValueConstraints<int>(
            value: overflowCount,
            constraints: BoxConstraints.loose(Size(
              _isHorizontal ? childrenSizes.elementAt(i) : constraints.maxWidth,
              _isHorizontal ? constraints.maxHeight : childrenSizes.elementAt(i),
            )),
          ),
          parentUsesSize: true,
        );
      }
    }

    // We fill the extent based on the offset
    double offset = 0;

    // If we try to center the children we start with half the remaining space.
    if (mainAxisAlignment == MainAxisAlignment.center) {
      offset = remainder / 2;
    }

    // If we try to align the children at the end we start with the remaining space.
    if (mainAxisAlignment == MainAxisAlignment.end) {
      offset = remainder;
    }

    // Determine the max cross size
    final maxCrossSize = math.max(
      indicatorCrossSize,
      renderedChildren.isNotEmpty
          ? renderedChildren.map((child) => _getCrossSizeOfRenderBox(child)).reduce((a, b) => math.max(a, b))
          : 0.0,
    );

    for (final child in renderedChildren) {
      final childParentData = child.parentData as LdOverflowViewParentData;

      childParentData.offstage = false;

      final double childCrossSize = _getCrossSizeOfRenderBox(child);

      double childCrossOffset = 0;

      if (crossAxisAlignment == CrossAxisAlignment.start) {
        childCrossOffset = 0;
      } else if (crossAxisAlignment == CrossAxisAlignment.end) {
        childCrossOffset = maxCrossSize - childCrossSize;
      } else if (crossAxisAlignment == CrossAxisAlignment.center) {
        childCrossOffset = (maxCrossSize - childCrossSize) / 2;
      }

      if (_isHorizontal) {
        childParentData.offset = Offset(offset, childCrossOffset);
      } else {
        childParentData.offset = Offset(childCrossOffset, offset);
      }

      offset += _getMainSizeOfRenderBox(child) + spacing;
    }

    // Calculate the actual total space used including spacing
    final totalUsedSpaceForSize = filledExtent + _spacingExtent(renderedChildren.length);
    final trailingSpace = availableExtent - totalUsedSpaceForSize;

    Size idealSize;
    if (_isHorizontal) {
      idealSize = Size(offset + trailingSpace, maxCrossSize);
    } else {
      idealSize = Size(maxCrossSize, offset + trailingSpace);
    }

    size = constraints.constrain(idealSize);
  }

  double _spacingExtent(int childCount) {
    if (childCount == 0) {
      return 0;
    }
    return spacing * (childCount - 1);
  }
}

extension RenderObjectExtensions on RenderObject {
  bool get isOnstage => (parentData as LdOverflowViewParentData).offstage == false;
}
