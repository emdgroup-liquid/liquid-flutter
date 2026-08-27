import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/rrule/rrule_draft.dart';

/// A labeled field that opens a modal to edit a [RecurrenceRule].
class LdRecurrencePicker extends StatelessWidget {
  const LdRecurrencePicker({
    super.key,
    this.value,
    required this.onChanged,
    this.start,
    this.label,
    this.size = LdSize.m,
    this.disabled = false,
    this.useRootNavigator = false,
    this.config = const LdRecurrenceConfig(),
  });

  final RecurrenceRule? value;
  final ValueChanged<RecurrenceRule> onChanged;

  /// First instance used to expand the rule (RFC 5545 DTSTART).
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
    final summary = ldRecurrenceRuleSummary(
      value,
      l10n: l10n,
      localeName: Localizations.localeOf(context).toString(),
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
          key: const Key('recurrence_picker_button'),
          disabled: disabled,
          onPressed: () async {
            final navigator = useRootNavigator ? Navigator.of(context, rootNavigator: true) : Navigator.of(context);
            final result = await navigator.push<RecurrenceRule?>(
              LdModalRoute(
                context: context,
                pageBuilder: (context) => LdRecurrencePickerModal(
                  initialValue: value,
                  start: start,
                  title: label ?? l10n.selectRecurrence,
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

/// Modal host for [LdRecurrenceForm]. Not exported from the package barrel.
class LdRecurrencePickerModal extends StatefulWidget {
  const LdRecurrencePickerModal({
    super.key,
    this.initialValue,
    this.start,
    required this.title,
    this.config = const LdRecurrenceConfig(),
  });

  final RecurrenceRule? initialValue;
  final DateTime? start;
  final String title;
  final LdRecurrenceConfig config;

  @override
  State<LdRecurrencePickerModal> createState() => _LdRecurrencePickerModalState();
}

class _LdRecurrencePickerModalState extends State<LdRecurrencePickerModal> {
  late RecurrenceRule _rule = widget.initialValue ?? LdRecurrenceDraft.initial(start: widget.start).toRule();

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      key: const Key('recurrence_picker_sheet'),
      body: LdAppBar(
        title: Text(widget.title),
        child: LdAppBar.bottom(
          actions: [
            LdFlexibleChild(
              child: LdButton.vague(
                key: const Key('done'),
                width: double.infinity,
                child: Text(LiquidLocalizations.of(context).done),
                onPressed: () => Navigator.pop(context, _rule),
              ),
            ),
          ],
          child: LdScaffoldBody(
            children: [
              LdRecurrenceForm(
                value: _rule,
                start: widget.start,
                config: widget.config,
                onChanged: (rule) {
                  setState(() {
                    _rule = rule;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
