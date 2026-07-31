import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/bubbles/agent_activity_group.dart';
import 'package:liquid_flutter_ai/src/bubbles/agent_markdown.dart';
import 'package:liquid_flutter_ai/src/bubbles/approval.dart';
import 'package:liquid_flutter_ai/src/bubbles/reasoning.dart';
import 'package:liquid_flutter_ai/src/bubbles/system_prompt.dart';
import 'package:liquid_flutter_ai/src/bubbles/tool_call.dart';
import 'package:liquid_flutter_ai/src/bubbles/user_bubble.dart';
import 'package:liquid_flutter_ai/src/conversation/group_items.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';
import 'package:scroll_velocity_notifier/scroll_velocity_notifier.dart';

/// Reversed conversation list (newest near the compose bar).
///
/// When [dismissKeyboardOnFling] is true (default), a fast fling on the list
/// moves focus into an empty [FocusScope] so the compose field loses focus and
/// the soft keyboard dismisses.
class LdConversation extends StatefulWidget {
  final List<LdConversationItem> items;
  final bool group;
  final List<LdConversationVisualGroup> Function(List<LdConversationItem>)?
  grouper;
  final Widget Function(
    BuildContext context,
    LdConversationItem item,
    bool isSingleton,
  )?
  itemBuilder;
  final Widget Function(BuildContext context, LdConversationVisualGroup group)?
  groupBuilder;
  final Widget? empty;
  final Widget? header;
  final Widget? footer;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;

  /// Steal focus from the compose field when the list is flung quickly.
  final bool dismissKeyboardOnFling;

  const LdConversation({
    super.key,
    required this.items,
    this.group = true,
    this.grouper,
    this.itemBuilder,
    this.groupBuilder,
    this.empty,
    this.header,
    this.footer,
    this.scrollController,
    this.padding,
    this.dismissKeyboardOnFling = true,
  });

  /// Default item → widget mapping. Exposed so custom [groupBuilder]s can
  /// delegate singleton rendering back to the standard bubbles.
  static Widget defaultItemBuilder(
    BuildContext context,
    LdConversationItem item,
    bool isSingleton,
  ) {
    return switch (item) {
      LdSystemPromptItem() => LdSystemPromptCard(item: item),
      LdUserMessageItem(text: final text, attachments: final attachments) =>
        LdUserBubble(text: text, attachments: attachments),
      LdAgentMarkdownItem(
        markdown: final markdown,
        isStreaming: final isStreaming,
      ) =>
        LdAgentMarkdownReply(markdown: markdown, isStreaming: isStreaming),
      LdToolCallItem() => LdToolCallCard(item: item),
      LdApprovalItem() => LdApprovalCard(item: item),
      LdReasoningItem() => LdReasoningCard(
        item: item,
        isSingleton: isSingleton,
      ),
    };
  }

  /// Default group → widget mapping, delegating singleton items to
  /// [defaultItemBuilder] (or a caller-provided [resolvedItemBuilder]).
  static Widget defaultGroupBuilder(
    BuildContext context,
    LdConversationVisualGroup group,
    Widget Function(
      BuildContext context,
      LdConversationItem item,
      bool isSingleton,
    )
    resolvedItemBuilder,
  ) {
    return switch (group) {
      LdConversationSingletonGroup(item: final item) => resolvedItemBuilder(
        context,
        item,
        true,
      ),
      LdConversationActivityGroup() => LdAgentActivityGroup(
        group: group,
        isActive: group.isActive,
        itemBuilder: (context, item, isSingleton) =>
            resolvedItemBuilder(context, item, isSingleton),
      ),
    };
  }

  @override
  State<LdConversation> createState() => _LdConversationState();
}

class _LdConversationState extends State<LdConversation> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  /// Match mo conversation list: only dismiss on a decisive fling.
  static const _flingVelocityThreshold = 20.0;
  static const _flingScrollDeltaThreshold = 30.0;

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification, double velocity) {
    if (!widget.dismissKeyboardOnFling) {
      return false;
    }
    if (notification is! ScrollUpdateNotification) {
      return false;
    }
    if (velocity.abs() > _flingVelocityThreshold &&
        (notification.scrollDelta?.abs() ?? 0) > _flingScrollDeltaThreshold) {
      _focusScopeNode.requestFocus();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.empty ?? const SizedBox.shrink();
    }

    final resolvedItemBuilder =
        widget.itemBuilder ?? LdConversation.defaultItemBuilder;
    final resolvedGrouper = widget.grouper ?? groupConversationItems;

    final visualGroups = widget.group
        ? resolvedGrouper(widget.items)
        : widget.items
              .map<LdConversationVisualGroup>(LdConversationSingletonGroup.new)
              .toList();

    // Items arrive oldest → newest; the list is reversed so newest renders
    // near the bottom (closest to the compose bar).
    final displayGroups = visualGroups.reversed.toList(growable: false);

    final hasHeader = widget.header != null;
    final hasFooter = widget.footer != null;
    final footerOffset = hasFooter ? 1 : 0;
    final itemCount =
        displayGroups.length + (hasHeader ? 1 : 0) + (hasFooter ? 1 : 0);

    Widget buildRow(BuildContext context, int index) {
      if (hasFooter && index == 0) {
        return KeyedSubtree(
          key: const ValueKey('ld-conversation-footer'),
          child: widget.footer!,
        );
      }

      final groupIndex = index - footerOffset;
      if (groupIndex < displayGroups.length) {
        final visualGroup = displayGroups[groupIndex];
        final child = widget.groupBuilder != null
            ? widget.groupBuilder!(context, visualGroup)
            : LdConversation.defaultGroupBuilder(
                context,
                visualGroup,
                resolvedItemBuilder,
              );
        return KeyedSubtree(
          key: ValueKey(visualGroup.key),
          child: child.padVertical(size: LdSize.xs),
        );
      }

      return KeyedSubtree(
        key: const ValueKey('ld-conversation-header'),
        child: widget.header!,
      );
    }

    final body = LdScaffoldBody(
      reverse: true,
      itemCount: itemCount,
      addContainer: true,
      itemBuilder: buildRow,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<String>) {
          return null;
        }
        final id = key.value;
        if (hasFooter && id == 'ld-conversation-footer') {
          return 0;
        }
        if (hasHeader && id == 'ld-conversation-header') {
          return itemCount - 1;
        }
        final groupIndex = displayGroups.indexWhere((g) => g.key == id);
        if (groupIndex < 0) {
          return null;
        }
        return groupIndex + footerOffset;
      },
      scrollController: widget.scrollController,
      minimumPadding: widget.padding?.resolve(Directionality.of(context)),
    );

    return ScrollVelocityNotifier(
      onNotification: _onScrollNotification,
      child: FocusScope(node: _focusScopeNode, child: body),
    );
  }
}
