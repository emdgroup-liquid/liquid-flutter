import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations_en.dart';
import 'package:liquid_flutter/src/rrule/recurrence_timeline.dart';
import 'package:liquid_flutter/src/rrule/rrule_summary.dart';
import 'package:rrule/rrule.dart';

void main() {
  final l10n = LiquidLocalizationsEn();

  setUpAll(() async {
    await initializeDateFormatting('en');
  });

  group('ldRecurrenceDeltaLabel', () {
    test('uses one day between adjacent weekdays', () {
      expect(
        ldRecurrenceDeltaLabel(
          DateTime(2024, 1, 15),
          DateTime(2024, 1, 16),
          l10n,
        ),
        '1 day',
      );
    });

    test('uses weeks when the same weekday is an exact week multiple apart', () {
      expect(
        ldRecurrenceDeltaLabel(
          DateTime(2024, 1, 15),
          DateTime(2024, 2, 5),
          l10n,
        ),
        '3 weeks',
      );
    });

    test('uses minutes for sub-daily gaps', () {
      expect(
        ldRecurrenceDeltaLabel(
          DateTime(2024, 1, 15, 9),
          DateTime(2024, 1, 15, 9, 3),
          l10n,
        ),
        '3 minutes',
      );
    });

    test('composes hours and minutes for long gaps', () {
      expect(
        ldRecurrenceDeltaLabel(
          DateTime(2024, 1, 15, 9),
          DateTime(2024, 1, 15, 12, 50),
          l10n,
        ),
        '3 hours 50 minutes',
      );
    });

    test('uses months when the calendar day matches', () {
      expect(
        ldRecurrenceDeltaLabel(
          DateTime(2024, 1, 15),
          DateTime(2024, 4, 15),
          l10n,
        ),
        '3 months',
      );
    });
  });

  group('ldRecurrenceOccurrenceFormat', () {
    test('formats weekday, date, and time with spaces', () {
      final formatted = ldRecurrenceOccurrenceFormat(
        'en',
        includeTime: true,
      ).format(DateTime(2024, 1, 15, 9, 30, 0));

      expect(formatted, 'Mon, Jan 15, 2024 09:30:00');
    });
  });

  group('ldRecurrenceRuleSummary', () {
    test('appends times of day', () {
      expect(
        ldRecurrenceRuleSummary(
          RecurrenceRule(
            frequency: Frequency.daily,
            byHours: const [13, 17],
            byMinutes: const [0],
          ),
          l10n: l10n,
          localeName: 'en',
        ),
        'Every 1 day at 13:00, 17:00',
      );
    });
  });

  group('ldRecurrenceOrdinal', () {
    test('formats English suffixes', () {
      expect(ldRecurrenceOrdinal(1, 'en'), '1st');
      expect(ldRecurrenceOrdinal(2, 'en'), '2nd');
      expect(ldRecurrenceOrdinal(3, 'en'), '3rd');
      expect(ldRecurrenceOrdinal(4, 'en'), '4th');
      expect(ldRecurrenceOrdinal(11, 'en'), '11th');
      expect(ldRecurrenceOrdinal(12, 'en'), '12th');
      expect(ldRecurrenceOrdinal(13, 'en'), '13th');
      expect(ldRecurrenceOrdinal(21, 'en'), '21st');
      expect(ldRecurrenceOrdinal(22, 'en'), '22nd');
      expect(ldRecurrenceOrdinal(23, 'en'), '23rd');
    });

    test('formats German with trailing period', () {
      expect(ldRecurrenceOrdinal(1, 'de'), '1.');
      expect(ldRecurrenceOrdinal(23, 'de_DE'), '23.');
    });
  });

  group('ldRecurrenceTimelineRows', () {
    test('uses series index for a separate last occurrence', () {
      final rows = ldRecurrenceTimelineRows(
        occurrences: [
          DateTime(2024, 1, 15),
          DateTime(2024, 1, 16),
          DateTime(2024, 1, 17),
        ],
        last: DateTime(2024, 1, 24),
        lastOccurrenceNumber: 10,
        l10n: l10n,
      );

      expect(rows, hasLength(4));
      expect(rows.map((e) => e.occurrenceNumber), [1, 2, 3, 10]);
      expect(rows.last.isLastOccurrence, isTrue);
      expect(rows[2].connectorLabel, '6 more');
    });

    test('omits skipped label when nothing is between next and last', () {
      final rows = ldRecurrenceTimelineRows(
        occurrences: [
          DateTime(2024, 1, 15),
          DateTime(2024, 1, 16),
          DateTime(2024, 1, 17),
        ],
        last: DateTime(2024, 1, 18),
        lastOccurrenceNumber: 4,
        l10n: l10n,
      );

      expect(rows, hasLength(4));
      expect(rows[2].connectorLabel, isNull);
      expect(rows.last.occurrenceNumber, 4);
    });
  });
}
