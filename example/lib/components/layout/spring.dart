import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class Spring extends StatefulWidget {
  const Spring({super.key});

  @override
  State<Spring> createState() => _SpringState();
}

class _SpringState extends State<Spring> {
  double position = 1.0;
  double mass = 5;
  double springConstant = 10.0;
  double dampingCoefficient = 9;

  void updatePosition() {
    setState(() {
      position = Random().nextDouble() * 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/layout/spring.dart",
      title: 'Spring',
      demo: LdAutoSpace(
        children: [
          ComponentWell(
              child: Center(
            child: LdSpring(
              mass: mass,
              position: position,
              springConstant: springConstant,
              dampingCoefficient: dampingCoefficient,
              builder: (context, state) => Transform.translate(
                offset: Offset(state.position * 50, 0),
                child: Container(
                  height: 20,
                  width: 20 + min(max(state.velocity.abs() * 20, 0), 50),
                  decoration: BoxDecoration(
                    color: LdTheme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          )),
          LdText("Mass: $mass"),
          Slider(
              max: 100,
              min: 1,
              value: mass,
              onChanged: (value) => setState(() => mass = value)),
          LdText("Spring Constant: $springConstant"),
          Slider(
              max: 100,
              min: 1,
              value: springConstant,
              onChanged: (value) => setState(() => springConstant = value)),
          LdText("Damping Coefficient: $dampingCoefficient"),
          Slider(
              max: 20,
              min: -0.5,
              value: dampingCoefficient,
              onChanged: (value) => setState(() => dampingCoefficient = value)),
          LdButton(
            onPressed: updatePosition,
            child: const Text('Update Position'),
          ),
          const LdDivider(),
          ComponentWell(
              child: Column(
            children: [
              LdChainedSprings(
                targetPosition: position,
                count: 5,
                builder: (context, states) {
                  return Column(
                    children: [
                      for (var state in states)
                        Transform.translate(
                          offset: Offset(state.position * 50, 0),
                          child: Container(
                            height: 20,
                            width:
                                20 + min(max(state.velocity.abs() * 20, 0), 50),
                            decoration: BoxDecoration(
                              color: LdTheme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              )
            ],
          ))
        ],
      ),
    );
  }
}
