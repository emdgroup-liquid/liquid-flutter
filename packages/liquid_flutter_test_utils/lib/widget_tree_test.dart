import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_test_utils/diff_util.dart';
import 'package:liquid_flutter_test_utils/widget_creation_location.dart';
import 'package:liquid_flutter_test_utils/widget_tree_package_index.dart';
import 'package:path/path.dart' as path;

const Set<dynamic> defaultIgnoredWidgets = {
  MediaQuery,
  Material,
  AnimatedDefaultTextStyle,
  DefaultTextStyle,
  PhysicalModel,
  AnimatedPhysicalModel,
  AnimatedBuilder,
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

    /// Package name whose widget instantiations are shown in the tree.
    /// When null, auto-detected from the running test file path.
    this.focusPackage,

    /// When true, only widgets instantiated in the focus package are shown;
    /// foreign implementation scaffolding is passed through.
    this.filterByCreationLocation = true,
  });

  final Finder Function(WidgetTester, Widget)? findWidget;
  final String failurePath;
  final String goldenPath;
  final String? goldenName;
  final Set<dynamic> strippedWidgets;
  final bool stripPrivateWidgets;
  final IncludeWidgetBounds includeWidgetBounds;
  final int boundsPrecision;
  final String? focusPackage;
  final bool filterByCreationLocation;
}

/// Context for building a filtered widget tree.
class WidgetTreeContext {
  WidgetTreeContext({
    required this.options,
    required this.tester,
    required this.focusScope,
  });

  final WidgetTreeOptions options;
  final WidgetTester tester;
  final FocusPackageScope? focusScope;

  bool get useProvenanceFilter =>
      options.filterByCreationLocation &&
      focusScope != null &&
      isWidgetCreationTracked();

  bool isFocusCreated(Element element) {
    final scope = focusScope;
    if (scope == null) {
      return true;
    }
    return scope.isFocusCreated(element);
  }
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

