import 'package:flutter/widgets.dart';

/// A file or image attached to a compose draft or user message.
class LdComposeAttachment {
  final String id;
  final String name;
  final String? mimeType;

  /// Optional preview widget (e.g. image thumbnail). Provided by the app.
  final Widget? preview;

  const LdComposeAttachment({
    required this.id,
    required this.name,
    this.mimeType,
    this.preview,
  });

  bool get isImage =>
      mimeType?.startsWith('image/') == true ||
      RegExp(r'\.(png|jpe?g|gif|webp|heic)$', caseSensitive: false)
          .hasMatch(name);

  bool get isAudio =>
      mimeType?.startsWith('audio/') == true ||
      RegExp(r'\.(m4a|mp3|wav|aac|ogg|flac|opus|3gp)$', caseSensitive: false)
          .hasMatch(name);
}
