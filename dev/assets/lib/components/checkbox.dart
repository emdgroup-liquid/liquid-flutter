import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class CheckboxDemo extends StatefulWidget {
  const CheckboxDemo({super.key});

  @override
  State<CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<CheckboxDemo> {
  bool _checkedA = true;
  bool _checkedB = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdCheckbox",
      demo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComponentWell(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const LdTextL("Large size"),
              ldSpacerM,
              LdCheckbox(
                  label: "Checkbox",
                  size: LdSize.l,
                  checked: _checkedA,
                  onChanged: (p0) => setState(() {
                        _checkedA = p0 == true;
                      })),
              const SizedBox(
                height: 8,
              ),
              LdCheckbox(
                  label: "Checkbox",
                  checked: _checkedB,
                  size: LdSize.l,
                  onChanged: (p0) => setState(() {
                        _checkedB = p0 == true;
                      })),
              ldSpacerL,
              const LdTextL(
                "Medium size",
              ),
              ldSpacerM,
              LdCheckbox(
                  label: "Checkbox",
                  checked: _checkedA,
                  onChanged: (p0) => setState(() {
                        _checkedA = p0 == true;
                      })),
              const SizedBox(
                height: 8,
              ),
              LdCheckbox(
                  label: "Checkbox",
                  checked: _checkedB,
                  onChanged: (p0) => setState(() {
                        _checkedB = p0 == true;
                      })),
              const SizedBox(
                height: 8,
              ),
              /*begin demo:LdCheckbox*/
              const LdCheckbox(
                label: "Checkbox",
                checked: true,
                disabled: true,
              ),
              /*end demo:LdCheckbox*/
              ldSpacerM,
              const LdTextL(
                "Small size",
              ),
              ldSpacerM,
              const LdCheckbox(
                label: "Checkbox",
                size: LdSize.s,
                checked: true,
              ),
              ldSpacerS,
              const LdCheckbox(
                label: "Checkbox",
                size: LdSize.s,
                checked: true,
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
