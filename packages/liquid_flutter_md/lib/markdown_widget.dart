import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

/// Decodes HTML entities produced by the `markdown` package (e.g. `&quot;`).
final _mdHtmlUnescape = HtmlUnescape();

final _markdownDocument = md.Document(extensionSet: md.ExtensionSet.gitHubWeb);

/// Parses [data] into markdown AST nodes using the same configuration as [LdMarkdown].
List<md.Node> parseMarkdownNodes(String data) => _markdownDocument.parse(data);

/// Returns a human-readable debug representation of the markdown AST for [data].
String formatMarkdownTree(String data) {
  final nodes = parseMarkdownNodes(data);
  if (nodes.isEmpty) {
    return '';
  }
  return nodes.map((node) => node.toDebugString()).join('\n');
}

extension MarkdownNodeDebug on md.Node {
  String toDebugString({int indent = 0}) {
    final indentString = ' ' * indent;

    if (this is md.Element) {
      final element = this as md.Element;
      final children =
          element.children
              ?.map((child) => child.toDebugString(indent: indent + 2))
              .join('\n') ??
          '';
      final attributes = element.attributes.isEmpty
          ? ''
          : ', attributes: ${element.attributes}';
      return '$indentString Element(tag: ${element.tag}$attributes, children: [\n$children\n$indentString])';
    } else if (this is md.Text) {
      final text = this as md.Text;
      return '$indentString Text(textContent: ${text.textContent})';
    } else if (this is md.UnparsedContent) {
      final unparsedContent = this as md.UnparsedContent;
      return '$indentString UnparsedContent(textContent: ${unparsedContent.textContent})';
    }
    return '$indentString $runtimeType(textContent: $textContent)';
  }
}

/// A custom markdown widget that renders markdown using Liquid Flutter components
class LdMarkdown extends StatelessWidget {
  final String data;
  final bool shrinkWrap;
  final EdgeInsets padding;

  const LdMarkdown({
    super.key,
    required this.data,
    this.shrinkWrap = true,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final nodes = parseMarkdownNodes(data);
    final widgets = markdownToWidgets(context, nodes);

    if (widgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: shrinkWrap
          ? LdAutoSpace(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
    );
  }
}

TextStyle _paragraphStyle(BuildContext context) {
  final theme = LdTheme.of(context);
  return ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m);
}

List<Widget> markdownToWidgets(BuildContext context, List<md.Node> nodes) {
  return nodes
      .map((node) => _nodeToBlockWidget(context, node))
      .whereType<Widget>()
      .toList();
}

Widget? _nodeToBlockWidget(BuildContext context, md.Node node) {
  if (node is md.Element) {
    return _elementToBlockWidget(context, node);
  }
  if (node is md.Text) {
    return _orphanTextWidget(context, node.textContent);
  }
  if (node is md.UnparsedContent) {
    return Text.rich(
      TextSpan(text: node.textContent, style: _paragraphStyle(context)),
    );
  }
  return null;
}

Widget _orphanTextWidget(BuildContext context, String text) {
  return Text.rich(
    TextSpan(
      text: _mdHtmlUnescape.convert(text),
      style: _paragraphStyle(context),
    ),
  );
}

Widget _elementToBlockWidget(BuildContext context, md.Element node) {
  final theme = LdTheme.of(context);

  return switch (node.tag) {
    'p' ||
    'h1' ||
    'h2' ||
    'h3' ||
    'h4' ||
    'h5' ||
    'h6' ||
    'em' ||
    'i' => buildText(context, node),

    'ul' => _buildList(context, node, ordered: false),
    'ol' => _buildList(context, node, ordered: true),

    'img' => Image.network(node.attributes['src'] ?? ''),

    'br' => ldSpacerL,
    'hr' => LdDivider(),

    'li' => _buildStandaloneListItem(context, node),

    'input' => LdCheckbox(checked: node.attributes['checked'] == 'true'),

    'strong' => Text.rich(
      TextSpan(
        style: _paragraphStyle(context),
        children: [buildTextSpan(context, node)],
      ),
    ),

    'pre' => LdBundle(
      children: [
        LdCard(
          child: _combineBlockWidgets(
            context,
            node.children ?? [],
          ),
        ),
      ],
    ),

    'code' => _MarkdownCode(
      code: node.textContent,
      language: node.attributes['class']?.split('-').lastOrNull ?? 'text',
    ),

    'blockquote' => LdCard(
      child: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: markdownToWidgets(context, node.children ?? []),
      ),
    ),

    'table' => LdCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: (node.children ?? [])
            .map((child) => _elementToBlockWidget(context, child as md.Element))
            .toList(),
      ),
    ),
    'tbody' => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: (node.children ?? [])
          .map((child) => _elementToBlockWidget(context, child as md.Element))
          .toList(),
    ),
    'thead' => LdAutoBackground(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: (node.children ?? [])
            .map((child) => _elementToBlockWidget(context, child as md.Element))
            .toList(),
      ),
    ),
    'th' || 'td' => Expanded(
      child: Padding(
        padding: theme.pad(size: LdSize.s),
        child: _tableCellContent(context, node),
      ),
    ),
    'tr' => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: (node.children ?? [])
          .map((child) => _elementToBlockWidget(context, child as md.Element))
          .toList(),
    ),

    'div' => switch (node.attributes['class']?.split(' ').firstOrNull) {
      'markdown-alert' => LdHint(
        type: switch (node.attributes['class']?.split('-').last) {
          'note' => LdHintType.info,
          'tip' => LdHintType.info,
          'important' => LdHintType.warning,
          'caution' => LdHintType.warning,
          'warning' => LdHintType.warning,
          _ => throw Exception(
            'Invalid hint type: ${node.attributes['class']?.split('-').last}',
          ),
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: markdownToWidgets(context, node.children ?? []),
        ),
      ),
      _ => SizedBox(
        width: double.infinity,
        child: _combineBlockWidgets(context, node.children ?? []),
      ),
    },

    _ => Text(node.tag),
  };
}

