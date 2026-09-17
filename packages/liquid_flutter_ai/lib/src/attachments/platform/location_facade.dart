import '../attachment_models.dart';

/// Facade over device location.
///
/// Host apps can replace the bundled native implementation; tests supply a
/// fake. No location-plugin type appears here.
abstract interface class LdLocationFacade {
  /// Whether device location services are enabled.
  Future<bool> isServiceEnabled();

  /// Requests location permission, prompting the user when necessary.
  Future<LdPermissionState> requestPermission();

  /// Reads the current position, or `null` when unavailable.
  Future<LdGeoPosition?> currentPosition();

  /// Streams position updates. Callers must cancel the subscription.
  Stream<LdGeoPosition> positionStream();
}

/// Facade over a source of nearby/named places.
///
/// Place search normally requires a places provider (Google, Mapbox, …), so
/// this is app-injected rather than bundled.
abstract interface class LdPlaceSource {
  /// Returns places near [origin] (used for the initial "choose a place" list).
  Future<List<LdPlace>> nearby(LdGeoPosition origin);

  /// Searches for places matching [query].
  Future<List<LdPlace>> search(String query);
}

/// Default [LdPlaceSource] that returns nothing.
class LdEmptyPlaceSource implements LdPlaceSource {
  const LdEmptyPlaceSource();

  @override
  Future<List<LdPlace>> nearby(LdGeoPosition origin) async => const [];

  @override
  Future<List<LdPlace>> search(String query) async => const [];
}
