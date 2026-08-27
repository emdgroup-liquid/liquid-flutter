import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/rrule/recurrence_occurrences.dart';
import 'package:liquid_flutter/src/rrule/recurrence_timeline.dart';
import 'package:liquid_flutter/src/rrule/rrule_draft.dart';
import 'package:liquid_flutter/src/rrule/rrule_summary.dart';

const _nthOccurrences = [1, 2, 3, 4, -1];

/// Inline editor for an RFC 5545 [RecurrenceRule].
///
/// Supports secondly through yearly frequencies, interval, weekly weekdays,
/// monthly/yearly day or nth-weekday, times of day (`BYHOUR` / `BYMINUTE`),
/// and never / until / count endings.
/// Restrict available parts with [config].
class LdRecurrenceForm extends StatefulWidget {
  const LdRecurrenceForm({
    super.key,
    this.value,
    required this.onChanged,
    this.start,
    this.disabled = false,
    this.config = const LdRecurrenceConfig(),
  });

  final RecurrenceRule? value;
  final ValueChanged<RecurrenceRule> onChanged;

  /// First instance used to expand the rule (RFC 5545 DTSTART).
  ///
  /// Defaults to [DateTime.now] when omitted.
  final DateTime? start;
  final bool disabled;
  final LdRecurrenceConfig config;

  @override
  State<LdRecurrenceForm> createState() => _LdRecurrenceFormState();
}

