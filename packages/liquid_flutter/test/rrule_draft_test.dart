import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/src/rrule/recurrence_occurrences.dart';
import 'package:liquid_flutter/src/rrule/rrule_draft.dart';
import 'package:rrule/rrule.dart';

void main() {
  group('LdRecurrenceDraft', () {
    test('round-trips a weekly rule', () {
      final rule = RecurrenceRule(
        frequency: Frequency.weekly,
        interval: 2,
        byWeekDays: [
          ByWeekDayEntry(DateTime.tuesday),
          ByWeekDayEntry(DateTime.thursday),
        ],
      );

      expect(LdRecurrenceDraft.fromRule(rule).toRule(), rule);
    });

    test('round-trips monthly on a month day', () {
      final rule = RecurrenceRule(
        frequency: Frequency.monthly,
        byMonthDays: const [15],
      );

      expect(LdRecurrenceDraft.fromRule(rule).toRule(), rule);
    });

    test('round-trips monthly on the last weekday', () {
      final rule = RecurrenceRule(
        frequency: Frequency.monthly,
        byWeekDays: [ByWeekDayEntry(DateTime.tuesday, -1)],
      );

      expect(LdRecurrenceDraft.fromRule(rule).toRule(), rule);
    });

    test('round-trips yearly months and last day', () {
      final rule = RecurrenceRule(
        frequency: Frequency.yearly,
        byMonths: const [1, 6],
        byMonthDays: const [-1],
      );

      expect(LdRecurrenceDraft.fromRule(rule).toRule(), rule);
    });

    test('round-trips hourly interval', () {
      final rule = RecurrenceRule(
        frequency: Frequency.hourly,
        interval: 3,
      );

      expect(LdRecurrenceDraft.fromRule(rule).toRule(), rule);
    });

    test('round-trips minutely and secondly', () {
      expect(
        LdRecurrenceDraft.fromRule(RecurrenceRule(frequency: Frequency.minutely, interval: 15)).toRule(),
        RecurrenceRule(frequency: Frequency.minutely, interval: 15),
      );
      expect(
        LdRecurrenceDraft.fromRule(RecurrenceRule(frequency: Frequency.secondly, interval: 30)).toRule(),
        RecurrenceRule(frequency: Frequency.secondly, interval: 30),
      );
    });

    test('round-trips until and count', () {
      final untilRule = RecurrenceRule(
        frequency: Frequency.daily,
        until: DateTime.utc(2024, 6, 1, 23, 59, 59),
      );
      expect(LdRecurrenceDraft.fromRule(untilRule).toRule(), untilRule);

      final countRule = RecurrenceRule(
        frequency: Frequency.weekly,
        count: 8,
        byWeekDays: [ByWeekDayEntry(DateTime.monday)],
      );
      expect(LdRecurrenceDraft.fromRule(countRule).toRule(), countRule);
    });

    test('round-trips daily by-hours and by-minutes', () {
      final rule = RecurrenceRule(
        frequency: Frequency.daily,
        byHours: const [13, 17],
        byMinutes: const [0],
      );

      expect(LdRecurrenceDraft.fromRule(rule).toRule(), rule);
    });

    test('loads hours and minutes as separate sets', () {
      final draft = LdRecurrenceDraft.fromRule(
        RecurrenceRule(
          frequency: Frequency.daily,
          byHours: const [13, 17],
        ),
        start: DateTime(2024, 1, 15, 10, 30),
      );

      expect(draft.hours, {13, 17});
      expect(draft.minutes, isEmpty);
      expect(draft.times, isEmpty);
    });

    test('expands hours and minutes as a cartesian product', () {
      final draft = LdRecurrenceDraft.fromRule(
        RecurrenceRule(
          frequency: Frequency.daily,
          byHours: const [13, 17],
          byMinutes: const [0, 30],
        ),
      );

      expect(draft.hours, {13, 17});
      expect(draft.minutes, {0, 30});
      expect(draft.times, [
        const LdRecurrenceTime(hour: 13, minute: 0),
        const LdRecurrenceTime(hour: 13, minute: 30),
        const LdRecurrenceTime(hour: 17, minute: 0),
        const LdRecurrenceTime(hour: 17, minute: 30),
      ]);
    });

    test('toggleHour in single mode replaces the hour', () {
      final draft = const LdRecurrenceDraft(
        frequency: Frequency.daily,
        hours: {13},
        minutes: {0},
      ).toggleHour(17, LdRecurrenceTimesMode.single);

      expect(draft.hours, {17});
      expect(draft.minutes, {0});
    });

    test('toggleHour in linear mode collapses minutes when both axes grow', () {
      final draft = const LdRecurrenceDraft(
        frequency: Frequency.daily,
        hours: {13},
        minutes: {0, 30},
      ).toggleHour(17, LdRecurrenceTimesMode.linear);

      expect(draft.hours, {13, 17});
      expect(draft.minutes, {0});
    });

    test('toggleMinute in matrix mode keeps the full product', () {
      final draft = const LdRecurrenceDraft(
        frequency: Frequency.daily,
        hours: {13, 17},
        minutes: {0},
      ).toggleMinute(30, LdRecurrenceTimesMode.matrix);

      expect(draft.hours, {13, 17});
      expect(draft.minutes, {0, 30});
      expect(draft.times, hasLength(4));
    });

    test('ldClampRecurrenceTimes enforces single and linear modes', () {
      final single = ldClampRecurrenceTimes(
        hours: {13, 17},
        minutes: {0, 30},
        mode: LdRecurrenceTimesMode.single,
      );
      expect(single.hours, {13});
      expect(single.minutes, {0});

      final linear = ldClampRecurrenceTimes(
        hours: {13, 17},
        minutes: {0, 30},
        mode: LdRecurrenceTimesMode.linear,
      );
      expect(linear.hours, {13, 17});
      expect(linear.minutes, {0});
    });

    test('detects unsupported by-seconds', () {
      final rule = RecurrenceRule(
        frequency: Frequency.daily,
        bySeconds: const [0],
      );
      expect(ldRecurrenceRuleHasUnsupportedParts(rule), isTrue);
    });

    test('treats daily by-hours as supported', () {
      final rule = RecurrenceRule(
        frequency: Frequency.daily,
        byHours: const [9, 17],
        byMinutes: const [0],
      );
      expect(ldRecurrenceRuleHasUnsupportedParts(rule), isFalse);
    });

    test('treats hourly by-hours as unsupported', () {
      final rule = RecurrenceRule(
        frequency: Frequency.hourly,
        byHours: const [9],
      );
      expect(ldRecurrenceRuleHasUnsupportedParts(rule), isTrue);
    });
  });

  group('ldRecurrenceOccurrencePreview', () {
    test('includes last when count is set', () {
      final preview = ldRecurrenceOccurrencePreview(
        rule: RecurrenceRule(
          frequency: Frequency.daily,
          count: 5,
        ),
        start: DateTime(2024, 1, 15),
      );

      expect(preview.finite, isTrue);
      expect(preview.next, hasLength(3));
      expect(preview.next.first, DateTime(2024, 1, 15));
      expect(preview.last, DateTime(2024, 1, 19));
      expect(preview.lastTruncated, isFalse);
    });

    test('uses next last when count fits in the preview', () {
      final preview = ldRecurrenceOccurrencePreview(
        rule: RecurrenceRule(
          frequency: Frequency.daily,
          count: 2,
        ),
        start: DateTime(2024, 1, 15),
      );

      expect(preview.next, hasLength(2));
      expect(preview.last, preview.next.last);
    });

    test('omits last when the rule never ends', () {
      final preview = ldRecurrenceOccurrencePreview(
        rule: RecurrenceRule(frequency: Frequency.weekly),
        start: DateTime(2024, 1, 15),
      );

      expect(preview.finite, isFalse);
      expect(preview.last, isNull);
      expect(preview.next, hasLength(3));
    });
  });

  group('ldRecurrenceMergedOccurrencePreview', () {
    test('returns empty for no rules', () {
      final preview = ldRecurrenceMergedOccurrencePreview(
        rules: const [],
        start: DateTime(2024, 1, 15),
      );

      expect(preview.next, isEmpty);
      expect(preview.finite, isFalse);
      expect(preview.last, isNull);
    });

    test('merges overlapping rules and dedupes', () {
      final preview = ldRecurrenceMergedOccurrencePreview(
        rules: [
          RecurrenceRule(
            frequency: Frequency.daily,
            byHours: const [9],
            byMinutes: const [0],
            count: 3,
          ),
          RecurrenceRule(
            frequency: Frequency.daily,
            byHours: const [17],
            byMinutes: const [0],
            count: 3,
          ),
        ],
        start: DateTime(2024, 1, 15, 9),
        nextCount: 4,
      );

      expect(preview.finite, isTrue);
      expect(preview.next, [
        DateTime(2024, 1, 15, 9),
        DateTime(2024, 1, 15, 17),
        DateTime(2024, 1, 16, 9),
        DateTime(2024, 1, 16, 17),
      ]);
      expect(preview.last, DateTime(2024, 1, 17, 17));
    });

    test('omits last when any rule is open-ended', () {
      final preview = ldRecurrenceMergedOccurrencePreview(
        rules: [
          RecurrenceRule(
            frequency: Frequency.daily,
            count: 5,
          ),
          RecurrenceRule(frequency: Frequency.weekly),
        ],
        start: DateTime(2024, 1, 15),
      );

      expect(preview.finite, isFalse);
      expect(preview.last, isNull);
      expect(preview.next, hasLength(3));
    });
  });
}
