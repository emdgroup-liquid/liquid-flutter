import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class RadiusDocumentation extends StatelessWidget {
  const RadiusDocumentation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return ComponentPage(
      title: "Border Radius",
      demo: LdAutoSpace(children: [
        const LdTextP(
          "Predefined border radii that can be used to create rounded corners. In general liquid does not contain sharp corners.",
        ),
        LdCard(
          padding: LdTheme.of(context).pad(size: LdSize.l) * 2,
          child: Wrap(
            runAlignment: WrapAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 32,
            runSpacing: 8,
            children: [
              BorderRadiusVisualizer(
                radius: theme.radius(LdSize.xs),
                child: const Text("theme.radius(LdSize.xs)"),
              ),
              BorderRadiusVisualizer(
                radius: theme.radius(LdSize.s),
                child: const Text("theme.radius(LdSize.s) "),
              ),
              BorderRadiusVisualizer(
                radius: theme.radius(LdSize.m),
                child: const Text("theme.radius(LdSize.m)d"),
              ),
              BorderRadiusVisualizer(
                radius: theme.radius(LdSize.l),
                child: const Text("theme.radius(LdSize.l)g"),
              ),
            ],
          ),
        ),
        const Text(
            "You can access the raw sizes using the following constants:"),
        const CodeBlock(code: """
        const theme.radius(LdSize.xs)Size = 2.0;
        const ldRadiusSSize = 4.0;
        const theme.radius(LdSize.m)Size = 8.0;
        const theme.radius(LdSize.l)Size = 16.0;"""),
      ]),
    );
  }
}

class BorderRadiusVisualizer extends StatelessWidget {
  final BorderRadius radius;
  final Widget child;
  const BorderRadiusVisualizer({
    required this.radius,
    required this.child,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              border: Border.all(color: LdTheme.of(context).border),
              borderRadius: radius,
              color: LdTheme.of(context).background),
        ),
        LdTextPs(radius.topLeft.toString()),
        ldSpacerS,
        DefaultTextStyle(
          style: ldBuildTextStyle(
            LdTheme.of(context),
            LdTextType.label,
            LdSize.m,
          ),
          child: child,
        )
      ],
    );
  }
}
