import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class TextListDemo extends StatelessWidget {
  const TextListDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        LdText.h("Text Lists"),
        LdText.p(
          "LdText.list allows you to create bulleted or enumerated lists using paragraph text typography.",
        ),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.l("Bulleted List"),
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
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.l("Enumerated List"),
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
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.l("Different Sizes"),
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
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.l("Muted List"),
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
    );
  }
}
