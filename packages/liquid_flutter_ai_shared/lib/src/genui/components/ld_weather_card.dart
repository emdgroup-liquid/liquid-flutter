import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_a2ui_refs.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_a2ui_schemas.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

enum LdTemperatureUnit {
  c,
  f;

  static LdTemperatureUnit parse(
    Object? raw, {
    LdTemperatureUnit or = LdTemperatureUnit.c,
  }) {
    return switch (raw) {
      'f' || 'F' => LdTemperatureUnit.f,
      _ => or,
    };
  }

  String get label => switch (this) {
    LdTemperatureUnit.c => 'C',
    LdTemperatureUnit.f => 'F',
  };

  static const schemaValues = ['c', 'f'];
}

final ldWeatherCardSchema = S.object(
  description: 'Opinionated weather snapshot card.',
  properties: {
    'location': S.string(),
    'temperature': LdA2uiSchemas.numberReference(),
    'unit': S.string(enumValues: LdTemperatureUnit.schemaValues),
    'condition': S.string(
      description:
          'Condition key: sunny, cloudy, partlyCloudy, rainy, stormy, '
          'snowy, foggy, windy — rendered as a human-readable label — '
          'or a short free-text label.',
    ),
    'summary': S.string(),
    'high': S.number(),
    'low': S.number(),
    'humidity': S.number(description: 'Relative humidity percent.'),
    'wind': S.string(description: 'Wind summary, e.g. 12 km/h NW.'),
  },
  required: ['location', 'temperature', 'condition'],
);

class LdWeatherCardData {
  const LdWeatherCardData({
    required this.location,
    required this.temperature,
    this.unit = LdTemperatureUnit.c,
    required this.condition,
    this.summary,
    this.high,
    this.low,
    this.humidity,
    this.wind,
  });

  final String location;
  final LdNumberRef temperature;
  final LdTemperatureUnit unit;
  final String condition;
  final String? summary;
  final num? high;
  final num? low;
  final num? humidity;
  final String? wind;

  factory LdWeatherCardData.fromJson(Object? json) {
    final map = ldRequireJsonMap(json, 'LdWeatherCard');
    final location = ldJsonString(map['location']) ?? '';
    final condition = ldJsonString(map['condition']) ?? '';
    if (location.isEmpty || condition.isEmpty) {
      throw FormatException(
        'LdWeatherCard requires location, temperature, condition',
      );
    }
    return LdWeatherCardData(
      location: location,
      temperature: LdNumberRef.parse(
        map['temperature'],
        field: 'LdWeatherCard.temperature',
      ),
      unit: LdTemperatureUnit.parse(map['unit']),
      condition: condition,
      summary: ldJsonString(map['summary']),
      high: ldJsonNum(map['high']),
      low: ldJsonNum(map['low']),
      humidity: ldJsonNum(map['humidity']),
      wind: ldJsonString(map['wind']),
    );
  }
}
