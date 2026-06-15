import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/overflow/overflow_rendering.dart';
import 'package:liquid_flutter/src/overflow/overflow_view.dart';

/// A child of [LdOverflowView] that must remain visible in the bar and is never
/// moved into the overflow menu.
///
/// When space is tight, overflowable siblings are hidden first; the title
/// ([LdFlexibleChild]) shrinks before pinned children are clipped.
class LdOverflowPinnedChild extends ParentDataWidget<LdOverflowViewParentData> {
  const LdOverflowPinnedChild({
    super.key,
    required super.child,
  });

  @override
  void applyParentData(RenderObject renderObject) {
    final LdOverflowViewParentData parentData = renderObject.parentData! as LdOverflowViewParentData;
    if (!parentData.pinnedFromOverflow) {
      parentData.pinnedFromOverflow = true;
      final LdRenderOverflowView targetParent = renderObject.parent! as LdRenderOverflowView;
      targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => LdOverflowView;
}
