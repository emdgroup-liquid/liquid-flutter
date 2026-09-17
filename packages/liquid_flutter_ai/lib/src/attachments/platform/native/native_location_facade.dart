import 'package:geolocator/geolocator.dart';

import '../../attachment_models.dart';
import '../location_facade.dart';

/// Bundled [LdLocationFacade] backed by `package:geolocator`.
class LdNativeLocationFacade implements LdLocationFacade {
  @override
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  @override
  Future<LdPermissionState> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LdGeoPosition?> currentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return null;
    }
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    final position = await Geolocator.getCurrentPosition();
    return _toPosition(position);
  }

  @override
  Stream<LdGeoPosition> positionStream() =>
      Geolocator.getPositionStream().map(_toPosition);

  LdGeoPosition _toPosition(Position position) => LdGeoPosition(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracyMeters: position.accuracy,
  );

  LdPermissionState _mapPermission(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.denied => LdPermissionState.denied,
        LocationPermission.deniedForever => LdPermissionState.restricted,
        LocationPermission.whileInUse => LdPermissionState.authorized,
        LocationPermission.always => LdPermissionState.authorized,
        LocationPermission.unableToDetermine => LdPermissionState.notDetermined,
      };
}
