import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/rrule/rrule_summary.dart';

/// Row metadata used to build [LdTimelineItem]s for recurrence previews.
@visibleForTesting
typedef LdRecurrenceTimelineRow = ({
  DateTime date,
  int occurrenceNumber,
  bool isLastOccurrence,
  String? connectorLabel,
});

/// Builds timeline rows from a compact next/last occurrence preview.
@visibleForTesting
List<LdRecurrenceTimelineRow> ldRecurrenceTimelineRows({
  required List<DateTime> occurrences,
  DateTime? last,
  int? lastOccurrenceNumber,
  required LiquidLocalizations l10n,
}) {
  if (occurrences.isEmpty && last == null) {
    return const [];
  }

  final lastIsSeparate = last != null && (occurrences.isEmpty || occurrences.last != last);
  final skippedBetween = switch ((lastIsSeparate, lastOccurrenceNumber)) {
    (true, final lastNumber?) when lastNumber > occurrences.length + 1 =>
      lastNumber - occurrences.length - 1,
    _ => 0,
  };
  final skippedLabel = switch (skippedBetween > 0) {
    true => l10n.recurrenceNMore(skippedBetween),
    false => null,
  };
  final rows = <LdRecurrenceTimelineRow>[];
  for (var index = 0; index < occurrences.length; index++) {
    final date = occurrences[index];
    final isLastNext = index == occurrences.length - 1;
    final connectorLabel = switch ((isLastNext, lastIsSeparate, isLastNext ? null : occurrences[index + 1])) {
      (false, _, final next) when next != null => ldRecurrenceDeltaLabel(date, next, l10n),
      (true, true, _) => skippedLabel,
      _ => null,
    };
    rows.add(
      (
        date: date,
        occurrenceNumber: index + 1,
        isLastOccurrence: last != null && date == last,
        connectorLabel: connectorLabel,
      ),
    );
  }

  if (lastIsSeparate) {
    rows.add(
      (
        date: last,
        occurrenceNumber: lastOccurrenceNumber ?? occurrences.length + 1,
        isLastOccurrence: true,
        connectorLabel: null,
      ),
    );
  }

  return rows;
}

LdTimelineLineType _lineType({
  required bool isLastOccurrence,
  required bool isLastDisplayed,
  required bool isFirstDisplayed,
}) {
  if (isLastOccurrence) {
    return LdTimelineLineType.end;
  }
  if (isLastDisplayed) {
    return LdTimelineLineType.fadeEnd;
  }
  if (isFirstDisplayed) {
    return LdTimelineLineType.start;
  }
  return LdTimelineLineType.solid;
}

/// Occurrence preview timeline built on [LdTimeline].
class LdRecurrenceTimeline extends StatelessWidget {
  const LdRecurrenceTimeline({
    super.key,
    required this.occurrences,
    this.last,
    this.lastOccurrenceNumber,
    this.truncated = false,
    required this.dateFormat,
  });

  final List<DateTime> occurrences;
  final DateTime? last;
  final int? lastOccurrenceNumber;

  /// When true, shows [LiquidLocalizations.recurrenceShowingFirstN] above the rail.
  final bool truncated;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final l10n = LiquidLocalizations.of(context);
    final rows = ldRecurrenceTimelineRows(
      occurrences: occurrences,
      last: last,
      lastOccurrenceNumber: lastOccurrenceNumber,
      l10n: l10n,
    );
    final items = <LdTimelineItem>[
      for (var index = 0; index < rows.length; index++)
        _itemForRow(
          l10n: l10n,
          row: rows[index],
          isFirstDisplayed: index == 0,
          isLastDisplayed: index == rows.length - 1,
        ),
    ];

    final timeline = LdTimeline(items: items);
    if (!truncated) {
      return timeline;
    }

    return LdAutoSpace(
      children: [
        LdHint(
          type: LdHintType.info,
          withBackground: true,
          child: Text(l10n.recurrenceShowingFirstN(occurrences.length)),
        ),
        timeline,
      ],
    );
  }

  LdTimelineItem _itemForRow({
    required LiquidLocalizations l10n,
    required LdRecurrenceTimelineRow row,
    required bool isFirstDisplayed,
    required bool isLastDisplayed,
  }) {
    final ordinal = ldRecurrenceOrdinal(
      row.occurrenceNumber,
      l10n.localeName,
    );
    final title = switch (row.isLastOccurrence) {
      true => l10n.recurrenceLastNthOccurrence(ordinal),
      false => l10n.recurrenceNthOccurrence(ordinal),
    };

    return LdTimelineItem(
      time: Text(dateFormat.format(row.date)),
      title: Text(title),
      connectorLabel: row.connectorLabel != null ? Text(row.connectorLabel!) : null,
      lineType: _lineType(
        isLastOccurrence: row.isLastOccurrence,
        isLastDisplayed: isLastDisplayed,
        isFirstDisplayed: isFirstDisplayed,
      ),
    );
  }
}

/// Pushes the full occurrence list sheet used by form and multi-picker.
void ldRecurrenceShowAllOccurrencesSheet(
  BuildContext context, {
  required List<DateTime> instances,
  required bool truncated,
  required DateFormat dateFormat,
  Key? scaffoldKey,
}) {
  final l10n = LiquidLocalizations.of(context);
  final last = truncated || instances.isEmpty ? null : instances.last;

  Navigator.of(context).push<void>(
    LdModalRoute(
      context: context,
      pageBuilder: (context) {
        return LdScaffold(
          key: scaffoldKey,
          body: LdAppBar.top(
            title: Text(l10n.recurrenceAllOccurrences),
            child: LdScaffoldBody(
              children: [
                LdRecurrenceTimeline(
                  occurrences: instances,
                  last: last,
                  lastOccurrenceNumber: last == null ? null : instances.length,
                  truncated: truncated,
                  dateFormat: dateFormat,
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
