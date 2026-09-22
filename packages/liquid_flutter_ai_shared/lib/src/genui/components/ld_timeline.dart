import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_genui_tone.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

final ldTimelineSchema = S.object(
  description: 'Vertical chronological timeline of events.',
  properties: {
    'title': S.string(),
    'items': S.list(
      items: S.object(
        properties: {
          'time': S.string(),
          'title': S.string(),
          'body': S.string(),
          'tone': S.string(enumValues: LdGenuiTone.schemaValues),
        },
        required: ['title'],
      ),
    ),
  },
  required: ['items'],
);

class LdTimelineItemData {
  const LdTimelineItemData({
    this.time,
    required this.title,
    this.body,
    this.tone = LdGenuiTone.info,
  });

  final String? time;
  final String title;
  final String? body;
  final LdGenuiTone tone;

  static LdTimelineItemData? tryParse(Map<String, Object?> json) {
    final title = ldJsonString(json['title']);
    if (title == null) return null;
    return LdTimelineItemData(
      time: ldJsonString(json['time']),
      title: title,
      body: ldJsonString(json['body']),
      tone: LdGenuiTone.parse(json['tone']),
    );
  }
}

class LdTimelineData {
  const LdTimelineData({this.title, required this.items});

  final String? title;
  final List<LdTimelineItemData> items;

  factory LdTimelineData.fromJson(Object? json) {
    final map = ldRequireJsonMap(json, 'LdTimeline');
    final items = ldJsonObjectListWhere(
      map['items'],
      LdTimelineItemData.tryParse,
    );
    if (items.isEmpty) {
      throw FormatException('LdTimeline requires at least one item');
    }
    return LdTimelineData(title: ldJsonString(map['title']), items: items);
  }
}
