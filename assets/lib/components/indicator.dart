import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class IndicatorDemo extends StatelessWidget {
  const IndicatorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdIndicator",
      text: "An indicator is a visual representation of a status or state.",
      demo:
          LdAutoSpace(crossAxisAlignment: CrossAxisAlignment.center, children: [
        ...LdIndicatorType.values
            .map(
              (e) => Row(
                children: [
                  LdIndicator(type: e),
                  ldSpacerM,
                  LdTextPs(e.toString())
                ],
              ),
            )
            .toList()
      ]),
      apiComponents: const [
        "LdIndicator",
      ],
    );
  }
}
