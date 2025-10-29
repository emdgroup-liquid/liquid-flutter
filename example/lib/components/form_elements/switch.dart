import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import '../component_well/component_well.dart';

class SwitchDemo extends StatefulWidget {
  const SwitchDemo({super.key});

  @override
  State<SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<SwitchDemo> {
  String value = "two";

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        path: "lib/components/form_elements/switch.dart",
        title: "LdSwitch",
        text:
            "A component that allows the user to switch between several options",
        demo: ComponentWell(
            child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              LdSwitch<String>(
                size: LdSize.s,
                children: const {
                  "one": Text("Less"),
                  "two": Text("More is more and more is better"),
                  "three": Text("Super"),
                },
                value: value,
                onChanged: (value) => setState(() => this.value = value),
              ),
              ldSpacerM,
              LdSwitch<String>(
                children: const {
                  "one": Text("Less"),
                  "two": Text("More is more and more is better"),
                  "three": Text("Super"),
                },
                value: value,
                onChanged: (value) => setState(() => this.value = value),
              ),
              ldSpacerM,
              LdSwitch<String>(
                size: LdSize.l,
                children: const {
                  "one": Text("Less"),
                  "two": Text("More is more and more is better"),
                  "three": Text("Super"),
                },
                value: value,
                onChanged: (value) => setState(() => this.value = value),
              ),
            ],
          ),
        )));
  }
}
