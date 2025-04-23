import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class OrbDemo extends StatefulWidget {
  const OrbDemo({super.key});

  @override
  State<OrbDemo> createState() => _OrbDemoState();
}

class _OrbDemoState extends State<OrbDemo> {
  double _level = 0.5;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        title: "LdOrb",
        demo: Column(
          children: [
            ComponentWell(
              child: Column(
                children: [
                  LdOrb(_level),
                ],
              ),
            ),
            SizedBox(
              width: 250,
              child: Slider(
                value: _level,
                min: 0.0,
                max: 1.0,
                onChanged: (e) {
                  setState(() {
                    _level = e;
                  });
                },
              ),
            )
          ],
        ));
  }
}
