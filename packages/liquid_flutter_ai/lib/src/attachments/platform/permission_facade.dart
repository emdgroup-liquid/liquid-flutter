import '../attachment_models.dart';

/// Facade for cross-cutting permission concerns.
abstract interface class LdPermissionFacade {
  /// Opens the operating system's settings page for this app.
  Future<bool> openAppSettings();

  /// Reads the current state of [kind] without prompting.
  Future<LdPermissionState> status(LdPermissionKind kind);
}
