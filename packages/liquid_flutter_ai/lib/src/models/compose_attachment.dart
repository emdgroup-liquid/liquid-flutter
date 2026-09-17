import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_flutter_ai/src/attachments/attachment_models.dart';
import 'package:liquid_flutter_ai/src/attachments/attachment_result.dart';

/// A file or image attached to a compose draft or user message.
class LdComposeAttachment {
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

  const LdComposeAttachment({
    required this.id,
    required this.name,
    this.mimeType,
    this.preview,
    this.file,
    this.kind,
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
      preview: thumbnail == null
          ? null
          : Image.memory(thumbnail, fit: BoxFit.cover),
    );
  }

  bool get isImage =>
      kind == LdAttachmentKind.image ||
      mimeType?.startsWith('image/') == true ||
      RegExp(r'\.(png|jpe?g|gif|webp|heic)$', caseSensitive: false)
          .hasMatch(name);

  bool get isAudio =>
      mimeType?.startsWith('audio/') == true ||
      RegExp(r'\.(m4a|mp3|wav|aac|ogg|flac|opus|3gp)$', caseSensitive: false)
          .hasMatch(name);
}