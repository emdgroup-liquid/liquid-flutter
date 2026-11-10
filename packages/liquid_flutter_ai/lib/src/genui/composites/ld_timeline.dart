import 'package:a2ui_core/a2ui_core.dart' show ComponentNode;
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

final ldTimeline = ldCatalogItem(
  name: 'LdTimeline',
  schema: ldTimelineSchema,
  parse: LdTimelineData.fromJson,
  builder: (node, _, data) => LdGenuiTimeline(node: node, data: data),
);

class LdGenuiTimeline extends StatelessWidget {
  const LdGenuiTimeline({super.key, required this.node, required this.data});

  final ComponentNode<ComponentImplementation> node;
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
                  _ => LdGenuiFallback(
                    error: FormatException(
                      'LdTimelineItem "${node.componentId}" time is required',
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
