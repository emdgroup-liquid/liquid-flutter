import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeSalesCard extends StatelessWidget {
  const HomeSalesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LdCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [LdText.l('Sales'), Spacer(), Icon(LucideIcons.arrowRight, size: 16)]),
          ldSpacerL,
          LdCounter.l(value: 9452002),
          LdText.ls('+13% from last month'),
        ],
      ),
    );
  }
}
