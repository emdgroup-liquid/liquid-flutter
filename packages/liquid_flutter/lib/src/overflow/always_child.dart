import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:liquid_flutter/src/overflow/overflow_rendering.dart';
import 'package:liquid_flutter/src/overflow/overflow_view.dart';

/// A child of [LdOverflowView] that is always moved into the overflow menu,
/// regardless of the available space.
///
/// The overflow indicator is always shown while such a child exists, even when
/// every sibling fits, and the [LdOverflowView.builder] always receives its
/// index in `overflowedChildIndices`.
///
/// Unlike [LdOverflowPinnedChild] (a [ParentDataWidget]), this is a
/// [SingleChildRenderObjectWidget] so that it works correctly even when the
/// child subtree introduces intermediate render objects (e.g. a [Tooltip] with
/// an internal [RepaintBoundary]).
class LdOverflowAlwaysChild extends SingleChildRenderObjectWidget {
  const LdOverflowAlwaysChild({
    super.key,
    required super.child,
  });

  @override
  SingleChildRenderObjectElement createElement() => _LdOverflowAlwaysChildElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLdOverflowAlwaysChild();
  }
}

class _LdOverflowAlwaysChildElement extends SingleChildRenderObjectElement {
  _LdOverflowAlwaysChildElement(LdOverflowAlwaysChild super.widget);

  @override
  void attachRenderObject(Object? newSlot) {
    super.attachRenderObject(newSlot);
    final pd = renderObject.parentData;
    if (pd is LdOverflowViewParentData && !pd.alwaysOverflow) {
      pd.alwaysOverflow = true;
      (renderObject.parent! as LdRenderOverflowView).markNeedsLayout();
    }
  }
}

class _RenderLdOverflowAlwaysChild extends RenderProxyBox {}