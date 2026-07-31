import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/conversation/group_items.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Activity cluster: expanded body while active, summary header when done.
///
/// Header and body stay mounted for the lifetime of the group. Visibility is
/// swapped with [AnimatedSize] so collapse/expand does not remount or jump.
/// While [isActive], the summary header is height-folded away; when activity
/// finishes, the body folds away and the header opens. Tap re-expands.
class LdAgentActivityGroup extends StatefulWidget {
  final LdConversationActivityGroup group;
  final bool isActive;
  final Widget Function(
    BuildContext context,
    LdConversationItem item,
    bool isSingleton,
  )
  itemBuilder;

  const LdAgentActivityGroup({
    super.key,
    required this.group,
    this.isActive = false,
    required this.itemBuilder,
  });

  @override
  State<LdAgentActivityGroup> createState() => _LdAgentActivityGroupState();
}

class _LdAgentActivityGroupState extends State<LdAgentActivityGroup> {
  var _userExpanded = false;

  @override
  void didUpdateWidget(covariant LdAgentActivityGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive && !widget.isActive) {
      // Freshly completed — land in collapsed summary.
      _userExpanded = false;
    }
  }

  bool get _showHeader => !widget.isActive;

  bool get _showBody => widget.isActive || _userExpanded;

  void _toggle() {
    setState(() => _userExpanded = !_userExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    // Always build both layers so AnimatedSize only changes height factors.

    final body = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in widget.group.items) _buildItem(context, item),
        ],
      ).spaceS(),
    );

    return LdTouchableSurface(
      onPressed: _toggle,
      active: _userExpanded,
      builder: (context, status, child) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _userExpanded ? theme.surface : theme.background,
          borderRadius: theme.radius(LdSize.s),
        ),
        padding: _userExpanded ? theme.pad(size: LdSize.s) : EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Keep header mounted; fold height with AnimatedSize + Offstage so
            // collapse/expand never remounts or jumps a frame.
            LdReveal(
              revealed: _showHeader,
              initialRevealed: _showHeader,
              child: _buildHeader(
                theme,
                outlineColor(theme.primary, theme, status).text,
              ),
            ),
            LdReveal(
              revealed: _userExpanded,
              initialRevealed: _userExpanded,
              child: ldSpacerS,
            ),
            LdReveal(
              revealed: _showBody,
              initialRevealed: _showBody,
              child: LdListItemConfigProvider(
                config: LdListItemConfig(
                  padding: _userExpanded
                      ? theme.pad(size: LdSize.s)
                      : EdgeInsets.zero,
                ),
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LdTheme theme, Color textColor) {
    final summary = ldActivitySummary(widget.group);
    final iconSize = theme.labelSize(LdSize.s);
    final leadingIcon = widget.group.hasRunningTools
        ? LdLoader(size: iconSize, neutral: true)
        : Icon(LucideIcons.brain, size: iconSize, color: textColor);

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leadingIcon,

          Flexible(
            child: LdText.l(
              summary,
              overflow: TextOverflow.ellipsis,
              color: textColor,
            ),
          ),
          Icon(
            _userExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
            size: iconSize,
            color: textColor,
          ),
        ],
      ).spaceS(),
    );
  }

  Widget _buildItem(BuildContext context, LdConversationItem item) {
    final builder = widget.itemBuilder;
    return KeyedSubtree(
      key: ValueKey(item.id),
      child: builder(context, item, widget.group.items.length == 1),
    );
  }
}

/// Builds the collapsed header summary, e.g. `3 tool calls · Thought 12s`.
String ldActivitySummary(LdConversationActivityGroup group) {
  final parts = <String>[];

  final toolCallCount = group.toolCallCount;
  if (toolCallCount > 0) {
    parts.add(toolCallCount == 1 ? '1 tool call' : '$toolCallCount tool calls');
  }

  final reasoningDuration = group.totalReasoningDuration;
  if (reasoningDuration != null) {
    parts.add('Thought ${_ldFormatDuration(reasoningDuration)}');
  }

  return parts.isEmpty ? 'Activity' : parts.join(' · ');
}

String _ldFormatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds < 60) {
    return '${totalSeconds}s';
  }
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes}m ${seconds}s';
}
