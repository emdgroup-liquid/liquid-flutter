import 'dart:developer' as developer;

import 'package:liquid_flutter/src/rrule/rrule_draft.dart';
import 'package:rrule/rrule.dart';

const ldRecurrencePreviewCount = 3;
const ldRecurrenceMaxOccurrences = 500;

/// Compact preview of upcoming instances, plus the last instance when the rule ends.
class LdRecurrenceOccurrencePreview {
  const LdRecurrenceOccurrencePreview({
    required this.next,
    this.last,
    this.lastOccurrenceNumber,
    required this.finite,
    required this.lastTruncated,
  });

  final List<DateTime> next;
  final DateTime? last;

  /// 1-based index of [last] in the full series (e.g. `COUNT=10` → `10`).
  final int? lastOccurrenceNumber;
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

class _MergedExpansion {
  const _MergedExpansion({
    required this.instances,
    required this.truncated,
  });

  final List<DateTime> instances;
  final bool truncated;
}

bool ldRecurrenceRuleIsFinite(RecurrenceRule rule) {
  return rule.count != null || rule.until != null;
}

void _reportExpansionError(Object error, StackTrace stackTrace) {
  assert(() {
    developer.log(
      'Failed to expand RecurrenceRule',
      name: 'liquid_flutter.rrule',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  }());
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
          lastOccurrenceNumber: exhaustedCount ? count : null,
          finite: true,
          lastTruncated: !exhaustedCount,
        );
      }
    }
  } catch (error, stackTrace) {
    _reportExpansionError(error, stackTrace);
    return const LdRecurrenceOccurrencePreview(
      next: [],
      finite: false,
      lastTruncated: false,
    );
  }

  return LdRecurrenceOccurrencePreview(
    next: next,
    last: finite ? lastSeen : null,
    lastOccurrenceNumber: finite ? count : null,
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
  } catch (error, stackTrace) {
    _reportExpansionError(error, stackTrace);
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
///
/// Expands each rule one past [maxAll] so a series that ends exactly at the
/// cap is not treated as truncated.
_MergedExpansion _ldRecurrenceMergedInstances({
  required List<RecurrenceRule> rules,
  required DateTime start,
  required int maxAll,
}) {
  if (rules.isEmpty) {
    return const _MergedExpansion(instances: [], truncated: false);
  }

  final utcStart = ldToRruleUtc(start);
  final merged = <DateTime>{};
  final peekLimit = maxAll + 1;

  for (final rule in rules) {
    var count = 0;
    try {
      for (final instance in rule.getInstances(start: utcStart)) {
        merged.add(ldFromRruleUtc(instance));
        count++;
        if (count >= peekLimit) {
          break;
        }
      }
    } catch (error, stackTrace) {
      _reportExpansionError(error, stackTrace);
    }
  }

  final sorted = merged.toList()..sort();
  if (sorted.length > maxAll) {
    return _MergedExpansion(
      instances: sorted.sublist(0, maxAll),
      truncated: true,
    );
  }
  return _MergedExpansion(
    instances: sorted,
    truncated: false,
  );
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
  final expansion = _ldRecurrenceMergedInstances(
    rules: rules,
    start: start,
    maxAll: maxAll,
  );

  if (expansion.instances.isEmpty) {
    return LdRecurrenceOccurrencePreview(
      next: const [],
      finite: finite,
      lastTruncated: false,
    );
  }

  final next = expansion.instances.take(nextCount).toList();
  if (!finite) {
    return LdRecurrenceOccurrencePreview(
      next: next,
      finite: false,
      lastTruncated: false,
    );
  }

  final truncated = expansion.truncated;
  return LdRecurrenceOccurrencePreview(
    next: next,
    last: truncated ? null : expansion.instances.last,
    lastOccurrenceNumber: truncated ? null : expansion.instances.length,
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
  final expansion = _ldRecurrenceMergedInstances(
    rules: rules,
    start: start,
    maxAll: maxAll,
  );

  return LdRecurrenceOccurrenceList(
    instances: expansion.instances,
    truncated: !finite || expansion.truncated,
  );
}
