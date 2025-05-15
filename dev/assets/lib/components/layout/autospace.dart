import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AutoSpaceDemo extends StatefulWidget {
  const AutoSpaceDemo({super.key});

  @override
  State<AutoSpaceDemo> createState() => _AutoSpaceDemoState();
}

class _AutoSpaceDemoState extends State<AutoSpaceDemo> {
  bool _animate = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdAutoSpace",
      demo: LdAutoSpace(children: [
        ComponentWell(
          padding: LdTheme.of(context).pad(size: LdSize.m),
          child: LdAutoSpace(
            animate: _animate,
            children: [
              const LdTextHl(
                "Autospace Demo Form",
              ),
              const LdTextL(
                "This is a demo form to show how autospace works",
              ),
              const LdTextP(
                "It will automatically space out elements based on their type",
              ),
              LdButton(
                  trailing: const Icon(LucideIcons.arrowRight),
                  onPressed: () {},
                  child: const Text("Already have filled this form?")),
              const LdInput(label: "Enter something here", hint: "Test"),
              ldSpacerS,
              const LdInput(
                hint: "Test",
                label: "With label",
              ),
              const LdDivider(),
              const LdTextHs(
                "Second section",
              ),
              const LdRadio(
                checked: true,
                label: "Option 1",
              ),
              const LdRadio(
                checked: false,
                label: "Option 2",
              ),
              const LdRadio(
                checked: false,
                label: "Option 3",
              ),
              const LdCheckbox(checked: true, label: "Agree to the ToS"),
              LdButton(child: const Text("Button"), onPressed: () {}),
              const LdDivider(),
              const LdTextP("This is a paragraph. It should be spaced out."),
              const LdTextL("This is a label.")
            ],
          ),
        ),
        LdToggle(
            checked: _animate,
            label: "Animate",
            onChanged: (value) {
              setState(() {
                _animate = value;
              });
            }),
      ]),
    );
  }
}
