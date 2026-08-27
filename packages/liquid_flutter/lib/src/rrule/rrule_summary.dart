import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations.dart';
import 'package:liquid_flutter/src/rrule/rrule_draft.dart';
import 'package:rrule/rrule.dart';

String ldRecurrenceUnitLabel(
  Frequency frequency,
  int count,
  LiquidLocalizations l10n,
) {
  if (frequency == Frequency.secondly) {
    return l10n.recurrenceUnitSeconds(count);
  }
  if (frequency == Frequency.minutely) {
    return l10n.recurrenceUnitMinutes(count);
  }
  if (frequency == Frequency.hourly) {
    return l10n.recurrenceUnitHours(count);
  }
  if (frequency == Frequency.daily) {
    return l10n.recurrenceUnitDays(count);
  }
  if (frequency == Frequency.weekly) {
    return l10n.recurrenceUnitWeeks(count);
  }
  if (frequency == Frequency.monthly) {
    return l10n.recurrenceUnitMonths(count);
  }
  return l10n.recurrenceUnitYears(count);
}

/// Interval phrase including the count, e.g. `3 minutes` or `1 week`.
String ldRecurrenceIntervalLabel(
  Frequency frequency,
  int count,
  LiquidLocalizations l10n,
) {
  return '$count ${ldRecurrenceUnitLabel(frequency, count, l10n)}';
}

/// Human-readable gap between two occurrence timestamps.
String ldRecurrenceDeltaLabel(
  DateTime from,
  DateTime to,
  LiquidLocalizations l10n,
) {
  final start = from.isBefore(to) ? from : to;
  final end = from.isBefore(to) ? to : from;
  final sameClock = start.hour == end.hour &&
      start.minute == end.minute &&
      start.second == end.second &&
      start.millisecond == end.millisecond;

  if (sameClock) {
    final monthDelta = (end.year - start.year) * 12 + (end.month - start.month);
    if (end.day == start.day && monthDelta > 0) {
      return switch (monthDelta % 12 == 0) {
        true => ldRecurrenceIntervalLabel(Frequency.yearly, monthDelta ~/ 12, l10n),
        false => ldRecurrenceIntervalLabel(Frequency.monthly, monthDelta, l10n),
      };
    }
    final days = DateTime(end.year, end.month, end.day).difference(DateTime(start.year, start.month, start.day)).inDays;
    if (days > 0) {
      return switch (days % 7 == 0) {
        true => ldRecurrenceIntervalLabel(Frequency.weekly, days ~/ 7, l10n),
        false => ldRecurrenceIntervalLabel(Frequency.daily, days, l10n),
      };
    }
  }

  final delta = end.difference(start);
  final days = delta.inDays;
  final hours = delta.inHours.remainder(24);
  final minutes = delta.inMinutes.remainder(60);
  final seconds = delta.inSeconds.remainder(60);

  final parts = <String>[];
  if (days > 0) {
    parts.add(ldRecurrenceIntervalLabel(Frequency.daily, days, l10n));
  }
  if (hours > 0) {
    parts.add(ldRecurrenceIntervalLabel(Frequency.hourly, hours, l10n));
  }
  if (minutes > 0) {
    parts.add(ldRecurrenceIntervalLabel(Frequency.minutely, minutes, l10n));
  }
  if (parts.isEmpty) {
    final secs = seconds < 1 ? 1 : seconds;
    parts.add(ldRecurrenceIntervalLabel(Frequency.secondly, secs, l10n));
  }
  return parts.join(' ');
}

String ldRecurrenceNthLabel(int occurrence, LiquidLocalizations l10n) {
  return switch (occurrence) {
    1 => l10n.recurrenceNthFirst,
    2 => l10n.recurrenceNthSecond,
    3 => l10n.recurrenceNthThird,
    4 => l10n.recurrenceNthFourth,
    _ => l10n.recurrenceNthLast,
  };
}

/// Locale-aware ordinal for open-ended indices (e.g. timeline rows).
///
/// English: `1st`, `2nd`, `3rd`, `23rd`. German: `1.`, `2.`, `23.`.
String ldRecurrenceOrdinal(int n, String locale) {
  final language = Intl.shortLocale(locale);
  if (language == 'en') {
    final mod100 = n % 100;
    final mod10 = n % 10;
    final suffix = switch ((mod100 >= 11 && mod100 <= 13, mod10)) {
      (true, _) => 'th',
      (_, 1) => 'st',
      (_, 2) => 'nd',
      (_, 3) => 'rd',
      _ => 'th',
    };
    return '$n$suffix';
  }
  return '$n.';
}

