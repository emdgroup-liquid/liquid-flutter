import '../attachment_models.dart';
import 'camera_facade.dart';
import 'contacts_facade.dart';
import 'file_facade.dart';
import 'location_facade.dart';
import 'map_facade.dart';
import 'media_facade.dart';
import 'native/native_camera_facade.dart';
import 'native/native_contacts_facade.dart';
import 'native/native_file_facade.dart';
import 'native/native_location_facade.dart';
import 'native/native_map_facade.dart';
import 'native/native_media_facade.dart';
import 'native/native_permission_facade.dart';
import 'permission_facade.dart';

/// The set of facades the attachment picker depends on.
///
/// Every native dependency is exposed here so host apps can swap an individual
/// implementation (see [copyWith]) and tests can inject fakes. The picker never
/// imports a plugin directly.
class LdAttachmentServices {
  const LdAttachmentServices({
    required this.camera,
    required this.media,
    required this.files,
    required this.location,
    required this.contacts,
    required this.permissions,
    required this.map,
    this.places = const LdEmptyPlaceSource(),
    this.recentFiles = const LdEmptyRecentFilesSource(),
  });

  /// The default bundle backed by the bundled native implementations.
  factory LdAttachmentServices.native({
    LdCameraFacade? camera,
    LdMediaFacade? media,
    LdFileFacade? files,
    LdLocationFacade? location,
    LdContactsFacade? contacts,
    LdPermissionFacade? permissions,
    LdMapFacade? map,
    LdPlaceSource? places,
    LdRecentFilesSource? recentFiles,
  }) {
    return LdAttachmentServices(
      camera: camera ?? LdNativeCameraFacade(),
      media: media ?? LdNativeMediaFacade(),
      files: files ?? LdNativeFileFacade(),
      location: location ?? LdNativeLocationFacade(),
      contacts: contacts ?? LdNativeContactsFacade(),
      permissions: permissions ?? LdNativePermissionFacade(),
      map: map ?? LdNativeMapFacade(),
      places: places ?? const LdEmptyPlaceSource(),
      recentFiles: recentFiles ?? const LdEmptyRecentFilesSource(),
    );
  }

  final LdCameraFacade camera;
  final LdMediaFacade media;
  final LdFileFacade files;
  final LdLocationFacade location;
  final LdContactsFacade contacts;
  final LdPermissionFacade permissions;
  final LdMapFacade map;

  /// App-provided place search for the location tab.
  final LdPlaceSource places;

  /// App-provided recently-sent files for the file tab.
  final LdRecentFilesSource recentFiles;

  LdAttachmentServices copyWith({
    LdCameraFacade? camera,
    LdMediaFacade? media,
    LdFileFacade? files,
    LdLocationFacade? location,
    LdContactsFacade? contacts,
    LdPermissionFacade? permissions,
    LdMapFacade? map,
    LdPlaceSource? places,
    LdRecentFilesSource? recentFiles,
  }) {
    return LdAttachmentServices(
      camera: camera ?? this.camera,
      media: media ?? this.media,
      files: files ?? this.files,
      location: location ?? this.location,
      contacts: contacts ?? this.contacts,
      permissions: permissions ?? this.permissions,
      map: map ?? this.map,
      places: places ?? this.places,
      recentFiles: recentFiles ?? this.recentFiles,
    );
  }
}

/// Convenience alias for the empty-bundle factory, kept so hosts can write
/// `const LdAttachmentServices.empty()`-style defaults without pulling native
/// facades into a pure test tree.
///
/// Note: [LdAttachmentServices.native] is the production default.
typedef LdAttachmentServicesFactory = LdAttachmentServices Function();

/// Extension used by the picker to resolve a place's label.
extension LdPlaceLabel on LdPlace {
  String get label =>
      subtitle == null || subtitle!.isEmpty ? name : '$name · $subtitle';
}
