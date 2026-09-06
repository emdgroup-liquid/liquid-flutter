import 'package:flutter/foundation.dart';
import 'package:liquid_flutter_ai/src/models/compose_attachment.dart';

enum LdToolCallStatus {
  pending,
  running,
  done,
  error,
}

enum LdApprovalStatus {
  pending,
  approved,
  denied,
}

/// Flat transcript item. Apps own ordering (oldest → newest).
@immutable
sealed class LdConversationItem {
  final String id;

  const LdConversationItem({
    required this.id,
  });
}

final class LdSystemPromptItem extends LdConversationItem {
  final String content;

  /// Optional short label shown in the collapsed header.
  /// Defaults to "System prompt" in [LdSystemPromptCard].
  final String? title;

  const LdSystemPromptItem({
    required super.id,
    required this.content,
    this.title,
  });
}

final class LdUserMessageItem extends LdConversationItem {
  final String text;
  final List<LdComposeAttachment> attachments;

  const LdUserMessageItem({
    required super.id,
    required this.text,
    this.attachments = const [],
  });
}

final class LdAgentMarkdownItem extends LdConversationItem {
  final String markdown;
  final bool isStreaming;

  const LdAgentMarkdownItem({
    required super.id,
    required this.markdown,
    this.isStreaming = false,
  });
}

final class LdToolCallItem extends LdConversationItem {
  final String name;
  final String toolCallId;
  final LdToolCallStatus status;
  final String? argsPreview;
  final String? resultPreview;

  /// Full tool arguments for the detail modal (may exceed [argsPreview]).
  final String? args;

  /// Full tool result for the detail modal (may exceed [resultPreview]).
  final String? result;

  const LdToolCallItem({
    required super.id,
    required this.name,
    required this.toolCallId,
    this.status = LdToolCallStatus.pending,
    this.argsPreview,
    this.resultPreview,
    this.args,
    this.result,
  });
}

final class LdApprovalItem extends LdConversationItem {
  final String title;
  final String? description;
  final String? toolCallId;
  final String? toolName;
  final Object? arguments;

  /// Optional JSON Schema for the tool input (map or JSON string).
  final Object? inputSchema;
  final LdApprovalStatus status;

  const LdApprovalItem({
    required super.id,
    required this.title,
    this.description,
    this.toolCallId,
    this.toolName,
    this.arguments,
    this.inputSchema,
    this.status = LdApprovalStatus.pending,
  });
}

final class LdReasoningItem extends LdConversationItem {
  final String content;
  final Duration? duration;
  final bool isStreaming;

  const LdReasoningItem({
    required super.id,
    required this.content,
    this.duration,
    this.isStreaming = false,
  });
}

/// Visible provider / runner failure. Never looks like a successful reply.
final class LdTurnErrorItem extends LdConversationItem {
  final String message;
  final String? code;

  const LdTurnErrorItem({
    required super.id,
    required this.message,
    this.code,
  });
}

/// Whether [item] is tool/reasoning noise that can collapse into an activity group.
bool ldIsAgentActivityItem(LdConversationItem item) {
  return switch (item) {
    LdToolCallItem() => true,
    LdReasoningItem() => true,
    LdApprovalItem(:final status) => status == LdApprovalStatus.approved,
    _ => false,
  };
}

/// Pending approvals must stay visible and actionable.
bool ldIsPendingApproval(LdConversationItem item) {
  return item is LdApprovalItem && item.status == LdApprovalStatus.pending;
}
