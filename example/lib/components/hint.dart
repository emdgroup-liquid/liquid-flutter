import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HintDemo extends StatelessWidget {
  const HintDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComponentPage(
      title: "LdHint",
      demo: ComponentWell(
        child: LdAutoSpace(
          children: [
            LdHint(type: LdHintType.info, child: Text("Hello world")),
            LdHint(type: LdHintType.error, child: Text("Hello world")),
            LdHint(type: LdHintType.warning, child: Text("Hello world"))
          ],
        ),
      ),
    );
  }
}
