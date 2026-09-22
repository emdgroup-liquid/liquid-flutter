import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../attachment_models.dart';
import '../attachment_picker_controller.dart';
import '../attachment_result.dart';
import '../camera/camera_capture_view.dart';
import '../platform/camera_facade.dart';
import '../widgets/empty_state.dart';
import '../widgets/media_tile.dart';
import '../widgets/permission_prompt.dart';

/// Gallery tab: a Telegram-style header (2-row camera preview + 4 recent
/// photos), the recent media grid, and the limited-access banner.
class LdGalleryTab extends StatefulWidget {
  const LdGalleryTab({super.key, required this.controller});

  final LdAttachmentPickerController controller;

  @override
  State<LdGalleryTab> createState() => _LdGalleryTabState();
}

class _LdGalleryTabState extends State<LdGalleryTab>
    with WidgetsBindingObserver {
  static const int _pageSize = 60;
  static const double _spacing = 4;

  /// Number of recent photos shown in the 2x2 block beside the camera.
  static const int _headerPhotos = 4;

  final ScrollController _scroll = ScrollController();
  final List<LdMediaAsset> _assets = [];
  final Map<String, Uint8List> _thumbnails = {};
  final Set<String> _requestedThumbnails = {};
  final Set<String> _resolving = {};

  LdCameraSession? _cameraSession;
  bool _cameraExpanded = false;
  bool _capturing = false;

  /// A captured-but-unconfirmed photo, shown for review before attaching.
  LdPickedAttachment? _captured;

  bool _loadingPage = false;
  bool _hasMore = true;
  int _page = 0;
  Object? _error;

  LdAttachmentPickerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _init();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    _cameraSession?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermission();
    }
  }

  Future<void> _init() async {
    // Opening the gallery (the picker's default tab) is the trigger to ask for
    // photo access, matching the platform picker flow.
    await _controller.loadMediaPermission(request: true);
    if (!mounted) {
      return;
    }
    if (_controller.hasMediaAccess) {
      await _loadNextPage();
    }
    if (_controller.config.cameraEnabled) {
      await _initCamera();
    }
  }

  /// Re-reads the permission silently (used on app resume) so a grant made in
  /// the system settings flows back into the UI without reopening the picker.
  Future<void> _refreshPermission() async {
    await _controller.loadMediaPermission();
    if (!mounted) {
      return;
    }
    if (_controller.hasMediaAccess &&
        _assets.isEmpty &&
        !_loadingPage &&
        _hasMore) {
      await _loadNextPage();
    }
  }

  Future<void> _initCamera() async {
    if (_cameraSession != null) {
      return;
    }
    try {
      final available = await _controller.services.camera.isAvailable();
      if (!available || !mounted) {
        return;
      }
      final session = await _controller.services.camera.createSession();
      if (!mounted) {
        await session.dispose();
        return;
      }
      setState(() => _cameraSession = session);
    } catch (error, stackTrace) {
      debugPrint('LdGalleryTab: failed to open camera: $error\n$stackTrace');
    }
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 600) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loadingPage || !_hasMore) {
      return;
    }
    setState(() {
      _loadingPage = true;
      _error = null;
    });
    try {
      final assets = await _controller.services.media.recentAssets(
        page: _page,
        pageSize: _pageSize,
        types: _controller.config.mediaTypes,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _assets.addAll(assets);
        _page += 1;
        _hasMore = assets.length >= _pageSize;
        _loadingPage = false;
      });
    } catch (error, stackTrace) {
      debugPrint('LdGalleryTab: failed to load assets: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingPage = false;
        _error = error;
      });
    }
  }

  Future<void> _loadThumbnail(LdMediaAsset asset) async {
    if (_requestedThumbnails.contains(asset.id)) {
      return;
    }
    _requestedThumbnails.add(asset.id);
    try {
      final bytes = await _controller.services.media.thumbnail(asset);
      if (!mounted) {
        return;
      }
      if (bytes != null && bytes.isNotEmpty) {
        setState(() => _thumbnails[asset.id] = bytes);
      }
    } catch (error, stackTrace) {
      debugPrint('LdGalleryTab: failed to load thumbnail: $error\n$stackTrace');
    }
  }

  Future<void> _toggleAsset(LdMediaAsset asset) async {
    if (_resolving.contains(asset.id)) {
      return;
    }
    setState(() => _resolving.add(asset.id));
    try {
      final file = await _controller.services.media.resolveFile(asset);
      if (!mounted) {
        return;
      }
      if (file == null) {
        return;
      }
      _controller.handleTap(
        LdPickedAttachment(
          id: 'media:${asset.id}',
          kind: asset.kind,
          name: asset.title ?? (asset.isVideo ? 'Video' : 'Photo'),
          file: file,
          mimeType: asset.mimeType,
          thumbnail: _thumbnails[asset.id],
          duration: asset.isVideo ? asset.duration : null,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _resolving.remove(asset.id));
      }
    }
  }

  Future<void> _requestPermission() async {
    await _controller.loadMediaPermission(request: true);
    if (mounted && _controller.hasMediaAccess) {
      await _loadNextPage();
    }
  }

  // --- Camera -------------------------------------------------------------

  void _openCamera() {
    if (_cameraSession == null) {
      return;
    }
    setState(() => _cameraExpanded = true);
  }

  void _closeCamera() {
    setState(() => _cameraExpanded = false);
  }

  Future<void> _flipCamera() async {
    final session = _cameraSession;
    if (session == null) {
      return;
    }
    try {
      await session.flip();
    } catch (error, stackTrace) {
      debugPrint('LdGalleryTab: flip failed: $error\n$stackTrace');
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _toggleFlash() async {
    final session = _cameraSession;
    if (session == null) {
      return;
    }
    final next = switch (session.flashMode) {
      LdFlashMode.off => LdFlashMode.auto,
      LdFlashMode.auto => LdFlashMode.always,
      LdFlashMode.always => LdFlashMode.off,
      LdFlashMode.torch => LdFlashMode.off,
    };
    try {
      await session.setFlashMode(next);
    } catch (error, stackTrace) {
      debugPrint('LdGalleryTab: flash toggle failed: $error\n$stackTrace');
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _capture() async {
    final session = _cameraSession;
    if (session == null || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final file = await session.takePicture();
      Uint8List? thumbnail;
      try {
        thumbnail = await file.readAsBytes();
      } catch (_) {
        thumbnail = null;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _capturing = false;
        _captured = LdPickedAttachment(
          id: 'camera:${DateTime.now().microsecondsSinceEpoch}',
          kind: LdAttachmentKind.image,
          name: file.name,
          file: file,
          mimeType: 'image/jpeg',
          thumbnail: thumbnail,
        );
      });
    } catch (error, stackTrace) {
      debugPrint('LdGalleryTab: capture failed: $error\n$stackTrace');
      if (mounted) {
        setState(() => _capturing = false);
      }
    }
  }

  /// Attaches the reviewed capture (and finishes the picker in single-select
  /// mode).
  void _confirmCapture() {
    final captured = _captured;
    if (captured == null) {
      return;
    }
    setState(() => _captured = null);
    _controller.pickAndConfirm(captured);
    if (mounted && _controller.multiple) {
      setState(() => _cameraExpanded = false);
    }
  }

  void _discardCapture() {
    setState(() => _captured = null);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final labels = controller.labels;

    if (!controller.mediaPermissionResolved) {
      return const Center(child: LdLoader());
    }

    if (!controller.hasMediaAccess) {
      final state = controller.mediaPermission;
      if (state == LdPermissionState.notDetermined) {
        return LdAttachmentPermissionPrompt(
          message: labels.photosDenied,
          actionLabel: labels.allowAccess,
          onAction: _requestPermission,
        );
      }
      return LdAttachmentPermissionPrompt(
        message: labels.photosDenied,
        actionLabel: labels.openSettings,
        onAction: state == LdPermissionState.restricted
            ? null
            : controller.openSettings,
      );
    }

    return Column(
      children: [
        if (controller.isLimited)
          _LimitedBanner(
            message: labels.limitedAccessMessage,
            selectLabel: labels.selectMorePhotos,
            settingsLabel: labels.changeSettings,
            onSelect: controller.presentLimited,
            onSettings: controller.openSettings,
          ),
        Expanded(child: _buildGrid(context)),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final controller = _controller;
    final theme = LdTheme.of(context);
    final session = _cameraSession;
    final showCamera = session != null && controller.config.cameraEnabled;
    final count = _assets.length + (showCamera ? 1 : 0);

    if (count == 0) {
      if (_loadingPage) {
        return const Center(child: LdLoader());
      }
      if (_error != null) {
        return LdAttachmentEmptyState(
          icon: LucideIcons.circleAlert,
          message: controller.labels.noPhotos,
          action: LdButton.outline(
            onPressed: _loadNextPage,
            child: const Text('Retry'),
          ),
        );
      }
      return LdAttachmentEmptyState(
        icon: LucideIcons.images,
        message: controller.labels.noPhotos,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final inset =
            MediaQuery.paddingOf(context) + theme.pad(size: LdSize.xs);
        final columns = controller.config.galleryColumns;
        final contentWidth = constraints.maxWidth - inset.horizontal;
        final cell = (contentWidth - _spacing * (columns - 1)) / columns;

        final headerCount = showCamera
            ? (_assets.length < _headerPhotos ? _assets.length : _headerPhotos)
            : 0;

        return Stack(
          children: [
            CustomScrollView(
              controller: _scroll,
              slivers: [
                if (showCamera)
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: inset.left,
                      right: inset.right,
                      top: inset.top,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _buildHeader(context, cell, headerCount),
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: inset.left,
                    right: inset.right,
                    top: showCamera ? _spacing : inset.top,
                    bottom: inset.bottom,
                  ),
                  sliver: SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: _spacing,
                      mainAxisSpacing: _spacing,
                    ),
                    itemCount: _assets.length - headerCount,
                    itemBuilder: (context, index) =>
                        _mediaTile(context, _assets[headerCount + index]),
                  ),
                ),
                if (_loadingPage)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(
                        theme.paddingSize(size: LdSize.s),
                      ),
                      child: const Center(child: LdLoader(size: 20)),
                    ),
                  ),
              ],
            ),
            if (showCamera)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _scroll,
                  builder: (context, _) {
                    final offset = _scroll.hasClients ? _scroll.offset : 0.0;
                    final collapsed = Rect.fromLTWH(
                      inset.left,
                      inset.top - offset,
                      cell,
                      cell * 2 + _spacing,
                    );
                    final expanded = Rect.fromLTWH(
                      0,
                      0,
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return LdSpring(
                      position: _cameraExpanded ? 1 : 0,
                      initialPosition: _cameraExpanded ? 1 : 0,
                      springConstant: 14,
                      dampingCoefficient: 10,
                      builder: (context, state, _) {
                        final t = state.position.clamp(0.0, 1.0).toDouble();
                        final eased = Curves.easeOutCubic.transform(t);
                        final rect = Rect.lerp(collapsed, expanded, eased)!;
                        return Stack(
                          children: [
                            Positioned.fromRect(
                              rect: rect,
                              child: _buildCameraSurface(context, eased),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  /// The Telegram-style header: a 2-row-tall camera slot on the left with up to
  /// [_headerPhotos] recent photos arranged 2x2 to its right.
  Widget _buildHeader(BuildContext context, double cell, int photoCount) {
    return SizedBox(
      height: cell * 2 + _spacing,
      child: Stack(
        children: [
          for (var i = 0; i < photoCount; i++)
            Positioned(
              left: cell + _spacing + (i % 2) * (cell + _spacing),
              top: (i ~/ 2) * (cell + _spacing),
              width: cell,
              height: cell,
              child: _mediaTile(context, _assets[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraSurface(BuildContext context, double eased) {
    final session = _cameraSession;
    if (session == null) {
      return const SizedBox.shrink();
    }
    final theme = LdTheme.of(context);
    final showControls = eased > 0.5;
    final radius = BorderRadius.lerp(
      theme.radius(LdSize.s),
      BorderRadius.zero,
      eased,
    )!;

    return ClipRRect(
      borderRadius: radius,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: showControls ? null : _openCamera,
        child: _captured != null
            ? _CapturedReview(
                attachment: _captured!,
                onConfirm: _confirmCapture,
                onDiscard: _discardCapture,
              )
            : showControls
            ? LdCameraView(
                session: session,
                labels: _controller.labels,
                busy: _capturing,
                onCapture: _capture,
                onFlip: _flipCamera,
                onFlashToggle: _toggleFlash,
                onClose: _closeCamera,
              )
            : _CameraEntryTile(
                session: session,
                label: _controller.labels.camera,
              ),
      ),
    );
  }

  Widget _mediaTile(BuildContext context, LdMediaAsset asset) {
    final id = 'media:${asset.id}';
    final selectedIndex = _controller.selectionIndex(id);
    _loadThumbnail(asset);
    return LdAttachmentMediaTile(
      asset: asset,
      thumbnail: _thumbnails[asset.id],
      loading: _resolving.contains(asset.id),
      selected: selectedIndex != null,
      selectionIndex: _controller.multiple && selectedIndex != null
          ? selectedIndex + 1
          : null,
      onTap: () => _toggleAsset(asset),
    );
  }
}

/// The collapsed camera entry: live preview plus a small "Camera" badge.
class _CameraEntryTile extends StatelessWidget {
  const _CameraEntryTile({required this.session, required this.label});

  final LdCameraSession session;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        ldCameraFittedPreview(context, session),
        Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.camera, color: Colors.white, size: 13),
              ldHSpacerXS,
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ).padS(),
        ),
      ],
    );
  }
}

class _CapturedReview extends StatelessWidget {
  const _CapturedReview({
    required this.attachment,
    required this.onConfirm,
    required this.onDiscard,
  });

  final LdPickedAttachment attachment;
  final VoidCallback onConfirm;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final bytes = attachment.thumbnail;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        if (bytes != null && bytes.isNotEmpty)
          Image.memory(
            bytes,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(LucideIcons.image, color: Colors.white54, size: 42),
            ),
          )
        else
          const Center(
            child: Icon(LucideIcons.image, color: Colors.white54, size: 42),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xB3000000)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.paddingSize(size: LdSize.l),
                vertical: theme.paddingSize(size: LdSize.m),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LdButton.outline(
                    key: const ValueKey('ld-capture-discard'),
                    onPressed: onDiscard,
                    size: LdSize.l,
                    child: const Icon(LucideIcons.x),
                  ),
                  LdButton.filled(
                    key: const ValueKey('ld-capture-confirm'),
                    onPressed: onConfirm,
                    size: LdSize.l,
                    child: const Icon(LucideIcons.check),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LimitedBanner extends StatelessWidget {
  const _LimitedBanner({
    required this.message,
    required this.selectLabel,
    required this.settingsLabel,
    required this.onSelect,
    required this.onSettings,
  });

  final String message;
  final String selectLabel;
  final String settingsLabel;
  final VoidCallback onSelect;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        theme.paddingSize(size: LdSize.xs),
        theme.paddingSize(size: LdSize.xs),
        theme.paddingSize(size: LdSize.xs),
        0,
      ),
      child: LdCard(
        child: Row(
          children: [
            Expanded(child: LdText.ps(message, maxLines: 2)),
            ldHSpacerS,
            LdButton.ghost(
              size: LdSize.s,
              onPressed: onSelect,
              child: Text(selectLabel),
            ),
            LdButton.ghost(
              size: LdSize.s,
              onPressed: onSettings,
              child: Text(settingsLabel),
            ),
          ],
        ),
      ),
    );
  }
}
