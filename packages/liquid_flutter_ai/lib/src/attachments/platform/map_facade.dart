import 'package:flutter/widgets.dart';

import '../attachment_models.dart';

/// Facade over map rendering for the location tab.
///
/// The bundled implementation uses MapLibre; host apps can swap in another map
/// SDK and tests can supply a lightweight placeholder.
abstract interface class LdMapFacade {
  /// Whether a map widget can be built on this platform.
  bool get isSupported;

  /// Builds the map widget for [request].
  Widget buildMap(BuildContext context, LdMapRequest request);
}
