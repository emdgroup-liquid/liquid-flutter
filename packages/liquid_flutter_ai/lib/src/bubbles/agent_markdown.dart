import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/bubbles/stream_reveal.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

/// Start-aligned agent reply rendered as markdown.
///
/// While [isStreaming] is true, content is wrapped in [LdStreamReveal] so
/// layout growth (any blocks inside) fades in at the bottom edge.
class LdAgentMarkdownReply extends StatelessWidget {
  final String markdown;
  final bool isStreaming;

  const LdAgentMarkdownReply({
    super.key,
    required this.markdown,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdReveal.quick(
          revealed: markdown.isEmpty,
          initialRevealed: false,
          child: Row(
            children: [
              LdLoader(size: theme.labelSize(LdSize.s)),
              LdMute(child: LdText.l("Preparing response...")),
            ],
          ).spaceS(),
        ),
        if (markdown.isNotEmpty)
          LdStreamReveal(
            active: isStreaming,
            child: SizedBox(
              width: double.infinity,
              child: LdMarkdown(data: markdown),
            ),
          ),
      ],
    );
  }
}
