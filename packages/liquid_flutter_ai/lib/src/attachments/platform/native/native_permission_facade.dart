import 'package:permission_handler/permission_handler.dart' as ph;

import '../../attachment_models.dart';
import '../permission_facade.dart';

/// Bundled [LdPermissionFacade] backed by `package:permission_handler`.
class LdNativePermissionFacade implements LdPermissionFacade {
  @override
  Future<bool> openAppSettings() => ph.openAppSettings();

  @override
  Future<LdPermissionState> status(LdPermissionKind kind) async {
    final status = await _permission(kind).status;
    return _mapPermission(status);
  }

  ph.Permission _permission(LdPermissionKind kind) => switch (kind) {
    LdPermissionKind.camera => ph.Permission.camera,
    LdPermissionKind.photos => ph.Permission.photos,
    LdPermissionKind.location => ph.Permission.location,
    LdPermissionKind.contacts => ph.Permission.contacts,
    LdPermissionKind.microphone => ph.Permission.microphone,
  };

  LdPermissionState _mapPermission(ph.PermissionStatus status) =>
      switch (status) {
        ph.PermissionStatus.granted => LdPermissionState.authorized,
        ph.PermissionStatus.limited => LdPermissionState.limited,
        ph.PermissionStatus.provisional => LdPermissionState.authorized,
        ph.PermissionStatus.denied => LdPermissionState.denied,
        ph.PermissionStatus.permanentlyDenied => LdPermissionState.restricted,
        ph.PermissionStatus.restricted => LdPermissionState.restricted,
      };
}
