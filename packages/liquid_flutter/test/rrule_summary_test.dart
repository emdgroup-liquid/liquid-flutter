import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations_en.dart';
import 'package:liquid_flutter/src/rrule/rrule_summary.dart';
import 'package:rrule/rrule.dart';

void main() {
  final l10n = LiquidLocalizationsEn();

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
}