  String toXmlString({
    int indent = 0,
    required int boundsPrecision,
    Rect? parentBounds,
    BoxConstraints? parentConstraints,
  }) {
    final indentStr = '  ' * indent;
    final tag = widget.runtimeType
        .toString()
        .replaceAll('<', '-')
        .replaceAll('>', '')
        .replaceAll(',', '-')
        .replaceAll(' ', '');

    // associate properties with their values (opt-in selection)
    final diagnostics = widget.toDiagnosticsNode().getProperties();
    final allowedNames = _allowedPropertyNames(widget, diagnostics);
    final Map<String, dynamic> props = {};

    // Process properties, handling BoxDecoration specially
    for (final p in diagnostics) {
      if (p.name != null && p.value != null && allowedNames.contains(p.name)) {
        // Check if this is a BoxDecoration property (bg or decoration)
        if ((p.name == 'bg' || p.name == 'decoration') &&
            p.value is BoxDecoration) {
          // Flatten BoxDecoration properties directly onto the element
          final decoration = p.value as BoxDecoration;
          final flattenedProps = _serializeBoxDecoration(decoration);
          // Sanitize the flattened property values
          for (final entry in flattenedProps.entries) {
            props[entry.key] = _sanitizeAttributeValue(entry.value);
          }
        } else {
          // Regular property handling
          props[p.name!] = _sanitizeAttributeValue(
            _getPropertyValueString(p),
          );
        }
      }
    }

    // Determine if bounds should be included:
    // - Always include for root widget (parentBounds is null)
    // - Include if bounds differ from parent bounds
    final shouldIncludeBounds = bounds != null &&
        (parentBounds == null ||
            !_boundsMatchParent(bounds!, parentBounds, boundsPrecision));

    // Determine if constraints should be included:
    // - Always include for root widget (parentConstraints is null)
    // - Include if constraints differ from parent constraints
    final boxConstraints =
        constraints is BoxConstraints ? (constraints as BoxConstraints) : null;
    final shouldIncludeConstraints = boxConstraints != null &&
        (parentConstraints == null ||
            !_constraintsMatchParent(boxConstraints, parentConstraints));

    final attrs = [
      ...props.entries.map((e) {
        // Height and line height are conflicting properties
        if (e.key == "height") {
          return ' lineHeight="${e.value}"';
        }
        return ' ${e.key}="${e.value}"';
      }),
      if (shouldIncludeBounds) ...[
        if (!props.containsKey("left"))
          ' left="${bounds!.left.toStringAsFixed(boundsPrecision)}"',
        if (!props.containsKey("top"))
          ' top="${bounds!.top.toStringAsFixed(boundsPrecision)}"',
        ' width="${bounds!.width.toStringAsFixed(boundsPrecision)}"',
        ' height="${bounds!.height.toStringAsFixed(boundsPrecision)}"',
      ],
      if (shouldIncludeConstraints) ...[
        ' maxHeight="${boxConstraints.maxHeight.toStringAsFixed(boundsPrecision)}"',
        ' maxWidth="${boxConstraints.maxWidth.toStringAsFixed(boundsPrecision)}"',
        ' minHeight="${boxConstraints.minHeight.toStringAsFixed(boundsPrecision)}"',
        ' minWidth="${boxConstraints.minWidth.toStringAsFixed(boundsPrecision)}"',
      ],
      if (widget is RichText) ...[
        ' text="${_sanitizeAttributeValue((widget as RichText).text.toPlainText())}"',
        ' color="${_colorToHex((widget as RichText).text.style?.color)}"',
        ' family="${(widget as RichText).text.style?.fontFamily ?? 'null'}"',
        ' size="${(widget as RichText).text.style?.fontSize ?? 'null'}"',
        ' weight="${(widget as RichText).text.style?.fontWeight?.toString() ?? 'null'}"',
        ' lineHeight="${(widget as RichText).text.style?.height?.toString() ?? 'null'}"',
      ],
      if (widget is Text) ...[
        ' text="${_sanitizeAttributeValue((widget as Text).data ?? (widget as Text).textSpan?.toPlainText() ?? '')}"',
        ' overflow="${(widget as Text).overflow?.toString() ?? 'null'}"',
        ' alignment="${(widget as Text).textAlign?.toString() ?? 'null'}"',
        ' weight="${(widget as Text).style?.fontWeight?.toString() ?? 'null'}"',
        ' lineHeight="${(widget as Text).style?.height?.toString() ?? 'null'}"',
      ],
      // Handle LdText widget - check by runtimeType string to avoid import dependency
      if (widget.runtimeType.toString() == 'LdText')
        ...(() {
          try {
            final ldText = widget as dynamic;
            return [
              ' type="${ldText.type?.toString() ?? 'null'}"',
              ' size="${ldText.size?.toString() ?? 'null'}"',
            ];
          } catch (_) {
            return <String>[];
          }
        })(),
    ].join('');

    final content = children.isEmpty
        ? ''
        : [
              '',
              ...children.map((child) => child.toXmlString(
                  indent: indent + 1,
                  boundsPrecision: boundsPrecision,
                  parentBounds: bounds,
                  parentConstraints: boxConstraints)),
              '',
            ].join('\n') +
            indentStr;
    final slash = children.isEmpty ? ' /' : '';
    final closingTag = children.isEmpty ? '' : '</$tag>';
    final result = '$indentStr<$tag$attrs$slash>$content$closingTag'
        // replace UID hash codes with a generic placeholder
        .replaceAllMapped(
      RegExp(r'([a-zA-Z_>]+)#[0-9a-fA-F]+'),
      (match) => '${match.group(1)}#HASH',
    );
    return result;
  }
}

