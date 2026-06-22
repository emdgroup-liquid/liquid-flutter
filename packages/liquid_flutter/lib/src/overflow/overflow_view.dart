import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/overflow/overflow_rendering.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

/// A widget that displays its children in a one-dimensional array until there
/// is no more room. If all the children don't fit in the available space, it
/// displays an indicator at the end.

class LdOverflowView extends MultiChildRenderObjectWidget {
  /// The direction to use as the main axis.
  final Axis direction;

  /// The amount of space between successive children.
  final double spacing;

  /// The alignment of the children along the main axis.
  final MainAxisAlignment mainAxisAlignment;

  /// The alignment of the children along the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// The builder for the overflow indicator.
  ///
  /// [overflowedChildIndices] lists content-child indices (excluding the overflow
  /// indicator) that were moved off stage into the menu.
  final Widget Function(BuildContext context, List<int> overflowedChildIndices) builder;

  /// Creates an [LdOverflowView].

  LdOverflowView({
    super.key,
    required this.builder,
    required List<Widget> children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.direction = Axis.horizontal,
    this.spacing = 0,
  }) : super(
          children: [
            ...children,
            ValueLayoutBuilder<List<int>>(
              builder: (context, constraints) {
                return builder(context, constraints.value);
              },
            ),
          ],
        );

  @override
  LdOverflowViewElement createElement() {
    return LdOverflowViewElement(this);
  }

  @override
  LdRenderOverflowView createRenderObject(BuildContext context) {
    return LdRenderOverflowView(
      direction: direction,
      spacing: spacing,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    LdRenderOverflowView renderObject,
  ) {
    renderObject
      ..direction = direction
      ..spacing = spacing
      ..mainAxisAlignment = mainAxisAlignment
      ..crossAxisAlignment = crossAxisAlignment;
  }
}

class LdOverflowViewElement extends MultiChildRenderObjectElement {
  LdOverflowViewElement(LdOverflowView super.widget);

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    for (var element in children) {
      if (element.renderObject?.isOnstage == true) {
        visitor(element);
      }
    }
  }
}
