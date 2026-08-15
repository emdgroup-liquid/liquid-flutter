import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/bubbles/agent_activity_group.dart';
import 'package:liquid_flutter_ai/src/bubbles/agent_markdown.dart';
import 'package:liquid_flutter_ai/src/bubbles/approval.dart';
import 'package:liquid_flutter_ai/src/bubbles/reasoning.dart';
import 'package:liquid_flutter_ai/src/bubbles/system_prompt.dart';
import 'package:liquid_flutter_ai/src/bubbles/tool_call.dart';
import 'package:liquid_flutter_ai/src/bubbles/user_bubble.dart';
import 'package:liquid_flutter_ai/src/conversation/approval_actions.dart';
import 'package:liquid_flutter_ai/src/conversation/group_items.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';
import 'package:scroll_velocity_notifier/scroll_velocity_notifier.dart';

typedef LdConversationItemBuilder =
    Widget Function(
      BuildContext context,
      LdConversationItem item,
      bool isSingleton,
    );

typedef LdConversationGroupBuilder =
    Widget Function(
      BuildContext context,
      LdConversationVisualGroup group,
      LdConversationItemBuilder itemBuilder,
    );

/// Builds a custom tool-call row that replaces [LdToolCallCard].
typedef LdToolCallOverride = Widget Function(BuildContext context);

/// Return non-null to replace [LdToolCallCard] and keep the item as a singleton
/// (never folded into an activity group). Invoked for every [LdToolCallItem]
/// regardless of [LdToolCallStatus] — including pending/running (e.g. inline
/// subagents).
typedef LdToolCallOverrideResolver =
    LdToolCallOverride? Function(LdToolCallItem item);

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
  final LdConversationItemBuilder? itemBuilder;
  final LdConversationGroupBuilder? groupBuilder;

  /// When non-null for a tool call, replaces [LdToolCallCard] and pins that
  /// item outside activity-group collapse. Used by the default grouper via
  /// [groupConversationItems]'s `pinToolCall`.
  final LdToolCallOverrideResolver? toolCallOverride;

  /// Host handlers for pending approvals. Wired into [LdApprovalCard] by
  /// [defaultItemBuilder] when [itemBuilder] is null (or when a custom
  /// [itemBuilder] forwards [approval] to [defaultItemBuilder]).
  final LdConversationApprovalActions? approval;

  /// When set and greater than 0, items before this index are hidden until the
  /// user reveals them via the built-in control at the oldest end of the list.
  final int? hideBeforeIndex;

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
    this.toolCallOverride,
    this.approval,
    this.hideBeforeIndex,
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
    bool isSingleton, {
    LdConversationApprovalActions? approval,
    LdToolCallOverrideResolver? toolCallOverride,
  }) {
    return switch (item) {
      LdSystemPromptItem() => LdSystemPromptCard(item: item),
      LdUserMessageItem(text: final text, attachments: final attachments) =>
        LdUserBubble(text: text, attachments: attachments),
      LdAgentMarkdownItem(
        markdown: final markdown,
        isStreaming: final isStreaming,
      ) =>
        LdAgentMarkdownReply(markdown: markdown, isStreaming: isStreaming),
      LdToolCallItem() =>
        toolCallOverride?.call(item)?.call(context) ??
            LdToolCallCard(item: item),
      LdApprovalItem() => LdApprovalCard(
        item: item,
        onApprove: approval?.onApprove == null
            ? null
            : () => approval!.onApprove!(item),
        onDeny: approval?.onDeny == null ? null : () => approval!.onDeny!(item),
        onApproveWithRule: approval?.onApproveWithRule == null
            ? null
            : (result) => approval!.onApproveWithRule!(item, result),
        seedRule: approval?.seedRuleFor?.call(item),
      ),
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
    LdConversationItemBuilder resolvedItemBuilder,
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

  var _historyRevealed = false;

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LdConversation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hideBeforeIndex != widget.hideBeforeIndex) {
      _historyRevealed = false;
    }
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

  int get _effectiveHideBefore {
    final hide = widget.hideBeforeIndex;
    if (hide == null || hide <= 0 || _historyRevealed) {
      return 0;
    }
    return hide.clamp(0, widget.items.length);
  }

  List<LdConversationItem> get _visibleItems {
    final hide = _effectiveHideBefore;
    if (hide <= 0) {
      return widget.items;
    }
    return widget.items.sublist(hide);
  }

  int get _hiddenCount => _effectiveHideBefore;

  bool get _showRevealControl => _hiddenCount > 0;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.empty ?? const SizedBox.shrink();
    }

    final approval = widget.approval;
    final toolCallOverride = widget.toolCallOverride;

    Widget resolvedItemBuilder(
      BuildContext context,
      LdConversationItem item,
      bool isSingleton,
    ) {
      if (item is LdToolCallItem) {
        final override = toolCallOverride?.call(item);
        if (override != null) {
          return override(context);
        }
      }
      if (widget.itemBuilder != null) {
        return widget.itemBuilder!(context, item, isSingleton);
      }
      return LdConversation.defaultItemBuilder(
        context,
        item,
        isSingleton,
        approval: approval,
        toolCallOverride: toolCallOverride,
      );
    }

    final visibleItems = _visibleItems;
    final pinToolCall = toolCallOverride == null
        ? null
        : (LdToolCallItem item) => toolCallOverride(item) != null;

    final List<LdConversationVisualGroup> visualGroups;
    if (!widget.group) {
      visualGroups = visibleItems
          .map<LdConversationVisualGroup>(LdConversationSingletonGroup.new)
          .toList();
    } else if (widget.grouper != null) {
      visualGroups = widget.grouper!(visibleItems);
    } else {
      visualGroups = groupConversationItems(
        visibleItems,
        pinToolCall: pinToolCall,
      );
    }

    // Items arrive oldest → newest; the list is reversed so newest renders
    // near the bottom (closest to the compose bar).
    final displayGroups = visualGroups.reversed.toList(growable: false);

    final showReveal = _showRevealControl;
    final hasHostHeader = widget.header != null;
    final hasOldestChrome = showReveal || hasHostHeader;
    final hasFooter = widget.footer != null;
    final footerOffset = hasFooter ? 1 : 0;
    final itemCount =
        displayGroups.length +
        (hasOldestChrome ? 1 : 0) +
        (hasFooter ? 1 : 0);

    Widget buildOldestChrome() {
      final children = <Widget>[
        if (showReveal) _buildRevealControl(context),
        if (hasHostHeader) widget.header!,
      ];
      if (children.length == 1) {
        return children.single;
      }
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ).spaceS();
    }

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
            ? widget.groupBuilder!(context, visualGroup, resolvedItemBuilder)
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
        child: buildOldestChrome(),
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
        if (hasOldestChrome && id == 'ld-conversation-header') {
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

  Widget _buildRevealControl(BuildContext context) {
    final count = _hiddenCount;
    final label = count == 1
        ? 'Show 1 earlier message'
        : 'Show $count earlier messages';

    return Center(
      child: LdButton.ghost(
        size: LdSize.s,
        onPressed: () {
          setState(() => _historyRevealed = true);
        },
        child: Text(label),
      ),
    );
  }
}
