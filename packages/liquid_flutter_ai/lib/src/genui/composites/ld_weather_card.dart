import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final ldWeatherCard = ldCatalogItem(
  name: 'LdWeatherCard',
  schema: ldWeatherCardSchema,
  parse: LdWeatherCardData.fromJson,
  builder: (ctx, data) => LdWeatherCard(catalogContext: ctx, data: data),
);

class LdWeatherCard extends StatelessWidget {
  const LdWeatherCard({
    super.key,
    required this.catalogContext,
    required this.data,
  });

  final CatalogItemContext catalogContext;
  final LdWeatherCardData data;

  @override
  Widget build(BuildContext context) {
    return BoundNumber(
      dataContext: catalogContext.dataContext,
      value: data.temperature.boundValue,
      builder: (context, temperature) =>
          _LdWeatherCardBody(data: data, temperature: temperature),
    );
  }
}

class _LdWeatherCardBody extends StatelessWidget {
  const _LdWeatherCardBody({required this.data, required this.temperature});

  final LdWeatherCardData data;
  final num? temperature;

  @override
  Widget build(BuildContext context) {
    final unit = data.unit.label;
    final temp = temperature;
    final tempLabel = temp == null ? '—' : '${temp.round()}°$unit';
    final summary = data.summary;
    final high = data.high;
    final low = data.low;
    final humidity = data.humidity;
    final wind = data.wind;
    final meta = <String>[
      if (high != null && low != null) 'H ${high.round()}° / L ${low.round()}°',
      if (humidity != null) '${humidity.round()}% humidity',
      if (wind != null && wind.isNotEmpty) wind,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_weatherIcon(data.condition), size: 40),
        ldHSpacerM,
        Expanded(
          child: LdAutoSpace(
            children: [
              LdText.l(data.location, size: LdSize.s),
              LdText.hl(tempLabel),
              LdText.p(_weatherConditionLabel(data.condition)),
              if (summary != null && summary.isNotEmpty) LdText.p(summary),
              if (meta.isNotEmpty) LdText.caption(meta.join(' · ')),
            ],
          ),
        ),
      ],
    );
  }
}

String _conditionKey(String condition) =>
    condition.toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');

IconData _weatherIcon(String condition) {
  return switch (_conditionKey(condition)) {
    'sunny' || 'clear' => LucideIcons.sun,
    'cloudy' || 'overcast' => LucideIcons.cloud,
    'partlycloudy' || 'partlycloud' => LucideIcons.cloudSun,
    'rainy' || 'rain' || 'showers' => LucideIcons.cloudRain,
    'stormy' || 'thunder' || 'thunderstorm' => LucideIcons.cloudLightning,
    'snowy' || 'snow' => LucideIcons.snowflake,
    'foggy' || 'fog' || 'mist' => LucideIcons.cloudFog,
    'windy' || 'wind' => LucideIcons.wind,
    _ => LucideIcons.cloudSun,
  };
}

String _weatherConditionLabel(String condition) {
  return switch (_conditionKey(condition)) {
    'sunny' => 'Sunny',
    'clear' => 'Clear',
    'cloudy' => 'Cloudy',
    'overcast' => 'Overcast',
    'partlycloudy' || 'partlycloud' => 'Partly cloudy',
    'rainy' || 'rain' => 'Rainy',
    'showers' => 'Showers',
    'stormy' || 'thunder' || 'thunderstorm' => 'Stormy',
    'snowy' || 'snow' => 'Snowy',
    'foggy' || 'fog' => 'Foggy',
    'mist' => 'Mist',
    'windy' || 'wind' => 'Windy',
    _ => _humanizeCondition(condition),
  };
}

String _humanizeCondition(String raw) {
  final words = raw
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return raw;
  return [
    '${words.first[0].toUpperCase()}${words.first.substring(1).toLowerCase()}',
    ...words.skip(1).map((w) => w.toLowerCase()),
  ].join(' ');
}
