import 'package:jiffy/jiffy.dart';
import 'package:meta/meta.dart';

/// Calendar and clock fields of a duration, in decreasing order.
///
/// Years and months are civil-calendar units. They cannot be converted to a
/// [Duration] without an anchor [DateTime].
enum LdDurationUnit {
  years,
  months,
  weeks,
  days,
  hours,
  minutes,
  seconds,
}

/// A calendar-aware duration that stores the components the user picked.
///
/// Unlike [Duration], this type can represent years and months. Equality is
/// component-wise (`1 month ≠ 30 days`). Apply it to a [DateTime] with
/// [LdDurationDateTime.addLdDuration].
///
/// The wire format is ISO 8601 (`P1Y2M3DT4H5M6S`, `PT15M`, `P2W`).
@immutable
class LdDuration implements Comparable<LdDuration> {
  const LdDuration({
    this.years = 0,
    this.months = 0,
    this.weeks = 0,
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
  })  : assert(years >= 0, 'years must be >= 0'),
        assert(months >= 0, 'months must be >= 0'),
        assert(weeks >= 0, 'weeks must be >= 0'),
        assert(days >= 0, 'days must be >= 0'),
        assert(hours >= 0, 'hours must be >= 0'),
        assert(minutes >= 0, 'minutes must be >= 0'),
        assert(seconds >= 0, 'seconds must be >= 0');

  final int years;
  final int months;
  final int weeks;
  final int days;
  final int hours;
  final int minutes;
  final int seconds;

  static const zero = LdDuration();

  /// Clock units only. Negative [duration] throws.
  factory LdDuration.fromDuration(Duration duration) {
    if (duration.isNegative) {
      throw ArgumentError.value(duration, 'duration', 'must not be negative');
    }
    return LdDuration(
      days: duration.inDays,
      hours: duration.inHours.remainder(24),
      minutes: duration.inMinutes.remainder(60),
      seconds: duration.inSeconds.remainder(60),
    );
  }

  factory LdDuration.parse(String iso8601) {
    final parsed = tryParse(iso8601);
    if (parsed == null) {
      throw FormatException('Invalid ISO 8601 duration', iso8601);
    }
    return parsed;
  }

