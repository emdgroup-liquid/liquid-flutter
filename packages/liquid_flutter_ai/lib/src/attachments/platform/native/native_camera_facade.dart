import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:flutter/widgets.dart';

import '../../attachment_models.dart';
import '../camera_facade.dart';

/// Bundled [LdCameraFacade] backed by `package:camera`.
///
/// Replace via [LdAttachmentServices.copyWith] to use a different camera SDK.
class LdNativeCameraFacade implements LdCameraFacade {
  @override
  Future<bool> isAvailable() async {
    try {
      final cameras = await availableCameras();
      return cameras.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<LdCameraSession> createSession({
    LdLensDirection? lens,
    LdFlashMode flashMode = LdFlashMode.off,
  }) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw const LdCameraException('No camera available on this device.');
    }
    final description = _select(cameras, lens);
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    await controller.setFlashMode(_flashMode(flashMode));
    return LdNativeCameraSession(
      controller: controller,
      available: cameras,
      flashMode: flashMode,
    );
  }

  CameraDescription _select(
    List<CameraDescription> cameras,
    LdLensDirection? lens,
  ) {
    if (lens != null) {
      final target = _lensDirection(lens);
      for (final camera in cameras) {
        if (camera.lensDirection == target) {
          return camera;
        }
      }
    }
    for (final camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.back) {
        return camera;
      }
    }
    return cameras.first;
  }

  CameraLensDirection _lensDirection(LdLensDirection lens) => switch (lens) {
    LdLensDirection.front => CameraLensDirection.front,
    LdLensDirection.back => CameraLensDirection.back,
    LdLensDirection.external => CameraLensDirection.external,
  };

  FlashMode _flashMode(LdFlashMode mode) => switch (mode) {
    LdFlashMode.off => FlashMode.off,
    LdFlashMode.auto => FlashMode.auto,
    LdFlashMode.always => FlashMode.always,
    LdFlashMode.torch => FlashMode.torch,
  };
}

/// Bundled [LdCameraSession] backed by `package:camera`.
class LdNativeCameraSession implements LdCameraSession {
  LdNativeCameraSession({
    required CameraController controller,
    required List<CameraDescription> available,
    required LdFlashMode flashMode,
  }) : _controller = controller,
       _available = available,
       _flashMode = flashMode;

  final CameraController _controller;
  final List<CameraDescription> _available;
  LdFlashMode _flashMode;

  @override
  LdLensDirection get lensDirection =>
      switch (_controller.description.lensDirection) {
        CameraLensDirection.front => LdLensDirection.front,
        CameraLensDirection.back => LdLensDirection.back,
        CameraLensDirection.external => LdLensDirection.external,
      };

  @override
  LdFlashMode get flashMode => _flashMode;

  @override
  double get previewAspectRatio {
    final value = _controller.value;
    if (!value.isInitialized || value.previewSize == null) {
      return 3 / 4;
    }
    final ratio = value.aspectRatio;
    final orientation = value.deviceOrientation;
    final landscape =
        orientation == DeviceOrientation.landscapeLeft ||
        orientation == DeviceOrientation.landscapeRight;
    return landscape ? ratio : 1 / ratio;
  }

  @override
  Widget buildPreview(BuildContext context) => CameraPreview(_controller);

  @override
  Future<void> setFlashMode(LdFlashMode mode) async {
    try {
      await _controller.setFlashMode(_flashModeToPlugin(mode));
      _flashMode = mode;
    } on CameraException {
      // Flash mode unsupported on this lens (e.g. torch on the front camera).
      // Keep the previous mode rather than lying to the UI.
    }
  }

  @override
  Future<void> flip() async {
    final current = _controller.description.lensDirection;
    final target = current == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    CameraDescription? match;
    for (final camera in _available) {
      if (camera.lensDirection == target) {
        match = camera;
        break;
      }
    }
    if (match == null) {
      return;
    }
    // Reinitialize in place: [CameraPreview] stays bound to this controller, so
    // the preview swaps lenses without tearing down the widget.
    await _controller.setDescription(match);
    await setFlashMode(_flashMode);
  }

  @override
  Future<XFile> takePicture() => _controller.takePicture();

  @override
  Future<void> dispose() => _controller.dispose();

  FlashMode _flashModeToPlugin(LdFlashMode mode) => switch (mode) {
    LdFlashMode.off => FlashMode.off,
    LdFlashMode.auto => FlashMode.auto,
    LdFlashMode.always => FlashMode.always,
    LdFlashMode.torch => FlashMode.torch,
  };
}
