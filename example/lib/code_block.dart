import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:syntax_highlight/syntax_highlight.dart';

class CodeBlock extends StatefulWidget {
  final String code;
  final String language;

  const CodeBlock({Key? key, required this.code, this.language = "dart"})
      : super(key: key);

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  HighlighterTheme? theme;
  HighlighterTheme? themeDark;

  final int maxLines = 10;
  late int lines;

  @override
  void initState() {
    lines = widget.code.trim().split("\n").length;
    loadHighlighter();
    super.initState();
  }

  String reduceIndent(String code, bool expanded) {
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

    if (expanded) return lines.join("\n");

    return lines.sublist(0, min(lines.length, maxLines)).join("\n");
  }

  void loadHighlighter() async {
    theme = await HighlighterTheme.loadLightTheme();
    themeDark = await HighlighterTheme.loadFromAssets(
        ["assets/dark_plus.json", "assets/dark_vs.json"],
        TextStyle(
          fontFamily: "NotoSansMono",
          color: Colors.white,
          fontSize: LdTheme.of(context).paragraphSize(LdSize.s),
        ));
    if (mounted) {
      setState(() {});
    }
  }

  bool expanded = false;

  void toggleExpanded() {
    setState(() {
      expanded = !expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (theme == null) return const SizedBox();

    final code = reduceIndent(widget.code, expanded);

    var highlighter = Highlighter(
      language: widget.language,
      theme: themeDark!,
    );
    final highlightedCode = highlighter.highlight(code.trim());
    return LayoutBuilder(
      builder: (context, _) => LdCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: LdTheme.of(context).palette.neutral.shades.last,
              ),
              child: AnimatedSize(
                duration: 0.2.seconds,
                child: IntrinsicHeight(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: LdTheme.of(context).pad(size: LdSize.m),
                        child: SelectableRegion(
                          focusNode: FocusNode(),
                          selectionControls: materialTextSelectionControls,
                          child: Text.rich(
                            highlightedCode,
                          ),
                        ),
                      ),
                      if (lines > maxLines)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: LdTouchableSurface(
                            color: shadSky,
                            mode: LdTouchableSurfaceMode.solid,
                            onTap: toggleExpanded,
                            builder: (context, colors, status) =>
                                AnimatedContainer(
                              duration: 300.ms,
                              padding: EdgeInsets.only(
                                top: expanded
                                    ? 8
                                    : status.hovering
                                        ? 32
                                        : 16,
                                bottom: expanded
                                    ? 8
                                    : status.hovering
                                        ? 32
                                        : 16,
                              ),
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RotatedBox(
                                      quarterTurns: expanded ? 1 : -1,
                                      child: Icon(
                                        Icons.chevron_left,
                                        color: colors.text,
                                        size: 16,
                                      )),
                                  Text(expanded ? "Show less" : "Show more",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: colors.text,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    colors.surface.withOpacity(0),
                                    colors.surface.withOpacity(0.9),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (kIsWeb ||
                Platform.isWindows ||
                Platform.isMacOS ||
                Platform.isLinux)
              Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LdButton(
                      color: shadSky,
                      size: LdSize.s,
                      mode: LdButtonMode.outline,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        LdNotificationsController.of(context).addNotification(
                          LdNotification(
                              message: "Copied to clipboard",
                              type: LdNotificationType.success),
                        );
                      },
                      child: const Text("Copy"),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
