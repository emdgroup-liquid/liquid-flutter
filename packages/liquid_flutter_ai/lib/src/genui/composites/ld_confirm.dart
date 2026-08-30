import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

final ldConfirm = CatalogItem(
  name: 'LdConfirm',
  dataSchema: ldConfirmSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final title = d['title'] as String? ?? '';
    final message = d['message'] as String?;
    final tone = d['tone'] as String? ?? 'info';
    final primary = d['primary'] as JsonMap?;
    final secondary = d['secondary'] as JsonMap?;

    if (title.isEmpty || primary == null) {
      final error = FormatException(
        'LdConfirm "${ctx.id}" requires title and primary{label,action}',
      );
      ctx.reportError(error, StackTrace.current);
      return FallbackWidget(error: error);
    }

    return Builder(
      builder: (context) {
        final theme = LdTheme.of(context);
        final color = switch (tone) {
          'warning' => theme.warning,
          'danger' => theme.error,
          _ => null,
        };

        return LdAutoSpace(
          children: [
            LdText.hs(title),
            if (message != null && message.isNotEmpty) LdText.p(message),
            LdDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (secondary != null) ...[
                  LdButton(
                    size: LdSize.m,
                    mode: LdButtonMode.outline,
                    onPressed: () =>
                        dispatchAction(ctx, secondary['action'] as JsonMap?),
                    child: Text(secondary['label'] as String? ?? 'Cancel'),
                  ),
                ],
                LdButton(
                  mode: LdButtonMode.filled,
                  color: color,
                  size: LdSize.m,
                  onPressed: () =>
                      dispatchAction(ctx, primary['action'] as JsonMap?),
                  child: Text(primary['label'] as String? ?? 'Confirm'),
                ),
              ],
            ).spaceS(),
          ],
        );
      },
    );
  },
);
