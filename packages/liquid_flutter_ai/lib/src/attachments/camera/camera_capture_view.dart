import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../attachment_labels.dart';
import '../attachment_models.dart';
import '../platform/camera_facade.dart';

/// Fits a camera preview into its parent without distortion (`BoxFit.cover`).
///
/// The preview is sized to [LdCameraSession.previewAspectRatio] before being
/// scaled, which keeps the texture's proportions intact inside square tiles or
/// full-screen frames.
Widget ldCameraFittedPreview(BuildContext context, LdCameraSession session) {
  return FittedBox(
    fit: BoxFit.cover,
    child: SizedBox(
      width: session.previewAspectRatio * 1000,
      height: 1000,
      child: session.buildPreview(context),
    ),
  );
}

/// The expanded live camera surface: preview plus flash / shutter / flip and a
/// close control.
///
/// This is rendered in-place by the gallery (no route, no Hero); the gallery
/// animates its position and size with a spring.
class LdCameraView extends StatelessWidget {
  const LdCameraView({
    super.key,
    required this.session,
    required this.labels,
    required this.busy,
    required this.onCapture,
    required this.onFlip,
    required this.onFlashToggle,
    required this.onClose,
  });

  final LdCameraSession session;
  final LdAttachmentPickerLabels labels;
  final bool busy;
  final VoidCallback onCapture;
  final VoidCallback onFlip;
  final VoidCallback onFlashToggle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        ldCameraFittedPreview(context, session),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.all(theme.paddingSize(size: LdSize.s)),
            child: LdButton.outline(
              size: LdSize.l,
              onPressed: onClose,
              child: Icon(LucideIcons.x),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.5],
                colors: [Color(0x00000000), Color(0xB3000000)],
              ),
            ),
            child: Padding(
              padding:
                  MediaQuery.paddingOf(context).copyWith(top: 0) + theme.pad(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LdButton.outline(
                    size: LdSize.l,
                    onPressed: onFlashToggle,
                    child: Icon(_flashIcon(session.flashMode)),
                  ),
                  _ShutterButton(busy: busy, onPressed: onCapture),
                  LdButton.outline(
                    size: LdSize.l,
                    onPressed: onFlip,
                    child: Icon(LucideIcons.switchCamera),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _flashIcon(LdFlashMode mode) => switch (mode) {
    LdFlashMode.off => LucideIcons.flashlightOff,
    LdFlashMode.auto => LucideIcons.zap,
    LdFlashMode.always => LucideIcons.flashlight,
    LdFlashMode.torch => LucideIcons.sun,
  };
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.busy, required this.onPressed});

  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Capture',
      child: GestureDetector(
        key: const ValueKey('ld-camera-shutter'),
        onTap: busy ? null : onPressed,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: busy
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
