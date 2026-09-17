import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';

import '../attachment_models.dart';

/// Facade over a camera plugin.
///
/// Host apps can replace the bundled native implementation to use a different
/// SDK, and tests can supply a fake. No camera-plugin type appears here.
abstract interface class LdCameraFacade {
  /// Whether a camera is available on this platform/device.
  Future<bool> isAvailable();

  /// Opens a camera session for the default (or requested) lens.
  ///
  /// Throws [LdCameraException] when the camera cannot be opened.
  Future<LdCameraSession> createSession({
    LdLensDirection? lens,
    LdFlashMode flashMode = LdFlashMode.off,
  });
}

/// A live camera session. Dispose it when the capture view is torn down.
abstract interface class LdCameraSession {
  /// The lens currently in use.
  LdLensDirection get lensDirection;

  /// The current flash mode.
  LdFlashMode get flashMode;

  /// The visible preview's width / height ratio (orientation included).
  ///
  /// Callers use it to fit the preview without distortion.
  double get previewAspectRatio;

  /// Builds the live preview widget for this session.
  Widget buildPreview(BuildContext context);

  /// Sets the flash mode.
  Future<void> setFlashMode(LdFlashMode mode);

  /// Switches between front and back lens when available.
  Future<void> flip();

  /// Captures a still image.
  Future<XFile> takePicture();

  /// Releases the native camera resources.
  Future<void> dispose();
}

/// Thrown by [LdCameraFacade] / [LdCameraSession] on failure.
class LdCameraException implements Exception {
  const LdCameraException(this.message);

  final String message;

  @override
  String toString() => 'LdCameraException: $message';
}
