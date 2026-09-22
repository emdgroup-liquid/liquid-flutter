import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final ldConfirm = ldCatalogItem(
  name: 'LdConfirm',
  schema: ldConfirmSchema,
  parse: LdConfirmData.fromJson,
  builder: (ctx, data) => LdConfirm(catalogContext: ctx, data: data),
);

class LdConfirm extends StatelessWidget {
  const LdConfirm({
    super.key,
    required this.catalogContext,
    required this.data,
  });

  final CatalogItemContext catalogContext;
  final LdConfirmData data;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final color = switch (data.tone) {
      LdConfirmTone.warning => theme.warning,
      LdConfirmTone.danger => theme.error,
      LdConfirmTone.info => null,
    };
    final message = data.message;
    final secondary = data.secondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdBadge(
          symmetric: true,
          color: color,
          size: LdSize.l,
          child: Icon(LucideIcons.circleQuestionMark),
        ),

        Expanded(
          child: LdAutoSpace(
            children: [
              LdText.h(data.title),
              if (message != null && message.isNotEmpty) LdText.p(message),
              LdHorizontalScroll(
                children: [
                  if (secondary != null) ...[
                    LdButton(
                      size: LdSize.l,
                      mode: LdButtonMode.outline,
                      onPressed: () =>
                          dispatchLdAction(catalogContext, secondary.action),
                      child: Text(secondary.label),
                    ),
                  ],
                  LdButton(
                    mode: LdButtonMode.filled,
                    color: color,
                    size: LdSize.l,
                    onPressed: () =>
                        dispatchLdAction(catalogContext, data.primary.action),
                    child: Text(data.primary.label),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ).spaceS();
  }
}
