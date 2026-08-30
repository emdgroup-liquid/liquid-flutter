import 'package:liquid_flutter/src/duration/ld_duration.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations.dart';

/// Localized compact (`1h 30m`) or verbose (`1 hour 30 minutes`) duration text.
String ldFormatDuration(
  LdDuration duration, {
  required LiquidLocalizations l10n,
  bool compact = true,
}) {
  if (duration.isZero) {
    return compact ? l10n.durationCompactSeconds(0) : '0 ${l10n.durationUnitSeconds(0)}';
  }

  final parts = <String>[];

  void add(int count, String Function(int) compactFn, String Function(int) unitFn) {
    if (count == 0) {
      return;
    }
    if (compact) {
      parts.add(compactFn(count));
    } else {
      parts.add('$count ${unitFn(count)}');
    }
  }

  add(duration.years, l10n.durationCompactYears, l10n.durationUnitYears);
  add(duration.months, l10n.durationCompactMonths, l10n.durationUnitMonths);
  add(duration.weeks, l10n.durationCompactWeeks, l10n.durationUnitWeeks);
  add(duration.days, l10n.durationCompactDays, l10n.durationUnitDays);
  add(duration.hours, l10n.durationCompactHours, l10n.durationUnitHours);
  add(duration.minutes, l10n.durationCompactMinutes, l10n.durationUnitMinutes);
  add(duration.seconds, l10n.durationCompactSeconds, l10n.durationUnitSeconds);

  return parts.join(' ');
}

String ldDurationUnitHint(
  LdDurationUnit unit,
  LiquidLocalizations l10n,
) {
  return switch (unit) {
    LdDurationUnit.years => l10n.durationHintYears,
    LdDurationUnit.months => l10n.durationHintMonths,
    LdDurationUnit.weeks => l10n.durationHintWeeks,
    LdDurationUnit.days => l10n.durationHintDays,
    LdDurationUnit.hours => l10n.durationHintHours,
    LdDurationUnit.minutes => l10n.durationHintMinutes,
    LdDurationUnit.seconds => l10n.durationHintSeconds,
  };
}

String ldDurationUnitName(
  LdDurationUnit unit,
  LiquidLocalizations l10n,
) {
  return switch (unit) {
    LdDurationUnit.years => l10n.durationUnitYears(0),
    LdDurationUnit.months => l10n.durationUnitMonths(0),
    LdDurationUnit.weeks => l10n.durationUnitWeeks(0),
    LdDurationUnit.days => l10n.durationUnitDays(0),
    LdDurationUnit.hours => l10n.durationUnitHours(0),
    LdDurationUnit.minutes => l10n.durationUnitMinutes(0),
    LdDurationUnit.seconds => l10n.durationUnitSeconds(0),
  };
}
