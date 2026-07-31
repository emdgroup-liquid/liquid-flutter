import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/approval/tool_allow_field_tree.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

/// Editable argument-pattern tree for an [LdToolAllowRule].
///
/// Pass [inputSchema] to show schema properties (including omitted optionals
/// as Not allowed). The current [rule] acts as the seed pattern so edits
/// extend multi-value leaves instead of replacing them blindly.
class LdToolAllowRuleEditor extends StatelessWidget {
  const LdToolAllowRuleEditor({
    super.key,
    required this.rule,
    required this.onChanged,
    this.inputSchema,
  });

  final LdToolAllowRule rule;
  final ValueChanged<LdToolAllowRule> onChanged;
  final Object? inputSchema;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    if (rule.wildcard) {
      return LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdText.l(rule.toolName),
          LdHint(
            type: LdHintType.info,
            child: const Text('Any arguments allowed for this tool.'),
          ),
          LdButton.outline(
            width: double.infinity,
            onPressed: () {
              onChanged(
                LdToolAllowRule(
                  toolName: rule.toolName,
                  argumentPattern: const {},
                ),
              );
            },
            child: const Text('Require specific arguments'),
          ),
        ],
      );
    }

    final session = ldBuildToolAllowFieldSession(
      inputSchema: inputSchema,
      arguments: null,
      seedRule: rule,
    );

    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdText.l(rule.toolName),
        LdText.p(
          'Tap a field to set Fixed, Any, or Not allowed. Fixed leaves may '
          'list several allowed values (OR). Nested object shapes are not '
          'OR-combined.',
          color: theme.textMuted,
          size: LdSize.s,
        ),
        LdToolAllowFieldTree(
          session: session,
          onPinChanged: (path, pin) {
            final next = session.copyWithPins({
              ...session.pins,
              path: pin,
            });
            onChanged(next.toRule(rule.toolName));
          },
          emptyLabel: 'No argument pattern — rule requires no arguments.',
        ),
        LdButton.outline(
          width: double.infinity,
          onPressed: () {
            onChanged(LdToolAllowRule.wildcardAll(toolName: rule.toolName));
          },
          child: const Text('Allow any arguments'),
        ),
      ],
    );
  }
}
