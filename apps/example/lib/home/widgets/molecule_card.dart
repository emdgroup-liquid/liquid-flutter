import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeMoleculeCard extends StatelessWidget {
  const HomeMoleculeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LdCard(
      footer: Row(
        children: [
          LdButton.ghost(child: Icon(LucideIcons.star), onPressed: () {}),
          LdButton.ghost(child: Icon(LucideIcons.messageCircle), onPressed: () {}),
          LdButton.ghost(child: Icon(LucideIcons.userPlus), onPressed: () {}),
          LdButton.ghost(child: Icon(LucideIcons.share), onPressed: () {}),
          Spacer(),
          LdTag(child: Text('100')),
        ],
      ),
      child: LdAutoSpace(
        children: [
          Image.asset('assets/molecule.png'),
          LdText.h('GCGR Antagonist 13K'),
          LdText.p('Automatic Retrosynthesis'),
          LdMute(child: LdText.ls('11/01/24, 4:28 AM')),
        ],
      ),
    );
  }
}
