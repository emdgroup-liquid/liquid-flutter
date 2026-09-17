import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

import '../attachment_models.dart';

/// Facade over the device photo library (recents, permissions, thumbnails).
///
/// Host apps can replace the bundled native implementation; tests supply a
/// fake. No photo-library-plugin type appears here.
abstract interface class LdMediaFacade {
  /// Whether this platform supports limited photo-library access and a
  /// "manage selection" flow.
  bool get supportsLimitedAccess;

  /// Requests access, prompting the user when necessary.
  Future<LdPermissionState> requestPermission({LdMediaType? forType});

  /// Reads the current permission state without prompting.
  Future<LdPermissionState> permissionState();

  /// Presents the system limited-library picker so the user can grant access
  /// to additional assets. No-op where unsupported.
  Future<void> presentLimited();

  /// Loads one page of recent assets.
  ///
  /// [page] is zero-based; [pageSize] is the number of assets per page.
  Future<List<LdMediaAsset>> recentAssets({
    required int page,
    required int pageSize,
    required Set<LdMediaType> types,
  });

  /// Loads a thumbnail for [asset] and returns the encoded bytes, or `null`.
  Future<Uint8List?> thumbnail(
    LdMediaAsset asset, {
    int width = 240,
    int height = 240,
  });

  /// Resolves the original file for [asset], or `null` when unavailable.
  Future<XFile?> resolveFile(LdMediaAsset asset);
}
