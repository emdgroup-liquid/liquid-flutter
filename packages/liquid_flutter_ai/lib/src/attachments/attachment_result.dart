import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';

import 'attachment_models.dart';

/// A single attachment returned by [LdAttachmentPicker].
///
/// This is the neutral result type produced by the picker; host apps map it
/// onto their own message/attachment models (for example
/// `LdComposeAttachment`).
@immutable
class LdPickedAttachment {
  const LdPickedAttachment({
    required this.id,
    required this.kind,
    required this.name,
    this.file,
    this.mimeType,
    this.thumbnail,
    this.location,
    this.place,
    this.contact,
    this.duration,
    this.size,
  });

  /// Stable identifier, unique within a selection.
  final String id;
  final LdAttachmentKind kind;
  final String name;

  /// The underlying file for image/video/file kinds.
  final XFile? file;

  final String? mimeType;

  /// A small preview image for media attachments, when available.
  final Uint8List? thumbnail;

  /// Payload for a shared location.
  final LdGeoPosition? location;

  /// Payload for a shared place.
  final LdPlace? place;

  /// Payload for a shared contact.
  final LdContactEntry? contact;

  /// Duration for video/audio attachments, when known.
  final Duration? duration;

  /// Byte length when known (typically files).
  final int? size;

  bool get isImage => kind == LdAttachmentKind.image;
  bool get isVideo => kind == LdAttachmentKind.video;

  LdPickedAttachment copyWith({
    String? id,
    LdAttachmentKind? kind,
    String? name,
    XFile? file,
    String? mimeType,
    Uint8List? thumbnail,
    LdGeoPosition? location,
    LdPlace? place,
    LdContactEntry? contact,
    Duration? duration,
    int? size,
  }) {
    return LdPickedAttachment(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      file: file ?? this.file,
      mimeType: mimeType ?? this.mimeType,
      thumbnail: thumbnail ?? this.thumbnail,
      location: location ?? this.location,
      place: place ?? this.place,
      contact: contact ?? this.contact,
      duration: duration ?? this.duration,
      size: size ?? this.size,
    );
  }

  @override
  String toString() => 'LdPickedAttachment($kind, $name)';
}
