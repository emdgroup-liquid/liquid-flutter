import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Collapsed-by-default system prompt row.
class LdSystemPromptCard extends StatefulWidget {
  final LdSystemPromptItem item;

  /// When true, content is visible on first mount. Defaults to false.
  final bool initiallyExpanded;

  const LdSystemPromptCard({
    super.key,
    required this.item,
    this.initiallyExpanded = false,
  });

  @override
  State<LdSystemPromptCard> createState() => _LdSystemPromptCardState();
}

class _LdSystemPromptCardState extends State<LdSystemPromptCard> {
  late var _expanded = widget.initiallyExpanded;

  @override
  void didUpdateWidget(covariant LdSystemPromptCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded &&
        widget.initiallyExpanded &&
        !_expanded) {
      _expanded = true;
    }
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final iconSize = theme.labelSize(LdSize.s);
    final rawTitle = widget.item.title?.trim();
    final title = (rawTitle == null || rawTitle.isEmpty)
        ? 'System prompt'
        : rawTitle;
    final textStyle = ldBuildTextStyle(
      theme,
      LdTextType.paragraph,
      LdSize.s,
      color: theme.textMuted,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        LdTouchableSurface(
          onPressed: _toggle,
          active: _expanded,
          builder: (context, status, child) => Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.scrollText,
                  size: iconSize,
                  color: theme.textMuted,
                ),
                Flexible(
                  child: LdMute(
                    child: LdText.l(title, overflow: TextOverflow.ellipsis),
                  ),
                ),
                Icon(
                  _expanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: iconSize,
                  color: theme.textMuted,
                ),
              ],
            ).spaceS(),
          ),
        ),
        LdReveal(
          revealed: _expanded,
          initialRevealed: _expanded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ldSpacerS,
              SelectableText(
                widget.item.content,
                style: textStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
