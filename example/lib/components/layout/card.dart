import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class CardDemo extends StatefulWidget {
  const CardDemo({super.key});

  @override
  State<CardDemo> createState() => _CardDemoState();
}

class _CardDemoState extends State<CardDemo> {
  @override
  Widget build(BuildContext context) {
    var ipsum = const Text(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc vel tincidunt lacinia, nunc nisl aliquam nisl, eu aliquet nisl nisl eu ante.");
    return ComponentPage(
      path: "lib/components/layout/card.dart",
      title: "LdCard",
      demo: LdAutoSpace(
        children: [
          LdText.p(
            "Cards are versatile containers that group related content and actions. They can include headers, footers, and various interactive elements. Cards provide a consistent way to present information while maintaining visual hierarchy and organization.",
          ),
          LdText.p(
            "Cards can be styled with or without elevation (flat), and can be placed on different background surfaces. They automatically adapt their appearance based on the theme and surface they're placed on.",
          ),
          LdText.h("Flat Card with child only"),
          ComponentWell(
            child: LdCard(
              child: LdText.l("Hello world"),
            ),
          ),
          LdText.h("Flat Card with header and footer"),
          ComponentWell(
            child: Column(
              children: [
                LdCard(
                  child: LdAutoSpace(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LdText.h(
                        "Hello World!",
                      ),
                      // lorem ipsum text
                      ipsum,
                    ],
                  ),
                ),
                ldSpacerM,
                LdCard(
                  header: const Row(
                    children: [
                      LdTag(child: Text("Important information for you")),
                    ],
                  ),
                  footer: Row(
                    children: [
                      LdButton(
                        child: const Text("Action"),
                        onPressed: () {},
                      ),
                    ],
                  ), // bool

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LdText.h(
                        "Hello footer",
                      ),
                      ldSpacerM,
                      // lorem ipsum text
                      ipsum,
                    ],
                  ),
                ),
              ],
            ),
          ),
          LdText.h("Card on surface"),
          ComponentWell(
            onSurface: true,
            child: LdCard(
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LdText.h("Card on surface"),
                  LdText.l(
                    "This card is placed on a surface background. Notice how it adapts its appearance automatically.",
                  ),
                ],
              ),
            ),
          ),
          LdText.h("Elevated Card"),
          ComponentWell(
            child: LdCard(
              flat: false,
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LdText.h("Elevated Card"),
                  LdText.l(
                    "This card has elevation applied to make it stand out from the background.",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
