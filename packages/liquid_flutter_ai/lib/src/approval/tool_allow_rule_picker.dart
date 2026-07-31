import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/approval/tool_allow_field_tree.dart';
import 'package:liquid_flutter_ai/src/approval/tool_allow_rule.dart';

/// Result from [LdToolAllowRulePickerSheet] / [ldShowToolAllowRulePicker].
class LdToolAllowRulePickerResult {
  const LdToolAllowRulePickerResult({required this.approved, this.savedRule});

  final bool approved;
  final LdToolAllowRule? savedRule;
}

/// Lets the user pin argument fields as exact or wildcard before saving a rule.
class LdToolAllowRulePickerSheet extends StatefulWidget {
  const LdToolAllowRulePickerSheet({
    super.key,
    required this.toolName,
    required this.functionArguments,
  });

  final String toolName;
  final Object? functionArguments;

  @override
  State<LdToolAllowRulePickerSheet> createState() =>
      _LdToolAllowRulePickerSheetState();
}

class _LdToolAllowRulePickerSheetState
    extends State<LdToolAllowRulePickerSheet> {
  late final Map<String, dynamic> _args;
  late Map<String, LdToolAllowPinMode> _pins;

  @override
  void initState() {
    super.initState();
    _args = ldParseToolArguments(widget.functionArguments);
    _pins = ldDefaultPinsForArgs(_args);
  }

  void _pop(LdToolAllowRulePickerResult result) {
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      body: LdAppBar(
        title: Text('Allow ${widget.toolName}'),
        child: LdAppBar.bottom(
          actions: [
            LdButton.ghost(
              width: double.infinity,
              onPressed: () {
                _pop(const LdToolAllowRulePickerResult(approved: false));
              },
              child: Text('Cancel'),
            ),
            LdFlexibleChild(
              child: LdButton.vague(
                width: double.infinity,
                onPressed: () {
                  final rule = LdToolAllowRule.fromPicker(
                    widget.toolName,
                    _args,
                    _pins,
                  );
                  _pop(
                    LdToolAllowRulePickerResult(
                      approved: true,
                      savedRule: rule,
                    ),
                  );
                },
                child: Text('Approve & save rule'),
              ),
            ),
          ],
          child: LdScaffoldBody(
            addContainer: true,
            children: [
              LdText.p(
                'Choose which argument fields must match exactly, '
                'or allow any arguments for this tool on future calls. The agent will be able to use this tool on their own in accordance to the parameters you specify. If the agent passes additional arguments not covered by your choice, an approval will be triggered.',
              ),
              LdToolAllowFieldTree(
                args: _args,
                pins: _pins,
                onPinChanged: (path, mode) {
                  setState(() => _pins[path] = mode);
                },
                emptyLabel:
                    'No arguments to pin — rule will require no arguments.',
              ).padL(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens [LdToolAllowRulePickerSheet] via [LdModalRoute].
Future<LdToolAllowRulePickerResult?> ldShowToolAllowRulePicker(
  BuildContext context, {
  required String toolName,
  required Object? arguments,
}) {
  return LdModalRoute<LdToolAllowRulePickerResult>(
    context: context,
    dialogSize: LdSize.l,
    pageBuilder: (modalContext) => LdToolAllowRulePickerSheet(
      toolName: toolName,
      functionArguments: arguments,
    ),
  ).show(context, useRootNavigator: true);
}
