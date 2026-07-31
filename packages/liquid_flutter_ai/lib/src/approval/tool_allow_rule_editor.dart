import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/approval/tool_allow_field_tree.dart';
import 'package:liquid_flutter_ai/src/approval/tool_allow_rule.dart';

/// Editable argument-pattern tree for an [LdToolAllowRule].
///
/// Apps embed this in their own settings chrome. Toggling pins or switching
/// to "allow any args" emits a new rule via [onChanged].
class LdToolAllowRuleEditor extends StatelessWidget {
  const LdToolAllowRuleEditor({
    super.key,
    required this.rule,
    required this.onChanged,
  });

  final LdToolAllowRule rule;
  final ValueChanged<LdToolAllowRule> onChanged;

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

    final args = ldArgsFromPattern(rule.argumentPattern);
    final pins = ldPinsFromPattern(rule.argumentPattern);
    // Ensure every path from args has a pin (pattern may omit nested keys).
    final mergedPins = {...ldDefaultPinsForArgs(args), ...pins};

    return LdAutoSpace(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdText.l(rule.toolName),
        LdText.p(
          'Toggle exact vs wildcard for each argument field.',
          color: theme.textMuted,
          size: LdSize.s,
        ),
        LdToolAllowFieldTree(
          args: args,
          pins: mergedPins,
          onPinChanged: (path, mode) {
            final nextPins = Map<String, LdToolAllowPinMode>.from(mergedPins)
              ..[path] = mode;
            onChanged(
              LdToolAllowRule.fromPicker(rule.toolName, args, nextPins),
            );
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
