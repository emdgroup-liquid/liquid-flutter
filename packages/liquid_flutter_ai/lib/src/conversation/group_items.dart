import 'package:liquid_flutter_ai/src/models/conversation_item.dart';

/// A visual row in the conversation list after grouping.
sealed class LdConversationVisualGroup {
  const LdConversationVisualGroup();

  String get key;
}

/// A single primary item rendered on its own row.
final class LdConversationSingletonGroup extends LdConversationVisualGroup {
  final LdConversationItem item;

  const LdConversationSingletonGroup(this.item);

  @override
  String get key => item.id;
}

/// Collapsed activity (tool calls + reasoning + completed approvals).
final class LdConversationActivityGroup extends LdConversationVisualGroup {
  final List<LdConversationItem> items;

  bool isLast;

  LdConversationActivityGroup(this.items, {this.isLast = false});

  /// Stable across appends within the same open activity buffer.
  @override
  String get key {
    if (items.isEmpty) {
      return 'activity-empty';
    }
    return 'activity-${items.first.id}';
  }

  int get toolCallCount => items.whereType<LdToolCallItem>().length;

  Duration? get totalReasoningDuration {
    Duration total = Duration.zero;
    var hasAny = false;
    for (final item in items.whereType<LdReasoningItem>()) {
      final d = item.duration;
      if (d != null) {
        hasAny = true;
        total += d;
      }
    }
    return hasAny ? total : null;
  }

  bool get hasRunningTools => items.whereType<LdToolCallItem>().any(
    (t) =>
        t.status == LdToolCallStatus.pending ||
        t.status == LdToolCallStatus.running,
  );

  bool get hasStreamingReasoning =>
      items.whereType<LdReasoningItem>().any((r) => r.isStreaming);

  /// True while tools are running or reasoning is still streaming.
  bool get isActive => isLast || hasRunningTools || hasStreamingReasoning;
}

/// Groups flat transcript items for display.
///
/// - Coalesces tool pieces that share [LdToolCallItem.toolCallId] (keeps latest).
/// - Buffers consecutive tool / reasoning / completed-approval items into
///   [LdConversationActivityGroup] (even for a single item, so the group widget
///   stays mounted when more activity appends).
/// - Flushes on user messages, agent markdown, system prompts, and pending
///   approvals.
/// - System prompts and pending approvals are always singleton rows.
List<LdConversationVisualGroup> groupConversationItems(
  List<LdConversationItem> items, {
  bool coalesceToolCalls = true,
}) {
  final prepared = coalesceToolCalls ? _coalesceToolCalls(items) : items;
  final result = <LdConversationVisualGroup>[];
  final buffer = <LdConversationItem>[];

  void flushBuffer() {
    if (buffer.isEmpty) {
      return;
    }
    // Always emit an activity group (even for a single item) so reasoning can
    // open inside [LdAgentActivityGroup] and tools can append without remount.
    result.add(LdConversationActivityGroup(List.unmodifiable(buffer)));
    buffer.clear();
  }

  for (final item in prepared) {
    if (ldIsPendingApproval(item)) {
      flushBuffer();
      result.add(LdConversationSingletonGroup(item));
      continue;
    }

    if (ldIsAgentActivityItem(item)) {
      buffer.add(item);
      continue;
    }

    flushBuffer();
    result.add(LdConversationSingletonGroup(item));
  }

  flushBuffer();
  if (result.isNotEmpty) {
    final last = result[result.length - 1];
    if (last is LdConversationActivityGroup) {
      last.isLast = true;
    }
  }

  return result;
}

/// Keeps the last tool item per [LdToolCallItem.toolCallId], preserving order
/// of first occurrence.
List<LdConversationItem> _coalesceToolCalls(List<LdConversationItem> items) {
  final latestByToolCallId = <String, LdToolCallItem>{};
  for (final item in items) {
    if (item is LdToolCallItem) {
      latestByToolCallId[item.toolCallId] = item;
    }
  }

  final seen = <String>{};
  final result = <LdConversationItem>[];
  for (final item in items) {
    if (item is! LdToolCallItem) {
      result.add(item);
      continue;
    }
    if (seen.contains(item.toolCallId)) {
      continue;
    }
    seen.add(item.toolCallId);
    result.add(latestByToolCallId[item.toolCallId]!);
  }
  return result;
}
