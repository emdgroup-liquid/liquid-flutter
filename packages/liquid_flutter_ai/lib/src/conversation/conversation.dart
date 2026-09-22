import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/bubbles/agent_activity_group.dart';
import 'package:liquid_flutter_ai/src/bubbles/agent_markdown.dart';
import 'package:liquid_flutter_ai/src/bubbles/approval.dart';
import 'package:liquid_flutter_ai/src/bubbles/reasoning.dart';
import 'package:liquid_flutter_ai/src/bubbles/system_prompt.dart';
import 'package:liquid_flutter_ai/src/bubbles/tool_call.dart';
import 'package:liquid_flutter_ai/src/bubbles/turn_error.dart';
import 'package:liquid_flutter_ai/src/bubbles/user_bubble.dart';
import 'package:liquid_flutter_ai/src/conversation/approval_actions.dart';
import 'package:liquid_flutter_ai/src/conversation/group_items.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';
import 'package:liquid_flutter_ai/src/send/outgoing_scope.dart';
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

typedef LdToolCallPressedCallback =
    void Function(BuildContext context, LdToolCallItem item);

/// Chronological conversation list (oldest at the top, newest at the bottom).
///
/// The list auto-scrolls to the newest content while the user is at (or near)
/// the bottom, and leaves the scroll position alone once they have scrolled up.
/// This avoids the index-jump behavior of a `reverse: true` list, where new
/// content inserted near the anchor shifts whatever the user is reading.
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

  /// Custom tool-call tap handler. When null, [LdToolCallCard] opens the
  /// built-in detail modal.
  final LdToolCallPressedCallback? onToolCallPressed;

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
    this.onToolCallPressed,
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
    LdToolCallPressedCallback? onToolCallPressed,
  }) {
    return switch (item) {
      LdSystemPromptItem() => LdSystemPromptCard(item: item),
      LdUserMessageItem() => LdUserBubble(
        text: item.text,
        attachments: item.attachments,
        delivery: item.delivery,
        deliveryError: item.deliveryError,
        onRetry: () =>
            LdOutgoingScope.maybeOf(context, listen: false)?.retry(item.id),
        onRetryAttachment: (attachmentId) => LdOutgoingScope.maybeOf(
          context,
          listen: false,
        )?.retryMessageAttachment(item.id, attachmentId),
      ),
      LdAgentMarkdownItem(
        markdown: final markdown,
        isStreaming: final isStreaming,
      ) =>
        LdAgentMarkdownReply(markdown: markdown, isStreaming: isStreaming),
      LdToolCallItem() =>
        toolCallOverride?.call(item)?.call(context) ??
            LdToolCallCard(
              item: item,
              onPressed: onToolCallPressed == null
                  ? null
                  : () => onToolCallPressed(context, item),
            ),
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
      LdTurnErrorItem() => LdTurnErrorCard(item: item),
      // Apps render inline GenUI surfaces via their own itemBuilder (they own
      // the surface manager); the default is a no-op placeholder.
      LdGenuiSurfaceItem() => const SizedBox.shrink(),
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
  /// Distance from the bottom (in logical pixels) within which the list
  /// re-pins to the newest content when it grows.
  static const _bottomPinThreshold = 80.0;

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  /// Match mo conversation list: only dismiss on a decisive fling.
  static const _flingVelocityThreshold = 20.0;
  static const _flingScrollDeltaThreshold = 30.0;

  /// Owns the list's [ScrollController] when the caller does not provide one.
  /// A [_BottomAnchoredScrollController] starts the non-reversed list at the
  /// bottom so a conversation opens on its newest messages without a jump.
  ScrollController? _ownedController;

  /// Whether the viewport is at (or near) the bottom and should follow new
  /// content. Cleared when the user scrolls away from the bottom.
  bool _pinnedToBottom = true;

  var _historyRevealed = false;

  ScrollController get _scrollController =>
      widget.scrollController ??
      (_ownedController ??= _BottomAnchoredScrollController());

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LdConversation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hideBeforeIndex != widget.hideBeforeIndex) {
      _historyRevealed = false;
    }
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

  /// Jumps to the newest content when the list is pinned to the bottom.
  ///
  /// Called after the list's dimensions change (new items, streaming text, or
  /// a viewport resize such as the keyboard opening) so the viewport follows
  /// content growth the way a reversed list would — but without shifting the
  /// user's position once they have scrolled up.
  void _pinToBottom() {
    if (!mounted || !_pinnedToBottom) {
      return;
    }
    final controller = _scrollController;
    if (!controller.hasClients) {
      return;
    }
    final position = controller.position;
    if (!position.hasContentDimensions) {
      return;
    }
    final target = position.maxScrollExtent;
    if ((position.pixels - target).abs() > 0.5) {
      controller.jumpTo(target);
    }
  }

  /// Tracks whether the viewport is at (or near) the bottom. Any pixel change
  /// that leaves the bottom band unpins the list until the user returns.
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final metrics = notification.metrics;
    final pinned =
        metrics.maxScrollExtent - metrics.pixels <= _bottomPinThreshold;
    _pinnedToBottom = pinned;
    return false;
  }

  /// Dismisses the soft keyboard when the list is flung quickly enough to
  /// look intentional, by stealing focus from the compose field.
  bool _onFlingNotification(ScrollNotification notification, double velocity) {
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

  double _lastMaxScrollExtent = -1;

  /// Re-pins after the list's content or viewport dimensions change.
  bool _handleScrollMetrics(ScrollMetricsNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (_pinnedToBottom &&
        notification.metrics.maxScrollExtent != _lastMaxScrollExtent) {
      _lastMaxScrollExtent = notification.metrics.maxScrollExtent;
      _pinToBottom();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.empty ?? const SizedBox.shrink();
    }

    final approval = widget.approval;
    final toolCallOverride = widget.toolCallOverride;
    final onToolCallPressed = widget.onToolCallPressed;

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
        onToolCallPressed: onToolCallPressed,
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

    // Items arrive oldest → newest and render top → bottom; the list auto-pins
    // to the newest content while the user is at (or near) the bottom.
    final displayGroups = visualGroups;

    final showReveal = _showRevealControl;
    final hasHostHeader = widget.header != null;
    final hasOldestChrome = showReveal || hasHostHeader;
    final hasFooter = widget.footer != null;
    final oldestChromeOffset = hasOldestChrome ? 1 : 0;
    final itemCount =
        oldestChromeOffset + displayGroups.length + (hasFooter ? 1 : 0);

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
      if (hasOldestChrome && index == 0) {
        return KeyedSubtree(
          key: const ValueKey('ld-conversation-header'),
          child: buildOldestChrome(),
        );
      }

      final groupIndex = index - oldestChromeOffset;
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
        key: const ValueKey('ld-conversation-footer'),
        child: widget.footer!,
      );
    }

    Widget body = LdScaffoldBody(
      itemCount: itemCount,
      addContainer: true,
      itemBuilder: buildRow,
      findChildIndexCallback: (key) {
        if (key is! ValueKey<String>) {
          return null;
        }
        final id = key.value;
        if (hasOldestChrome && id == 'ld-conversation-header') {
          return 0;
        }
        if (hasFooter && id == 'ld-conversation-footer') {
          return itemCount - 1;
        }
        final groupIndex = displayGroups.indexWhere((g) => g.key == id);
        if (groupIndex < 0) {
          return null;
        }
        return groupIndex + oldestChromeOffset;
      },
      scrollController: _scrollController,
      minimumPadding: widget.padding?.resolve(Directionality.of(context)),
    );

    body = NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleScrollMetrics,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: body,
      ),
    );

    return ScrollVelocityNotifier(
      onNotification: _onFlingNotification,
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

/// A [ScrollController] whose position starts at the bottom on its first
/// layout, so a non-reversed conversation list opens on its newest messages
/// without a visible jump.
///
/// Standard offset restoration still applies when a previous position exists;
/// only a freshly created position is anchored to the bottom.
class _BottomAnchoredScrollController extends ScrollController {
  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _BottomAnchoredScrollPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
    );
  }
}

class _BottomAnchoredScrollPosition extends ScrollPositionWithSingleContext {
  _BottomAnchoredScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
  }) : _restored = oldPosition != null;

  /// Whether an existing position was restored (in which case its offset is
  /// kept instead of anchoring to the bottom).
  bool _restored;

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    final changed = super.applyContentDimensions(
      minScrollExtent,
      maxScrollExtent,
    );
    if (!_restored && haveDimensions) {
      _restored = true;
      if (maxScrollExtent.isFinite && pixels != maxScrollExtent) {
        correctPixels(maxScrollExtent);
        return false;
      }
    }
    return changed;
  }
}
