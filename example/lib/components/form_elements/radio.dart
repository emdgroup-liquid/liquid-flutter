import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class RadioDemo extends StatefulWidget {
  const RadioDemo({super.key});

  @override
  State<RadioDemo> createState() => _RadioDemoState();
}

class _RadioDemoState extends State<RadioDemo> {
  String _selection = "cookie";

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/radio.dart",
      title: "LdRadio",
      demo: ComponentWell(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LdRadio(
              label: "Cookie",
              checked: _selection == "cookie",
              onChanged: (p0) => setState(() {
                _selection = "cookie";
              }),
            ),
            const SizedBox(
              height: 8,
            ),
            LdRadio(
              label:
                  "Pie with a very long label to explain what this choice does",
              checked: _selection == "pie",
              onChanged: (p0) => setState(() {
                _selection = "pie";
              }),
            ),
            const SizedBox(
              height: 8,
            ),
            LdRadio(
              label: "Yes",
              checked: _selection == "yes",
              onChanged: (p0) => setState(() {
                _selection = "yes";
              }),
            ),
          ]),
        ),
      ),
    );
  }
}
