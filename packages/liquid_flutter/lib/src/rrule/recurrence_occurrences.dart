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
