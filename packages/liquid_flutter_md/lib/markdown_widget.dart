import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

/// Decodes HTML entities produced by the `markdown` package (e.g. `&quot;`).
final _mdHtmlUnescape = HtmlUnescape();

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

    // Parse markdown
    final document = md.Document(extensionSet: md.ExtensionSet.gitHubWeb);

    final nodes = document.parse(data);

    // Build widgets using visitor

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

List<Widget> markdownToWidgets(BuildContext context, List<md.Node> nodes) {
  final widgets = <Widget>[];

  final theme = LdTheme.of(context);
  for (final node in nodes) {
    if (node is md.Element) {
      final childrenWidgets = markdownToWidgets(context, node.children ?? []);
      final child = switch (childrenWidgets.length) {
        0 => const SizedBox.shrink(),
        1 => childrenWidgets.first,
        _ => Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          runSpacing: theme.pad(size: LdSize.xs).vertical,
          children: childrenWidgets,
        ),
      };
      widgets.add(switch (node.tag) {
        'p' ||
        'h1' ||
        'h2' ||
        'h3' ||
        'h4' ||
        'h5' ||
        'h6' ||
        'em' ||
        'i' => buildText(context, node),

        'ul' => LdBundle(
          children: childrenWidgets
              .map(
                (e) => Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•'),
                      SizedBox(width: 4),
                      Expanded(child: e),
                    ],
                  ),
                ),
              )
              .toList(),
        ),

        'img' => Image.network(node.attributes['src'] ?? ''),
        'ol' => LdBundle(
          children: childrenWidgets
              .mapIndexed(
                (index, e) => Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}.'),
                      SizedBox(width: 4),
                      Flexible(child: e),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
        'br' => ldSpacerL,
        'hr' => LdDivider(),
        'li' => child,
        'input' => LdCheckbox(checked: node.attributes['checked'] == 'true'),

        'strong' => DefaultTextStyle(
          style: TextStyle(fontWeight: FontWeight.bold),
          child: child,
        ),
        'pre' => LdBundle(children: [LdCard(child: child)]),
        'code' => _MarkdownCode(
          code: node.textContent,
          language: node.attributes['class']?.split('-').lastOrNull ?? 'text',
        ),
        'blockquote' => LdCard(
          child: LdAutoSpace(
            children: markdownToWidgets(context, node.children ?? []),
          ),
        ),

        'table' => LdCard(
          padding: EdgeInsets.zero,
          child: Column(children: [...childrenWidgets]),
        ),
        'tbody' => Column(children: childrenWidgets),
        'thead' => LdAutoBackground(child: Column(children: childrenWidgets)),
        'th' || 'td' => Expanded(
          child: Padding(
            padding: theme.pad(size: LdSize.s),
            child: child,
          ),
        ),
        'tr' => Row(children: childrenWidgets),

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
              children: childrenWidgets,
            ),
          ),
          _ => SizedBox(width: double.infinity, child: child),
        },

        _ => Text(node.tag),
      });
    } else if (node is md.Text) {
      //print('text: ${node.textContent}');
      widgets.add(Text(_mdHtmlUnescape.convert(node.textContent)));
    } else if (node is md.UnparsedContent) {
      // print('unparsedContent: ${node.textContent}');
      widgets.add(Text(node.textContent));
    }
  }
  return widgets;
}

class _MarkdownCode extends StatefulWidget {
  final String code;
  final String language;
  const _MarkdownCode({required this.code, required this.language});

  @override
  State<_MarkdownCode> createState() => _MarkdownCodeState();
}

class _MarkdownCodeState extends State<_MarkdownCode> {
  TextSpan highlightedCode = TextSpan();
  Highlighter? highlighter;
  @override
  void initState() {
    super.initState();
    _loadHighlighter();
  }

  void _loadHighlighter() async {
    final theme = await (LdTheme.of(context).isDark
        ? HighlighterTheme.loadDarkTheme()
        : HighlighterTheme.loadLightTheme());
    await Highlighter.initialize([widget.language]);

    highlighter = Highlighter(language: widget.language, theme: theme);
    highlightedCode =
        highlighter?.highlight(_mdHtmlUnescape.convert(widget.code)) ??
        TextSpan();
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant _MarkdownCode oldWidget) {
    if (oldWidget.code != widget.code) {
      highlightedCode =
          highlighter?.highlight(_mdHtmlUnescape.convert(widget.code)) ??
          TextSpan();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.language.isEmpty || widget.language == 'text') {
      return Text(widget.code);
    }
    return Text.rich(highlightedCode);
  }
}
/* 
extension on md.Node {
  String toStringHuman({int indent = 0}) {
    final indentString = ' ' * indent;

    if (this is md.Element) {
      final element = this as md.Element;
      final children =
          element.children
              ?.map((e) => e.toStringHuman(indent: indent + 2))
              .join('\n') ??
          '';
      return '$indentString Element(tag: ${element.tag}, attributes: ${element.attributes}, children: [\n$children\n$indentString])';
    } else if (this is md.Text) {
      final text = this as md.Text;
      return '$indentString Text(textContent: ${text.textContent})';
    } else if (this is md.UnparsedContent) {
      final unparsedContent = this as md.UnparsedContent;
      return '$indent StringUnparsedContent(textContent: ${unparsedContent.textContent})';
    }
    return '$indentString Text(textContent: $textContent)';
  }
} */

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
        children: [
          ...text.children?.map((e) => buildTextSpan(context, e)).toList() ??
              [],
        ],
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

TextSpan buildTextSpan(BuildContext context, md.Node node) {
  if (node is md.Text) {
    return TextSpan(text: _mdHtmlUnescape.convert(node.textContent));
  } else if (node is md.Element) {
    final theme = LdTheme.of(context);
    final children =
        node.children?.map((e) => buildTextSpan(context, e)).toList() ?? [];
    return switch (node.tag) {
      'strong' => TextSpan(
        children: [...children],
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      'em' || 'i' => TextSpan(
        children: [...children],
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      'a' => TextSpan(
        children: [...children],
        mouseCursor: SystemMouseCursors.click,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launchUrl(Uri.parse(node.attributes['href'] ?? ''));
          },
        style: TextStyle(color: theme.primaryColor),
      ),
      'code' => TextSpan(
        children: [...children],
        style: TextStyle(
          fontFamily: 'monospace',
          background: Paint()..color = theme.surface,
        ),
      ),
      _ => TextSpan(children: children),
    };
  }
  return TextSpan(text: _mdHtmlUnescape.convert(node.textContent));
}