  static LdDuration? tryParse(String iso8601) {
    if (iso8601.isEmpty || iso8601.codeUnitAt(0) != 80 /* P */) {
      return null;
    }
    if (iso8601.contains('.') || iso8601.contains(',')) {
      return null;
    }

    final rest = iso8601.substring(1);
    if (rest.isEmpty) {
      return null;
    }

    var inTime = false;
    var years = 0;
    var months = 0;
    var weeks = 0;
    var days = 0;
    var hours = 0;
    var minutes = 0;
    var seconds = 0;
    var sawAny = false;
    var sawWeek = false;
    var sawYmd = false;
    final number = StringBuffer();

    for (var i = 0; i < rest.length; i++) {
      final code = rest.codeUnitAt(i);
      if (code == 84 /* T */) {
        if (inTime || number.isNotEmpty) {
          return null;
        }
        inTime = true;
        if (i == rest.length - 1) {
          return null;
        }
        continue;
      }
      if (code >= 48 && code <= 57) {
        number.writeCharCode(code);
        continue;
      }
      if (number.isEmpty) {
        return null;
      }
      final n = int.tryParse(number.toString());
      if (n == null) {
        return null;
      }
      number.clear();
      sawAny = true;
      switch (code) {
        case 89: // Y
          if (inTime) {
            return null;
          }
          years = n;
          sawYmd = true;
        case 77: // M
          if (inTime) {
            minutes = n;
          } else {
            months = n;
            sawYmd = true;
          }
        case 87: // W
          if (inTime) {
            return null;
          }
          weeks = n;
          sawWeek = true;
        case 68: // D
          if (inTime) {
            return null;
          }
          days = n;
          sawYmd = true;
        case 72: // H
          if (!inTime) {
            return null;
          }
          hours = n;
        case 83: // S
          if (!inTime) {
            return null;
          }
          seconds = n;
        default:
          return null;
      }
    }
    if (number.isNotEmpty || !sawAny) {
      return null;
    }
    if (sawWeek && sawYmd) {
      return null;
    }
    return LdDuration(
      years: years,
      months: months,
      weeks: weeks,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  factory LdDuration.fromJson(String json) => LdDuration.parse(json);

  String toJson() => toIso8601String();

  bool get isZero =>
      years == 0 && months == 0 && weeks == 0 && days == 0 && hours == 0 && minutes == 0 && seconds == 0;

  int component(LdDurationUnit unit) {
    return switch (unit) {
      LdDurationUnit.years => years,
      LdDurationUnit.months => months,
      LdDurationUnit.weeks => weeks,
      LdDurationUnit.days => days,
      LdDurationUnit.hours => hours,
      LdDurationUnit.minutes => minutes,
      LdDurationUnit.seconds => seconds,
    };
  }

  LdDuration copyWith({
    int? years,
    int? months,
    int? weeks,
    int? days,
    int? hours,
    int? minutes,
    int? seconds,
  }) {
    return LdDuration(
      years: years ?? this.years,
      months: months ?? this.months,
      weeks: weeks ?? this.weeks,
      days: days ?? this.days,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
    );
  }

  LdDuration withComponent(LdDurationUnit unit, int value) {
    return switch (unit) {
      LdDurationUnit.years => copyWith(years: value),
      LdDurationUnit.months => copyWith(months: value),
      LdDurationUnit.weeks => copyWith(weeks: value),
      LdDurationUnit.days => copyWith(days: value),
      LdDurationUnit.hours => copyWith(hours: value),
      LdDurationUnit.minutes => copyWith(minutes: value),
      LdDurationUnit.seconds => copyWith(seconds: value),
    };
  }

  /// Carry overflowing clock and month fields. Days are not converted to weeks.
  LdDuration normalized() {
    var nextSeconds = seconds;
    var nextMinutes = minutes;
    var nextHours = hours;
    var nextDays = days;
    var nextMonths = months;
    var nextYears = years;

    nextMinutes += nextSeconds ~/ 60;
    nextSeconds = nextSeconds % 60;
    nextHours += nextMinutes ~/ 60;
    nextMinutes = nextMinutes % 60;
    nextDays += nextHours ~/ 24;
    nextHours = nextHours % 24;
    nextYears += nextMonths ~/ 12;
    nextMonths = nextMonths % 12;

    return LdDuration(
      years: nextYears,
      months: nextMonths,
      weeks: weeks,
      days: nextDays,
      hours: nextHours,
      minutes: nextMinutes,
      seconds: nextSeconds,
    );
  }

  /// Drops or folds fields that are not in [units].
  ///
  /// Years and months that are not enabled are dropped (they have no fixed
  /// conversion to days). Weeks fold into days, days into hours, and so on.
  LdDuration alignTo(Set<LdDurationUnit> units) {
    var nextYears = years;
    var nextMonths = months;
    var nextWeeks = weeks;
    var nextDays = days;
    var nextHours = hours;
    var nextMinutes = minutes;
    var nextSeconds = seconds;

    if (!units.contains(LdDurationUnit.years)) {
      nextYears = 0;
    }
    if (!units.contains(LdDurationUnit.months)) {
      nextMonths = 0;
    }
    if (!units.contains(LdDurationUnit.weeks)) {
      if (units.contains(LdDurationUnit.days)) {
        nextDays += nextWeeks * 7;
      }
      nextWeeks = 0;
    }
    if (!units.contains(LdDurationUnit.days)) {
      if (units.contains(LdDurationUnit.hours)) {
        nextHours += nextDays * 24;
      }
      nextDays = 0;
    }
    if (!units.contains(LdDurationUnit.hours)) {
      if (units.contains(LdDurationUnit.minutes)) {
        nextMinutes += nextHours * 60;
      }
      nextHours = 0;
    }
    if (!units.contains(LdDurationUnit.minutes)) {
      if (units.contains(LdDurationUnit.seconds)) {
        nextSeconds += nextMinutes * 60;
      }
      nextMinutes = 0;
    }
    if (!units.contains(LdDurationUnit.seconds)) {
      nextSeconds = 0;
    }

    return LdDuration(
      years: nextYears,
      months: nextMonths,
      weeks: nextWeeks,
      days: nextDays,
      hours: nextHours,
      minutes: nextMinutes,
      seconds: nextSeconds,
    );
  }

  LdDuration snap({
    int minuteStep = 1,
    int secondStep = 1,
  }) {
    int snapValue(int value, int step) {
      if (step <= 1) {
        return value;
      }
      return (value / step).round() * step;
    }

    return copyWith(
      minutes: snapValue(minutes, minuteStep),
      seconds: snapValue(seconds, secondStep),
    ).normalized();
  }

  LdDuration clamp({
    LdDuration? min,
    LdDuration? max,
  }) {
    var next = this;
    if (min != null && next.compareTo(min) < 0) {
      next = min;
    }
    if (max != null && next.compareTo(max) > 0) {
      next = max;
    }
    return next;
  }

  /// Non-null only when [years] and [months] are zero. Weeks become 7 days.
  Duration? get asDuration {
    if (years != 0 || months != 0) {
      return null;
    }
    return Duration(
      days: days + weeks * 7,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  /// Elapsed time of applying this duration at [anchor].
  Duration toDurationAt(DateTime anchor) {
    return anchor.addLdDuration(this).difference(anchor);
  }

  /// ISO 8601 duration. Weeks mixed with Y/M/D are folded into days.
  String toIso8601String() {
    final foldWeeks = weeks != 0 && (years != 0 || months != 0 || days != 0);
    final emitWeeks = weeks != 0 && !foldWeeks;
    final emitDays = days + (foldWeeks ? weeks * 7 : 0);

    final date = StringBuffer('P');
    if (years != 0) {
      date.write('${years}Y');
    }
    if (months != 0) {
      date.write('${months}M');
    }
    if (emitWeeks) {
      date.write('${weeks}W');
    }
    if (emitDays != 0) {
      date.write('${emitDays}D');
    }

    final time = StringBuffer();
    if (hours != 0) {
      time.write('${hours}H');
    }
    if (minutes != 0) {
      time.write('${minutes}M');
    }
    if (seconds != 0) {
      time.write('${seconds}S');
    }

    if (date.length == 1 && time.isEmpty) {
      return 'PT0S';
    }
    if (time.isNotEmpty) {
      date.write('T');
      date.write(time);
    }
    return date.toString();
  }

  /// Compact ASCII form for tests and logs: `1y 3mo 2d 4h`.
  String toCompactString() {
    if (isZero) {
      return '0s';
    }
    final parts = <String>[];
    if (years != 0) {
      parts.add('${years}y');
    }
    if (months != 0) {
      parts.add('${months}mo');
    }
    if (weeks != 0) {
      parts.add('${weeks}w');
    }
    if (days != 0) {
      parts.add('${days}d');
    }
    if (hours != 0) {
      parts.add('${hours}h');
    }
    if (minutes != 0) {
      parts.add('${minutes}m');
    }
    if (seconds != 0) {
      parts.add('${seconds}s');
    }
    return parts.join(' ');
  }

  @override
  int compareTo(LdDuration other) {
    final a = [years, months, weeks, days, hours, minutes, seconds];
    final b = [
      other.years,
      other.months,
      other.weeks,
      other.days,
      other.hours,
      other.minutes,
      other.seconds,
    ];
    for (var i = 0; i < a.length; i++) {
      final compared = a[i].compareTo(b[i]);
      if (compared != 0) {
        return compared;
      }
    }
    return 0;
  }

  @override
  bool operator ==(Object other) {
    return other is LdDuration &&
        other.years == years &&
        other.months == months &&
        other.weeks == weeks &&
        other.days == days &&
        other.hours == hours &&
        other.minutes == minutes &&
        other.seconds == seconds;
  }

  @override
  int get hashCode => Object.hash(years, months, weeks, days, hours, minutes, seconds);

  @override
  String toString() => toIso8601String();
}

extension LdDurationDateTime on DateTime {
  /// Adds [duration] with civil-calendar month/year rules (month-end clamps).
  DateTime addLdDuration(LdDuration duration) {
    if (duration.isZero) {
      return this;
    }
    final result = Jiffy.parseFromDateTime(this)
        .add(
          years: duration.years,
          months: duration.months,
          weeks: duration.weeks,
          days: duration.days,
          hours: duration.hours,
          minutes: duration.minutes,
          seconds: duration.seconds,
        )
        .dateTime;
    return isUtc ? result.toUtc() : result;
  }

  /// Subtracts [duration] with civil-calendar month/year rules (month-end clamps).
  DateTime subtractLdDuration(LdDuration duration) {
    if (duration.isZero) {
      return this;
    }
    final result = Jiffy.parseFromDateTime(this)
        .subtract(
          years: duration.years,
          months: duration.months,
          weeks: duration.weeks,
          days: duration.days,
          hours: duration.hours,
          minutes: duration.minutes,
          seconds: duration.seconds,
        )
        .dateTime;
    return isUtc ? result.toUtc() : result;
  }
}
