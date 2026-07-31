import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/bubbles/stream_reveal.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Max visible lines while reasoning is streaming (ticker window).
const int kLdReasoningTickerLines = 5;

/// Inline reasoning: ticker while streaming, collapses to a summary when done.
class LdReasoningCard extends StatefulWidget {
  final LdReasoningItem item;
  final bool isSingleton;

  const LdReasoningCard({
    super.key,
    required this.item,
    required this.isSingleton,
  });

  @override
  State<LdReasoningCard> createState() => _LdReasoningCardState();
}

class _LdReasoningCardState extends State<LdReasoningCard> {
  bool _userExpanded = false;

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get reasoningIsShort =>
      widget.item.content.trim().split('\n').length <= 3;

  bool get _shortenReasoning => switch (widget.item.isStreaming) {
    true => true,
    false => switch (reasoningIsShort) {
      true => true,
      false => switch (widget.isSingleton) {
        true => false,
        false => !_userExpanded,
      },
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    final showTicker =
        widget.item.isStreaming || reasoningIsShort || widget.isSingleton;

    return Column(
      children: [
        LdReveal(
          revealed: !showTicker,
          initialRevealed: !showTicker,
          child: _buildSummary(theme),
        ),

        LdReveal(
          revealed: showTicker || _userExpanded,
          initialRevealed: showTicker || _userExpanded,
          child: _buildTicker(theme),
        ),
      ],
    );
  }

  Widget _buildSummary(LdTheme theme) {
    final iconSize = theme.labelSize(LdSize.s);
    final label = ldReasoningLabel(widget.item.duration);

    return LdListItem(
      borderRadius: theme.radius(LdSize.s),
      leading: LdAvatar(
        color: theme.palette.neutral,
        child: Icon(LucideIcons.brain, size: iconSize),
      ),
      title: Text(label),
      onPressed: () {
        setState(() {
          _userExpanded = !_userExpanded;
        });
      },
    );
  }

  Widget _buildTicker(LdTheme theme) {
    final textStyle = ldBuildTextStyle(
      theme,
      LdTextType.paragraph,
      LdSize.s,
      color: theme.textMuted,
    );
    final lineHeight = (textStyle.fontSize ?? 14) * (textStyle.height ?? 1.35);
    final maxHeight = lineHeight * kLdReasoningTickerLines;
    final hasContent = widget.item.content.trim().isNotEmpty;

    return Column(
      children: [
        LdReveal.quick(
          revealed: !hasContent,
          initialRevealed: false,
          child: Row(
            children: [
              LdLoader(size: theme.labelSize(LdSize.s)),
              LdText.l('Thinking', color: theme.textMuted),
            ],
          ).spaceS(),
        ),
        LdReveal.quick(
          revealed: hasContent,
          initialRevealed: hasContent,
          child: LdWrapConditional(
            condition: _shortenReasoning,
            builder: (context, child) => ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: maxHeight,
                minWidth: double.infinity,
              ),
              child: LdScrollEdgeFade(
                fadeColor: theme.background,
                controller: _scrollController,
                bottomScrimExtent: 0,
                topScrimExtent: 0,
                fadeExtent: lineHeight * 0.85,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(
                    context,
                  ).copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    reverse: true,
                    padding: EdgeInsets.zero,
                    controller: _scrollController,
                    physics: !_shortenReasoning
                        ? const NeverScrollableScrollPhysics()
                        : const ClampingScrollPhysics(),
                    child: child,
                  ),
                ),
              ),
            ),

            child: LdStreamReveal(
              active: widget.item.isStreaming,
              child: SizedBox(
                width: double.infinity,
                child: Text(widget.item.content, style: textStyle),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Builds the "Thought" / "Thought for 12s" header label.
String ldReasoningLabel(Duration? duration) {
  if (duration == null) {
    return 'Thought';
  }
  return 'Thought for ${_ldFormatDuration(duration)}';
}

/// Formats a duration as seconds (`12s`) or minutes + seconds (`1m 5s`).
String _ldFormatDuration(Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds < 60) {
    return '${totalSeconds}s';
  }
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '${minutes}m ${seconds}s';
}
