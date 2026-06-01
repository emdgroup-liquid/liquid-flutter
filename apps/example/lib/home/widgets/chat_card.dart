import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class HomeChatCard extends StatelessWidget {
  const HomeChatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return LdCard(
      child: LdAutoSpace(
        children: [
          Row(
            children: [
              LdAvatar(child: Text('S')),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LdText.hs('Sarah Johnson'),
                    LdMute(child: LdText.ls('sarah.johnson@example.com')),
                  ],
                ),
              ),
              LdButton.ghost(child: Icon(LucideIcons.plus), onPressed: () {}),
            ],
          ).spaceM(),
          Container(
            decoration: BoxDecoration(borderRadius: theme.radius(LdSize.m), color: theme.background),
            padding: theme.pad(size: LdSize.m),
            child: Text('Hi, how can I help you today?'),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(borderRadius: theme.radius(LdSize.m), color: theme.primaryColor),
              padding: theme.pad(size: LdSize.m),
              child: Text("Hello, I'm having trouble signing in", style: TextStyle(color: theme.primaryColorText)),
            ),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: theme.radius(LdSize.m), color: theme.background),
            padding: theme.pad(size: LdSize.m),
            child: Text("Okay, I'll help you with that"),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(borderRadius: theme.radius(LdSize.m), color: theme.primaryColor),
              padding: theme.pad(size: LdSize.m),
              child: Text('Thank you for helping me!', style: TextStyle(color: theme.primaryColorText)),
            ),
          ),
          Row(
            children: [
              Expanded(child: LdInput(hint: 'Type your message...')),
              LdButton(child: Icon(LucideIcons.send), onPressed: () {}),
            ],
          ).spaceM(),
        ],
      ),
    );
  }
}
