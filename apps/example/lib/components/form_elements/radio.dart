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

  final Map<String, String> _choices = {
    "cookie": "Cookie",
    "pie": "Pie with a very long label to explain what this choice does",
    "yes": "Yes",
  };

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/radio.dart",
      title: "LdRadio",
      demo: ComponentWell(
        child: LdAutoSpace(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LdText.hs("Large size"),

            ..._choices.entries.map(
              (entry) => LdRadio(
                label: entry.value,
                size: LdSize.l,
                checked: _selection == entry.key,
                onChanged: (p0) => setState(() {
                  _selection = entry.key;
                }),
              ),
            ),

            LdText.hs("Default size"),
            ..._choices.entries.map(
              (entry) => LdRadio(
                label: entry.value,
                checked: _selection == entry.key,
                onChanged: (p0) => setState(() {
                  _selection = entry.key;
                }),
              ),
            ),

            LdDivider(),

            ..._choices.entries.map(
              (entry) => LdRadio(
                label: entry.value,
                size: LdSize.s,
                checked: _selection == entry.key,
                onChanged: (p0) => setState(() {
                  _selection = entry.key;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
