import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HomeStockCard extends StatelessWidget {
  const HomeStockCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LdCard(
      child: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LdText.h('Stock level', textAlign: TextAlign.center),
          LdMute(child: LdText.ls('0.5l remaining.', textAlign: TextAlign.center)),
          LdOrb(0.5),
          LdDivider(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              LdButton(child: Text('Add stock'), onPressed: () {}),
              LdButton.outline(child: Text('Refill'), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
