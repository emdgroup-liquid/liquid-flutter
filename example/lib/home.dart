import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';

import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return LdScaffoldBody(
      addContainer: true,
      children: [
        LdAutoSpace(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(borderRadius: theme.radius(LdSize.m)),
                  clipBehavior: Clip.hardEdge,
                  child: Image.asset("liquid_flutter_icon.jpg", width: 48, height: 48),
                ),
                ldSpacerM,
                Flexible(
                  child: LdAutoSpace(
                    children: [
                      LdText.hl(
                        "Liquid Flutter",
                      ),
                      LdText.l(
                        "Cross platform design system for Flutter.",
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                LdTag(
                  child: Text("Web"),
                ),
                LdTag(
                  child: Text("MacOS"),
                ),
                LdTag(
                  child: Text("Windows"),
                ),
                LdTag(
                  child: Text("Linux"),
                ),
                LdTag(
                  child: Text("Android"),
                ),
                LdTag(
                  child: Text("iOS"),
                ),
              ],
            ),
            LdText.p(
              "Liquid Flutter is a Flutter implementation of the liquid "
              "design system used at EMD. "
              "It is designed to be used in desktop and mobile applications."
              " While the design system is licensed under Apache 2.0 please "
              "note that EMD Branding elements are provided with a"
              "proprietary license.",
            ),
            const LdDivider(),
            ldSpacerL,
            LdText.hs("Demos"),
            Wrap(spacing: 8, runSpacing: 8, children: [
              LdButton(
                  mode: LdButtonMode.outline,
                  trailing: const Icon(LucideIcons.arrowRight),
                  onPressed: () {
                    context.go("/chemical");
                  },
                  child: const Text("Chemical Inventory")),
              LdButton(
                mode: LdButtonMode.outline,
                trailing: const Icon(LucideIcons.arrowRight),
                onPressed: () {
                  context.go("/task-demo");
                },
                child: const Text("Task Demo"),
              ),
              LdButton(
                mode: LdButtonMode.outline,
                trailing: const Icon(LucideIcons.arrowRight),
                onPressed: () {
                  context.go("/components/bento-gallery");
                },
                child: const Text("Widget Gallery"),
              ),
            ]),
            const LdDivider(),
            LdText.h("Getting Started"),
            LdText.p(
              "To get started using liquid flutter please add it as a dependency to your project:",
            ),
            const CodeBlock(
              language: "sh",
              code: """flutter pub add liquid_flutter""",
            ),
            LdAccordion.fromList(
              [
                LdAccordionItem(
                    child: const CodeBlock(
                      language: "sh",
                      code: """
                flutter pub add liquid_flutter_emd_theme
                """,
                    ),
                    header: const Text("EMD Corporate theme installation"))
              ],
              wrapActiveInCard: true,
            ),
            LdText.p(
                "Setup a Liquid Theme at the top of your application. This will  be used to provide the color theme to all components via context."),
            const CodeBlock(
              code: """
                LdThemeProvider(
                  theme: // Optionally provide an instance of LdTheme(),
                  child: ...
                )""",
            ),
            LdText.p(
                "To automatically keep the material theme in sync with the Liquid theme use the LdThemedAppBuilder. This will also rebuild the entire app in case you change the liquid theme at runtime."),
            const CodeBlock(
              code: """
                LdThemeProvider(
                  child: LdThemedAppBuilder(appBuilder: (context, theme) {
                    return MaterialApp(
                      title: 'Liquid Design Demo',
                      theme: theme,
                    );
                  })
                )""",
            ),
            LdText.p(
                "You can now also access the Liquid theme via the LdTheme.of(context) method. This will return the LdTheme object which contains all the colors and other theme related properties."),
            const CodeBlock(
              code: """var theme = LdTheme.of(context);""",
            ),
            LdText.p(
              "You can now use the components in your app. Please refer to the documentation for more information.",
            ),
          ],
        )
      ],
    );
  }
}
