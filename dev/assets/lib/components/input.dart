import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class InputDemo extends StatefulWidget {
  const InputDemo({super.key});

  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  bool _onSurface = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdInput",
      demo: Column(
        children: [
          ComponentWell(
            onSurface: _onSurface,
            child: LdAutoSpace(
              children: [
                LdInput(
                  hint: "I like cookies",
                  controller: TextEditingController(text: "Hey"),
                  size: LdSize.l,
                  label: "Input something here",
                  showClear: true,
                ),
                const LdInput(
                  hint: "I like cookies",
                  size: LdSize.m,
                  disabled: true,
                  label: "Input nothing here",
                ),
                const LdInput(
                  hint: "I dont agree",
                  size: LdSize.s,
                  valid: false,
                  label: "Invalid",
                ),
                const LdInput(
                  hint: "Wait for it...",
                  size: LdSize.s,
                  loading: true,
                  label: "Loading",
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: LdInput(
                        size: LdSize.s,
                        hint: "I adjust my size",
                        label: "With size s ..",
                      ),
                    ),
                    ldSpacerS,
                    LdButton(
                      size: LdSize.s,
                      onPressed: () {},
                      mode: LdButtonMode.outline,
                      child: const Text("Fitting button"),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: LdInput(
                        hint: "I adjust my size",
                        label: "With size m..",
                      ),
                    ),
                    ldSpacerM,
                    LdButton(
                      onPressed: () {},
                      mode: LdButtonMode.outline,
                      child: const Text("Fitting button"),
                    )
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: LdInput(
                        size: LdSize.l,
                        hint: "I adjust my size",
                        label: "With size l..",
                      ),
                    ),
                    ldSpacerL,
                    LdButton(
                      size: LdSize.l,
                      onPressed: () {},
                      mode: LdButtonMode.outline,
                      child: const Text("Fitting button"),
                    )
                  ],
                )
              ],
            ),
          ),
          ldSpacerM,
          LdToggle(
              label: "On Surface",
              checked: _onSurface,
              onChanged: (value) {
                setState(() {
                  _onSurface = value;
                });
              })
        ],
      ),
    );
  }
}
