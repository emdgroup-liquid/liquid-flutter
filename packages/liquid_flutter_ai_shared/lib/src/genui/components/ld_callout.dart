import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_genui_tone.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

final ldCalloutSchema = S.object(
  description: 'Status banner (info/warning/success/error).',
  properties: {
    'type': S.string(enumValues: LdGenuiTone.schemaValues),
    'title': S.string(),
    'body': S.string(),
  },
  required: ['type', 'body'],
);

class LdCalloutData {
  const LdCalloutData({required this.type, this.title, required this.body});

  final LdGenuiTone type;
  final String? title;
  final String body;

  factory LdCalloutData.fromJson(Object? json) {
    final map = ldRequireJsonMap(json, 'LdCallout');
    return LdCalloutData(
      type: LdGenuiTone.parse(map['type']),
      title: ldJsonString(map['title']),
      body: ldJsonString(map['body']) ?? '',
    );
  }
}
