import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

class SourceCode extends StatefulWidget {
  final String code;
  final String language;
  final EdgeInsets? padding;

  const SourceCode({super.key, required this.code, this.language = "dart", this.padding});

  @override
  State<SourceCode> createState() => _SourceCodeState();
}

class _SourceCodeState extends State<SourceCode> {
  HighlighterTheme? theme;
  HighlighterTheme? themeDark;

  @override
  void initState() {
    _loadHighlighter();
    super.initState();
  }

  void _loadHighlighter() async {
    final ldTheme = LdTheme.of(context);
    theme = await HighlighterTheme.loadLightTheme();
    themeDark = await HighlighterTheme.loadFromAssets(
        ["assets/dark_plus.json", "assets/dark_vs.json"],
        TextStyle(
          fontFamily: "NotoSansMono",
          color: ldTheme.palette.neutral.shades.last,
          fontSize: ldTheme.paragraphSize(LdSize.s),
        ));
    if (mounted) {
      setState(() {});
    }
  }

  String reduceIndent(String code) {
    double minIndent = double.infinity;
    for (final line in code.split("\n")) {
      if (line.trim().isEmpty) {
        continue;
      }
      final indent = line.length - line.trimLeft().length;
      if (indent < minIndent) {
        minIndent = indent.toDouble();
      }
    }

    // Remove the minimum indent from all lines
    final lines = code.split("\n");
    for (var i = 0; i < lines.length; i++) {
      lines[i] = lines[i].substring(min(minIndent.toInt(), lines[i].length));
    }

    return lines.join("\n");
  }

  @override
  Widget build(BuildContext context) {
    if (theme == null) return const SizedBox();

    final code = reduceIndent(widget.code);

    var highlighter = Highlighter(
      language: widget.language,
      theme: themeDark!,
    );

    final highlightedCode = highlighter.highlight(code);

    return Container(
      width: double.infinity,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: LdTheme.of(context).palette.neutral.shades.last,
      ),
      child: SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: materialTextSelectionControls,
        child: Text.rich(highlightedCode),
      ),
    );
  }
}