Widget _combineBlockWidgets(BuildContext context, List<md.Node> nodes) {
  final widgets = markdownToWidgets(context, nodes);
  return switch (widgets.length) {
    0 => const SizedBox.shrink(),
    1 => widgets.first,
    _ => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    ),
  };
}

Widget _tableCellContent(BuildContext context, md.Element cell) {
  final children = cell.children ?? [];
  if (children.isEmpty) {
    return const SizedBox.shrink();
  }

  if (children.length == 1 && children.first is md.Element) {
    final child = children.first as md.Element;
    if (child.tag == 'p') {
      return buildText(context, child);
    }
  }

  return Text.rich(
    TextSpan(
      style: _paragraphStyle(context),
      children: _inlineNodesToSpans(context, children),
    ),
  );
}

bool _listHasNestedLists(md.Element list) {
  for (final node in list.children ?? []) {
    if (node is! md.Element || node.tag != 'li') {
      continue;
    }
    for (final child in node.children ?? []) {
      if (child is md.Element && (child.tag == 'ul' || child.tag == 'ol')) {
        return true;
      }
    }
  }
  return false;
}

EdgeInsets _listPadding(BuildContext context, {required int indent}) {
  final theme = LdTheme.of(context);
  final step = theme.pad(size: LdSize.s.adjust(-1)).left;
  if (indent == 0) {
    return theme.pad(size: LdSize.s.adjust(-1)).copyWith(
      top: 0,
      bottom: 0,
      right: 0,
    );
  }
  // Each nested list adds one inset step relative to its parent item.
  return EdgeInsets.only(left: step);
}

Widget _buildList(
  BuildContext context,
  md.Element list, {
  required bool ordered,
  int indent = 0,
}) {
  if (_listHasNestedLists(list)) {
    return Padding(
      padding: _listPadding(context, indent: indent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < (list.children?.length ?? 0); i++)
            if (list.children![i] is md.Element)
              _buildNestedListItem(
                context,
                list.children![i] as md.Element,
                ordered: ordered,
                index: i,
                indent: indent,
              ),
        ],
      ),
    );
  }

  return Padding(
    padding: _listPadding(context, indent: indent),
    child: Text.rich(
      TextSpan(
        style: _paragraphStyle(context),
        children: _flatListSpans(context, list, ordered: ordered),
      ),
    ),
  );
}

List<InlineSpan> _flatListSpans(
  BuildContext context,
  md.Element list, {
  required bool ordered,
}) {
  final style = _paragraphStyle(context);
  final spans = <InlineSpan>[];
  var itemIndex = 0;

  for (final node in list.children ?? []) {
    if (node is! md.Element || node.tag != 'li') {
      continue;
    }

    if (itemIndex > 0) {
      spans.add(TextSpan(text: '\n', style: style));
    }

    spans.addAll(
      _listItemPrefixSpans(context, node, ordered: ordered, index: itemIndex),
    );
    spans.addAll(_listItemInlineSpans(context, node, style: style));
    itemIndex++;
  }

  return spans;
}

Widget _buildStandaloneListItem(BuildContext context, md.Element li) {
  return _buildNestedListItem(
    context,
    li,
    ordered: false,
    index: 0,
    indent: 0,
  );
}

Widget _buildNestedListItem(
  BuildContext context,
  md.Element li, {
  required bool ordered,
  required int index,
  required int indent,
}) {
  final style = _paragraphStyle(context);
  final inlineSpans = <InlineSpan>[
    ..._listItemPrefixSpans(context, li, ordered: ordered, index: index),
    ..._listItemInlineSpans(context, li, style: style),
  ];

  final nestedLists = <Widget>[];
  for (final child in li.children ?? []) {
    if (child is md.Element && (child.tag == 'ul' || child.tag == 'ol')) {
      nestedLists.add(
        _buildList(
          context,
          child,
          ordered: child.tag == 'ol',
          indent: indent + 1,
        ),
      );
    }
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text.rich(TextSpan(style: style, children: inlineSpans)),
      ...nestedLists,
    ],
  );
}

