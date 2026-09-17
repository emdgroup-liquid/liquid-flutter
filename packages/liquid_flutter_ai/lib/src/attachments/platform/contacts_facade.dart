import '../attachment_models.dart';

/// Facade over the device contacts database.
///
/// Host apps can replace the bundled native implementation; tests supply a
/// fake. No contacts-plugin type appears here.
abstract interface class LdContactsFacade {
  /// Whether contacts are available on this platform.
  bool get isSupported;

  /// Reads the current contacts permission without prompting.
  Future<LdPermissionState> permissionState();

  /// Requests contacts permission, prompting the user when necessary.
  Future<LdPermissionState> requestPermission();

  /// Loads contacts, optionally filtered by [query].
  Future<List<LdContactEntry>> loadContacts({String? query});

  /// Loads an avatar image for [contact], or `null` when unavailable.
  Future<List<int>?> avatar(LdContactEntry contact);
}
