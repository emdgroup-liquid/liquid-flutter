import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class HomeDownloadCard extends StatelessWidget {
  const HomeDownloadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LdCard(
      child: LdAutoSpace(
        children: [
          LdText.l('Your download has started'),
          Row(
            children: [
              LdAvatar(child: LdLoader(size: 24)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LdText.p('Downloading...'),
                    LdMute(child: LdText.ls('129MB / 1000MB ')),
                  ],
                ),
              ),
              LdButton.outline(child: Text('Cancel'), onPressed: () {}),
            ],
          ).spaceM(),
        ],
      ),
    );
  }
}
