import 'package:liquid_flutter/src/rrule/rrule_draft.dart';
import 'package:rrule/rrule.dart';

const ldRecurrencePreviewCount = 3;
const ldRecurrenceMaxOccurrences = 500;

/// Compact preview of upcoming instances, plus the last instance when the rule ends.
class LdRecurrenceOccurrencePreview {
  const LdRecurrenceOccurrencePreview({
    required this.next,
    this.last,
    required this.finite,
    required this.lastTruncated,
  });

  final List<DateTime> next;
  final DateTime? last;
  final bool finite;
  final bool lastTruncated;
}

class LdRecurrenceOccurrenceList {
  const LdRecurrenceOccurrenceList({
    required this.instances,
    required this.truncated,
  });

  final List<DateTime> instances;
  final bool truncated;
}

bool ldRecurrenceRuleIsFinite(RecurrenceRule rule) {
  return rule.count != null || rule.until != null;
}

LdRecurrenceOccurrencePreview ldRecurrenceOccurrencePreview({
  required RecurrenceRule rule,
  required DateTime start,
  int nextCount = ldRecurrencePreviewCount,
  int maxAll = ldRecurrenceMaxOccurrences,
}) {
  final finite = ldRecurrenceRuleIsFinite(rule);
  final utcStart = ldToRruleUtc(start);
  final next = <DateTime>[];
  DateTime? lastSeen;
  var count = 0;

  try {
    for (final instance in rule.getInstances(start: utcStart)) {
      final local = ldFromRruleUtc(instance);
      count++;
      if (next.length < nextCount) {
        next.add(local);
      }
      lastSeen = local;
      if (!finite && next.length >= nextCount) {
        break;
      }
      if (finite && count >= maxAll) {
        final exhaustedCount = rule.count != null && rule.count! <= maxAll;
        return LdRecurrenceOccurrencePreview(
          next: next,
          last: exhaustedCount ? lastSeen : null,
          finite: true,
          lastTruncated: !exhaustedCount,
        );
      }
    }
  } catch (_) {
    return const LdRecurrenceOccurrencePreview(
      next: [],
      finite: false,
      lastTruncated: false,
    );
  }

  return LdRecurrenceOccurrencePreview(
    next: next,
    last: finite ? lastSeen : null,
    finite: finite,
    lastTruncated: false,
  );
}

LdRecurrenceOccurrenceList ldRecurrenceAllOccurrences({
  required RecurrenceRule rule,
  required DateTime start,
  int maxAll = ldRecurrenceMaxOccurrences,
}) {
  final utcStart = ldToRruleUtc(start);
  final instances = <DateTime>[];
  var truncated = false;

  try {
    for (final instance in rule.getInstances(start: utcStart)) {
      instances.add(ldFromRruleUtc(instance));
      if (instances.length >= maxAll) {
        final countDone = rule.count != null && rule.count! <= maxAll;
        truncated = !countDone;
        break;
      }
    }
  } catch (_) {
    return const LdRecurrenceOccurrenceList(
      instances: [],
      truncated: false,
    );
  }

  return LdRecurrenceOccurrenceList(
    instances: instances,
    truncated: truncated,
  );
}

/// Merged, sorted, de-duplicated instances across [rules].
List<DateTime> _ldRecurrenceMergedInstances({
  required List<RecurrenceRule> rules,
  required DateTime start,
  required int maxAll,
}) {
  if (rules.isEmpty) {
    return const [];
  }

  final utcStart = ldToRruleUtc(start);
  final merged = <DateTime>{};

  for (final rule in rules) {
    var count = 0;
    try {
      for (final instance in rule.getInstances(start: utcStart)) {
        merged.add(ldFromRruleUtc(instance));
        count++;
        if (count >= maxAll) {
          break;
        }
      }
    } catch (_) {
      // Skip rules that cannot expand.
    }
  }

  final sorted = merged.toList()..sort();
  if (sorted.length <= maxAll) {
    return sorted;
  }
  return sorted.sublist(0, maxAll);
}

/// Compact preview of upcoming instances across multiple rules.
///
/// [last] is only set when every rule is finite (has `COUNT` or `UNTIL`).
LdRecurrenceOccurrencePreview ldRecurrenceMergedOccurrencePreview({
  required List<RecurrenceRule> rules,
  required DateTime start,
  int nextCount = ldRecurrencePreviewCount,
  int maxAll = ldRecurrenceMaxOccurrences,
}) {
  if (rules.isEmpty) {
    return const LdRecurrenceOccurrencePreview(
      next: [],
      finite: false,
      lastTruncated: false,
    );
  }

  final finite = rules.every(ldRecurrenceRuleIsFinite);
  final all = _ldRecurrenceMergedInstances(
    rules: rules,
    start: start,
    maxAll: maxAll,
  );

  if (all.isEmpty) {
    return LdRecurrenceOccurrencePreview(
      next: const [],
      finite: finite,
      lastTruncated: false,
    );
  }

  final next = all.take(nextCount).toList();
  if (!finite) {
    return LdRecurrenceOccurrencePreview(
      next: next,
      finite: false,
      lastTruncated: false,
    );
  }

  final truncated = all.length >= maxAll;
  return LdRecurrenceOccurrencePreview(
    next: next,
    last: truncated ? null : all.last,
    finite: true,
    lastTruncated: truncated,
  );
}

/// Full merged occurrence list across multiple rules (capped).
LdRecurrenceOccurrenceList ldRecurrenceMergedAllOccurrences({
  required List<RecurrenceRule> rules,
  required DateTime start,
  int maxAll = ldRecurrenceMaxOccurrences,
}) {
  if (rules.isEmpty) {
    return const LdRecurrenceOccurrenceList(
      instances: [],
      truncated: false,
    );
  }

  final finite = rules.every(ldRecurrenceRuleIsFinite);
  final all = _ldRecurrenceMergedInstances(
    rules: rules,
    start: start,
    maxAll: maxAll,
  );

  return LdRecurrenceOccurrenceList(
    instances: all,
    truncated: !finite || all.length >= maxAll,
  );
}
