import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdRevealDemo extends StatefulWidget {
  const LdRevealDemo({super.key});

  @override
  State<LdRevealDemo> createState() => _LdRevealDemoState();
}

class _LdRevealDemoState extends State<LdRevealDemo> {
  bool _revealed = true;

  double _transformOffset = 20;

  double mass = 5;
  double springConstant = 10.0;
  double dampingCoefficient = 15;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/feedback/reveal.dart",
      title: "LdReveal",
      apiComponents: const ["LdReveal"],
      demo: LdAutoSpace(children: [
        const LdTextHs("Watch some content magically appear and disappear"),
        ComponentWell(
          child: Center(
            child: LdAutoSpace(
              children: [
                LdCard(
                  footer: Row(
                    children: [
                      LdReveal(
                        revealed: _revealed,
                        mass: mass,
                        springConstant: springConstant,
                        dampingCoefficient: dampingCoefficient,
                        transformXOffset: -_transformOffset,
                        child: Row(
                          children: [
                            LdButton(
                                child: const Text("Appearching button"),
                                onPressed: () {}),
                            ldSpacerS,
                          ],
                        ),
                      ),
                      const LdTextP("Some actions might reveal"),
                    ],
                  ),
                  child: const LdTextHs("This will stay at all times"),
                ),
                const LdTextP(
                    "It's about managing expectations tiger team it is all exactly as i said, but i don't like it. Let's unpack that later we should leverage existing asserts that ladder up to the message. We need to socialize the comms with the wider stakeholder community we're building the plane while we're flying it, but if you want to motivate these clowns, try less carrot and more stick, race without a finish line performance review, so what do you feel you would bring to the table if you were hired for this position."),
                const LdTextPs(
                    "Filler text by http://officeipsum.com/index.php"),
                LdReveal(
                  revealed: _revealed,
                  mass: mass,
                  springConstant: springConstant,
                  dampingCoefficient: dampingCoefficient,
                  transformYOffset: _transformOffset,
                  child: Padding(
                    // 1px padding to prevent the reveal from being clipped
                    padding: const EdgeInsets.all(1),
                    child: LdCard(
                      child: LdAutoSpace(
                        children: [
                          const LdText(
                              "This is some content that is revealed when the switch is on"),
                          LdButton(
                              child: const Text("Hello world"),
                              onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
                ),
                const LdCard(
                  child: Text("Static card that will always be here"),
                ),
              ],
            ),
          ),
        ),
        LdToggle(
          checked: _revealed,
          size: LdSize.l,
          label: "Revealed",
          onChanged: (v) => setState(() => _revealed = v),
        ),
        LdSwitch<double>(
          label: "Transform Offset",
          value: _transformOffset,
          onChanged: (v) => setState(() => _transformOffset = v),
          children: {
            0: const Text("0"),
            10: const Text("10"),
            20: const Text("20"),
            50: const Text("50"),
          },
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  LdText("Mass: $mass"),
                  Slider(
                      max: 100,
                      min: 1,
                      value: mass,
                      onChanged: (value) => setState(() => mass = value)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  LdText("Spring Constant: $springConstant"),
                  Slider(
                      max: 100,
                      min: 1,
                      value: springConstant,
                      onChanged: (value) =>
                          setState(() => springConstant = value)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  LdText("Damping Coefficient: $dampingCoefficient"),
                  Slider(
                      max: 20,
                      min: 5,
                      value: dampingCoefficient,
                      onChanged: (value) =>
                          setState(() => dampingCoefficient = value)),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
