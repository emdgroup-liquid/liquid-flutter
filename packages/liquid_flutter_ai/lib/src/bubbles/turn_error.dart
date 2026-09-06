import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';

/// Start-aligned turn failure, distinct from an assistant markdown reply.
class LdTurnErrorCard extends StatelessWidget {
  final LdTurnErrorItem item;

  const LdTurnErrorCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final code = item.code?.trim();
    return Align(
      alignment: Alignment.centerLeft,
      child: LdHint.error(
        withBackground: true,
        crossAxisAlignment: CrossAxisAlignment.start,
        child: LdAutoSpace(
          children: [
            LdText.l(
              'Turn failed',
              color: theme.errorColor,
            ),
            LdText.p(item.message),
            if (code != null && code.isNotEmpty) LdText.caption(code),
          ],
        ),
      ),
    );
  }
}
