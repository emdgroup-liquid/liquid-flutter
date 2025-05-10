import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HintDemo extends StatelessWidget {
  const HintDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdHint",
      apiComponents: const ["LdHint", "LdHintType"],
      demo: ComponentWell(
        onSurface: true,
        description: const LdTextP(
          "The LdHint component is a visual indicator paired with a text message. The status of the hint is an LdIndicator.",
        ),
        child: LdAutoSpace(
          children: [
            LdHint(type: LdHintType.info, child: Text("Info")),
            LdHint(type: LdHintType.error, child: Text("Error")),
            LdHint(type: LdHintType.warning, child: Text("Warning")),
            LdHint(type: LdHintType.success, child: Text("Success")),
            LdHint(type: LdHintType.canceled, child: Text("Canceled")),
            LdHint(type: LdHintType.loading, child: Text("Loading")),
            LdHint(type: LdHintType.pending, child: Text("Pending")),
            LdHint(type: LdHintType.ongoing, child: Text("Ongoing")),
          ],
        ),
      ),
    );
  }
}
