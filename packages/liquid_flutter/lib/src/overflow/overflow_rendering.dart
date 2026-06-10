import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:liquid_flutter/src/overflow/adaptive_child.dart';
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

  RenderLdOverflowAdaptiveChild? _findAdaptiveDescendant(RenderBox root) {
    if (root is RenderLdOverflowAdaptiveChild) {
      return root;
    }
    RenderLdOverflowAdaptiveChild? found;
    root.visitChildren((child) {
      if (found != null || child is! RenderBox) {
        return;
      }
      found = _findAdaptiveDescendant(child);
    });
    return found;
  }

  void _visitAdaptiveDescendants(
    RenderBox root,
    void Function(RenderLdOverflowAdaptiveChild adaptive) visitor,
  ) {
    if (root is RenderLdOverflowAdaptiveChild) {
      visitor(root);
      return;
    }
    root.visitChildren((child) {
      if (child is RenderBox) {
        _visitAdaptiveDescendants(child, visitor);
      }
    });
  }

  bool _hasAdaptiveChildren(List<RenderBox> children) {
    for (final child in children) {
      if (child is LdOverflowAdaptiveSize || _findAdaptiveDescendant(child) != null) {
        return true;
      }
    }
    return false;
  }

  void _setAllAdaptiveUseCompact(List<RenderBox> children, bool useCompact) {
    for (final child in children) {
      _visitAdaptiveDescendants(child, (adaptive) {
        adaptive.resolveUseCompact(useCompact);
      });
    }
  }

  void _collectAdaptivesInChildOrder(
    List<RenderBox> children,
    List<RenderLdOverflowAdaptiveChild> adaptives,
  ) {
    for (final child in children) {
      void visit(RenderBox box) {
        if (box is RenderLdOverflowAdaptiveChild) {
          adaptives.add(box);
          return;
        }
        box.visitChildren((RenderObject descendant) {
          if (descendant is RenderBox) {
            visit(descendant);
          }
        });
      }
      visit(child);
    }
  }

  bool _rowNeedsMoreCompaction(
    List<RenderBox> children,
    List<double> childrenSizes,
    double availableExtent,
  ) {
    final adaptives = <RenderLdOverflowAdaptiveChild>[];
    _collectAdaptivesInChildOrder(children, adaptives);
    if (!adaptives.any((adaptive) => !adaptive.useCompact)) {
      return false;
    }

    final extentBudgetForNonFlex = _extentBudgetForNonFlexChildren(children, availableExtent);
    final fit = _computeFit(childrenSizes, extentBudgetForNonFlex);
    final onStageFit = _fitOnStageChildren(
      children,
      childrenSizes,
      availableExtent,
      fit.fittingChildren,
      fit.showOverflowIndicator,
      fit.filledExtent,
    );
    if (onStageFit.showOverflowIndicator) {
      return true;
    }
    if (onStageFit.fittingChildren < children.length) {
      return true;
    }
    return _projectedOnStageExtent(
          children,
          onStageFit.fittingChildren,
          childrenSizes,
        ) >
        availableExtent + 0.5;
  }

  /// Compacts [LdOverflowAdaptiveChild] widgets from the trailing edge until the row fits.
  List<double> _resolveAdaptiveCompaction(
    List<RenderBox> children,
    double availableExtent,
  ) {
    _setAllAdaptiveUseCompact(children, false);
    var childrenSizes = _getChildrenMainSizes(children, preferExpanded: true);
    if (!_rowNeedsMoreCompaction(children, childrenSizes, availableExtent)) {
      return childrenSizes;
    }

    final adaptives = <RenderLdOverflowAdaptiveChild>[];
    _collectAdaptivesInChildOrder(children, adaptives);

    for (var i = adaptives.length - 1; i >= 0; i--) {
      adaptives[i].resolveUseCompact(true);
      childrenSizes = _getChildrenMainSizes(children, preferExpanded: false);
      if (!_rowNeedsMoreCompaction(children, childrenSizes, availableExtent)) {
        break;
      }
    }

    return childrenSizes;
  }

  LdOverflowAdaptiveSize? _adaptiveSizeForChild(RenderBox child) {
    if (child is LdOverflowAdaptiveSize) {
      return child;
    }
    return _findAdaptiveDescendant(child);
  }

  double _childMainSize(
    RenderBox child, {
    required bool preferExpanded,
    required double crossExtent,
  }) {
    final parentData = child.parentData as LdOverflowViewParentData;
    if (parentData.consumeRemainder != null && parentData.consumeRemainder! > 0) {
      return 0.0;
    }
    final adaptive = _adaptiveSizeForChild(child);
    if (adaptive != null) {
      if (preferExpanded) {
        return adaptive.preferredMainSize(crossExtent, isHorizontal: _isHorizontal);
      }
      return adaptive.useCompact
          ? adaptive.compactMainSize(crossExtent, isHorizontal: _isHorizontal)
          : adaptive.preferredMainSize(crossExtent, isHorizontal: _isHorizontal);
    }
    return _isHorizontal ? child.getMinIntrinsicWidth(constraints.maxHeight) : child.getMinIntrinsicHeight(constraints.maxWidth);
  }

  List<double> _getChildrenMainSizes(
    List<RenderBox> children, {
    required bool preferExpanded,
  }) {
    final crossExtent = _isHorizontal ? constraints.maxHeight : constraints.maxWidth;

    return children.map((child) => _childMainSize(child, preferExpanded: preferExpanded, crossExtent: crossExtent)).toList();
  }

  bool _isFlexChild(LdOverflowViewParentData parentData) {
    return parentData.consumeRemainder != null && parentData.consumeRemainder! > 0;
  }

  double _flexChildMinMainSize(RenderBox child) {
    return _isHorizontal ? child.getMinIntrinsicWidth(constraints.maxHeight) : child.getMinIntrinsicHeight(constraints.maxWidth);
  }

  /// Minimum main-axis space reserved for [LdFlexibleChild] widgets before fitting
  /// fixed and adaptive children. Keeps titles from collapsing to zero width while
  /// actions still use their expanded size.
  double _reservedExtentForFlexChildren(List<RenderBox> children) {
    final flexIndices = <int>[];
    for (var i = 0; i < children.length; i++) {
      final parentData = children[i].parentData as LdOverflowViewParentData;
      if (_isFlexChild(parentData)) {
        flexIndices.add(i);
      }
    }
    if (flexIndices.isEmpty) {
      return 0;
    }

    var reserved = 0.0;
    for (final i in flexIndices) {
      reserved += _flexChildMinMainSize(children[i]);
    }

    if (flexIndices.length > 1) {
      reserved += spacing * (flexIndices.length - 1);
    }

    final lastFlexIndex = flexIndices.last;
    for (var i = lastFlexIndex + 1; i < children.length - 1; i++) {
      final parentData = children[i].parentData as LdOverflowViewParentData;
      if (!_isFlexChild(parentData)) {
        reserved += spacing;
        break;
      }
    }

    return math.min(reserved, _availableExtent);
  }

  double _extentBudgetForNonFlexChildren(
    List<RenderBox> children,
    double availableExtent,
  ) {
    return math.max(0, availableExtent - _reservedExtentForFlexChildren(children));
  }

  /// Main-axis extent if the first [fittingChildren] children are on stage, using
  /// flex minimums and measured sizes for fixed/adaptive children.
  double _projectedOnStageExtent(
    List<RenderBox> children,
    int fittingChildren,
    List<double> childrenSizes,
  ) {
    if (fittingChildren <= 0) {
      return 0;
    }
    var total = _spacingExtent(fittingChildren);
    for (var i = 0; i < fittingChildren; i++) {
      final parentData = children[i].parentData as LdOverflowViewParentData;
      if (_isFlexChild(parentData)) {
        total += _flexChildMinMainSize(children[i]);
      } else {
        total += childrenSizes[i];
      }
    }
    return total;
  }

  double _filledNonFlexExtent(
    List<RenderBox> children,
    int fittingChildren,
    List<double> childrenSizes,
  ) {
    var total = 0.0;
    for (var i = 0; i < fittingChildren; i++) {
      final parentData = children[i].parentData as LdOverflowViewParentData;
      if (!_isFlexChild(parentData)) {
        total += childrenSizes[i];
      }
    }
    return total;
  }

  /// Ensures the on-stage children (including flex minimums) fit in [availableExtent],
  /// moving trailing non-flex children into the overflow menu when needed.
  ({int fittingChildren, bool showOverflowIndicator, double filledExtent}) _fitOnStageChildren(
    List<RenderBox> children,
    List<double> childrenSizes,
    double availableExtent,
    int fittingChildren,
    bool showOverflowIndicator,
    double filledExtent,
  ) {
    var fitting = fittingChildren;
    var showOverflow = showOverflowIndicator;
    var filled = filledExtent;

    while (fitting > 0) {
      var projected = _projectedOnStageExtent(children, fitting, childrenSizes);
      var overflowCount = children.length - fitting;

      var indicatorSize = 0.0;
      if (overflowCount > 0) {
        showOverflow = true;
        final overflowIndicator = _layoutOverflowIndicator(overflowCount);
        indicatorSize = _getIndicatorSize(overflowIndicator);
        projected += indicatorSize + spacing;
      }

      if (projected <= availableExtent) {
        filled = _filledNonFlexExtent(children, fitting, childrenSizes);
        return (fittingChildren: fitting, showOverflowIndicator: showOverflow, filledExtent: filled);
      }

      showOverflow = true;
      var lastNonFlexIndex = fitting - 1;
      while (lastNonFlexIndex >= 0) {
        final parentData = children[lastNonFlexIndex].parentData as LdOverflowViewParentData;
        if (!_isFlexChild(parentData)) {
          break;
        }
        lastNonFlexIndex--;
      }
      if (lastNonFlexIndex < 0) {
        // Only flex children on stage: clamp the title via flex layout. If trailing
        // children were removed because they did not fit, still show the overflow menu.
        filled = _filledNonFlexExtent(children, fitting, childrenSizes);
        return (
          fittingChildren: fitting,
          showOverflowIndicator: fitting < children.length,
          filledExtent: filled,
        );
      }
      fitting = lastNonFlexIndex;
    }

    return (fittingChildren: 0, showOverflowIndicator: true, filledExtent: 0);
  }

  ({bool showOverflowIndicator, int fittingChildren, double filledExtent}) _computeFit(
    List<double> childrenSizes,
    double availableExtent,
  ) {
    var filledExtent = 0.0;
    var fittingChildren = 0;
    var showOverflowIndicator = false;

    for (final childSize in childrenSizes) {
      final newExtent = filledExtent + childSize + _spacingExtent(fittingChildren + 1);
      if (newExtent <= availableExtent) {
        filledExtent += childSize;
        fittingChildren++;
      } else {
        showOverflowIndicator = true;
        break;
      }
    }

    return (
      showOverflowIndicator: showOverflowIndicator,
      fittingChildren: fittingChildren,
      filledExtent: filledExtent,
    );
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

    final children = _children;
    final hasAdaptiveChildren = _hasAdaptiveChildren(children);
    final extentBudgetForNonFlex = _extentBudgetForNonFlexChildren(children, availableExtent);

    // Prefer expanded labels; compact adaptives from the trailing edge until the row fits.
    var childrenSizes = hasAdaptiveChildren
        ? _resolveAdaptiveCompaction(children, availableExtent)
        : _getChildrenMainSizes(children, preferExpanded: true);

    var fit = _computeFit(childrenSizes, extentBudgetForNonFlex);
    var filledExtent = fit.filledExtent;
    var fittingChildren = fit.fittingChildren;
    showOverflowIndicator = fit.showOverflowIndicator;

    final onStageFit = _fitOnStageChildren(
      children,
      childrenSizes,
      availableExtent,
      fittingChildren,
      showOverflowIndicator,
      filledExtent,
    );
    fittingChildren = onStageFit.fittingChildren;
    showOverflowIndicator = onStageFit.showOverflowIndicator;
    filledExtent = onStageFit.filledExtent;

    final renderedChildren = children.sublist(0, fittingChildren);

    var overflowCount = childCount - fittingChildren - 1;
    showOverflowIndicator = showOverflowIndicator && overflowCount > 0;

    if (showOverflowIndicator) {
      _layoutOverflowIndicator(overflowCount);
      _getIndicatorSize(overflowIndicator);
      _layoutOverflowIndicator(overflowCount);
      renderedChildren.add(overflowIndicator);
    } else {
      final overflowIndicatorParentData = overflowIndicator.parentData as LdOverflowViewParentData;
      overflowIndicatorParentData.offstage = true;
    }
    final indicatorCrossSize = getCrossSize(overflowIndicator.size);

    var totalUsedSpace = _projectedOnStageExtent(children, fittingChildren, childrenSizes);
    if (showOverflowIndicator && overflowCount > 0) {
      totalUsedSpace += _getMainSizeOfRenderBox(overflowIndicator) + spacing;
    }
    var remainder = availableExtent - totalUsedSpace;

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
        final child = entry.value;
        final parentData = child.parentData as LdOverflowViewParentData;
        final flex = parentData.consumeRemainder!;
        final flexRatio = flex / totalFlex;
        final additionalSpace = remainder * flexRatio;
        final minFlexExtent = _flexChildMinMainSize(child);
        flexChildFinalWidths[i] = minFlexExtent + additionalSpace;
      }
      remainder = 0;
    } else if (expandedChildren.isNotEmpty) {
      var nonFlexOnStage = 0.0;
      for (var i = 0; i < fittingChildren; i++) {
        final parentData = children[i].parentData as LdOverflowViewParentData;
        if (!_isFlexChild(parentData)) {
          nonFlexOnStage += childrenSizes[i];
        }
      }
      if (showOverflowIndicator && overflowCount > 0) {
        nonFlexOnStage += _getMainSizeOfRenderBox(overflowIndicator);
      }
      final flexSpacing = _spacingExtent(renderedChildren.length);
      var flexBudget = math.max(0, availableExtent - nonFlexOnStage - flexSpacing);
      for (final entry in expandedChildren) {
        final i = entry.key;
        final child = entry.value;
        final parentData = child.parentData as LdOverflowViewParentData;
        final flex = parentData.consumeRemainder!;
        final flexRatio = flex / totalFlex;
        final minFlexExtent = _flexChildMinMainSize(child);
        final flexShare = flexBudget * flexRatio;
        flexChildFinalWidths[i] = math.min(
          flexBudget,
          math.max(minFlexExtent, flexShare),
        ).toDouble();
      }
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

    // Position using space actually consumed after layout (not flex min projections).
    var actualUsedMainExtent = 0.0;
    for (var i = 0; i < renderedChildren.length; i++) {
      actualUsedMainExtent += _getMainSizeOfRenderBox(renderedChildren[i]);
      if (i < renderedChildren.length - 1) {
        actualUsedMainExtent += spacing;
      }
    }
    remainder = availableExtent - actualUsedMainExtent;

    var offset = 0.0;
    if (mainAxisAlignment == MainAxisAlignment.center) {
      offset = math.max(0, remainder / 2);
    } else if (mainAxisAlignment == MainAxisAlignment.end) {
      offset = math.max(0, remainder);
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

    final mainExtent = renderedChildren.isEmpty
        ? 0.0
        : math.max(0.0, offset - spacing).toDouble();
    _hasOverflow = showOverflowIndicator || mainExtent > availableExtent + 0.5;

    Size idealSize;
    if (_isHorizontal) {
      idealSize = Size(mainExtent, maxCrossSize);
    } else {
      idealSize = Size(maxCrossSize, mainExtent);
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
