import 'package:flutter/material.dart';
import 'package:liquid/demos/layout_documentation.dart';
import 'package:liquid/demos/radius_documentation.dart';
import 'package:liquid/demos/spacing_padding_documentation.dart';
import 'package:liquid/demos/typography_documentation.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import '../components/component_page.dart';

class TokensDemo extends StatelessWidget {
  const TokensDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        title: "Layout & Tokens",
        demo: Column(
          children: [
            LdAccordion.fromList(
              [
                LdAccordionItem(
                    header: const Text("Layout"),
                    child: const LayoutDocumentation()),
                LdAccordionItem(
                  header: const Text("Spacing & Padding"),
                  child: const SpacingPaddingDocumentation(),
                ),
                LdAccordionItem(
                    child: const RadiusDocumentation(),
                    header: const Text("Border Radius")),
                LdAccordionItem(
                    child: const TypographyDocumentation(),
                    header: const Text("Typography")),
              ],
              elevateActive: true,
            ),
            const SpacingPaddingDocumentation(),
          ],
        ));
  }
}

class SpacerVisualizer extends StatelessWidget {
  final Widget child;
  final LdSpacer spacer;
  const SpacerVisualizer({
    required this.child,
    required this.spacer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final size = theme.paddingSize(size: spacer.size);

    return Column(
      children: [
        Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
                border: Border.all(color: theme.border),
                borderRadius: theme.radius(LdSize.s),
                color: theme.surface),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: theme.surface,
                  child: spacer,
                ),
              ],
            )),
        child,
        LdTextPs(
          "Size: $size",
        ),
      ],
    );
  }
}
