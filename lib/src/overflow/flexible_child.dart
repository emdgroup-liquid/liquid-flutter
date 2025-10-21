import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/overflow/overflow_rendering.dart';
import 'package:liquid_flutter/src/overflow/overflow_view.dart';

/// A widget that makes its child flexible within an [LdOverflowView].
///
/// Similar to [Expanded] but works with [LdOverflowView] instead of [Flex].
/// The child will consume the remaining space in the main axis based on its flex value.
class LdFlexibleChild extends ParentDataWidget<LdOverflowViewParentData> {
  /// Creates a [LdFlexibleChild].
  const LdFlexibleChild({
    super.key,
    required super.child,
    this.flex = 1,
  });

  /// The flex value to use when distributing remaining space.
  ///
  /// The remaining space will be distributed proportionally based on the flex values
  /// of all FlexibleChild widgets. Defaults to 1.
  final int flex;

  @override
  void applyParentData(RenderObject renderObject) {
    final LdOverflowViewParentData parentData = renderObject.parentData! as LdOverflowViewParentData;
    if (parentData.consumeRemainder != flex) {
      parentData.consumeRemainder = flex;
      final LdRenderOverflowView targetParent = renderObject.parent! as LdRenderOverflowView;
      targetParent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => LdOverflowView;
}
