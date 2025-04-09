import 'package:flutter/material.dart';
import 'package:liquid/color_selector.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'component_page.dart';

class ToggleDemo extends StatefulWidget {
  const ToggleDemo({Key? key}) : super(key: key);

  @override
  State<ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<ToggleDemo> {
  LdSize _size = LdSize.m;
  late LdColor _color;
  bool _checked = false;

  bool _onSurface = false;

  @override
  void initState() {
    _color = LdTheme.of(context).palette.primary;
    super.initState();
  }

  void _changeSize(LdSize? size) {
    setState(() {
      _size = size ?? LdSize.m;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        title: "LdToggle",
        demo: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ComponentWell(
              onSurface: _onSurface,
              child: Center(
                child: LdToggle(
                    label: "Toggle with a label, color, and size",
                    size: _size,
                    color: _color,
                    checked: _checked,
                    onChanged: (checked) async {
                      setState(() {
                        _checked = checked;
                      });
                    }),
              ),
            ),
            ldVSpacerM,
            const LdTextH(
              "Color",
            ),
            ldSpacerM,
            ColorSelctor(
                colors: {
                  "primary": LdTheme.of(context).palette.primary,
                  "secondary": LdTheme.of(context).palette.secondary,
                  "success": LdTheme.of(context).palette.success,
                  "warning": LdTheme.of(context).palette.warning,
                  "error": LdTheme.of(context).palette.error,
                },
                active: _color,
                onChanged: (p0) => setState(() {
                      _color = p0;
                    })),
            ldVSpacerM,
            const LdTextH("Size"),
            ldSpacerM,
            LdSelect<LdSize>(
                value: _size,
                items: const [
                  LdSelectItem(child: Text("Normal"), value: LdSize.m),
                  LdSelectItem(child: Text("Large"), value: LdSize.l),
                  LdSelectItem(child: Text("Small"), value: LdSize.s),
                ],
                onChange: _changeSize),
            ldSpacerL,
            LdToggle(
              label: "On Surface",
              checked: _onSurface,
              onChanged: (checked) async {
                setState(() {
                  _onSurface = checked;
                });
              },
            ),
          ],
        ));
  }
}
