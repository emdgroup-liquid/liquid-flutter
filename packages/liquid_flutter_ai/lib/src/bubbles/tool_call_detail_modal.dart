import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';

/// Opens a modal with full tool-call arguments and result.
Future<void> showLdToolCallDetailModal(
  BuildContext context, {
  required LdToolCallItem item,
}) {
  final args = item.args ?? item.argsPreview ?? '';
  final result = item.result ?? item.resultPreview;

  return LdModalRoute<void>(
    context: context,
    pageBuilder: (modalContext) {
      final theme = LdTheme.of(modalContext);
      const monoStyle = TextStyle(fontFamily: 'monospace', fontSize: 12);

      return LdScaffold(
        body: LdAppBar.top(
          title: LdText.h('Tool call'),
          child: LdScaffoldBody(
            addContainer: true,
            children: [
              LdAutoSpace(
                children: [
                  LdText.p(item.name),
                  LdText.caption('Arguments'),
                  LdCard(
                    padding: theme.pad(),
                    child: SelectableText(args, style: monoStyle),
                  ),
                  if (result != null) ...[
                    LdText.caption('Result'),
                    LdCard(
                      padding: theme.pad(),
                      child: SelectableText(result, style: monoStyle),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    },
  ).show(context);
}
