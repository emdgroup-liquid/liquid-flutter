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
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc vel tincidunt lacinia, nunc nisl aliquam nisl, eu aliquet nisl nisl eu ante.",
    );
    return ComponentPage(
      path: "lib/components/layout/card.dart",
      title: "LdCard",
      text:
          "Cards are versatile containers that group related content and actions. They can include headers, footers, and various interactive elements. Cards provide a consistent way to present information while maintaining visual hierarchy and organization."
          "Cards can be styled with or without elevation (flat), and can be placed on different background surfaces. They automatically adapt their appearance based on the theme and surface they're placed on.",

      demo: LdAutoSpace(
        children: [
          ComponentWell(
            title: Text("Flat Card with child only"),
            child: LdCard(child: LdText.l("Hello world")),
          ),

          ComponentWell(
            title: Text("Flat Card with header and footer"),

            child: Column(
              children: [
                LdCard(
                  header: const Row(children: [LdTag(child: Text("Important information for you"))]),
                  footer: Row(
                    children: [LdButton(child: const Text("Action"), onPressed: () {})],
                  ), // bool

                  child: LdAutoSpace(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [LdText.h("Hello with a header"), ipsum],
                  ),
                ),
              ],
            ),
          ),
          ComponentWell(
            title: Text("Card on surface"),
            onSurface: true,
            child: LdCard(
              child: LdText.l(
                "This card is placed on a surface background. Notice how it adapts its appearance automatically.",
              ),
            ),
          ),
          ComponentWell(
            title: Text("Elevated Card"),
            child: LdCard(
              flat: false,
              child: LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LdText.h("Elevated Card"),
                  LdText.l("This card has elevation applied to make it stand out from the background."),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
