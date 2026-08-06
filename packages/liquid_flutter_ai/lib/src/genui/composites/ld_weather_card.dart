import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/composites/helpers.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

/// Turns condition keys like `partlyCloudy` into readable labels.
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
      .replaceAllMapped(
        RegExp(r'([a-z0-9])([A-Z])'),
        (m) => '${m[1]} ${m[2]}',
      )
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

final ldWeatherCard = CatalogItem(
  name: 'LdWeatherCard',
  dataSchema: ldWeatherCardSchema,
  widgetBuilder: (ctx) {
    final d = ctx.data as JsonMap;
    final location = d['location'] as String? ?? '';
    final condition = d['condition'] as String? ?? '';
    final unit = (d['unit'] as String? ?? 'c').toUpperCase();
    final summary = d['summary'] as String?;
    final high = d['high'] as num?;
    final low = d['low'] as num?;
    final humidity = d['humidity'] as num?;
    final wind = d['wind'] as String?;
    final tempRef = d['temperature'];
    final tempPath = bindingPath(tempRef, '${ctx.id}.temperature');

    if (location.isEmpty || condition.isEmpty) {
      final error = FormatException(
        'LdWeatherCard "${ctx.id}" requires location, temperature, condition',
      );
      ctx.reportError(error, StackTrace.current);
      return FallbackWidget(error: error);
    }

    Widget buildCard(num? temperature) {
      final tempLabel = temperature == null
          ? '—'
          : '${temperature.round()}°$unit';
      final meta = <String>[
        if (high != null && low != null)
          'H ${high.round()}° / L ${low.round()}°',
        if (humidity != null) '${humidity.round()}% humidity',
        if (wind != null && wind.isNotEmpty) wind,
      ];

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_weatherIcon(condition), size: 40),
          ldHSpacerM,
          Expanded(
            child: LdAutoSpace(
              children: [
                LdText.l(location, size: LdSize.s),
                LdText.hl(tempLabel),
                LdText.p(_weatherConditionLabel(condition)),
                if (summary != null && summary.isNotEmpty) LdText.p(summary),
                if (meta.isNotEmpty) LdText.caption(meta.join(' · ')),
              ],
            ),
          ),
        ],
      );
    }

    if (tempRef is num) {
      return buildCard(tempRef);
    }

    return BoundNumber(
      dataContext: ctx.dataContext,
      value: {'path': tempPath},
      builder: (context, val) => buildCard(val),
    );
  },
);
