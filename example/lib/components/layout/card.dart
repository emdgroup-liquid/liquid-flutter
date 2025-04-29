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
      title: "LdCard",
      demo: LdAutoSpace(
        children: [
          const LdTextP(
            "Cards are versatile containers that group related content and actions. They can include headers, footers, and various interactive elements. Cards provide a consistent way to present information while maintaining visual hierarchy and organization.",
          ),
          const LdTextP(
            "Cards can be styled with or without elevation (flat), and can be placed on different background surfaces. They automatically adapt their appearance based on the theme and surface they're placed on.",
          ),
          const LdTextH("Flat Card with child only"),
          const ComponentWell(
            child: LdCard(
              child: LdTextL("Hello world"),
            ),
          ),
          const LdTextH("Flat Card with header and footer"),
          ComponentWell(
            child: Column(
              children: [
                LdCard(
                  child: LdAutoSpace(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LdTextH(
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
                      const LdTextH(
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
          const LdTextH("Card on surface"),
          const ComponentWell(
            onSurface: true,
            child: LdCard(
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LdTextH("Card on surface"),
                  LdTextL(
                    "This card is placed on a surface background. Notice how it adapts its appearance automatically.",
                  ),
                ],
              ),
            ),
          ),
          const LdTextH("Elevated Card"),
          const ComponentWell(
            child: LdCard(
              flat: false,
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LdTextH("Elevated Card"),
                  LdTextL(
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
