import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Interactive demo shown in the generated docs via `<!-- demo:LdInputGroup -->`.
class LdInputGroupDemo extends StatelessWidget {
  const LdInputGroupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentWell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*begin demo:LdInputGroup*/
          LdInputGroup(
            children: [
              LdInputGroupText(const Icon(LucideIcons.search)),
              LdInput(hint: 'Search...'),
              LdButton(onPressed: () {}, child: const Text('Go')),
            ],
          ),
          /*end demo:LdInputGroup*/
        ],
      ),
    );
  }
}

class InputGroupDemo extends StatelessWidget {
  const InputGroupDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/input_group.dart",
      title: "LdInputGroup",
      demo: LdAutoSpace(
        children: [
          ComponentWell(
            onSurface: true,
            title: LdText.hs("Basic"),
            description: const LdText(
              "Join inputs, buttons, selects, checkboxes and text add-ons into a "
              "single control. Inner borders render at half width at the seams so "
              "neighbours sum to a clean 1px line, and only the outer corners round.",
            ),
            child: LdAutoSpace(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LdInputGroup(
                  children: [
                    LdInput(hint: 'Email'),
                    LdButton(onPressed: () {}, child: const Text('Subscribe')),
                  ],
                ),

                LdInputGroup(
                  children: [
                    LdInputGroupText(const Text('https://')),
                    LdInput(hint: 'example.com'),
                    LdInputGroupText(const Text('/')),
                  ],
                ),

                LdInputGroup(
                  children: [
                    LdInput(hint: 'Weight'),
                    LdInputGroupText(const Text('kg')),
                  ],
                ),
              ],
            ),
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs("Search bar"),
            child: LdInputGroup(
              children: [
                LdInputGroupText(const Icon(LucideIcons.search)),
                LdInput(hint: 'Search...'),
                LdButton.outline(onPressed: () {}, child: const Text('Go')),
              ],
            ),
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs("Mixed controls"),
            description: const LdText(
              "Selects and inputs grow to fill the row; buttons, checkboxes and "
              "radios stay at their intrinsic width.",
            ),
            child: LdAutoSpace(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LdInputGroup(
                  children: [
                    LdSelect<String>(
                      placeholder: 'Region',
                      items: const [
                        LdSelectItem(child: Text('EU'), value: 'EU'),
                        LdSelectItem(child: Text('US'), value: 'US'),
                        LdSelectItem(child: Text('APAC'), value: 'APAC'),
                      ],
                    ),
                    LdInput(hint: 'City'),
                    LdButton(onPressed: () {}, child: const Text('Apply')),
                  ],
                ),

                LdInputGroup(
                  children: [
                    LdCheckbox(onChanged: (_) {}, checked: true),
                    LdInput(hint: 'Remember me'),
                    LdRadio(onChanged: (_) {}, checked: false),
                  ],
                ),
              ],
            ),
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs("Sizes"),
            child: LdAutoSpace(
              children: [
                for (final size in [LdSize.s, LdSize.m, LdSize.l])
                  LdInputGroup(
                    size: size,
                    children: [
                      LdInput(hint: 'Size ${size.name}'),
                      LdButton.outline(onPressed: () {}, child: const Text('Go')),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
