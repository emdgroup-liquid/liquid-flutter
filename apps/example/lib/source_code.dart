import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/solarized-light.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class SourceCode extends StatelessWidget {
  final String code;
  final String language;
  final EdgeInsets? padding;

  const SourceCode({super.key, required this.code, this.language = "dart", this.padding});

  static String _reduceIndent(String code) {
    double minIndent = double.infinity;
    for (final line in code.split("\n")) {
      if (line.trim().isEmpty) continue;
      final indent = line.length - line.trimLeft().length;
      if (indent < minIndent) minIndent = indent.toDouble();
    }

    final lines = code.split("\n");
    for (var i = 0; i < lines.length; i++) {
      lines[i] = lines[i].substring(min(minIndent.toInt(), lines[i].length));
    }
    return lines.join("\n");
  }

  @override
  Widget build(BuildContext context) {
    final ldTheme = LdTheme.of(context, listen: true);
    final isDark = ldTheme.isDark;

    final baseTheme = isDark ? atomOneDarkTheme : solarizedLightTheme;
    // Override root background so it's transparent — the parent LdCard provides the surface.
    final highlightTheme = {
      ...baseTheme,
      'root': (baseTheme['root'] ?? const TextStyle()).copyWith(
        backgroundColor: Colors.transparent,
        color: ldTheme.text,
      ),
    };

    final fontSize = ldTheme.paragraphSize(LdSize.s);

    return HighlightView(
      _reduceIndent(code),
      language: language,
      theme: highlightTheme,
      padding: padding,
      textStyle: TextStyle(fontFamily: ldTheme.monoFontFamily, package: ldTheme.monoFontFamilyPackage, fontSize: fontSize, height: 1.5),
    );
  }
}
