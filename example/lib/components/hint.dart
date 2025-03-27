import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HintDemo extends StatelessWidget {
  const HintDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ComponentPage(
      title: "LdHint",
      demo: ComponentWell(
        child: LdAutoSpace(
          children: [
            LdHint(child: Text("Hello world"), type: LdHintType.info),
            LdHint(child: Text("Hello world"), type: LdHintType.error),
            LdHint(child: Text("Hello world"), type: LdHintType.warning)
          ],
        ),
      ),
    );
  }
}