Set<String> _allowedPropertyNames(
  Widget widget,
  List<DiagnosticsNode> diagnostics,
) {
  // Always allow keys by default.
  final allowed = <String>{'key'};

  // For Semantics widgets, keep all diagnostics so we do not lose
  // accessibility-related information.
  if (widget is Semantics || widget is IndexedSemantics) {
    return {
      for (final p in diagnostics)
        if (p.name != null) p.name!,
    };
  }

  // Use switch expression to match widget types and add specific properties.
  allowed.addAll(
    switch (widget) {
      Container() || DecoratedBox() || AnimatedContainer() => [
          // Decoration / padding / margin.
          'bg', // existing decoration diagnostic for Container.
          'decoration',
          'foregroundDecoration',
          'padding',
          'margin',
          'clipBehavior',
        ],
      Padding() => ['padding'],
      Row() || Column() => [
          // Row / Column layout parameters.
          'direction',
          'mainAxisAlignment',
          'mainAxisSize',
          'crossAxisAlignment',
          'verticalDirection',
          'clipBehavior',
          'spacing',
        ],
      Icon() => [
          // Icon data.
          'icon',
        ],
      ClipRect() || ClipRRect() || ClipPath() || ClipOval() => [
          // Clip widgets.
          'clipBehavior',
        ],
      ListView() ||
      GridView() ||
      PageView() ||
      SingleChildScrollView() ||
      CustomScrollView() ||
      Scrollable() ||
      ShrinkWrappingViewport() =>
        [
          // Scroll views and related widgets.
          'scrollDirection',
          'reverse',
          'physics',
          'shrinkWrap',
          'padding',
          'axisDirection',
        ],
      Expanded() || Flexible() => [
          // Flex parameters.
          'flex',
        ],
      Align() || Center() => [
          // Alignment parameters.
          'alignment',
        ],
      Listener() || MouseRegion() => [
          // Pointer / mouse behavior.
          'behavior',
        ],
      _ => [],
    },
  );

  return allowed;
}

/// Serializes a BoxDecoration to a flattened map of XML attributes
Map<String, String> _serializeBoxDecoration(BoxDecoration decoration) {
  final Map<String, String> props = {};

  // Color
  if (decoration.color != null) {
    props['bgColor'] = _colorToHex(decoration.color);
  }

  // BorderRadius (BorderRadiusGeometry can be BorderRadius or BorderRadiusDirectional)
  if (decoration.borderRadius != null) {
    if (decoration.borderRadius is BorderRadius) {
      props['borderRadius'] =
          _serializeBorderRadius(decoration.borderRadius! as BorderRadius);
    }
    // BorderRadiusDirectional could be handled here if needed
  }

  // Border (BoxBorder can be Border or BorderDirectional)
  if (decoration.border != null) {
    if (decoration.border is Border) {
      final borderProps = _serializeBorder(decoration.border! as Border);
      props.addAll(borderProps);
    }
    // BorderDirectional could be handled here if needed
  }

  // BoxShadow (simplified - just count for now, could be expanded)
  if (decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
    // For now, we'll just note that shadows exist
    // Could be expanded to serialize shadow details if needed
    props['hasBoxShadow'] = 'true';
  }

  // Gradient
  if (decoration.gradient != null) {
    // Could be expanded to serialize gradient details if needed
    props['hasGradient'] = 'true';
  }

  return props;
}

/// Serializes a BorderRadius to a compact string format
String _serializeBorderRadius(BorderRadius radius) {
  final topLeft = radius.topLeft;
  final topRight = radius.topRight;
  final bottomLeft = radius.bottomLeft;
  final bottomRight = radius.bottomRight;

  // Check if it's uniform (all corners the same and circular)
  if (topLeft.x == topLeft.y &&
      topRight.x == topRight.y &&
      bottomLeft.x == bottomLeft.y &&
      bottomRight.x == bottomRight.y &&
      topLeft.x == topRight.x &&
      topLeft.x == bottomLeft.x &&
      topLeft.x == bottomRight.x) {
    // Uniform circular radius - just return the value
    return topLeft.x.toString();
  }

  // For non-uniform radius, serialize each corner
  // Format: "tl:${x},${y} tr:${x},${y} bl:${x},${y} br:${x},${y}"
  return 'tl:${topLeft.x},${topLeft.y} tr:${topRight.x},${topRight.y} bl:${bottomLeft.x},${bottomLeft.y} br:${bottomRight.x},${bottomRight.y}';
}

