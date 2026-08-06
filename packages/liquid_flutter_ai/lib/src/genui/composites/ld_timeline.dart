import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

Color _timelineTone(LdTheme theme, String? tone) => switch (tone) {
  'warning' => theme.warningColor,
  'success' => theme.successColor,
  'error' => theme.errorColor,
  _ => theme.primaryColor,
};

final ldTimeline = CatalogItem(
  name: 'LdTimeline',
  dataSchema: ldTimelineSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final title = d['title'] as String?;
    final items = objectList(d['items']);
    if (items.isEmpty) {
      final error = FormatException(
        'LdTimeline "${ctx.id}" requires at least one item',
      );
      ctx.reportError(error, StackTrace.current);
      return FallbackWidget(error: error);
    }

    return Builder(
      builder: (context) {
        final theme = LdTheme.of(context);
        return LdAutoSpace(
          children: [
            if (title != null && title.isNotEmpty) LdText.h(title),
            for (var i = 0; i < items.length; i++)
              _TimelineRow(
                item: items[i],
                isLast: i == items.length - 1,
                color: _timelineTone(theme, items[i]['tone'] as String?),
                theme: theme,
              ),
          ],
        );
      },
    );
  },
);

class _TimelineRow extends StatelessWidget {
  final JsonMap item;
  final bool isLast;
  final Color color;
  final LdTheme theme;

  const _TimelineRow({
    required this.item,
    required this.isLast,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final time = item['time'] as String?;
    final title = item['title'] as String? ?? '';
    final body = item['body'] as String?;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: theme.border,
                    ),
                  ),
              ],
            ),
          ),
          ldHSpacerS,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : theme.paddingSize(size: LdSize.m),
              ),
              child: LdAutoSpace(
                children: [
                  if (time != null && time.isNotEmpty) LdText.caption(time),
                  LdText.l(title, size: LdSize.s),
                  if (body != null && body.isNotEmpty) LdText.p(body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
