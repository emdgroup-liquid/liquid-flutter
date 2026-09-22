import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_genui_action.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

final ldCalendarEventSchema = S.object(
  description: 'Single calendar event summary card.',
  properties: {
    'title': S.string(),
    'start': S.string(description: 'ISO-8601 start datetime.'),
    'end': S.string(description: 'ISO-8601 end datetime.'),
    'location': S.string(),
    'description': S.string(description: 'Plain text or markdown description.'),
    'allDay': S.boolean(),
    'action': ldGenuiActionSchema,
  },
  required: ['title', 'start'],
);

class LdCalendarEventData {
  const LdCalendarEventData({
    required this.title,
    required this.start,
    this.end,
    this.location,
    this.description,
    this.allDay = false,
    this.action,
  });

  final String title;
  final String start;
  final String? end;
  final String? location;
  final String? description;
  final bool allDay;
  final LdGenuiAction? action;

  DateTime? get startDate => DateTime.tryParse(start);
  DateTime? get endDate => end == null ? null : DateTime.tryParse(end!);

  factory LdCalendarEventData.fromJson(Object? json) {
    final map = ldRequireJsonMap(json, 'LdCalendarEvent');
    return LdCalendarEventData(
      title: ldRequireString(map['title'], 'LdCalendarEvent.title'),
      start: ldRequireString(map['start'], 'LdCalendarEvent.start'),
      end: ldJsonString(map['end']),
      location: ldJsonString(map['location']),
      description: ldJsonString(map['description']),
      allDay: ldJsonBool(map['allDay']) ?? false,
      action: LdGenuiAction.tryParse(map['action']),
    );
  }
}