/// Serializes a Border to a map of XML attributes
Map<String, String> _serializeBorder(Border border) {
  final Map<String, String> props = {};

  // Check if it's a uniform border (all sides the same)
  if (border.isUniform) {
    final side = border.top;
    if (side.style != BorderStyle.none) {
      props['borderColor'] = _colorToHex(side.color);
      props['borderWidth'] = side.width.toString();
      // Include strokeAlign if it's not the default (BorderSide.strokeAlignInside = -1.0)
      if (side.strokeAlign != BorderSide.strokeAlignInside) {
        props['borderStrokeAlign'] = side.strokeAlign.toString();
      }
    }
  } else {
    // Non-uniform border - serialize each side
    if (border.top.style != BorderStyle.none) {
      props['borderTopColor'] = _colorToHex(border.top.color);
      props['borderTopWidth'] = border.top.width.toString();
    }
    if (border.right.style != BorderStyle.none) {
      props['borderRightColor'] = _colorToHex(border.right.color);
      props['borderRightWidth'] = border.right.width.toString();
    }
    if (border.bottom.style != BorderStyle.none) {
      props['borderBottomColor'] = _colorToHex(border.bottom.color);
      props['borderBottomWidth'] = border.bottom.width.toString();
    }
    if (border.left.style != BorderStyle.none) {
      props['borderLeftColor'] = _colorToHex(border.left.color);
      props['borderLeftWidth'] = border.left.width.toString();
    }
  }

  return props;
}

String _getPropertyValueString(DiagnosticsNode property) {
  if (property is DiagnosticsProperty) {
    final value = property.value;
    if (value != null) {
      // Serialize Color objects to hex format with opacity
      if (value is Color) {
        return _colorToHex(value);
      }

      // Check if the value itself is an enum
      if (value is Enum) {
        // Return dot shorthand (e.g., ".vertical" instead of "Axis.vertical")
        return '.${value.name}';
      }

      // Use valueToString() for EnumProperty to get shorter enum names
      if (property is EnumProperty) {
        final enumValue = property.valueToString();
        // Return dot shorthand (e.g., ".vertical" instead of "Axis.vertical")
        return '.$enumValue';
      }

      // For string values that match patterns like "ClassName.memberName"
      // (without parentheses or complex syntax), convert to dot shorthand
      // (e.g., "EdgeInsets.zero" -> ".zero", "Clip.none" -> ".none")
      final stringValue = value.toString();
      // Match ClassName.memberName where memberName is a simple identifier
      // and doesn't contain parentheses (to avoid matching constructors like EdgeInsets.all(14.0))
      final dotShorthandPattern =
          RegExp(r'^([A-Z][a-zA-Z0-9_]*\.)([a-zA-Z0-9_]+)$');
      final match = dotShorthandPattern.firstMatch(stringValue);
      if (match != null && !stringValue.contains('(')) {
        return '.${match.group(2)}';
      }

      return stringValue;
    }
  }
  return 'null';
}

