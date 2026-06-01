import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HomeScannerCard extends StatelessWidget {
  const HomeScannerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LdCard(
      footer: Row(
        children: [
          Expanded(child: LdAutoSpace(children: [LdText.l('v1.2.0'), LdText.caption('Firmware')])),
          Expanded(child: LdAutoSpace(children: [LdText.l('3 months ago'), LdText.caption('Last update')])),
        ],
      ),
      child: ConstrainedBox(constraints: BoxConstraints(maxHeight: 100), child: Image.asset('assets/scanner.png')),
    );
  }
}
