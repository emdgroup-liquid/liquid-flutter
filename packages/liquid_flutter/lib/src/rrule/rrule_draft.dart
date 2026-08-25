import 'package:collection/collection.dart';
import 'package:rrule/rrule.dart';

enum LdRecurrenceMonthlyMode { byMonthDay, byNthWeekday }

enum LdRecurrenceEndMode { never, until, count }

/// Converts a local [DateTime] to a UTC [DateTime] with the same calendar fields.
DateTime ldToRruleUtc(DateTime dateTime) {
  if (dateTime.isUtc) {
    return dateTime;
  }
  return DateTime.utc(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    dateTime.hour,
    dateTime.minute,
    dateTime.second,
    dateTime.millisecond,
    dateTime.microsecond,
  );
}

/// Converts an rrule UTC [DateTime] back to a local [DateTime] with the same fields.
DateTime ldFromRruleUtc(DateTime dateTime) {
  return DateTime(
    dateTime.year,
    dateTime.month,
    dateTime.day,
    dateTime.hour,
    dateTime.minute,
    dateTime.second,
    dateTime.millisecond,
    dateTime.microsecond,
  );
}

bool ldRecurrenceFrequencyIsSubDaily(Frequency frequency) {
  return frequency == Frequency.hourly ||
      frequency == Frequency.minutely ||
      frequency == Frequency.secondly;
}

/// Whether [rule] uses RRULE parts that [LdRecurrenceForm] cannot edit.
bool ldRecurrenceRuleHasUnsupportedParts(RecurrenceRule rule) {
  if (rule.bySeconds.isNotEmpty ||
      rule.byYearDays.isNotEmpty ||
      rule.byWeeks.isNotEmpty ||
      rule.bySetPositions.isNotEmpty) {
    return true;
  }

  final frequency = rule.frequency;
  if (ldRecurrenceFrequencyIsSubDaily(frequency) &&
      (rule.byHours.isNotEmpty || rule.byMinutes.isNotEmpty)) {
    return true;
  }

  if (frequency == Frequency.weekly ||
      frequency == Frequency.daily ||
      frequency == Frequency.hourly ||
      frequency == Frequency.minutely ||
      frequency == Frequency.secondly) {
    if (rule.byMonthDays.isNotEmpty || rule.byMonths.isNotEmpty) {
      return true;
    }
  }

  if ((frequency == Frequency.hourly ||
          frequency == Frequency.minutely ||
          frequency == Frequency.secondly ||
          frequency == Frequency.daily) &&
      rule.byWeekDays.isNotEmpty) {
    return true;
  }

  return false;
}

int ldNthWeekdayOccurrence(DateTime date) {
  final nth = ((date.day - 1) ~/ 7) + 1;
  final nextWeek = date.add(const Duration(days: 7));
  if (nextWeek.month != date.month) {
    return -1;
  }
  return nth.clamp(1, 4);
}

/// A time of day encoded as RRULE `BYHOUR` / `BYMINUTE`.
class LdRecurrenceTime implements Comparable<LdRecurrenceTime> {
  const LdRecurrenceTime({
    required this.hour,
    required this.minute,
  })  : assert(hour >= 0 && hour <= 23),
        assert(minute >= 0 && minute <= 59);

  final int hour;
  final int minute;

  String get label => '$hour:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(LdRecurrenceTime other) {
    final byHour = hour.compareTo(other.hour);
    if (byHour != 0) {
      return byHour;
    }
    return minute.compareTo(other.minute);
  }

  @override
  bool operator ==(Object other) {
    return other is LdRecurrenceTime && hour == other.hour && minute == other.minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);
}

/// Cartesian product of [hours] × [minutes], sorted.
List<LdRecurrenceTime> ldRecurrenceTimesFromParts({
  required Iterable<int> hours,
  required Iterable<int> minutes,
}) {
  if (hours.isEmpty || minutes.isEmpty) {
    return const [];
  }
  final uniqueHours = hours.toSet().toList()..sort();
  final uniqueMinutes = minutes.toSet().toList()..sort();
  return [
    for (final hour in uniqueHours)
      for (final minute in uniqueMinutes)
        LdRecurrenceTime(hour: hour, minute: minute),
  ];
}

List<LdRecurrenceTime> ldRecurrenceTimesFromRule(
  RecurrenceRule rule,
  DateTime seed,
) {
  if (rule.byHours.isEmpty && rule.byMinutes.isEmpty) {
    return const [];
  }
  return ldRecurrenceTimesFromParts(
    hours: rule.byHours.isNotEmpty ? rule.byHours : [seed.hour],
    minutes: rule.byMinutes.isNotEmpty ? rule.byMinutes : [seed.minute],
  );
}

/// Editable subset of [RecurrenceRule] used by the recurrence picker UI.
class LdRecurrenceDraft {
  const LdRecurrenceDraft({
    required this.frequency,
    this.interval = 1,
    this.weekdays = const {},
    this.monthlyMode = LdRecurrenceMonthlyMode.byMonthDay,
    this.monthDay = 1,
    this.nthOccurrence = 1,
    this.nthWeekday = DateTime.monday,
    this.months = const {},
    this.endMode = LdRecurrenceEndMode.never,
    this.until,
    this.count = 10,
    this.times = const [],
  });

  final Frequency frequency;
  final int interval;
  final Set<int> weekdays;
  final LdRecurrenceMonthlyMode monthlyMode;
  final int monthDay;
  final int nthOccurrence;
  final int nthWeekday;
  final Set<int> months;
  final LdRecurrenceEndMode endMode;
  final DateTime? until;
  final int count;
  final List<LdRecurrenceTime> times;

  bool get isSubDaily => ldRecurrenceFrequencyIsSubDaily(frequency);

