import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ChooseDemo extends StatefulWidget {
  const ChooseDemo({super.key});

  @override
  State<ChooseDemo> createState() => _ChooseDemoState();
}

class _ChooseDemoState extends State<ChooseDemo> {
  Set<String> _value = {"test"};

  bool _onSurface = false;
  bool _allowEmpty = false;
  bool _disabled = false;
  bool _multiple = false;
  bool _enableSearch = false;
  LdChooseMode _mode = LdChooseMode.auto;

  void _onChange(Set<String> value) {
    setState(() {
      _value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdChoose",
      demo: LdAutoSpace(
        children: [
          const LdTextP(
            "LdChoose is a versatile dropdown selection component that allows users to select one or multiple items from a list of options. It supports both single and multiple selection modes, can be configured to require a selection or allow empty values, and adapts its appearance based on the platform and context.",
          ),
          const LdTextP(
            "The component provides a searchable interface on desktop and a bottom sheet selector on mobile devices. It handles keyboard navigation, supports disabled items, and can truncate long selections for better display. Use LdChoose when you need a rich selection interface with built-in platform-specific behaviors.",
          ),
          ComponentWell(
            onSurface: _onSurface,
            child: Column(
              children: [
                LdChoose<String>(
                  label: "Your pie choice",
                  allowEmpty: _allowEmpty,
                  disabled: _disabled,
                  multiple: _multiple,
                  placeholder: const Text("Choose a pie"),
                  enableSearch: _enableSearch,
                  value: _value,
                  truncateDisplay: 3,
                  mode: _mode,
                  onChange: _onChange,
                  items: const [
                    LdSelectItem(
                      child: Text("Raspberry pie"),
                      value: "raspberry",
                    ),
                    LdSelectItem(
                      child: Text("Strawberry pie"),
                      value: "strawberry",
                    ),
                    LdSelectItem(
                      child: Text("Apple pie"),
                      enabled: false,
                      value: "apple",
                    ),
                    LdSelectItem(
                      child: Text("Blueberry pie"),
                      value: "blueberry",
                    ),
                    LdSelectItem(
                      child: Text("Cherry pie"),
                      value: "cherry",
                    ),
                    LdSelectItem(
                      child: Text("Peach pie"),
                      value: "peach",
                    ),
                    LdSelectItem(
                      child: Text("Chocolate pie"),
                      value: "chocolate",
                    ),
                    LdSelectItem(
                      child: Text("Banana bread"),
                      value: "banana",
                    ),
                    LdSelectItem(
                      child: Text("Pumpkin pie"),
                      value: "pumpkin",
                    ),
                    LdSelectItem(
                      child: Text("Lemon pie"),
                      value: "lemon",
                    ),
                  ],
                ),
                ldSpacerM,
              ],
            ),
          ),
          ldSpacerM,
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              LdSelect<LdChooseMode>(
                  value: _mode,
                  onChange: (p0) {
                    setState(() {
                      _mode = p0;
                    });
                  },
                  items: const [
                    LdSelectItem(
                      child: Text("Auto (uses page for 10+ items)"),
                      value: LdChooseMode.auto,
                    ),
                    LdSelectItem(
                      child: Text("Page"),
                      value: LdChooseMode.page,
                    ),
                    LdSelectItem(
                      child: Text("Sheet"),
                      value: LdChooseMode.modal,
                    ),
                  ]),
              LdButton(
                  child: const Text("Add Strawberry pie"),
                  onPressed: () {
                    setState(() {
                      _value.add("strawberry");
                    });
                  }),
              LdToggle(
                checked: _multiple,
                onChanged: (p0) {
                  setState(() {
                    _multiple = p0;
                  });
                },
                label: "Allow multiple",
              ),
              LdToggle(
                checked: _onSurface,
                onChanged: (p0) {
                  setState(() {
                    _onSurface = p0;
                  });
                },
                label: "On surface",
              ),
              LdToggle(
                checked: _allowEmpty,
                onChanged: (p0) {
                  setState(() {
                    _allowEmpty = p0;
                  });
                },
                label: "Allow empty",
              ),
              LdToggle(
                checked: _disabled,
                onChanged: (p0) {
                  setState(() {
                    _disabled = !_disabled;
                  });
                },
                label: "Disabled",
              ),
              LdToggle(
                checked: _enableSearch,
                onChanged: (p0) {
                  setState(() {
                    _enableSearch = p0;
                  });
                },
                label: "Enable search",
              ),
            ],
          ),
          ldSpacerM,
        ],
      ),
    );
  }
}
