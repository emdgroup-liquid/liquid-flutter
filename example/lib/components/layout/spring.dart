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
  double width = 1.0;
  double height = 1.0;

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
            title: Text("LdSpring"),
            description: Text(
                "A physics-based spring animation widget that simulates spring motion using mass, spring constant, and damping coefficient parameters."),
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
            ),
          ),
          Row(
            spacing: LdTheme.of(context).paddingSize(size: LdSize.m),
            children: [
              Expanded(
                child: Column(
                  children: [
                    LdText("Mass: ${mass.toStringAsFixed(2)}"),
                    Slider(max: 100, min: 1, value: mass, onChanged: (value) => setState(() => mass = value)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    LdText("Spring Constant: ${springConstant.toStringAsFixed(2)}"),
                    Slider(
                        max: 100,
                        min: 1,
                        value: springConstant,
                        onChanged: (value) => setState(() => springConstant = value)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    LdText("Damping Coefficient: ${dampingCoefficient.toStringAsFixed(2)}"),
                    Slider(
                        max: 20,
                        min: -0.5,
                        value: dampingCoefficient,
                        onChanged: (value) => setState(() => dampingCoefficient = value)),
                  ],
                ),
              )
            ],
          ),
          Row(
            spacing: LdTheme.of(context).paddingSize(size: LdSize.m),
            children: [
              LdButton(
                onPressed: updatePosition,
                child: const Text('Update Position'),
              ),
              LdButton(
                onPressed: () {
                  setState(() {
                    mass = 5;
                    springConstant = 10;
                    dampingCoefficient = 9;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const LdDivider(),
          ComponentWell(
              title: Text("LdChainedSprings"),
              description: Text("A chain of springs that are connected to each other."),
              child: Column(
                children: [
                  LdChainedSprings(
                    targetPosition: position,
                    count: 5,
                    builder: (context, states) {
                      return Column(
                        spacing: LdTheme.of(context).paddingSize(size: LdSize.m),
                        children: [
                          for (var state in states)
                            Transform.translate(
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
                        ],
                      );
                    },
                  ),
                ],
              )),
          ComponentWell(
            title: Text("LdMultiSpring"),
            description:
                Text("A multi-spring animation widget that simulates several springs with their own positions."),
            child: Column(
              children: [
                LdMultiSpring(
                  targetPositions: [width, height],
                  mass: mass,
                  springConstant: springConstant,
                  dampingCoefficient: dampingCoefficient,
                  builder: (context, states) {
                    return Center(
                      child: Container(
                        width: 50 + states[0].position * 50,
                        height: 50 + states[1].position * 50,
                        decoration: BoxDecoration(
                          color: LdTheme.of(context).primaryColor.withAlpha(100),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  spacing: LdTheme.of(context).paddingSize(size: LdSize.m),
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          LdText("Width: ${width.toStringAsFixed(2)}"),
                          Slider(
                            min: 0.5,
                            max: 5.0,
                            value: width,
                            onChanged: (value) => setState(() => width = value),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          LdText("Height: ${height.toStringAsFixed(2)}"),
                          Slider(
                            min: 0.5,
                            max: 5.0,
                            value: height,
                            onChanged: (value) => setState(() => height = value),
                          ),
                        ],
                      ),
                    ),
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
