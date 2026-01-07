import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_test_utils/diff_util.dart';
import 'package:path/path.dart' as path;

const Set<dynamic> defaultIgnoredWidgets = {
  MediaQuery,
  Material,
  AnimatedDefaultTextStyle,
  DefaultTextStyle,
  PhysicalModel,
  AnimatedPhysicalModel,
  Semantics,
  Actions,
  'NotificationListener',
  Focus,
  'Provider',
  KeyedSubtree,
  MouseRegion,
  Builder,
};

enum IncludeWidgetBounds {
  none,
  relative,
  absolute,
}

class WidgetTreeOptions {
  const WidgetTreeOptions({
    /// A function to find the widget to create the tree for. If not provided,
    /// the widget passed to [widgetTreeMatchesGolden] will be used.
    this.findWidget,

    /// The path to the golden directory. If not provided,
    /// 'test/golden_widget_trees' will be used.
    this.goldenPath = 'test/golden_widget_trees',

    /// The path to the failure directory. If not provided,
    /// 'test/failures/golden_widget_trees' will be used.
    this.failurePath = 'test/failures/golden_widget_trees',

    /// The name of the golden file to compare with. If not provided, the name
    /// of the widget will be used.
    this.goldenName,

    /// A set of widgets to strip from the tree (in order to produce a less
    /// verbose tree). If not provided, a default set of widgets will be
    /// used, cf. [defaultIgnoredWidgets].
    this.strippedWidgets = defaultIgnoredWidgets,

    /// Whether to strip away private widgets (i.e. widgets starting with '_').
    /// Defaults to true.
    this.stripPrivateWidgets = true,

    /// Whether to include the bounds of the widgets in the tree. If set to
    /// [IncludeWidgetBounds.relative], the bounds will be relative to the
    /// parent widget. If set to [IncludeWidgetBounds.absolute], the bounds
    /// will be absolute on the screen. If set to [IncludeWidgetBounds.none],
    /// the bounds will not be included.
    this.includeWidgetBounds = IncludeWidgetBounds.relative,

    /// The precision of the bounds to include in the tree, e.g. 2 for
    /// 2 decimal places. Defaults to 0.
    this.boundsPrecision = 0,
  });

  final Finder Function(WidgetTester, Widget)? findWidget;
  final String failurePath;
  final String goldenPath;
  final String? goldenName;
  final Set<dynamic> strippedWidgets;
  final bool stripPrivateWidgets;
  final IncludeWidgetBounds includeWidgetBounds;
  final int boundsPrecision;
}

/// A node in the widget tree.
class WidgetTreeNode {
  WidgetTreeNode(this.widget, this.children, this.finder,
      {this.bounds, this.constraints});
  Widget widget;
  Rect? bounds;
  Constraints? constraints;
  Finder finder;
  List<WidgetTreeNode> children;

  String toXmlString({int indent = 0, required int boundsPrecision}) {
    final indentStr = '  ' * indent;
    final tag = widget.runtimeType
        .toString()
        .replaceAll('<', '-')
        .replaceAll('>', '')
        .replaceAll(',', '-')
        .replaceAll(' ', '');

    // associate properties with their values
    Map<String, dynamic> props = {
      for (var p in widget.toDiagnosticsNode().getProperties())
        if (p.name != null && p.value != null)
          p.name!: p.value
              .toString()
              .replaceAll('"', "'")
              .replaceAll("&", "&amp;")
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim(),
    };
    final attrs = [
      ...props.entries.map((e) {
        // Height and line height are conflicting properties
        if (e.key == "height") {
          return ' lineHeight="${e.value}"';
        }
        return ' ${e.key}="${e.value}"';
      }),
      if (bounds != null) ...[
        if (!props.containsKey("left"))
          ' left="${bounds!.left.toStringAsFixed(boundsPrecision)}"',
        if (!props.containsKey("top"))
          ' top="${bounds!.top.toStringAsFixed(boundsPrecision)}"',
        ' width="${bounds!.width.toStringAsFixed(boundsPrecision)}"',
        ' height="${bounds!.height.toStringAsFixed(boundsPrecision)}"',
      ],
      if (constraints is BoxConstraints) ...[
        ' maxHeight="${(constraints as BoxConstraints).maxHeight}"',
        ' maxWidth="${(constraints as BoxConstraints).maxWidth}"',
        ' minHeight="${(constraints as BoxConstraints).minHeight}"',
        ' minWidth="${(constraints as BoxConstraints).minWidth}"',
      ],
      if (widget is RichText) ...[
        ' color="${(widget as RichText).text.style?.color?.toString() ?? 'null'}"',
        ' family="${(widget as RichText).text.style?.fontFamily ?? 'null'}"',
        ' size="${(widget as RichText).text.style?.fontSize ?? 'null'}"',
        ' weight="${(widget as RichText).text.style?.fontWeight?.toString() ?? 'null'}"',
        ' lineHeight="${(widget as RichText).text.style?.height?.toString() ?? 'null'}"',
      ],
    ].join('');

    final content = children.isEmpty
        ? ''
        : [
              '',
              ...children.map((child) => child.toXmlString(
                  indent: indent + 1, boundsPrecision: boundsPrecision)),
              '',
            ].join('\n') +
            indentStr;
    final slash = children.isEmpty ? ' /' : '';
    final closingTag = children.isEmpty ? '' : '</$tag>';
    final result = '$indentStr<$tag$attrs$slash>$content$closingTag'
        // replace UID hash codes with a generic placeholder
        .replaceAllMapped(RegExp(r'([a-zA-Z_>]+)#[0-9a-fA-F]+'),
            (match) => '${match.group(1)}#HASH');
    return result;
  }
}

