import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class TagDemo extends StatefulWidget {
  const TagDemo({super.key});

  @override
  State<TagDemo> createState() => _TagDemoState();
}

class _TagDemoState extends State<TagDemo> {
  bool _onSurface = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdTag",
      demo: LdAutoSpace(
        children: [
          const LdTextP(
              "Tags are used to highlight or categorize content. They will slightly adapt to the surface in dark mode."),
          LdBundle(
            children: [
              ComponentWell(
                  onSurface: _onSurface,
                  child: const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        LdTag(
                          size: LdSize.xs,
                          child: Text("XS Tag"),
                        ),
                        LdTag(
                          size: LdSize.s,
                          child: Text("Small Tag"),
                        ),
                        LdTag(
                          size: LdSize.m,
                          child: Text("Medium Tag"),
                        ),
                        LdTag(
                          size: LdSize.l,
                          child: Text("Large Tag"),
                        ),
                      ])),
              LdToggle(
                  label: ("On surface"),
                  checked: _onSurface,
                  onChanged: (value) {
                    setState(() {
                      _onSurface = value;
                    });
                  }),
            ],
          ),
          const CodeBlock(code: """
LdTag(
  child: Text("Tag"),
  size: LdSize.m,
),
"""),
        ],
      ),
    );
  }
}