String _sanitizeAttributeValue(String value) {
  return value
      .replaceAll('"', "'")
      .replaceAll("&", "&amp;")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _colorToHex(Color? color) {
  if (color == null) return 'null';

  final a = (color.a * 255).toInt().toRadixString(16).padLeft(2, '0');
  final r = (color.r * 255).toInt().toRadixString(16).padLeft(2, '0');
  final g = (color.g * 255).toInt().toRadixString(16).padLeft(2, '0');
  final b = (color.b * 255).toInt().toRadixString(16).padLeft(2, '0');

  return '#$a$r$g$b'.toUpperCase();
}

/// Checks if the current bounds match the parent bounds.
/// For relative bounds, this means the widget fills its parent exactly.
/// For absolute bounds, this means the bounds are identical.
bool _boundsMatchParent(Rect bounds, Rect parentBounds, int precision) {
  // Round values to the specified precision for comparison
  final boundsLeft = bounds.left.toStringAsFixed(precision);
  final boundsTop = bounds.top.toStringAsFixed(precision);
  final boundsWidth = bounds.width.toStringAsFixed(precision);
  final boundsHeight = bounds.height.toStringAsFixed(precision);

  final parentLeft = parentBounds.left.toStringAsFixed(precision);
  final parentTop = parentBounds.top.toStringAsFixed(precision);
  final parentWidth = parentBounds.width.toStringAsFixed(precision);
  final parentHeight = parentBounds.height.toStringAsFixed(precision);

  // Bounds match if position and size match parent
  return boundsLeft == parentLeft &&
      boundsTop == parentTop &&
      boundsWidth == parentWidth &&
      boundsHeight == parentHeight;
}

/// Checks if the current constraints match the parent constraints.
bool _constraintsMatchParent(
    BoxConstraints constraints, BoxConstraints parentConstraints) {
  return constraints.maxHeight == parentConstraints.maxHeight &&
      constraints.maxWidth == parentConstraints.maxWidth &&
      constraints.minHeight == parentConstraints.minHeight &&
      constraints.minWidth == parentConstraints.minWidth;
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
  final testFilePath = currentTestFilePath();

  if (options.filterByCreationLocation && !isWidgetCreationTracked()) {
    debugPrint(
      'widgetTreeMatchesGolden: widget creation tracking is disabled; '
      'falling back to full widget tree capture.',
    );
  }

  final focusScope = WidgetTreePackageIndex.resolveForTest(
    testFilePath: testFilePath,
    focusPackageOverride: options.focusPackage,
  );

  final context = WidgetTreeContext(
    options: options,
    tester: tester,
    focusScope: focusScope,
  );

  final testTree = createWidgetTree(
    tester.element(
        options.findWidget?.call(tester, widget) ?? find.byWidget(widget)),
    context: context,
  );

  // strip all information from the tree that is not relevant for the comparison
  // e.g. hash codes, keys, etc. that change between test runs
  final testTreeStripped = testTree?.toXmlString(
        boundsPrecision: options.boundsPrecision,
        parentBounds: null,
        parentConstraints: null,
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
  required WidgetTreeContext context,
}) {
  final nodes = _visitElement(e, context);
  if (nodes.isEmpty) {
    return null;
  }
  if (nodes.length == 1) {
    return nodes.first;
  }
  return WidgetTreeNode(
    e.widget,
    nodes,
    find.byElementPredicate((el) => el == e),
    bounds: _elementBounds(e, context),
    constraints: e.renderObject?.constraints,
  );
}

List<WidgetTreeNode> _visitElement(Element e, WidgetTreeContext context) {
  final widget = e.widget;
  final childNodes = <WidgetTreeNode>[];

  e.visitChildren((element) {
    childNodes.addAll(_visitElement(element, context));
  });

  final finder = find.byElementPredicate((el) => el == e);
  final type = widget.runtimeType.toString();
  final typeWithoutGeneric = type.split('<').first;
  final bounds = _elementBounds(e, context);
  // ignore: invalid_use_of_protected_member
  final constraints = e.renderObject?.constraints;

  final shouldStripIgnored = context.options.strippedWidgets.any((stripped) {
    if (stripped is Type) {
      return widget.runtimeType == stripped;
    }
    if (stripped is String) {
      return type == stripped || typeWithoutGeneric == stripped;
    }
    return false;
  });

  final shouldStripPrivate = context.options.stripPrivateWidgets &&
      type.startsWith('_') &&
      !context.isFocusCreated(e);

  if (shouldStripIgnored || shouldStripPrivate) {
    if (childNodes.isEmpty) {
      return [];
    }
    if (childNodes.length == 1) {
      return childNodes;
    }
    return [
      WidgetTreeNode(
        widget,
        childNodes,
        finder,
        bounds: bounds,
        constraints: constraints,
      ),
    ];
  }

  if (!context.useProvenanceFilter) {
    return [
      WidgetTreeNode(
        widget,
        childNodes,
        finder,
        bounds: bounds,
        constraints: constraints,
      ),
    ];
  }

  if (context.isFocusCreated(e)) {
    return [
      WidgetTreeNode(
        widget,
        childNodes,
        finder,
        bounds: bounds,
        constraints: constraints,
      ),
    ];
  }

  return childNodes;
}

Rect? _elementBounds(Element e, WidgetTreeContext context) {
  final finder = find.byElementPredicate((el) => el == e);
  return switch (context.options.includeWidgetBounds) {
    IncludeWidgetBounds.none => null,
    IncludeWidgetBounds.relative => () {
        final renderObject = e.renderObject;
        if (renderObject is RenderBox) {
          final pos = renderObject.localToGlobal(
            Offset.zero,
            ancestor: e.renderObject?.parent,
          );
          return Rect.fromLTWH(
            pos.dx,
            pos.dy,
            renderObject.size.width,
            renderObject.size.height,
          );
        }

        if (renderObject is RenderSliverList) {
          final constraints = renderObject.constraints;
          final geometry = renderObject.geometry;

          if (geometry != null && !geometry.visible) {
            return null;
          }

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
    IncludeWidgetBounds.absolute => context.tester.getRect(finder),
  };
}