/// Wrapper for widget tree testing
Future<void> widgetTreeMatchesGolden(
  WidgetTester tester, {
  required Widget widget,
  WidgetTreeOptions options = const WidgetTreeOptions(),
  bool? update,
}) async {
  update ??= autoUpdateGoldenFiles;
  final goldenName = options.goldenName ?? widget.runtimeType.toString();

  final testTree = createWidgetTree(
    tester.element(
        options.findWidget?.call(tester, widget) ?? find.byWidget(widget)),
    tester: tester,
    options: options,
  );

  // strip all information from the tree that is not relevant for the comparison
  // e.g. hash codes, keys, etc. that change between test runs
  final testTreeStripped = testTree?.toXmlString(
        boundsPrecision: options.boundsPrecision,
      ) ??
      '';

  final goldenFile = File(
    path.join(Directory(options.goldenPath).path, '$goldenName.xml'),
  );

  // Create the golden directory if it does not exist
  final goldenSubDir = goldenFile.parent;
  if (!goldenSubDir.existsSync()) {
    goldenSubDir.createSync(recursive: true);
  }

  if (update || !goldenFile.existsSync()) {
    // Update or create the golden file
    goldenFile.writeAsStringSync(testTreeStripped);
  } else {
    // Compare with existing golden
    final goldenTree = goldenFile.readAsStringSync();

    try {
      expectEqualStrings(
        testTreeStripped,
        goldenTree,
        reason: 'Widget trees of ${goldenFile.path} does not match',
      );
    } on TestFailure catch (_) {
      // put the diff in the failure folder
      final diffFile = File(
        path.join(
            Directory(options.failurePath).path, '${goldenName}_diff.html'),
      );
      // Create the golden directory if it does not exist
      final diffFileDir = diffFile.parent;
      if (!diffFileDir.existsSync()) {
        diffFileDir.createSync(recursive: true);
      }
      final diffHtml = generateHtmlFormattedDiff(
        goldenTree,
        testTreeStripped,
        title: 'Widget Tree Comparison',
        subtitle: 'Widget tree diff for $goldenName',
      );
      diffFile.writeAsStringSync(diffHtml);
      rethrow;
    }
  }
}

/// Recursively creates a widget tree from the given element.
WidgetTreeNode? createWidgetTree(
  Element e, {
  required WidgetTester tester,
  required WidgetTreeOptions options,
}) {
  final widget = e.widget;
  final children = <WidgetTreeNode>[];

  e.visitChildren((element) {
    final child = createWidgetTree(
      element,
      tester: tester,
      options: options,
    );
    if (child != null) children.add(child);
  });

  final finder = find.byElementPredicate((el) => el == e);

  final type = widget.runtimeType.toString();
  final typeWithoutGeneric = type.split('<').first;
  final bounds = switch (options.includeWidgetBounds) {
    IncludeWidgetBounds.none => null,
    IncludeWidgetBounds.relative => () {
        final renderObject = e.renderObject;
        if (renderObject is RenderBox) {
          final pos = renderObject.localToGlobal(Offset.zero,
              ancestor: e.renderObject?.parent);
          return Rect.fromLTWH(
            pos.dx,
            pos.dy,
            renderObject.size.width,
            renderObject.size.height,
          );
        }

        if (renderObject is RenderSliverList) {
          // We cannot just get the bounds of the RenderSliverList
          final constraints = renderObject.constraints;

          // Get the SliverGeometry which contains positioning info
          final geometry = renderObject.geometry;

          if (geometry != null && !geometry.visible) {
            // If the sliver is not visible, return null or an empty rect
            return null;
          }

          // Calculate the bounds based on paintOrigin and paintExtent
          return Rect.fromLTWH(
            constraints.axis == Axis.vertical ? 0 : geometry!.paintOrigin,
            constraints.axis == Axis.vertical ? geometry!.paintOrigin : 0,
            constraints.axis == Axis.vertical
                ? constraints.crossAxisExtent
                : geometry!.paintExtent,
            constraints.axis == Axis.vertical
                ? geometry!.paintExtent
                : constraints.crossAxisExtent,
          );
        }

        return null;
      }(),
    IncludeWidgetBounds.absolute => tester.getRect(finder),
  };

  // ignore: invalid_use_of_protected_member
  final constraints = e.renderObject?.constraints;

  if (options.strippedWidgets.contains(type) ||
      options.strippedWidgets.contains(typeWithoutGeneric) ||
      (options.stripPrivateWidgets && type.startsWith('_'))) {
    if (children.isNotEmpty) {
      return children.length == 1
          ? children.first
          : WidgetTreeNode(widget, children, finder,
              bounds: bounds, constraints: constraints);
    } else {
      return null;
    }
  }

  return WidgetTreeNode(widget, children, finder,
      bounds: bounds, constraints: constraints);
}
