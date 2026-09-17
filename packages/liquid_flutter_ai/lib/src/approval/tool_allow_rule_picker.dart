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
  late final LdToolAllowRule _usedArgumentsRule;
  late final LdToolAllowRule _usedWildcardRule;
  bool _wildcard = false;

  @override
  void initState() {
    super.initState();
    _requestArgs = ldParseToolArguments(widget.functionArguments);
    final seed = widget.seedRule != null &&
            widget.seedRule!.toolName == widget.toolName
        ? widget.seedRule
        : null;
    _wildcard = seed?.wildcard ?? false;
    _session = _buildSession(seedRule: seed);
    _usedArgumentsRule = _buildSession().toRule(widget.toolName);
    _usedWildcardRule = _buildUsedWildcardSession().toRule(widget.toolName);
  }

  LdToolAllowFieldSession _buildSession({LdToolAllowRule? seedRule}) =>
      ldBuildToolAllowFieldSession(
        inputSchema: widget.inputSchema,
        arguments: widget.functionArguments,
        seedRule: seedRule,
      );

  /// Session where every argument path used by the request is pinned to Any.
  LdToolAllowFieldSession _buildUsedWildcardSession() {
    final session = _buildSession();
    final usedPaths = <String>{};
    void walk(Map<String, dynamic> map, String prefix) {
      for (final entry in map.entries) {
        final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
        usedPaths.add(path);
        if (entry.value is Map) {
          walk(Map<String, dynamic>.from(entry.value as Map), path);
        }
      }
    }

    walk(_requestArgs, '');
    final pins = <String, LdToolAllowFieldPin>{};
    for (final entry in session.pins.entries) {
      pins[entry.key] = usedPaths.contains(entry.key)
          ? const LdToolAllowFieldPin(mode: LdToolAllowPinMode.wildcard)
          : entry.value;
    }
    return session.copyWithPins(pins);
  }

  void _pop(LdToolAllowRulePickerResult result) {
    Navigator.of(context).pop(result);
  }

  void _applyWildcard() {
    setState(() => _wildcard = true);
  }

  void _applyUsedArguments() {
    setState(() {
      _wildcard = false;
      _session = _buildSession();
    });
  }

  void _applyUsedWildcard() {
    setState(() {
      _wildcard = false;
      _session = _buildUsedWildcardSession();
    });
  }

  bool get _usedArgumentsActive =>
      !_wildcard && _draftRule == _usedArgumentsRule;

  bool get _usedWildcardActive => !_wildcard && _draftRule == _usedWildcardRule;

  LdToolAllowRule get _draftRule => _wildcard
      ? LdToolAllowRule.wildcardAll(toolName: widget.toolName)
      : _session.toRule(widget.toolName);

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
                'allow any value (including when omitted), or mark as not '
                'allowed. Not allowed fields are omitted from the rule — if '
                'the agent passes them later, approval is required again. '
                'Nested object alternatives are not OR-combined; use Any on '
                'the parent or separate rules.',
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  LdButton(
                    mode: _wildcard
                        ? LdButtonMode.filled
                        : LdButtonMode.outline,
                    onPressed: _applyWildcard,
                    child: const Text('Allow any arguments'),
                  ),
                  LdButton(
                    mode: _usedArgumentsActive
                        ? LdButtonMode.filled
                        : LdButtonMode.outline,
                    onPressed: _applyUsedArguments,
                    child: const Text('Allow used'),
                  ),
                  LdButton(
                    mode: _usedWildcardActive
                        ? LdButtonMode.filled
                        : LdButtonMode.outline,
                    onPressed: _applyUsedWildcard,
                    child: const Text('Allow * for used'),
                  ),
                ],
              ),
              if (_wildcard)
                const LdHint(
                  type: LdHintType.info,
                  child: Text('Any arguments allowed for this tool.'),
                ).padL()
              else
                LdToolAllowFieldTree(
                  session: _session,
                  onPinChanged: (path, pin) {
                    setState(() {
                      _wildcard = false;
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
