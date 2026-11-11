import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

import 'api_key_list_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      appBars: [LdAppBar(title: Text('Settings'))],
      body: LdScaffoldBody(
        addContainer: true,
        children: [
          LdText.h('API Keys'),
          LdText.p(
            'Configure API keys for AI providers. Keys are stored securely on your device.',
          ),
          LdCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ApiKeyListItem(provider: 'openai', label: 'OpenAI'),
                ApiKeyListItem(provider: 'anthropic', label: 'Anthropic'),
                ApiKeyListItem(provider: 'gemini', label: 'Gemini'),
              ],
            ),
          ),
          LdText.caption(
            'Note: Ollama runs locally and does not require an API key.',
          ),
        ],
      ),
    );
  }
}
