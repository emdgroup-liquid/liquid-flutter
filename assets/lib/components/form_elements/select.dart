import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class SelectDemo extends StatefulWidget {
  const SelectDemo({super.key});

  @override
  State<SelectDemo> createState() => _SelectDemoState();
}

class _SelectDemoState extends State<SelectDemo> {
  bool _onSurface = false;
  bool _disabled = false;
  String _value = "test";

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return ComponentPage(
      path: "lib/components/form_elements/select.dart",
      title: "LdSelect",
      demo: ComponentWell(
        color: _onSurface ? theme.surface : theme.background,
        child: Column(
          children: [
            LdSelect<String>(
              label: "This is a label",
              onSurface: _onSurface,
              value: _value,
              disabled: _disabled,
              onChange: (p0) {
                setState(() {
                  _value = p0;
                });
              },
              items: List.generate(
                  32,
                  (index) => LdSelectItem(
                      value: index.toString(), child: Text("Choice $index"))),
            ),
            ldSpacerL,
            LdSelect<String>(
              onSurface: _onSurface,
              value: _value,
              disabled: _disabled,
              onChange: (p0) {
                setState(() {
                  _value = p0;
                });
              },
              items: const [
                LdSelectItem(child: Text("Hello world"), value: "test"),
                LdSelectItem(child: Text("Hello world 2"), value: "test2")
              ],
            ),
            ldSpacerM,
            LdToggle(
                checked: _onSurface,
                label: "On surface",
                onChanged: (e) {
                  setState(() {
                    _onSurface = e;
                  });
                }),
            ldSpacerM,
            LdToggle(
                checked: _disabled,
                label: "Disabled",
                onChanged: (e) {
                  setState(() {
                    _disabled = e;
                  });
                }),
          ],
        ),
      ).padL(),
    );
  }
}
