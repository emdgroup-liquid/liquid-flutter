import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class InputDemo extends StatefulWidget {
  const InputDemo({super.key});

  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  bool _onSurface = false;

  final _controller = TextEditingController(text: "Liquid Flutter is awesome!");
  final _disabledController = TextEditingController(text: "Disabled");

  @override
  void dispose() {
    _controller.dispose();
    _disabledController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/input.dart",
      title: "LdInput",
      demo: LdAutoSpace(
        children: [
          ComponentWell(
            onSurface: _onSurface,
            title: const LdTextHs("Different sizes"),
            child: LdAutoSpace(
              children: [
                LdInput(
                  size: LdSize.l,
                  hint: "I adjust my size",
                  label: "With size l..",
                ),
                LdInput(
                  size: LdSize.m,
                  hint: "I adjust my size",
                  label: "With size m..",
                ),
                LdInput(
                  size: LdSize.s,
                  hint: "I adjust my size",
                  label:
                      "With size s.. Using this input is probably a bad idea",
                ),
                LdInput(
                  size: LdSize.xs,
                  hint: "I adjust my size",
                  label: "With size xs.. Using this input is a bad idea",
                ),
              ],
            ),
          ),
          ComponentWell(
            title: const LdTextHs("Invalid input"),
            description: const LdText(
              "Use the valid property set to false to indicate that an input has invalid data.",
            ),
            child: LdAutoSpace(
              children: [
                const LdInput(
                  hint: "This input is invalid",
                  label: "Invalid input",
                  valid: false,
                ),
              ],
            ),
          ),
          ComponentWell(
            title: const LdTextHs("Loading input"),
            description: const LdText(
              "Use the loading property to indicate that the input is waiting for data or processing a request.",
            ),
            child: LdAutoSpace(
              children: [
                const LdInput(
                  hint: "Loading data...",
                  label: "Processing input",
                  loading: true,
                ),
              ],
            ),
          ),
          ComponentWell(
            title: const LdTextHs("Disabled input"),
            description: const LdText(
              "Use the disabled property to indicate that an input is not interactive.",
            ),
            child: LdAutoSpace(
              children: [
                const LdInput(
                  hint: "This input is disabled",
                  label: "Disabled input",
                  disabled: true,
                ),
              ],
            ),
          ),
          ComponentWell(
            title: const LdTextHs("With a button"),
            description: const LdText(
              "LdInput is designed to work well with buttons. Use the same size for the input and the button to make it fit.",
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: LdInput(
                    hint: "I will be the same height as the button",
                    label: "With size m..",
                  ),
                ),
                ldSpacerM,
                LdButtonOutline(
                  onPressed: () {},
                  child: const Text("Fitting button"),
                ),
                ldSpacerM,
                LdButton(
                  onPressed: () {},
                  child: const Text("Fitting button"),
                ),
              ],
            ),
          ),
          ComponentWell(
            onSurface: _onSurface,
            title: LdTextHs("With a shortcut hint"),
            description: const LdText(
              "The shortcut is displayed when the input is focused. Use an LdShortcutIndicator to display the shortcut. Use a widget like CallbackShortcuts to handle the shortcut itself.",
            ),
            child: LdAutoSpace(
              children: [
                LdInput(
                  hint: "I like cookies",
                  label: "Focus to see the shortcut.",
                  showClear: true,
                  trailingHint: const LdShortcutIndicator(
                    shortcut: SingleActivator(
                      LogicalKeyboardKey.keyK,
                      meta: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
