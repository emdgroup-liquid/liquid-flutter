import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/rrule/recurrence_occurrences.dart';
import 'package:liquid_flutter/src/rrule/recurrence_picker.dart';
import 'package:liquid_flutter/src/rrule/recurrence_timeline.dart';
import 'package:liquid_flutter/src/rrule/rrule_draft.dart';
import 'package:liquid_flutter/src/rrule/rrule_summary.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

String _recurrenceRulesSummary(
  List<RecurrenceRule> rules, {
  required LiquidLocalizations l10n,
  required String localeName,
}) {
  if (rules.isEmpty) {
    return l10n.selectRecurrences;
  }
  if (rules.length == 1) {
    return ldRecurrenceRuleSummary(
      rules.first,
      l10n: l10n,
      localeName: localeName,
    );
  }
  return l10n.recurrenceRulesCount(rules.length);
}

bool _rulesIncludeTime(List<RecurrenceRule> rules, DateTime start) {
  return rules.any((rule) {
    final draft = LdRecurrenceDraft.fromRule(rule, start: start);
    return draft.isSubDaily || draft.hasTimes;
  });
}

/// A labeled field that opens a modal to edit multiple [RecurrenceRule]s.
class LdRecurrenceMultiPicker extends StatelessWidget {
  const LdRecurrenceMultiPicker({
    super.key,
    this.value = const [],
    required this.onChanged,
    this.start,
    this.label,
    this.size = LdSize.m,
    this.disabled = false,
    this.useRootNavigator = false,
    this.config = const LdRecurrenceConfig(),
  });

  final List<RecurrenceRule> value;
  final ValueChanged<List<RecurrenceRule>> onChanged;

  /// First instance used to expand the rules (RFC 5545 DTSTART).
  ///
  /// Defaults to [DateTime.now] when omitted.
  final DateTime? start;
  final String? label;
  final LdSize size;
  final bool disabled;
  final bool useRootNavigator;
  final LdRecurrenceConfig config;

