import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class DividerDemo extends StatelessWidget {
  const DividerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentPage(
      title: "LdDivider",
      demo: Column(
        children: [
          ComponentWell(
            child: Column(
              children: [
                /*begin demo:LdDivider*/
                LdDivider(),
                /*end demo:LdDivider*/
                ldSpacerM,
                LdText(
                  "You have my undivided attention",
                ),
                ldSpacerM,
                LdDivider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