class _LdRecurrenceFormState extends State<LdRecurrenceForm> {
  late LdRecurrenceDraft _draft;
  late final TextEditingController _intervalController;
  late final TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    _draft = widget.value != null
        ? LdRecurrenceDraft.fromRule(widget.value!, start: widget.start)
        : LdRecurrenceDraft.initial(start: widget.start);
    _intervalController = TextEditingController(text: _draft.interval.toString());
    _countController = TextEditingController(text: _draft.count.toString());
  }

  @override
  void didUpdateWidget(covariant LdRecurrenceForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == oldWidget.value) {
      return;
    }
    _draft = widget.value != null
        ? LdRecurrenceDraft.fromRule(widget.value!, start: widget.start)
        : LdRecurrenceDraft.initial(start: widget.start);
    _intervalController.text = _draft.interval.toString();
    _countController.text = _draft.count.toString();
  }

  @override
  void dispose() {
    _intervalController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _emit(LdRecurrenceDraft draft) {
    final next = widget.config.clamp(draft);
    setState(() {
      _draft = next;
    });
    widget.onChanged(next.toRule());
  }

  LdRecurrenceDraft get _configuredDraft => widget.config.clamp(_draft);

  @override
  Widget build(BuildContext context) {
    final l10n = LiquidLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final theme = LdTheme.of(context);
    final showUnsupported = widget.value != null && ldRecurrenceRuleHasUnsupportedParts(widget.value!);
    final weekdays = ldLocaleOrderedWeekdays(context);
    final start = widget.start ?? DateTime.now();
    final draft = _configuredDraft;
    final rule = draft.toRule();
    final preview = ldRecurrenceOccurrencePreview(rule: rule, start: start);
    final previewFormat = ldRecurrenceOccurrenceFormat(
      localeName,
      includeTime: draft.isSubDaily || draft.hasTimes,
    );
    final frequencies = widget.config.enabledFrequencies;
    final endModes = widget.config.enabledEndModes;
    final showEndRadios = endModes.length > 1;

    return LdAutoSpace(
      children: [
        if (showUnsupported)
          LdHint(
            type: LdHintType.warning,
            withBackground: true,
            child: Text(l10n.recurrenceUnsupportedHint),
          ),
        Row(
          children: [
            LdText.l(l10n.recurrenceEvery),
            if (widget.config.showInterval) ...[
              ldSpacerS,
              SizedBox(
                width: 88,
                child: LdInput(
                  key: const Key('recurrence_interval'),
                  hint: '1',
                  controller: _intervalController,
                  disabled: widget.disabled,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null && parsed >= 1) {
                      _emit(_draft.copyWith(interval: parsed));
                    }
                  },
                ),
              ),
            ],
            ldSpacerS,
            Expanded(
              child: LdSelect<Frequency>(
                key: const Key('recurrence_frequency'),
                value: draft.frequency,
                disabled: widget.disabled,
                onChanged: (frequency) => _emit(_draft.copyWith(frequency: frequency)),
                items: [
                  for (final frequency in frequencies)
                    LdSelectItem(
                      value: frequency,
                      child: Text(
                        widget.config.showInterval
                            ? ldRecurrenceUnitLabel(frequency, draft.interval, l10n)
                            : ldRecurrenceIntervalLabel(frequency, draft.interval, l10n),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (draft.isWeekly && widget.config.showWeekdays)
          Wrap(
            spacing: theme.pad(size: LdSize.s).left,
            runSpacing: theme.pad(size: LdSize.s).left,
            children: [
              for (final day in weekdays)
                LdButton.outline(
                  key: Key('recurrence_weekday_$day'),
                  active: _draft.weekdays.contains(day),
                  size: LdSize.s,
                  disabled: widget.disabled,
                  onPressed: () => _toggleWeekday(day),
                  child: Text(ldRecurrenceWeekdayShortLabel(day, localeName)),
                )
            ],
          ),
        if ((draft.isMonthly || draft.isYearly) && widget.config.showMonthlyOptions)
          ..._buildMonthlyYearly(context, l10n, localeName),
        if (!draft.isSubDaily && widget.config.showTimes) ..._buildTimes(context, l10n, draft),
        if (widget.config.showEnding) ...[
          LdDivider(),
          LdText.caption(l10n.recurrenceEnds),
          if (endModes.contains(LdRecurrenceEndMode.never) && showEndRadios)
            LdRadio(
              key: const Key('recurrence_end_never'),
              label: l10n.recurrenceEndsNever,
              checked: draft.endMode == LdRecurrenceEndMode.never,
              disabled: widget.disabled,
              onChanged: (checked) {
                if (checked) {
                  _emit(_draft.copyWith(endMode: LdRecurrenceEndMode.never));
                }
              },
            ),
          if (endModes.contains(LdRecurrenceEndMode.until)) ...[
            if (showEndRadios)
              LdRadio(
                key: const Key('recurrence_end_until'),
                label: l10n.recurrenceEndsOn,
                checked: draft.endMode == LdRecurrenceEndMode.until,
                disabled: widget.disabled,
                onChanged: (checked) {
                  if (checked) {
                    _emit(
                      _draft.copyWith(
                        endMode: LdRecurrenceEndMode.until,
                        until: _draft.until ?? widget.start ?? DateTime.now().add(const Duration(days: 30)),
                      ),
                    );
                  }
                },
              ),
            if (draft.endMode == LdRecurrenceEndMode.until) ..._buildUntilPickers(l10n),
          ],
          if (endModes.contains(LdRecurrenceEndMode.count)) ...[
            if (showEndRadios)
              LdRadio(
                key: const Key('recurrence_end_count'),
                label: l10n.recurrenceEndsAfter,
                checked: draft.endMode == LdRecurrenceEndMode.count,
                disabled: widget.disabled,
                onChanged: (checked) {
                  if (checked) {
                    _emit(_draft.copyWith(endMode: LdRecurrenceEndMode.count));
                  }
                },
              ),
            if (draft.endMode == LdRecurrenceEndMode.count)
              Row(
                children: [
                  SizedBox(
                    width: 88,
                    child: LdInput(
                      key: const Key('recurrence_count'),
                      hint: '10',
                      controller: _countController,
                      disabled: widget.disabled,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed >= 1) {
                          _emit(_draft.copyWith(count: parsed));
                        }
                      },
                    ),
                  ),
                  ldSpacerS,
                  Expanded(
                    child: LdText.l(l10n.recurrenceOccurrences(draft.count)),
                  ),
                ],
              ),
          ],
        ],
        if (widget.config.showPreview && (preview.next.isNotEmpty || preview.last != null)) ...[
          Row(
            children: [
              Expanded(child: LdText.caption(l10n.recurrenceNextOccurrences)),
              if (preview.finite)
                LdButton.ghost(
                  key: const Key('recurrence_view_all'),
                  size: LdSize.s,
                  onPressed: () => _openAllOccurrences(context),
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
    );
  }

  List<Widget> _buildMonthlyYearly(
    BuildContext context,
    LiquidLocalizations l10n,
    String localeName,
  ) {
    final theme = LdTheme.of(context);
    return [
      if (_draft.isYearly)
        Wrap(
          spacing: theme.pad(size: LdSize.s).left,
          runSpacing: theme.pad(size: LdSize.s).left,
          children: [
            for (final month in List<int>.generate(12, (index) => index + 1))
              LdButton.outline(
                key: Key('recurrence_month_$month'),
                size: LdSize.s,
                active: _draft.months.contains(month),
                disabled: widget.disabled,
                onPressed: () => _toggleMonth(month),
                child: Text(ldRecurrenceMonthShortLabel(month, localeName)),
              )
          ],
        ),
      LdCard(
          flat: _draft.monthlyMode == LdRecurrenceMonthlyMode.byMonthDay,
          child: LdAutoSpace(children: [
            LdRadio(
              label: l10n.recurrenceOnDay,
              checked: _draft.monthlyMode == LdRecurrenceMonthlyMode.byMonthDay,
              disabled: widget.disabled,
              onChanged: (checked) {
                if (checked) {
                  _emit(_draft.copyWith(monthlyMode: LdRecurrenceMonthlyMode.byMonthDay));
                }
              },
            ),
            LdSelect<int>(
              key: const Key('recurrence_month_day'),
              value: _draft.monthDay,
              disabled: widget.disabled || _draft.monthlyMode != LdRecurrenceMonthlyMode.byMonthDay,
              onChanged: (day) => _emit(_draft.copyWith(monthDay: day)),
              items: [
                for (final day in List<int>.generate(31, (index) => index + 1))
                  LdSelectItem(
                    value: day,
                    child: Text('$day'),
                  ),
                LdSelectItem(
                  value: -1,
                  child: Text(l10n.recurrenceLastDay),
                ),
              ],
            ),
          ])),
      ldSpacerM,
      LdCard(
          flat: _draft.monthlyMode == LdRecurrenceMonthlyMode.byNthWeekday,
          child: LdAutoSpace(children: [
            LdRadio(
              label: l10n.recurrenceOnThe,
              checked: _draft.monthlyMode == LdRecurrenceMonthlyMode.byNthWeekday,
              disabled: widget.disabled,
              onChanged: (checked) {
                if (checked) {
                  _emit(_draft.copyWith(monthlyMode: LdRecurrenceMonthlyMode.byNthWeekday));
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: LdSelect<int>(
                    key: const Key('recurrence_nth_occurrence'),
                    value: _draft.nthOccurrence,
                    disabled: widget.disabled || _draft.monthlyMode != LdRecurrenceMonthlyMode.byNthWeekday,
                    onChanged: (occurrence) => _emit(_draft.copyWith(nthOccurrence: occurrence)),
                    items: [
                      for (final occurrence in _nthOccurrences)
                        LdSelectItem(
                          value: occurrence,
                          child: Text(ldRecurrenceNthLabel(occurrence, l10n)),
                        ),
                    ],
                  ),
                ),
                ldSpacerS,
                Expanded(
                  child: LdSelect<int>(
                    key: const Key('recurrence_nth_weekday'),
                    value: _draft.nthWeekday,
                    disabled: widget.disabled || _draft.monthlyMode != LdRecurrenceMonthlyMode.byNthWeekday,
                    onChanged: (weekday) => _emit(_draft.copyWith(nthWeekday: weekday)),
                    items: [
                      for (final day in ldLocaleOrderedWeekdays(context))
                        LdSelectItem(
                          value: day,
                          child: Text(ldRecurrenceWeekdayLabel(day, localeName)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ])),
    ];
  }

  List<Widget> _buildUntilPickers(LiquidLocalizations l10n) {
    final until = _draft.until ?? DateTime.now();
    return [
      LdDatePicker(
        value: until,
        disabled: widget.disabled,
        onChanged: (date) {
          final merged = DateTime(
            date.year,
            date.month,
            date.day,
            until.hour,
            until.minute,
            until.second,
          );
          _emit(_draft.copyWith(until: merged));
        },
      ),
      if (_draft.isSubDaily)
        LdTimePicker(
          value: TimeOfDay(hour: until.hour, minute: until.minute),
          disabled: widget.disabled,
          onChanged: (time) {
            _emit(
              _draft.copyWith(
                until: DateTime(
                  until.year,
                  until.month,
                  until.day,
                  time.hour,
                  time.minute,
                ),
              ),
            );
          },
        ),
    ];
  }

  void _openAllOccurrences(BuildContext context) {
    final localeName = Localizations.localeOf(context).toString();
    final start = widget.start ?? DateTime.now();
    final all = ldRecurrenceAllOccurrences(rule: _draft.toRule(), start: start);
    ldRecurrenceShowAllOccurrencesSheet(
      context,
      instances: all.instances,
      truncated: all.truncated,
      dateFormat: ldRecurrenceOccurrenceFormat(
        localeName,
        includeTime: _draft.isSubDaily || _draft.hasTimes,
      ),
      scaffoldKey: const Key('recurrence_all_occurrences_sheet'),
    );
  }

  List<Widget> _buildTimes(
    BuildContext context,
    LiquidLocalizations l10n,
    LdRecurrenceDraft draft,
  ) {
    final mode = widget.config.timesMode;
    final minuteOptions = ldRecurrenceMinuteOptions(
      precision: widget.config.minutePrecision,
      selected: draft.minutes,
    );
    final showMatrixHint = mode == LdRecurrenceTimesMode.matrix && draft.hours.length > 1 && draft.minutes.length > 1;

    return [
      LdDivider(),
      LdText.caption(l10n.recurrenceAt),
      LdText.l(l10n.recurrenceHours),
      LdHorizontalScroll(
        key: const Key('recurrence_hours'),
        layout: LdHorizontalScrollLayout.adaptive,
        initialPeek: false,
        children: [
          for (var hour = 0; hour < 24; hour++)
            LdButton.outline(
              key: Key('recurrence_hour_$hour'),
              active: draft.hours.contains(hour),
              size: LdSize.s,
              disabled: widget.disabled,
              onPressed: () => _emit(_draft.toggleHour(hour, mode)),
              child: Text(hour.toString().padLeft(2, '0')),
            ),
        ],
      ),
      LdText.l(l10n.recurrenceMinutes),
      LdHorizontalScroll(
        key: const Key('recurrence_minutes'),
        layout: LdHorizontalScrollLayout.adaptive,
        initialPeek: false,
        children: [
          for (final minute in minuteOptions)
            LdButton.outline(
              key: Key('recurrence_minute_$minute'),
              active: draft.minutes.contains(minute),
              size: LdSize.s,
              disabled: widget.disabled,
              onPressed: () => _emit(_draft.toggleMinute(minute, mode)),
              child: Text(minute.toString().padLeft(2, '0')),
            ),
        ],
      ),
      if (showMatrixHint)
        LdHint(
          type: LdHintType.info,
          withBackground: true,
          child: Text(l10n.recurrenceTimesMatrixHint),
        ),
    ];
  }

  void _toggleWeekday(int day) {
    if (widget.disabled) {
      return;
    }
    final next = Set<int>.from(_draft.weekdays);
    if (next.contains(day)) {
      next.remove(day);
    } else {
      next.add(day);
    }
    _emit(_draft.copyWith(weekdays: next));
  }

  void _toggleMonth(int month) {
    if (widget.disabled) {
      return;
    }
    final next = Set<int>.from(_draft.months);
    if (next.contains(month)) {
      next.remove(month);
    } else {
      next.add(month);
    }
    _emit(_draft.copyWith(months: next));
  }
}