  @override
  Widget build(BuildContext context) {
    final l10n = LiquidLocalizations.of(context);
    final theme = LdTheme.of(context, listen: true);
    final localeName = Localizations.localeOf(context).toString();
    final summary = _recurrenceRulesSummary(
      value,
      l10n: l10n,
      localeName: localeName,
    );
    final lineBoxHeight = theme.labelSize(size) * ldLineHeight(LdTextType.label, size: size);
    final fieldPadding = theme.controlContentPadding(size) - EdgeInsets.all(theme.borderWidth);

    return LdBundle(
      children: [
        if (label != null)
          LdText.l(
            label!,
            size: size,
          ),
        LdTouchableSurface(
          allowTapOutside: true,
          key: const Key('recurrence_multi_picker_button'),
          disabled: disabled,
          onPressed: () async {
            final navigator = useRootNavigator ? Navigator.of(context, rootNavigator: true) : Navigator.of(context);
            final result = await navigator.push<List<RecurrenceRule>?>(
              LdModalRoute(
                context: context,
                pageBuilder: (context) => _LdRecurrenceMultiPickerModal(
                  initialValue: value,
                  start: start,
                  title: label ?? l10n.selectRecurrences,
                  config: config,
                ),
              ),
            );
            if (result != null) {
              onChanged(result);
            }
          },
          builder: (context, status, _) => Builder(
            builder: (context) {
              final colorBundle = inputColor(theme, status, isValid: true);
              return Container(
                clipBehavior: Clip.hardEdge,
                padding: fieldPadding,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorBundle.surface,
                  borderRadius: theme.radius(LdSize.s),
                  border: Border.all(
                    color: colorBundle.border,
                    width: theme.borderWidth,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: lineBoxHeight,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: LdText.l(
                      summary,
                      size: size,
                      color: colorBundle.text,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// List modal for managing multiple recurrence rules (tier 1).
class _LdRecurrenceMultiPickerModal extends StatefulWidget {
  const _LdRecurrenceMultiPickerModal({
    this.initialValue = const [],
    this.start,
    required this.title,
    this.config = const LdRecurrenceConfig(),
  });

  final List<RecurrenceRule> initialValue;
  final DateTime? start;
  final String title;
  final LdRecurrenceConfig config;

  @override
  State<_LdRecurrenceMultiPickerModal> createState() => _LdRecurrenceMultiPickerModalState();
}

class _LdRecurrenceMultiPickerModalState extends State<_LdRecurrenceMultiPickerModal> {
  late List<RecurrenceRule> _rules = List<RecurrenceRule>.from(widget.initialValue);

  DateTime get _start => widget.start ?? DateTime.now();

  Future<void> _addRule() async {
    final result = await Navigator.of(context).push<RecurrenceRule?>(
      LdModalRoute(
        context: context,
        pageBuilder: (context) => LdRecurrencePickerModal(
          start: widget.start,
          title: LiquidLocalizations.of(context).recurrenceAddRule,
          config: widget.config,
        ),
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _rules = [..._rules, result];
    });
  }

  Future<void> _editRule(int index) async {
    final result = await Navigator.of(context).push<RecurrenceRule?>(
      LdModalRoute(
        context: context,
        pageBuilder: (context) => LdRecurrencePickerModal(
          initialValue: _rules[index],
          start: widget.start,
          title: LiquidLocalizations.of(context).selectRecurrence,
          config: widget.config,
        ),
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _rules = [
        for (var i = 0; i < _rules.length; i++)
          if (i == index) result else _rules[i],
      ];
    });
  }

  void _removeRule(int index) {
    setState(() {
      _rules = [
        for (var i = 0; i < _rules.length; i++)
          if (i != index) _rules[i],
      ];
    });
  }

  void _openAllOccurrences(BuildContext context, {required bool includeTime}) {
    final localeName = Localizations.localeOf(context).toString();
    final all = ldRecurrenceMergedAllOccurrences(rules: _rules, start: _start);
    ldRecurrenceShowAllOccurrencesSheet(
      context,
      instances: all.instances,
      truncated: all.truncated,
      dateFormat: ldRecurrenceOccurrenceFormat(
        localeName,
        includeTime: includeTime,
      ),
      scaffoldKey: const Key('recurrence_multi_all_occurrences_sheet'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LiquidLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final preview = ldRecurrenceMergedOccurrencePreview(
      rules: _rules,
      start: _start,
    );
    final includeTime = _rulesIncludeTime(_rules, _start);
    final previewFormat = ldRecurrenceOccurrenceFormat(
      localeName,
      includeTime: includeTime,
    );
    final showPreview = widget.config.showPreview && (preview.next.isNotEmpty || preview.last != null);

    return LdScaffold(
      key: const Key('recurrence_multi_picker_sheet'),
      body: LdAppBar(
        title: Text(widget.title),
        child: LdAppBar.bottom(
          actions: [
            LdFlexibleChild(
              child: LdButton.vague(
                key: const Key('recurrence_multi_done'),
                width: double.infinity,
                child: Text(l10n.done),
                onPressed: () => Navigator.pop(context, List<RecurrenceRule>.from(_rules)),
              ),
            ),
          ],
          child: LdScaffoldBody(
            shrinkWrap: true,
            children: [
              LdAutoSpace(
                children: [
                  LdCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (var index = 0; index < _rules.length; index++) ...[
                          LdListItem(
                            padding: LdTheme.of(context).pad(),
                            key: Key('recurrence_multi_rule_$index'),
                            title: Text(
                              ldRecurrenceRuleSummary(
                                _rules[index],
                                l10n: l10n,
                                localeName: localeName,
                              ),
                            ),
                            onPressed: () => _editRule(index),
                            trailing: LdButton.ghost(
                              size: LdSize.s,
                              color: LdTheme.of(context).error,
                              key: Key('recurrence_multi_remove_$index'),
                              onPressed: () => _removeRule(index),
                              child: const Icon(LucideIcons.x),
                            ),
                          ),
                          if (index < _rules.length - 1) LdDivider(),
                        ],
                        if (_rules.isNotEmpty) LdDivider(),
                        LdListItem(
                          key: const Key('recurrence_multi_add'),
                          leading: LdAvatar(
                            size: LdSize.s,
                            child: const Icon(LucideIcons.plus),
                          ),
                          onPressed: _addRule,
                          title: Text(l10n.recurrenceAddRule),
                        ),
                      ],
                    ),
                  ),
                  if (showPreview) ...[
                    Row(
                      children: [
                        Expanded(child: LdText.caption(l10n.recurrenceNextOccurrences)),
                        if (preview.finite)
                          LdButton.ghost(
                            key: const Key('recurrence_multi_view_all'),
                            size: LdSize.s,
                            trailing: const Icon(LucideIcons.chevronRight),
                            onPressed: () => _openAllOccurrences(
                              context,
                              includeTime: includeTime,
                            ),
                            child: Text(l10n.recurrenceViewAllOccurrences),
                          ),
                      ],
                    ),
                    LdCard(
                      child: LdRecurrenceTimeline(
                        occurrences: preview.next,
                        last: preview.last,
                        lastOccurrenceNumber: preview.lastOccurrenceNumber,
                        dateFormat: previewFormat,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
