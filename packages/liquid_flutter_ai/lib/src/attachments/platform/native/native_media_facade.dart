import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../attachment_models.dart';
import '../media_facade.dart';

/// Bundled [LdMediaFacade] backed by `package:photo_manager`.
class LdNativeMediaFacade implements LdMediaFacade {
  RequestType _requestType(Set<LdMediaType>? types) {
    if (types == null || types.isEmpty) {
      return RequestType.common;
    }
    final wantsImage = types.contains(LdMediaType.image);
    final wantsVideo = types.contains(LdMediaType.video);
    if (wantsImage && wantsVideo) {
      return RequestType.common;
    }
    return wantsImage ? RequestType.image : RequestType.video;
  }

  AndroidPermission _androidPermission(Set<LdMediaType>? types) =>
      AndroidPermission(type: _requestType(types), mediaLocation: false);

  @override
  bool get supportsLimitedAccess => true;

  @override
  Future<LdPermissionState> requestPermission({LdMediaType? forType}) async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: PermissionRequestOption(
        androidPermission: _androidPermission(
          forType == null ? null : {forType},
        ),
      ),
    );
    return _mapPermission(state);
  }

  @override
  Future<LdPermissionState> permissionState() async {
    final state = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(),
    );
    return _mapPermission(state);
  }

  @override
  Future<void> presentLimited() => PhotoManager.presentLimited();

  @override
  Future<List<LdMediaAsset>> recentAssets({
    required int page,
    required int pageSize,
    required Set<LdMediaType> types,
  }) async {
    final paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: _requestType(types),
      filterOption: FilterOptionGroup(
        orders: const [OrderOption(type: OrderOptionType.createDate)],
      ),
    );
    if (paths.isEmpty) {
      return const [];
    }
    final assets = await paths.first.getAssetListPaged(
      page: page,
      size: pageSize,
    );
    return assets.map(_toAsset).toList(growable: false);
  }

  @override
  Future<Uint8List?> thumbnail(
    LdMediaAsset asset, {
    int width = 240,
    int height = 240,
  }) async {
    final entity = await AssetEntity.fromId(asset.id);
    if (entity == null) {
      return null;
    }
    return entity.thumbnailDataWithSize(ThumbnailSize(width, height));
  }

  @override
  Future<XFile?> resolveFile(LdMediaAsset asset) async {
    final entity = await AssetEntity.fromId(asset.id);
    if (entity == null) {
      return null;
    }
    final file = await entity.originFile ?? await entity.file;
    if (file == null) {
      return null;
    }
    return XFile(file.path);
  }

  LdMediaAsset _toAsset(AssetEntity entity) {
    final isVideo = entity.type == AssetType.video;
    return LdMediaAsset(
      id: entity.id,
      kind: isVideo ? LdAttachmentKind.video : LdAttachmentKind.image,
      width: entity.width,
      height: entity.height,
      title: entity.title,
      duration: isVideo ? entity.videoDuration : Duration.zero,
      createDate: entity.createDateTime,
    );
  }

  LdPermissionState _mapPermission(PermissionState state) => switch (state) {
    PermissionState.notDetermined => LdPermissionState.notDetermined,
    PermissionState.restricted => LdPermissionState.restricted,
    PermissionState.denied => LdPermissionState.denied,
    PermissionState.authorized => LdPermissionState.authorized,
    PermissionState.limited => LdPermissionState.limited,
  };
}
