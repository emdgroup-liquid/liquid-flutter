import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

LdColor _timelineTone(LdTheme theme, String? tone) => switch (tone) {
  'warning' => theme.warning,
  'success' => theme.success,
  'error' => theme.error,
  _ => theme.primary,
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
            LdTimeline(
              items: [
                for (final item in items)
                  LdTimelineItem(
                    time: switch (item['time'] as String?) {
                      String time => Text(time),
                      _ => FallbackWidget(
                        error: FormatException(
                          'LdTimelineItem "${ctx.id}" time is required',
                        ),
                      ),
                    },
                    title: switch (item['title'] as String?) {
                      null => null,
                      String title => Text(title),
                    },
                    subtitle: switch (item['subtitle'] as String?) {
                      null => null,
                      String subtitle => Text(subtitle),
                    },
                    color: _timelineTone(theme, item['tone'] as String?),
                  ),
              ],
            ),
          ],
        );
      },
    );
  },
);
