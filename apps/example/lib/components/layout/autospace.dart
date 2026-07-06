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
      path: "lib/components/layout/autospace.dart",
      title: "LdAutoSpace",
      demo: LdAutoSpace(
        children: [
          ComponentWell(
            title: LdText.hs("LdAutoSpace()"),
            padding: LdTheme.of(context).pad(size: LdSize.m),
            child: LdAutoSpace(
              animate: _animate,
              children: [
                LdText.hl("Autospace Demo Form"),
                LdMute(child: LdText.l("This is a demo form to show how autospace works")),
                LdText.p("It will automatically space out elements based on their type"),
                LdButton.outline(
                  trailing: const Icon(LucideIcons.arrowRight),
                  onPressed: () {},
                  child: const Text("Already have filled this form?"),
                ),

                LdBundle(
                  children: [
                    const LdInput(label: "Enter something here", hint: "Test"),
                    const LdInput(hint: "Test", label: "With label"),
                    const LdDivider(),
                    LdText.hs("Second section"),
                    LdBundle(
                      children: [
                        const LdRadio(checked: true, label: "Option 1"),
                        const LdRadio(checked: false, label: "Option 2"),
                        const LdRadio(checked: false, label: "Option 3"),
                      ],
                    ),
                    const LdCheckbox(checked: true, label: "Agree to the ToS"),
                    LdButton(child: const Text("Button"), onPressed: () {}),
                  ],
                ),
                const LdDivider(),
                LdText.p("This is a paragraph. It should be spaced out."),
                LdText.l("This is a label."),
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
            },
          ),
        ],
      ),
    );
  }
}
