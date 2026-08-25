import 'package:liquid_flutter/src/rrule/rrule_draft.dart';
import 'package:rrule/rrule.dart';

/// Controls which parts of [LdRecurrenceForm] / [LdRecurrencePicker] are available.
class LdRecurrenceConfig {
  const LdRecurrenceConfig({
    this.frequencies = defaultFrequencies,
    this.endModes = defaultEndModes,
    this.showInterval = true,
    this.showWeekdays = true,
    this.showMonthlyOptions = true,
    this.showTimes = true,
    this.showPreview = true,
  });

  /// Daily through yearly, with ending enabled. Hides sub-daily frequencies.
  const LdRecurrenceConfig.calendar({
    this.endModes = defaultEndModes,
    this.showInterval = true,
    this.showWeekdays = true,
    this.showMonthlyOptions = true,
    this.showTimes = true,
    this.showPreview = true,
  }) : frequencies = calendarFrequencies;

  /// Same frequencies as the default config, but without an ending section.
  const LdRecurrenceConfig.withoutEnding({
    this.frequencies = defaultFrequencies,
    this.showInterval = true,
    this.showWeekdays = true,
    this.showMonthlyOptions = true,
    this.showTimes = true,
    this.showPreview = true,
  }) : endModes = const {};

  static const defaultFrequencies = [
    Frequency.secondly,
    Frequency.minutely,
    Frequency.hourly,
    Frequency.daily,
    Frequency.weekly,
    Frequency.monthly,
    Frequency.yearly,
  ];

  static const calendarFrequencies = [
    Frequency.daily,
    Frequency.weekly,
    Frequency.monthly,
    Frequency.yearly,
  ];

  static const defaultEndModes = {
    LdRecurrenceEndMode.never,
    LdRecurrenceEndMode.until,
    LdRecurrenceEndMode.count,
  };

  static const endModeOrder = [
    LdRecurrenceEndMode.never,
    LdRecurrenceEndMode.until,
    LdRecurrenceEndMode.count,
  ];

  /// Allowed frequencies, in the order they appear in the select.
  ///
  /// An empty list falls back to [defaultFrequencies].
  final List<Frequency> frequencies;

  /// Allowed ending modes. An empty set hides the ending section and forces
  /// [LdRecurrenceEndMode.never].
  final Set<LdRecurrenceEndMode> endModes;

  /// Whether the interval field is shown. Hidden interval keeps the current value.
  final bool showInterval;

  /// Whether weekly weekday chips are shown.
  final bool showWeekdays;

  /// Whether monthly/yearly day and nth-weekday controls (and yearly months) are shown.
  final bool showMonthlyOptions;

  /// Whether time-of-day chips (`BYHOUR` / `BYMINUTE`) are shown for daily and coarser frequencies.
  final bool showTimes;

  /// Whether the next-occurrence preview is shown.
  final bool showPreview;

  List<Frequency> get enabledFrequencies {
    if (frequencies.isEmpty) {
      return defaultFrequencies;
    }
    final seen = <Frequency>{};
    return [
      for (final frequency in frequencies)
        if (seen.add(frequency)) frequency,
    ];
  }

  List<LdRecurrenceEndMode> get enabledEndModes {
    return [
      for (final mode in endModeOrder)
        if (endModes.contains(mode)) mode,
    ];
  }

  bool get showEnding {
    final modes = enabledEndModes;
    if (modes.isEmpty) {
      return false;
    }
    if (modes.length == 1 && modes.first == LdRecurrenceEndMode.never) {
      return false;
    }
    return true;
  }

  LdRecurrenceDraft clamp(LdRecurrenceDraft draft) {
    final nextFrequencies = enabledFrequencies;
    final frequency = nextFrequencies.contains(draft.frequency) ? draft.frequency : nextFrequencies.first;
    final nextEndModes = enabledEndModes;
    final endMode = switch (nextEndModes) {
      [] => LdRecurrenceEndMode.never,
      final modes when modes.contains(draft.endMode) => draft.endMode,
      final modes => modes.first,
    };
    final times = ldRecurrenceFrequencyIsSubDaily(frequency) ? const <LdRecurrenceTime>[] : draft.times;
    if (frequency == draft.frequency && endMode == draft.endMode && times.length == draft.times.length) {
      return draft;
    }
    return draft.copyWith(
      frequency: frequency,
      endMode: endMode,
      times: times,
    );
  }
}
