import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Whether the render object behind [finder] is reachable through the visible
/// part of an [LdOverflowView]. Off-stage children and the idle variant of an
/// [LdOverflowAdaptiveChild] are laid out as well, so `hasSize` does not tell
/// them apart from what is actually shown.
bool isOnStage(WidgetTester tester, Finder finder) {
  if (finder.evaluate().isEmpty) {
    return false;
  }
  final target = tester.renderObject(finder);
  var found = false;
  void visit(RenderObject node) {
    if (found) {
      return;
    }
    if (identical(node, target)) {
      found = true;
      return;
    }
    node.visitChildrenForSemantics(visit);
  }

  for (final view in find.byType(LdOverflowView).evaluate()) {
    visit(view.renderObject!);
  }
  return found;
}
