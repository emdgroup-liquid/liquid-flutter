import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class TextListDocumentation extends StatelessWidget {
  const TextListDocumentation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const ComponentPage(
      path: "lib/demos/text_list_documentation.dart",
      title: "Text Lists",
      apiComponents: [
        "LdTextList",
      ],
      demo: LdAutoSpace(
        children: [
          LdTextP(
            "LdTextList allows you to create bulleted or enumerated lists using paragraph text typography.",
          ),
          CodeBlock(
            code: """
LdTextList(
  ['Item 1', 'Item 2', 'Item 3'],
  type: LdTextListType.bulleted,
);
""",
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdTextL("Bulleted List"),
                LdTextList(
                  [
                    "First bullet point with some longer text to demonstrate wrapping",
                    "Second bullet point",
                    "Third bullet point with even more text to show how the widget handles longer content",
                  ],
                  type: LdTextListType.bulleted,
                ),
              ],
            ),
          ),
          CodeBlock(
            code: """
LdTextList(
  ['First item', 'Second item', 'Third item'],
  type: LdTextListType.enumerated,
);
""",
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdTextL("Enumerated List"),
                LdTextList(
                  [
                    "First numbered item",
                    "Second numbered item with additional text",
                    "Third numbered item",
                  ],
                  type: LdTextListType.enumerated,
                ),
              ],
            ),
          ),
          LdTextP(
              "You can customize the size, color, and other text properties:"),
          CodeBlock(
            code: """
LdTextList(
  ['Custom styled item'],
  size: LdSize.l,
  color: Colors.blue,
  fontWeight: FontWeight.bold,
);
""",
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdTextL("Different Sizes"),
                LdTextList(
                  ["Small size item"],
                  size: LdSize.s,
                ),
                LdTextList(
                  ["Medium size item (default)"],
                  size: LdSize.m,
                ),
                LdTextList(
                  ["Large size item"],
                  size: LdSize.l,
                ),
              ],
            ),
          ),
          LdTextP(
              "The widget also supports muted text when wrapped in LdMute:"),
          CodeBlock(
            code: """
LdMute(
  child: LdTextList(
    ['Muted bullet point', 'Another muted item'],
    type: LdTextListType.bulleted,
  ),
);
""",
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdTextL("Muted List"),
                LdMute(
                  child: LdTextList(
                    [
                      "Muted bullet point",
                      "Another muted item",
                    ],
                    type: LdTextListType.bulleted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
