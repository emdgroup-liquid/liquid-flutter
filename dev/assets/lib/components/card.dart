import 'package:flutter/material.dart';

import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class CardDemo extends StatefulWidget {
  const CardDemo({Key? key}) : super(key: key);

  @override
  State<CardDemo> createState() => _CardDemoState();
}

class _CardDemoState extends State<CardDemo> {
  bool _onSurface = false;
  bool _flat = true;

  _toggleOnSurface(bool newState) {
    setState(() {
      _onSurface = newState;
    });
  }

  _toggleFlat(bool newState) {
    setState(() {
      _flat = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    var ipsum = const Text(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc vel tincidunt lacinia, nunc nisl aliquam nisl, eu aliquet nisl nisl eu ante.");
    return ComponentPage(
      title: "LdCard",
      demo: LdAutoSpace(
        children: [
          ComponentWell(
            onSurface: _onSurface,
            child: Column(
              children: [
                /*begin demo:LdCard*/
                LdCard(
                  flat: _flat,
                  child: const LdTextL("Hello world"),
                ),
                ldSpacerM,
                LdCard(
                  flat: _flat, // bool

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LdTextH(
                        "Hello footer",
                      ),
                      ldSpacerM,
                      // lorem ipsum text
                      ipsum,
                    ],
                  ),
                  header: const Row(
                    children: [
                      LdTag(child: Text("Important information for you")),
                    ],
                  ),
                  footer: Row(
                    children: [
                      LdButton(
                        child: const Text("Action"),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                /*end demo:LdCard*/
                ldSpacerM,
                const LdCard(
                    child: LdCard(
                  child: LdCard(
                    header: Text("Foo"),
                    child: LdInput(hint: "Search..."),
                  ),
                ))
              ],
            ),
          ),
          LdToggle(
              label: "On Surface background",
              checked: _onSurface,
              onChanged: _toggleOnSurface),
          LdToggle(
            label: "Flat (default)",
            checked: _flat,
            onChanged: _toggleFlat,
          )
        ],
      ),
    );
  }
}
