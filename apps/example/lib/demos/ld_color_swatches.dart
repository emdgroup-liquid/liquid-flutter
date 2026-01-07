import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdColorSwatches extends StatelessWidget {
  final LdColor color;
  const LdColorSwatches({super.key, required this.color});

  Widget _buildSwatch(Color a, Color b, Color background, BuildContext context) {
    final theme = LdTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.border, width: 2),
            borderRadius: theme.radius(LdSize.m),
            color: background,
          ),
          padding: theme.pad(),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(color: a, borderRadius: theme.radius(LdSize.m)),
            child: Center(
              child: Text("A", style: TextStyle(color: b, height: 1)),
            ),
          ),
        ),
        ldSpacerS,
        const LdText("Text"),
        LdMute(child: LdText.ls("WCAG AA >=4.5")),
        ldSpacerS,
        _colorContrast(_calcContrast(a, b), context, 4.5),
        ldSpacerM,
        const LdText("Background"),
        LdMute(child: LdText.ls("WCAG AA >=3.0")),
        ldSpacerS,
        _colorContrast(_calcContrast(a, background), context, 3),
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

  LdTag _colorContrast(double contrast, BuildContext context, double threshold) {
    if (contrast >= threshold) {
      return LdTag(
        color: LdTheme.of(context).palette.success,
        size: LdSize.m,
        child: Text("1:${contrast.toStringAsFixed(1)}"),
      );
    }
    return LdTag(
      color: LdTheme.of(context).palette.error,
      size: LdSize.m,
      child: Text("1:${contrast.toStringAsFixed(1)}"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = LdTheme.of(context).background;
    final isDark = LdTheme.of(context).isDark;

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
                      const LdText("Focus"),
                      ldSpacerS,
                      _buildSwatch(
                        color.focus(isDark),
                        color.contrastingText(color.focus(isDark)),
                        background,
                        context,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const LdText("Idle"),
                      ldSpacerS,
                      _buildSwatch(color.idle(isDark), color.contrastingText(color.idle(isDark)), background, context),
                    ],
                  ),
                  Column(
                    children: [
                      const LdText("Hover"),
                      ldSpacerS,
                      _buildSwatch(
                        color.hover(isDark),
                        color.contrastingText(color.hover(isDark)),
                        background,
                        context,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const LdText("Active"),
                      ldSpacerS,
                      _buildSwatch(
                        color.active(isDark),
                        color.contrastingText(color.active(isDark)),
                        background,
                        context,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const LdText("Disabled"),
                      ldSpacerS,
                      _buildSwatch(
                        color.disabled(isDark).center(isDark),
                        color.contrastingText(color.disabled(isDark).center(isDark)),
                        background,
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