  bool get isWeekly => frequency == Frequency.weekly;

  bool get isMonthly => frequency == Frequency.monthly;

  bool get isYearly => frequency == Frequency.yearly;

  factory LdRecurrenceDraft.initial({DateTime? start}) {
    final seed = start ?? DateTime.now();
    return LdRecurrenceDraft(
      frequency: Frequency.weekly,
      weekdays: {seed.weekday},
      monthDay: seed.day,
      nthOccurrence: ldNthWeekdayOccurrence(seed),
      nthWeekday: seed.weekday,
      months: {seed.month},
    );
  }

  factory LdRecurrenceDraft.fromRule(
    RecurrenceRule rule, {
    DateTime? start,
  }) {
    final seed = start ?? DateTime.now();
    final hasNth = rule.byWeekDays.any((entry) => entry.hasOccurrence);
    final nthEntry = rule.byWeekDays.where((entry) => entry.hasOccurrence).firstOrNull;
    final plainWeekdays = rule.byWeekDays.where((entry) => entry.hasNoOccurrence).map((entry) => entry.day).toSet();

    final endMode = rule.until != null
        ? LdRecurrenceEndMode.until
        : rule.count != null
            ? LdRecurrenceEndMode.count
            : LdRecurrenceEndMode.never;

    return LdRecurrenceDraft(
      frequency: rule.frequency,
      interval: rule.actualInterval,
      weekdays: plainWeekdays.isNotEmpty ? plainWeekdays : {seed.weekday},
      monthlyMode: hasNth ? LdRecurrenceMonthlyMode.byNthWeekday : LdRecurrenceMonthlyMode.byMonthDay,
      monthDay: rule.byMonthDays.isNotEmpty ? rule.byMonthDays.first : seed.day,
      nthOccurrence: nthEntry?.occurrence ?? ldNthWeekdayOccurrence(seed),
      nthWeekday: nthEntry?.day ?? seed.weekday,
      months: rule.byMonths.isNotEmpty ? rule.byMonths.toSet() : {seed.month},
      endMode: endMode,
      until: rule.until != null ? ldFromRruleUtc(rule.until!) : null,
      count: rule.count ?? 10,
      times: ldRecurrenceFrequencyIsSubDaily(rule.frequency)
          ? const []
          : ldRecurrenceTimesFromRule(rule, seed),
    );
  }

  LdRecurrenceDraft copyWith({
    Frequency? frequency,
    int? interval,
    Set<int>? weekdays,
    LdRecurrenceMonthlyMode? monthlyMode,
    int? monthDay,
    int? nthOccurrence,
    int? nthWeekday,
    Set<int>? months,
    LdRecurrenceEndMode? endMode,
    DateTime? until,
    bool clearUntil = false,
    int? count,
    List<LdRecurrenceTime>? times,
  }) {
    return LdRecurrenceDraft(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      weekdays: weekdays ?? this.weekdays,
      monthlyMode: monthlyMode ?? this.monthlyMode,
      monthDay: monthDay ?? this.monthDay,
      nthOccurrence: nthOccurrence ?? this.nthOccurrence,
      nthWeekday: nthWeekday ?? this.nthWeekday,
      months: months ?? this.months,
      endMode: endMode ?? this.endMode,
      until: clearUntil ? null : until ?? this.until,
      count: count ?? this.count,
      times: times ?? this.times,
    );
  }

  LdRecurrenceDraft addTime(LdRecurrenceTime time) {
    if (times.contains(time)) {
      return this;
    }
    final next = [...times, time]..sort();
    return copyWith(times: next);
  }

  LdRecurrenceDraft removeTime(LdRecurrenceTime time) {
    return copyWith(
      times: [
        for (final entry in times)
          if (entry != time) entry,
      ],
    );
  }

  RecurrenceRule toRule() {
    final byWeekDays = <ByWeekDayEntry>[];
    final byMonthDays = <int>[];
    final byMonths = <int>[];

    if (frequency == Frequency.weekly) {
      final days = weekdays.toList()..sort();
      byWeekDays.addAll(days.map(ByWeekDayEntry.new));
    } else if (frequency == Frequency.monthly || frequency == Frequency.yearly) {
      if (frequency == Frequency.yearly) {
        final sortedMonths = months.toList()..sort();
        byMonths.addAll(sortedMonths);
      }
      if (monthlyMode == LdRecurrenceMonthlyMode.byMonthDay) {
        byMonthDays.add(monthDay);
      } else {
        byWeekDays.add(ByWeekDayEntry(nthWeekday, nthOccurrence));
      }
    }

    var byHours = <int>[];
    var byMinutes = <int>[];
    if (!isSubDaily && times.isNotEmpty) {
      byHours = times.map((time) => time.hour).toSet().toList()..sort();
      byMinutes = times.map((time) => time.minute).toSet().toList()..sort();
    }

    DateTime? untilUtc;
    int? ruleCount;
    switch (endMode) {
      case LdRecurrenceEndMode.until:
        if (until != null) {
          untilUtc =
              isSubDaily ? ldToRruleUtc(until!) : DateTime.utc(until!.year, until!.month, until!.day, 23, 59, 59);
        }
      case LdRecurrenceEndMode.count:
        ruleCount = count < 1 ? 1 : count;
      case LdRecurrenceEndMode.never:
        break;
    }

    return RecurrenceRule(
      frequency: frequency,
      interval: interval <= 1 ? null : interval,
      byWeekDays: byWeekDays,
      byMonthDays: byMonthDays,
      byMonths: byMonths,
      byHours: byHours,
      byMinutes: byMinutes,
      until: untilUtc,
      count: ruleCount,
    );
  }
}
