import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Mixin for render objects that expose preferred and compact main-axis sizes
/// within [LdRenderOverflowView].
mixin LdOverflowAdaptiveSize on RenderBox {
  double preferredMainSize(double crossExtent, {required bool isHorizontal});

  double compactMainSize(double crossExtent, {required bool isHorizontal});

  bool get useCompact;

  set useCompact(bool value);
}

class _OverflowAdaptiveChildParentData extends ContainerBoxParentData<RenderBox> {}

/// A child of [LdOverflowView] that can render in an expanded or compact size.
///
/// The overflow layout prefers [expanded] and falls back to [compact] when the
/// row does not fit at the preferred size.
class LdOverflowAdaptiveChild extends MultiChildRenderObjectWidget {
  const LdOverflowAdaptiveChild({
    super.key,
    required this.expanded,
    required this.compact,
  });

  final Widget expanded;
  final Widget compact;

  @override
  List<Widget> get children => [expanded, compact];

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderLdOverflowAdaptiveChild();
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderLdOverflowAdaptiveChild renderObject,
  ) {}
}

class RenderLdOverflowAdaptiveChild extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverflowAdaptiveChildParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverflowAdaptiveChildParentData>,
        LdOverflowAdaptiveSize {
  bool _useCompact = false;

  @override
  bool get useCompact => _useCompact;

  /// Updates the resolved compact state during [LdRenderOverflowView] layout.
  ///
  /// Must not trigger [markNeedsLayout] because this is called from the parent's
  /// [performLayout].
  void resolveUseCompact(bool value) {
    _useCompact = value;
  }

  @override
  set useCompact(bool value) {
    if (_useCompact == value) {
      return;
    }
    _useCompact = value;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  (RenderBox? expanded, RenderBox? compact) _childPair() {
    RenderBox? expanded;
    RenderBox? compact;
    var index = 0;
    visitChildren((RenderObject child) {
      if (index == 0) {
        expanded = child as RenderBox;
      } else if (index == 1) {
        compact = child as RenderBox;
      }
      index++;
    });
    return (expanded, compact);
  }

  RenderBox? get _activeChild {
    final (expanded, compact) = _childPair();
    return _useCompact ? compact : expanded;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverflowAdaptiveChildParentData) {
      child.parentData = _OverflowAdaptiveChildParentData();
    }
  }

  @override
  double preferredMainSize(double crossExtent, {required bool isHorizontal}) {
    final (expanded, _) = _childPair();
    if (expanded == null) {
      return 0;
    }
    return isHorizontal ? expanded.getMaxIntrinsicWidth(crossExtent) : expanded.getMaxIntrinsicHeight(crossExtent);
  }

  @override
  double compactMainSize(double crossExtent, {required bool isHorizontal}) {
    final (_, compact) = _childPair();
    if (compact == null) {
      return 0;
    }
    return isHorizontal ? compact.getMinIntrinsicWidth(crossExtent) : compact.getMinIntrinsicHeight(crossExtent);
  }

  RenderBox? get _intrinsicReferenceChild {
    final (expanded, compact) = _childPair();
    return _useCompact ? compact : expanded;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _intrinsicReferenceChild?.getMinIntrinsicWidth(height) ?? 0;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    final (expanded, _) = _childPair();
    return expanded?.getMaxIntrinsicWidth(height) ?? 0;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _intrinsicReferenceChild?.getMinIntrinsicHeight(width) ?? 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final (expanded, _) = _childPair();
    return expanded?.getMaxIntrinsicHeight(width) ?? 0;
  }

  @override
  void performLayout() {
    final (expandedChild, compactChild) = _childPair();
    if (expandedChild == null || compactChild == null) {
      size = constraints.smallest;
      return;
    }

    final activeChild = _useCompact ? compactChild : expandedChild;
    activeChild.layout(constraints, parentUsesSize: true);
    size = activeChild.size;

    final activeParentData = activeChild.parentData! as _OverflowAdaptiveChildParentData;
    activeParentData.offset = Offset.zero;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final activeChild = _activeChild;
    if (activeChild != null) {
      context.paintChild(activeChild, offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final activeChild = _activeChild;
    if (activeChild == null) {
      return false;
    }
    return activeChild.hitTest(result, position: position);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    final activeChild = _activeChild;
    if (activeChild != null) {
      visitor(activeChild);
    }
  }
}
