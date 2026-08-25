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

    test('fills missing minutes from the start seed', () {
      final draft = LdRecurrenceDraft.fromRule(
        RecurrenceRule(
          frequency: Frequency.daily,
          byHours: const [13, 17],
        ),
        start: DateTime(2024, 1, 15, 10, 30),
      );

      expect(draft.times, [
        const LdRecurrenceTime(hour: 13, minute: 30),
        const LdRecurrenceTime(hour: 17, minute: 30),
      ]);
    });

    test('expands hours and minutes as a cartesian product', () {
      final draft = LdRecurrenceDraft.fromRule(
        RecurrenceRule(
          frequency: Frequency.daily,
          byHours: const [13, 17],
          byMinutes: const [0, 30],
        ),
      );

      expect(draft.times, [
        const LdRecurrenceTime(hour: 13, minute: 0),
        const LdRecurrenceTime(hour: 13, minute: 30),
        const LdRecurrenceTime(hour: 17, minute: 0),
        const LdRecurrenceTime(hour: 17, minute: 30),
      ]);
    });

    test('addTime appends a pair without cartesian expansion', () {
      final draft = LdRecurrenceDraft(
        frequency: Frequency.daily,
        times: const [LdRecurrenceTime(hour: 13, minute: 0)],
      ).addTime(const LdRecurrenceTime(hour: 17, minute: 0));

      expect(draft.times, [
        const LdRecurrenceTime(hour: 13, minute: 0),
        const LdRecurrenceTime(hour: 17, minute: 0),
      ]);

      expect(
        draft.addTime(const LdRecurrenceTime(hour: 13, minute: 30)).times,
        [
          const LdRecurrenceTime(hour: 13, minute: 0),
          const LdRecurrenceTime(hour: 13, minute: 30),
          const LdRecurrenceTime(hour: 17, minute: 0),
        ],
      );
    });

    test('addTime ignores duplicates', () {
      const time = LdRecurrenceTime(hour: 13, minute: 0);
      final draft = LdRecurrenceDraft(
        frequency: Frequency.daily,
        times: const [time],
      );

      expect(draft.addTime(time).times, [time]);
    });

    test('fromRule expands independent pairs stored as BYHOUR/BYMINUTE', () {
      final draft = LdRecurrenceDraft(
        frequency: Frequency.daily,
        times: const [
          LdRecurrenceTime(hour: 13, minute: 0),
          LdRecurrenceTime(hour: 17, minute: 30),
        ],
      );

      expect(LdRecurrenceDraft.fromRule(draft.toRule()).times, [
        const LdRecurrenceTime(hour: 13, minute: 0),
        const LdRecurrenceTime(hour: 13, minute: 30),
        const LdRecurrenceTime(hour: 17, minute: 0),
        const LdRecurrenceTime(hour: 17, minute: 30),
      ]);
    });

    test('removeTime drops only that pair', () {
      expect(
        const LdRecurrenceDraft(
          frequency: Frequency.daily,
          times: [
            LdRecurrenceTime(hour: 13, minute: 0),
            LdRecurrenceTime(hour: 17, minute: 0),
          ],
        ).removeTime(const LdRecurrenceTime(hour: 13, minute: 0)).times,
        [const LdRecurrenceTime(hour: 17, minute: 0)],
      );

      expect(
        const LdRecurrenceDraft(
          frequency: Frequency.daily,
          times: [
            LdRecurrenceTime(hour: 13, minute: 0),
            LdRecurrenceTime(hour: 13, minute: 30),
            LdRecurrenceTime(hour: 17, minute: 0),
            LdRecurrenceTime(hour: 17, minute: 30),
          ],
        ).removeTime(const LdRecurrenceTime(hour: 13, minute: 30)).times,
        [
          const LdRecurrenceTime(hour: 13, minute: 0),
          const LdRecurrenceTime(hour: 17, minute: 0),
          const LdRecurrenceTime(hour: 17, minute: 30),
        ],
      );
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
}
