import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/approval/tool_allow_field_tree.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

/// Result from [LdToolAllowRulePickerSheet] / [ldShowToolAllowRulePicker].
class LdToolAllowRulePickerResult {
  const LdToolAllowRulePickerResult({required this.approved, this.savedRule});

  final bool approved;
  final LdToolAllowRule? savedRule;
}

/// Lets the user pin argument fields as exact, wildcard, or not-allowed.
class LdToolAllowRulePickerSheet extends StatefulWidget {
  const LdToolAllowRulePickerSheet({
    super.key,
    required this.toolName,
    required this.functionArguments,
    this.inputSchema,
    this.seedRule,
  });

  final String toolName;
  final Object? functionArguments;
  final Object? inputSchema;
  final LdToolAllowRule? seedRule;

  @override
  State<LdToolAllowRulePickerSheet> createState() =>
      _LdToolAllowRulePickerSheetState();
}

class _LdToolAllowRulePickerSheetState
    extends State<LdToolAllowRulePickerSheet> {
  late LdToolAllowFieldSession _session;
  late final Map<String, dynamic> _requestArgs;

  @override
  void initState() {
    super.initState();
    _requestArgs = ldParseToolArguments(widget.functionArguments);
    final seed = widget.seedRule != null &&
            widget.seedRule!.toolName == widget.toolName
        ? widget.seedRule
        : null;
    _session = ldBuildToolAllowFieldSession(
      inputSchema: widget.inputSchema,
      arguments: widget.functionArguments,
      seedRule: seed,
    );
  }

  void _pop(LdToolAllowRulePickerResult result) {
    Navigator.of(context).pop(result);
  }

  LdToolAllowRule get _draftRule => _session.toRule(widget.toolName);

  bool get _draftMatchesRequest =>
      _draftRule.matches(widget.toolName, _requestArgs);

  String get _rulePreviewJson =>
      const JsonEncoder.withIndent('  ').convert(_draftRule.toJson());

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final matchesRequest = _draftMatchesRequest;

    return LdScaffold(
      body: LdAppBar(
        title: Text('Allow ${widget.toolName}'),
        bottom: matchesRequest
            ? null
            : const LdHint(
                type: LdHintType.warning,
                withBackground: true,
                child: Text(
                  'This rule would not match the current request. '
                  'The request will still be approved once, but an identical '
                  'future call will need approval again.',
                ),
              ).padS(),
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
                  _pop(
                    LdToolAllowRulePickerResult(
                      approved: true,
                      savedRule: _draftRule,
                    ),
                  );
                },
                child: Text(
                  matchesRequest
                      ? 'Approve & save rule'
                      : 'Approve once & save rule',
                ),
              ),
            ),
          ],
          child: LdScaffoldBody(
            addContainer: true,
            children: [
              LdText.p(
                'Choose which argument fields must match exactly, '
                'allow any value, or mark as not allowed. Not allowed fields '
                'are omitted from the rule — if the agent passes them later, '
                'approval is required again. Nested object alternatives are '
                'not OR-combined; use Any on the parent or separate rules.',
              ),
              LdToolAllowFieldTree(
                session: _session,
                onPinChanged: (path, pin) {
                  setState(() {
                    _session = _session.copyWithPins({
                      ..._session.pins,
                      path: pin,
                    });
                  });
                },
                emptyLabel:
                    'No arguments to pin — rule will require no arguments.',
              ).padL(),
              LdAccordion.single(
                initialOpen: false,
                size: LdSize.s,
                header: LdText.l('Rule preview'),
                child: Container(
                  width: double.infinity,
                  padding: theme.pad(size: LdSize.s),
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: theme.radius(LdSize.s),
                    border: Border.all(color: theme.border),
                  ),
                  child: SelectableText(
                    _rulePreviewJson,
                    style: ldBuildTextStyle(
                      theme,
                      LdTextType.label,
                      LdSize.xs,
                      color: theme.textMuted,
                    ).copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
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
  Object? inputSchema,
  LdToolAllowRule? seedRule,
}) {
  return LdModalRoute<LdToolAllowRulePickerResult>(
    context: context,
    dialogSize: LdSize.l,
    pageBuilder: (modalContext) => LdToolAllowRulePickerSheet(
      toolName: toolName,
      functionArguments: arguments,
      inputSchema: inputSchema,
      seedRule: seedRule,
    ),
  ).show(context, useRootNavigator: true);
}
