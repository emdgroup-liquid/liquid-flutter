import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdColorSwatches extends StatelessWidget {
  final LdColor color;
  const LdColorSwatches({super.key, required this.color});

  _buildSwatch(
    Color a,
    Color b,
    Color background,
    BuildContext context,
  ) {
    final theme = LdTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.border,
              width: 2,
            ),
            borderRadius: theme.radius(LdSize.m),
            color: background,
          ),
          padding: theme.pad(),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: a,
              borderRadius: theme.radius(LdSize.m),
            ),
            child: Center(
              child: Text(
                "A",
                style: TextStyle(color: b, height: 1),
              ),
            ),
          ),
        ),
        ldSpacerS,
        const LdText("SF/TX:"),
        _colorContrast(_calcContrast(a, b), context, 4.5),
        const LdText("SF/BG: "),
        _colorContrast(_calcContrast(a, background), context, 3),
        //Text("T/B: " + _calcContrast(b, background).toStringAsFixed(1))
      ],
    );
  }

  double _calcContrast(Color a, Color b) {
    final luminanceA = a.computeLuminance();
    final luminanceB = b.computeLuminance();
    final darkest = min(luminanceA, luminanceB);
    final lightest = max(luminanceA, luminanceB);
    return (lightest + 0.05) / (darkest + 0.05);
  }

  LdTag _colorContrast(
      double contrast, BuildContext context, double threshold) {
    if (contrast >= threshold) {
      return LdTag(
          color: LdTheme.of(context).palette.success,
          size: LdSize.s,
          child: Text("1:${contrast.toStringAsFixed(1)}"));
    }
    return LdTag(
        color: LdTheme.of(context).palette.error,
        size: LdSize.s,
        child: Text("1:${contrast.toStringAsFixed(1)}"));
  }

  @override
  Widget build(BuildContext context) {
    final lightBg = LdTheme.of(context).palette.neutral.shades.first;
    final darkBg = LdTheme.of(context).palette.neutral.shades.last;
    final theme = LdTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: LdTheme.of(context).pad(),
            decoration: BoxDecoration(
              border: Border.all(color: theme.border, width: 2),
              borderRadius: theme.radius(LdSize.m),
            ),
            child: DefaultTextStyle(
                style: const TextStyle(color: Colors.black),
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  spacing: 8,
                  children: [
                    Column(
                      children: [
                        const LdText("Idle"),
                        ldSpacerS,
                        _buildSwatch(
                          color.idle(false),
                          color.contrastingText(color.idle(false)),
                          lightBg,
                          context,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const LdText("Hover"),
                        ldSpacerS,
                        _buildSwatch(
                          color.hover(false),
                          color.contrastingText(color.hover(false)),
                          lightBg,
                          context,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const LdText("Active"),
                        ldSpacerS,
                        _buildSwatch(
                          color.active(false),
                          color.contrastingText(color.active(false)),
                          lightBg,
                          context,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const LdText("Focus"),
                        ldSpacerS,
                        _buildSwatch(
                          color.focus(false),
                          color.contrastingText(color.focus(false)),
                          lightBg,
                          context,
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        ),
        ldSpacerM,
        Expanded(
          child: Container(
            padding: LdTheme.of(context).pad(),
            decoration: BoxDecoration(
              border: Border.all(color: LdTheme.of(context).border, width: 2),
              borderRadius: theme.radius(LdSize.m),
              color: darkBg,
            ),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 8,
                children: [
                  Column(
                    children: [
                      const Text("Idle"),
                      ldSpacerS,
                      _buildSwatch(
                        color.idle(true),
                        color.contrastingText(color.idle(true)),
                        darkBg,
                        context,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Hover"),
                      ldSpacerS,
                      _buildSwatch(
                        color.hover(true),
                        color.contrastingText(color.hover(true)),
                        darkBg,
                        context,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Active"),
                      ldSpacerS,
                      _buildSwatch(
                        color.active(true),
                        color.contrastingText(color.active(true)),
                        darkBg,
                        context,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Focus"),
                      ldSpacerS,
                      _buildSwatch(
                        color.focus(true),
                        color.contrastingText(color.focus(true)),
                        darkBg,
                        context,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