List<InlineSpan> _listItemPrefixSpans(
  BuildContext context,
  md.Element li, {
  required bool ordered,
  required int index,
}) {
  final theme = LdTheme.of(context);
  final style = _paragraphStyle(context);
  final input = li.children?.whereType<md.Element>().firstWhereOrNull(
    (e) => e.tag == 'input',
  );

  if (input != null) {
    return [
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: EdgeInsets.only(right: theme.pad(size: LdSize.xs).right),
          child: LdCheckbox(checked: input.attributes['checked'] == 'true'),
        ),
      ),
    ];
  }

  final prefix = ordered ? '${index + 1}.' : '•';
  return [
    TextSpan(text: prefix, style: style),
    TextSpan(text: ' ', style: style),
  ];
}

List<InlineSpan> _listItemInlineSpans(
  BuildContext context,
  md.Element li, {
  required TextStyle style,
}) {
  final spans = <InlineSpan>[];
  var paragraphIndex = 0;

  for (final child in li.children ?? []) {
    if (child is md.Element) {
      switch (child.tag) {
        case 'input':
        case 'ul':
        case 'ol':
          continue;
        case 'p':
          if (paragraphIndex > 0) {
            spans.add(TextSpan(text: '\n', style: style));
          }
          spans.addAll(_inlineNodesToSpans(context, child.children ?? []));
          paragraphIndex++;
        default:
          spans.add(buildTextSpan(context, child));
      }
    } else {
      spans.add(buildTextSpan(context, child));
    }
  }

  return spans;
}

List<InlineSpan> _inlineNodesToSpans(
  BuildContext context,
  List<md.Node> nodes,
) {
  return nodes.map((node) => buildTextSpan(context, node)).toList();
}

class _MarkdownCode extends StatelessWidget {
  final String code;
  final String language;
  const _MarkdownCode({required this.code, required this.language});

  @override
  Widget build(BuildContext context) {
    return Text(
      _mdHtmlUnescape.convert(code),
      style: const TextStyle(fontFamily: 'monospace'),
    );
  }
}

Widget buildText(BuildContext context, md.Element text) {
  final theme = LdTheme.of(context);
  final (paddingTop, paddingBottom) = switch (text.tag) {
    'h1' => (LdSize.l, LdSize.s),
    'h2' => (LdSize.l, LdSize.s),
    'h3' => (LdSize.m, LdSize.s),
    'h4' => (LdSize.s, LdSize.xs),
    'h5' => (LdSize.s, LdSize.xs),
    'h6' => (LdSize.xs, LdSize.s),
    _ => (null, null),
  };
  final padding = EdgeInsets.only(
    top: paddingTop != null ? theme.pad(size: paddingTop).top : 0,
    bottom: paddingBottom != null ? theme.pad(size: paddingBottom).bottom : 0,
  );
  return Padding(
    padding: padding,
    child: Text.rich(
      TextSpan(
        children: _inlineNodesToSpans(context, text.children ?? []),
        style: switch (text.tag) {
          'p' => ldBuildTextStyle(theme, LdTextType.paragraph, LdSize.m),
          'h1' => ldBuildTextStyle(theme, LdTextType.headline, LdSize.l),
          'h2' => ldBuildTextStyle(theme, LdTextType.headline, LdSize.m),
          'h3' => ldBuildTextStyle(theme, LdTextType.headline, LdSize.s),
          'h4' => ldBuildTextStyle(theme, LdTextType.headline, LdSize.xs),
          'h5' => ldBuildTextStyle(theme, LdTextType.headline, LdSize.xs),
          'h6' => ldBuildTextStyle(theme, LdTextType.headline, LdSize.xs),
          'em' || 'i' => TextStyle(fontStyle: FontStyle.italic),
          _ => throw Exception('Invalid text type: ${text.tag}'),
        },
      ),
    ),
  );
}

InlineSpan buildTextSpan(BuildContext context, md.Node node) {
  if (node is md.Text) {
    return TextSpan(text: _mdHtmlUnescape.convert(node.textContent));
  }
  if (node is md.UnparsedContent) {
    return TextSpan(text: node.textContent);
  }
  if (node is md.Element) {
    final theme = LdTheme.of(context);
    final children =
        node.children?.map((e) => buildTextSpan(context, e)).toList() ?? [];
    return switch (node.tag) {
      'strong' => TextSpan(
        children: children,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      'em' || 'i' => TextSpan(
        children: children,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      'a' => TextSpan(
        children: children,
        mouseCursor: SystemMouseCursors.click,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrl(Uri.parse(node.attributes['href'] ?? ''));
          },
        style: TextStyle(color: theme.primaryColor),
      ),
      'code' => TextSpan(
        children: children,
        text: children.isEmpty ? _mdHtmlUnescape.convert(node.textContent) : null,
        style: TextStyle(
          fontFamily: 'monospace',
          background: Paint()..color = theme.surface,
        ),
      ),
      'br' => const TextSpan(text: '\n'),
      'p' => TextSpan(children: children),
      _ => TextSpan(children: children),
    };
  }
  return TextSpan(text: _mdHtmlUnescape.convert(node.textContent));
}
