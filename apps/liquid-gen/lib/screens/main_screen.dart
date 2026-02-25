import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../chat/chat_provider.dart';
import '../chat/chat_screen.dart';
import '../preview/preview_provider.dart';
import '../preview/preview_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => PreviewProvider()),
      ],
      child: LdScaffold(
        appBars: [
          LdAppBar(
            title: const Text('Liquid Gen'),
            actions: [
              LdButton.ghost(
                onPressed: () => context.push('/settings'),
                child: const Icon(LucideIcons.settings),
              ),
            ],
          ),
        ],
        body: Row(
          children: [
            // Left side: Chat interface
            Expanded(flex: 1, child: const ChatScreen()),
            // Right side: Preview interface
            Expanded(flex: 1, child: const PreviewScreen()),
          ],
        ),
      ),
    );
  }
}
