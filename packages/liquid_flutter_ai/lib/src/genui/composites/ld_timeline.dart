import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

final ldTimeline = ldCatalogItem(
  name: 'LdTimeline',
  schema: ldTimelineSchema,
  parse: LdTimelineData.fromJson,
  builder: (ctx, data) => LdGenuiTimeline(catalogContext: ctx, data: data),
);

class LdGenuiTimeline extends StatelessWidget {
  const LdGenuiTimeline({
    super.key,
    required this.catalogContext,
    required this.data,
  });

  final CatalogItemContext catalogContext;
  final LdTimelineData data;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final title = data.title;

    return LdAutoSpace(
      children: [
        if (title != null && title.isNotEmpty) LdText.h(title),
        LdTimeline(
          items: [
            for (final item in data.items)
              LdTimelineItem(
                time: switch (item.time) {
                  String time => Text(time),
                  _ => FallbackWidget(
                    error: FormatException(
                      'LdTimelineItem "${catalogContext.id}" time is required',
                    ),
                  ),
                },
                title: Text(item.title),
                subtitle: switch (item.body) {
                  null => null,
                  String body => Text(body),
                },
                color: _timelineTone(theme, item.tone),
              ),
          ],
        ),
      ],
    );
  }
}

LdColor _timelineTone(LdTheme theme, LdGenuiTone tone) => switch (tone) {
  LdGenuiTone.warning => theme.warning,
  LdGenuiTone.success => theme.success,
  LdGenuiTone.error => theme.error,
  LdGenuiTone.info => theme.primary,
};
