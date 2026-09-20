import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_flutter_ai/src/attachments/attachment_models.dart';
import 'package:liquid_flutter_ai/src/attachments/attachment_result.dart';

/// A file or image attached to a compose draft or user message.
class LdComposeAttachment {
  static const _unset = Object();

  final String id;
  final String name;
  final String? mimeType;

  /// Optional preview widget (e.g. image thumbnail). Provided by the app.
  final Widget? preview;

  /// The underlying file, when the host app captured one (e.g. from
  /// [LdAttachmentPicker]).
  final XFile? file;

  /// The attachment kind, when known.
  final LdAttachmentKind? kind;

  /// Byte length when known (typically files).
  final int? size;

  /// Determinate persist progress in `[0, 1]` while uploading.
  final double? persistProgress;

  /// Backend id after persist. Location/contact skip persist and use [id].
  final String? remoteId;

  /// Set when persist failed. Cleared on retry.
  final Object? persistError;

  const LdComposeAttachment({
    required this.id,
    required this.name,
    this.mimeType,
    this.preview,
    this.file,
    this.kind,
    this.size,
    this.persistProgress,
    this.remoteId,
    this.persistError,
  });

  /// Builds a compose attachment from a picked attachment, including a
  /// thumbnail preview when one is available.
  factory LdComposeAttachment.fromPicked(LdPickedAttachment picked) {
    final thumbnail = picked.thumbnail;
    return LdComposeAttachment(
      id: picked.id,
      name: picked.name,
      mimeType: picked.mimeType,
      file: picked.file,
      kind: picked.kind,
      size: picked.size,
      preview: thumbnail == null
          ? null
          : Image.memory(thumbnail, fit: BoxFit.contain),
    );
  }

  bool get isImage =>
      kind == LdAttachmentKind.image ||
      mimeType?.startsWith('image/') == true ||
      RegExp(
        r'\.(png|jpe?g|gif|webp|heic)$',
        caseSensitive: false,
      ).hasMatch(name);

  bool get isAudio =>
      mimeType?.startsWith('audio/') == true ||
      RegExp(
        r'\.(m4a|mp3|wav|aac|ogg|flac|opus|3gp)$',
        caseSensitive: false,
      ).hasMatch(name);

  /// File attachments without a [remoteId] still need the host persister.
  bool get needsPersist => file != null && remoteId == null;

  bool get isPersisting => persistProgress != null && remoteId == null;

  bool get hasPersistError => persistError != null;

  LdComposeAttachment copyWith({
    String? id,
    String? name,
    String? mimeType,
    Widget? preview,
    XFile? file,
    LdAttachmentKind? kind,
    int? size,
    Object? persistProgress = _unset,
    Object? remoteId = _unset,
    Object? persistError = _unset,
  }) {
    return LdComposeAttachment(
      id: id ?? this.id,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      preview: preview ?? this.preview,
      file: file ?? this.file,
      kind: kind ?? this.kind,
      size: size ?? this.size,
      persistProgress: identical(persistProgress, _unset)
          ? this.persistProgress
          : persistProgress as double?,
      remoteId: identical(remoteId, _unset)
          ? this.remoteId
          : remoteId as String?,
      persistError: identical(persistError, _unset)
          ? this.persistError
          : persistError,
    );
  }
}
