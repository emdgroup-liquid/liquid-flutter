import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  group('LdDuration ISO 8601', () {
    test('emits canonical strings', () {
      expect(const LdDuration().toIso8601String(), 'PT0S');
      expect(const LdDuration(minutes: 15).toIso8601String(), 'PT15M');
      expect(const LdDuration(hours: 1, minutes: 30).toIso8601String(), 'PT1H30M');
      expect(const LdDuration(years: 1, months: 2).toIso8601String(), 'P1Y2M');
      expect(const LdDuration(weeks: 2).toIso8601String(), 'P2W');
      expect(const LdDuration(days: 1, hours: 2).toIso8601String(), 'P1DT2H');
    });

    test('round-trips picker-produced values', () {
      const values = [
        LdDuration(minutes: 15),
        LdDuration(years: 1, months: 2),
        LdDuration(weeks: 2),
        LdDuration(days: 1, hours: 2),
        LdDuration(),
        LdDuration(months: 1),
        LdDuration(minutes: 1),
      ];
      for (final value in values) {
        expect(LdDuration.parse(value.toIso8601String()), value);
      }
    });

    test('distinguishes P1M and PT1M', () {
      expect(LdDuration.parse('P1M'), const LdDuration(months: 1));
      expect(LdDuration.parse('PT1M'), const LdDuration(minutes: 1));
    });

    test('folds weeks into days when mixed with other date units', () {
      expect(
        const LdDuration(weeks: 1, days: 3).toIso8601String(),
        'P10D',
      );
    });

    test('rejects negatives and fractions', () {
      expect(LdDuration.tryParse('-P1D'), isNull);
      expect(LdDuration.tryParse('PT1.5S'), isNull);
      expect(() => LdDuration.parse('PT1.5S'), throwsFormatException);
    });

    test('json is the ISO string', () {
      const duration = LdDuration(hours: 2);
      expect(duration.toJson(), 'PT2H');
      expect(LdDuration.fromJson('PT2H'), duration);
    });
  });

  group('LdDuration math', () {
    test('component equality is not elapsed time', () {
      expect(const LdDuration(months: 1), isNot(const LdDuration(days: 30)));
    });

    test('normalizes overflowing months and clock fields', () {
      expect(
        const LdDuration(months: 15, seconds: 90).normalized(),
        const LdDuration(years: 1, months: 3, minutes: 1, seconds: 30),
      );
    });

    test('asDuration is null when months or years are set', () {
      expect(const LdDuration(months: 1).asDuration, isNull);
      expect(const LdDuration(hours: 2).asDuration, const Duration(hours: 2));
      expect(const LdDuration(weeks: 1).asDuration, const Duration(days: 7));
    });

    test('fromDuration uses clock units only', () {
      expect(
        LdDuration.fromDuration(const Duration(days: 1, hours: 2, minutes: 3, seconds: 4)),
        const LdDuration(days: 1, hours: 2, minutes: 3, seconds: 4),
      );
    });
  });

  group('DateTime.addLdDuration', () {
    test('clamps January 31 plus one month', () {
      expect(
        DateTime(2024, 1, 31).addLdDuration(const LdDuration(months: 1)),
        DateTime(2024, 2, 29),
      );
    });

    test('clamps February 29 plus one year', () {
      expect(
        DateTime(2024, 2, 29).addLdDuration(const LdDuration(years: 1)),
        DateTime(2025, 2, 28),
      );
    });

    test('toDurationAt uses the anchor', () {
      final anchor = DateTime(2024, 1, 31);
      final elapsed = const LdDuration(months: 1).toDurationAt(anchor);
      expect(elapsed, DateTime(2024, 2, 29).difference(anchor));
    });
  });
}
