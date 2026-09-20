import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:maplibre/maplibre.dart';

import '../../attachment_models.dart';
import '../attachment_platform.dart';
import '../map_facade.dart';

/// Bundled [LdMapFacade] backed by `package:maplibre`.
///
/// The map is only a visual aid in the picker; interaction is deliberately
/// limited. Swap via [LdAttachmentServices.copyWith] for another SDK.
class LdNativeMapFacade implements LdMapFacade {
  const LdNativeMapFacade();

  @override
  bool get isSupported => ldMapPluginSupported;

  @override
  Widget buildMap(BuildContext context, LdMapRequest request) {
    final center = Geographic(
      lon: request.center.longitude,
      lat: request.center.latitude,
    );
    final theme = LdTheme.of(context);

    return MapLibreMap(
      options: MapOptions(
        initCenter: center,
        initZoom: request.zoom,
        initStyle: "https://tiles.openfreemap.org/styles/liberty",
      ),
      children: [
        WidgetLayer(
          markers: [
            Marker(
              point: center,
              size: const Size(28, 28),
              child: _MapUserDot(color: theme.primaryColor),
            ),
            for (final place in request.markers)
              Marker(
                point: Geographic(lon: place.longitude, lat: place.latitude),
                size: const Size(28, 28),
                child: _MapPin(color: theme.errorColor),
              ),
          ],
        ),
      ],
    );
  }
}

class _MapUserDot extends StatelessWidget {
  const _MapUserDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFFFFF), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 6, spreadRadius: 1),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(LucideIcons.mapPin, color: color);
  }
}
