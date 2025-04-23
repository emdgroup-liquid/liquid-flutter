import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class CheckboxDemo extends StatefulWidget {
  const CheckboxDemo({super.key});

  @override
  State<CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<CheckboxDemo> {
  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdCheckbox",
      demo: LdAutoSpace(
        children: [
          const LdTextP(
            "Checkboxes allow users to select one or more options from a set. They are commonly used for multiple-choice selections, task lists, and form submissions where multiple selections are allowed.",
          ),
          const LdTextP(
            "Use a checkbox when the user needs to make multiple independent selections. For binary (on/off) choices where only one selection is possible, consider using a toggle switch instead. Toggles are better suited for immediate actions like enabling/disabling a setting, while checkboxes are ideal for selecting items that will be acted upon later, such as in a form submission.",
          ),
          ComponentWell(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ...LdSize.values
                    .map(
                      (e) => SizedBox(
                        width: 200,
                        child: LdBundle(
                          children: [
                            LdCheckbox(
                              size: e,
                              label: "Checkbox $e",
                              checked: false,
                            ),
                            LdCheckbox(
                              size: e,
                              label: "Checkbox $e",
                              checked: true,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