String ldRecurrenceWeekdayLabel(int weekday, String locale) {
  final date = DateTime(2024, 1, weekday);
  return DateFormat.EEEE(locale).format(date);
}

String ldRecurrenceWeekdayShortLabel(int weekday, String locale) {
  final date = DateTime(2024, 1, weekday);
  return DateFormat.E(locale).format(date);
}

String ldRecurrenceMonthLabel(int month, String locale) {
  return DateFormat.MMMM(locale).format(DateTime(2024, month));
}

String ldRecurrenceMonthShortLabel(int month, String locale) {
  return DateFormat.MMM(locale).format(DateTime(2024, month));
}

DateFormat ldRecurrenceOccurrenceFormat(
  String localeName, {
  required bool includeTime,
}) {
  // Use ICU skeletons (`yMMMEd` / `Hms`), not a custom `yMMMd` pattern string.
  // `DateFormat('EEE, yMMMd')` treats those letters literally and yields
  // jammed output like `Mon, 2024Jan15`.
  final date = DateFormat.yMMMEd(localeName);
  return switch (includeTime) {
    true => date.addPattern(DateFormat.Hms(localeName).pattern!),
    false => date,
  };
}

/// Localized one-line summary of a [RecurrenceRule], or the empty-field placeholder.
String ldRecurrenceRuleSummary(
  RecurrenceRule? rule, {
  required LiquidLocalizations l10n,
  required String localeName,
}) {
  if (rule == null) {
    return l10n.selectRecurrence;
  }

  final draft = LdRecurrenceDraft.fromRule(rule);
  final buffer = StringBuffer();
  buffer.write(l10n.recurrenceEvery);
  buffer.write(' ');
  buffer.write(draft.interval);
  buffer.write(' ');
  buffer.write(ldRecurrenceUnitLabel(draft.frequency, draft.interval, l10n));

  if (draft.isWeekly && draft.weekdays.isNotEmpty) {
    final days = draft.weekdays.toList()..sort();
    buffer.write(' ');
    buffer.write(l10n.recurrenceOn);
    buffer.write(' ');
    buffer.write(
      days.map((day) => ldRecurrenceWeekdayShortLabel(day, localeName)).join(', '),
    );
  } else if (draft.isMonthly || draft.isYearly) {
    if (draft.isYearly && draft.months.isNotEmpty) {
      final months = draft.months.toList()..sort();
      buffer.write(' ');
      buffer.write(l10n.recurrenceIn);
      buffer.write(' ');
      buffer.write(
        months.map((month) => ldRecurrenceMonthShortLabel(month, localeName)).join(', '),
      );
    }
    buffer.write(' ');
    if (draft.monthlyMode == LdRecurrenceMonthlyMode.byMonthDay) {
      if (draft.monthDay == -1) {
        buffer.write(l10n.recurrenceLastDay.toLowerCase());
      } else {
        buffer.write(l10n.recurrenceOnDay.toLowerCase());
        buffer.write(' ');
        buffer.write(draft.monthDay);
      }
    } else {
      buffer.write(l10n.recurrenceOnThe.toLowerCase());
      buffer.write(' ');
      buffer.write(ldRecurrenceNthLabel(draft.nthOccurrence, l10n).toLowerCase());
      buffer.write(' ');
      buffer.write(ldRecurrenceWeekdayLabel(draft.nthWeekday, localeName));
    }
  }

  final times = ldRecurrenceTimesFromRule(rule, DateTime.now());
  if (times.isNotEmpty) {
    buffer.write(' ');
    buffer.write(
      l10n.recurrenceAtTimes(times.map((time) => time.label).join(', ')),
    );
  }

  switch (draft.endMode) {
    case LdRecurrenceEndMode.until:
      if (draft.until != null) {
        buffer.write(', ');
        buffer.write(l10n.recurrenceUntil);
        buffer.write(' ');
        buffer.write(DateFormat.yMMMd(localeName).format(draft.until!));
      }
    case LdRecurrenceEndMode.count:
      buffer.write(', ');
      buffer.write(l10n.recurrenceTimes(draft.count));
    case LdRecurrenceEndMode.never:
      break;
  }

  return buffer.toString();
}

List<int> ldLocaleOrderedWeekdays(BuildContext context) {
  final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
  return List<int>.generate(7, (index) {
    final materialIndex = (first + index) % 7;
    return materialIndex == 0 ? DateTime.sunday : materialIndex;
  });
}
