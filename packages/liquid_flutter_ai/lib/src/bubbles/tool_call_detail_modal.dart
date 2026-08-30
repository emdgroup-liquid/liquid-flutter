import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';

/// Pretty-prints [value] when it is a JSON object or array; otherwise returns
/// the original string unchanged (including invalid / scalar JSON).
String ldPrettyPrintJsonish(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return value;
  }
  if (!(trimmed.startsWith('{') || trimmed.startsWith('['))) {
    return value;
  }
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is! Map && decoded is! List) {
      return value;
    }
    return const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    return value;
  }
}

/// Opens a modal with full tool-call arguments and result.
Future<void> showLdToolCallDetailModal(
  BuildContext context, {
  required LdToolCallItem item,
}) {
  final args = ldPrettyPrintJsonish(item.args ?? item.argsPreview ?? '');
  final result = item.result ?? item.resultPreview;
  final prettyResult = result == null ? null : ldPrettyPrintJsonish(result);

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
                  if (prettyResult != null) ...[
                    LdText.caption('Result'),
                    LdCard(
                      padding: theme.pad(),
                      child: SelectableText(prettyResult, style: monoStyle),
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
