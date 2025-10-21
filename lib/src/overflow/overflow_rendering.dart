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

  Iterable<Size> _getChildrenIntrinsicSizes(List<RenderBox> children) {
    return _children.map((e) {
      return Size(
        e.getMaxIntrinsicWidth(constraints.maxHeight),
        e.getMaxIntrinsicHeight(constraints.maxWidth),
      );
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
    final overflowIndicatorConstraints = BoxValueConstraints<int>(
      value: overflowCount,
      constraints: _childConstraints(0),
    );

    overflowIndicator.layout(
      overflowIndicatorConstraints,
      parentUsesSize: true,
    );

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
    final childrenSizes = _getChildrenIntrinsicSizes(_children);

    // Needed to calculate the cross axis alignment later
    double maxCrossSize = 0;

    // Keep track of the total size of the children that are already on stage
    double filledExtent = 0;

    int fittingChildren = 0;

    for (final childSize in childrenSizes) {
      final mainSize = getMainSize(childSize);
      final crossSize = getCrossSize(childSize);

      maxCrossSize = math.max(maxCrossSize, crossSize);

      final newExtent = filledExtent + mainSize + _spacingExtent(fittingChildren + 1);

      // Check if the filled space is less than the available extent.
      if (newExtent <= availableExtent) {
        filledExtent += mainSize;
        fittingChildren++;
      } else {
        showOverflowIndicator = true;
        break;
      }
    }

    final renderedChildren = _children.sublist(0, fittingChildren);

    final overflowCount = childCount - fittingChildren - 1;

    if (showOverflowIndicator) {
      // We need to place the overflow indicator.
      // We start by determining its size, by passing the value of already
      // overflowing children.
      final overflowIndicator = _layoutOverflowIndicator(overflowCount);
      final indicatorSize = _getIndicatorSize(overflowIndicator);

      filledExtent += indicatorSize;

      // Remove children until we can fit the overflow indicator fits.
      while (filledExtent + _spacingExtent(fittingChildren + 1) > availableExtent) {
        final RenderBox lastChild = renderedChildren.last;
        final parentData = lastChild.parentData as LdOverflowViewParentData;
        parentData.offstage = true;

        renderedChildren.removeLast();
        fittingChildren--;

        filledExtent -= getMainSize(childrenSizes.elementAt(fittingChildren));
      }

      renderedChildren.add(overflowIndicator);

      // Now that we know the final count of fitting children we
      // layout again to pass the correct count to the overflow indicator.

      maxCrossSize = math.max(maxCrossSize, indicatorSize);
    } else {
      final overflowIndicatorParentData = overflowIndicator.parentData as LdOverflowViewParentData;
      overflowIndicatorParentData.offstage = true;
    }

    // Calculate the actual total space used by children including spacing
    double totalUsedSpace = filledExtent + _spacingExtent(renderedChildren.length);
    double remainder = availableExtent - totalUsedSpace;

    for (var i = 0; i < renderedChildren.length; i++) {
      final child = renderedChildren[i];
      child.layout(
        BoxValueConstraints<int>(
          value: overflowCount,
          constraints: BoxConstraints.loose(Size(
            _isHorizontal ? childrenSizes.elementAt(i).width : childrenSizes.elementAt(i).height,
            _isHorizontal ? childrenSizes.elementAt(i).height : childrenSizes.elementAt(i).width,
          )),
        ),
        parentUsesSize: true,
      );
    }

    // Handle Expanded widgets by distributing the remaining space based on flex ratios
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

    if (expandedChildren.isNotEmpty && remainder > 0) {
      for (final entry in expandedChildren) {
        final i = entry.key;
        final child = entry.value;
        final parentData = child.parentData as LdOverflowViewParentData;
        final flex = parentData.consumeRemainder!;
        final childMainSize = _isHorizontal ? childrenSizes.elementAt(i).width : childrenSizes.elementAt(i).height;
        final flexRatio = flex / totalFlex;
        final additionalSpace = remainder * flexRatio;

        if (_isHorizontal) {
          child.layout(
            BoxValueConstraints<int>(
              value: overflowCount,
              constraints: BoxConstraints.tight(Size(childMainSize + additionalSpace, maxCrossSize)),
            ),
            parentUsesSize: true,
          );
        } else {
          child.layout(
            BoxValueConstraints<int>(
              value: overflowCount,
              constraints: BoxConstraints.tight(Size(maxCrossSize, childMainSize + additionalSpace)),
            ),
            parentUsesSize: true,
          );
        }
      }
      remainder = 0;
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
