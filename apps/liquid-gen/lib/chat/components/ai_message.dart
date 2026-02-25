import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

import '../chat_provider.dart';

class AIMessage extends StatelessWidget {
  final ChatMessage message;

  const AIMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: theme.pad(size: LdSize.s).vertical,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: LdCard(
              padding: theme.pad(size: LdSize.m),
              child: LdText.p(message.content),
            ),
          ),
        ],
      ),
    );
  }
}
