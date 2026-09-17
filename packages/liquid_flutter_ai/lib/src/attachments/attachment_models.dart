import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';

/// The kind of attachment an [LdAttachmentPicker] can produce.
///
/// `image` and `video` are both surfaced through the gallery tab; `file`,
/// `location`, and `contact` each have their own tab. `custom` is used by
/// host-provided tabs registered via `LdAttachmentPickerConfig.customTabs`.
enum LdAttachmentKind { image, video, file, location, contact, custom }

/// The tab presented in the attachment picker's bottom navigation.
///
/// Tabs are derived from the enabled [LdAttachmentKind]s: the gallery tab is
/// shown when either `image` or `video` is enabled.
enum LdAttachmentTab { gallery, file, location, contacts }

/// Filter used when querying the gallery.
enum LdMediaType { image, video }

/// Generic permission state shared across all facades.
///
/// This mirrors the union of the states exposed by the native plugins but
/// stays independent of them so facades can be swapped or faked.
enum LdPermissionState {
  /// The user has not been asked yet.
  notDetermined,

  /// Access is blocked by a system-level restriction the user cannot change.
  restricted,

  /// The user explicitly denied access.
  denied,

  /// Full access was granted.
  authorized,

  /// Partial access was granted (e.g. iOS limited photo library).
  limited,
}

/// Which camera lens to use.
enum LdLensDirection { front, back, external }

/// Camera flash behaviour.
enum LdFlashMode { off, auto, always, torch }

/// A permission that can be queried through `LdPermissionFacade`.
enum LdPermissionKind { camera, photos, location, contacts, microphone }

/// A single gallery asset.
///
/// Deliberately plugin-neutral: native facades translate their own asset type
/// into this DTO so callers never depend on a specific plugin.
@immutable
class LdMediaAsset {
  const LdMediaAsset({
    required this.id,
    required this.kind,
    required this.width,
    required this.height,
    this.title,
    this.mimeType,
    this.duration = Duration.zero,
    this.createDate,
  });

  final String id;

  /// Either [LdAttachmentKind.image] or [LdAttachmentKind.video].
  final LdAttachmentKind kind;
  final int width;
  final int height;
  final String? title;
  final String? mimeType;
  final Duration duration;
  final DateTime? createDate;

  bool get isVideo => kind == LdAttachmentKind.video;
}

/// A file selected from the device or produced by a document scan.
@immutable
class LdFileEntry {
  const LdFileEntry({
    required this.name,
    required this.file,
    this.size,
    this.mimeType,
    this.modified,
  });

  final String name;
  final XFile file;
  final int? size;
  final String? mimeType;
  final DateTime? modified;
}

/// A geographic position with accuracy, independent of the location plugin.
@immutable
class LdGeoPosition {
  const LdGeoPosition({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;

  /// Horizontal accuracy in meters, when the platform reports it.
  final double? accuracyMeters;
}

/// A named place that can be shared as an attachment.
@immutable
class LdPlace {
  const LdPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.subtitle,
  });

  final String name;
  final String? subtitle;
  final double latitude;
  final double longitude;

  LdGeoPosition get position =>
      LdGeoPosition(latitude: latitude, longitude: longitude);
}

/// A contact that can be shared as an attachment.
@immutable
class LdContactEntry {
  const LdContactEntry({
    required this.id,
    required this.displayName,
    this.phoneNumbers = const [],
    this.email,
  });

  final String id;
  final String displayName;
  final List<String> phoneNumbers;
  final String? email;
}

/// Everything the map facade needs to render a picker map.
@immutable
class LdMapRequest {
  const LdMapRequest({
    required this.center,
    this.zoom = 15,
    this.markers = const [],
  });

  final LdGeoPosition center;
  final double zoom;
  final List<LdPlace> markers;
}

/// Small helper that returns the initial letters of a display name.
String ldInitialsFromName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

/// A raw thumbnail or avatar payload.
typedef LdBytes = Uint8List;
