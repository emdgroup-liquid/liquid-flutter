import 'package:flutter/foundation.dart';

/// Whether `package:photo_manager` and `package:flutter_contacts` ship a
/// native implementation.
///
/// Always checks [kIsWeb] first: on web [defaultTargetPlatform] often reports
/// Android and must not be treated as a native photo/contacts platform.
bool get ldPhotoLibraryPlatformSupported {
  if (kIsWeb) {
    return false;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS => true,
    _ => false,
  };
}

/// Whether limited photo-library access (`presentLimited`) exists.
bool get ldLimitedLibrarySupported {
  if (kIsWeb) {
    return false;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}

/// Whether `package:camera` ships an implementation (Android, iOS, web).
bool get ldCameraPluginSupported {
  if (kIsWeb) {
    return true;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}

/// Whether `package:maplibre` ships an implementation (Android, iOS, web).
bool get ldMapPluginSupported {
  if (kIsWeb) {
    return true;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}

/// Whether the host is macOS (never true on web).
bool get ldIsMacOS {
  if (kIsWeb) {
    return false;
  }
  return defaultTargetPlatform == TargetPlatform.macOS;
}

/// VisionKit / ML Kit document scan (Android and iOS only).
bool get ldDocumentScanSupported {
  if (kIsWeb) {
    return false;
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => true,
    _ => false,
  };
}
