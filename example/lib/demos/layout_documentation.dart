import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/components_accordion.dart';
import 'package:liquid/demos/spacing_padding_documentation.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LayoutDocumentation extends StatelessWidget {
  const LayoutDocumentation({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ComponentPage(
        apiComponents: [
          "LdAutoSpace",
          "LdSpacer",
          "LdContainer",
        ],
        title: "Layout & Tokens",
        demo: LdAutoSpace(children: [
          LdBundle(
            children: [
              LdTextP(
                  "To create consistent layouts, Liquid provides a set of predefined components."),
              LdTextHs("🦄 LdAutoSpace"),
              ComponentsAccordion(components: {"LdAutoSpace", "LdBundle"}),
              MarkdownBody(
                data:
                    "`LdAutoSpace` is a widget that can be used to create consistent spacing between its children. It will automatically space its children based on the theme's spacing values and the type of children",
              ),
              CodeBlock(code: """
                    LdAutoSpace(
                      children: [
                        LdTextHm("Hello World"),
                        LdTextP("This is a paragraph"),
                        LdBundle(
                          children: [
                            LdTextP("This is a bundle"),
                            LdTextP("It will auto space its children and create more space around itself"),
                          ],
                        )
                      ],
                    );
                  """),
            ],
          ),
          LdBundle(
            children: [
              LdTextHs("🖥️ LdContainer"),
              ComponentsAccordion(components: {"LdContainer"}),
              MarkdownBody(
                  data:
                      "`LdContainer` is a widget that centers content on large screens (like this page if you're on a desktop). It will allow a width of 1200 by default (configurable using the `maxWidth` parameter)."),
            ],
          ),
          SpacingPaddingDocumentation(),
        ]));
  }
}
