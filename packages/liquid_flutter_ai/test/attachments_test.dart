import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _wrap(Widget child) {
  return LdThemeProvider(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

class _FakeMedia implements LdMediaFacade {
  _FakeMedia({
    this.permission = LdPermissionState.authorized,
    this.assets = const [],
  });

  LdPermissionState permission;
  List<LdMediaAsset> assets;
  int requestCount = 0;

  @override
  bool get supportsLimitedAccess => true;

  @override
  Future<LdPermissionState> requestPermission({LdMediaType? forType}) async {
    requestCount++;
    return permission;
  }

  @override
  Future<LdPermissionState> permissionState() async => permission;

  @override
  Future<void> presentLimited() async {}

  @override
  Future<List<LdMediaAsset>> recentAssets({
    required int page,
    required int pageSize,
    required Set<LdMediaType> types,
  }) async => page == 0 ? assets : const [];

  @override
  Future<Uint8List?> thumbnail(
    LdMediaAsset asset, {
    int width = 240,
    int height = 240,
  }) async => null;

  @override
  Future<XFile?> resolveFile(LdMediaAsset asset) async =>
      XFile.fromData(Uint8List.fromList([1, 2, 3]), name: '${asset.id}.jpg');
}

class _FakeCameraSession implements LdCameraSession {
  LdLensDirection _lens = LdLensDirection.back;
  LdFlashMode _flash = LdFlashMode.off;

  @override
  LdLensDirection get lensDirection => _lens;

  @override
  LdFlashMode get flashMode => _flash;

  @override
  double get previewAspectRatio => 3 / 4;

  @override
  Widget buildPreview(BuildContext context) =>
      const SizedBox(key: ValueKey('ld-fake-camera-preview'));

  @override
  Future<void> setFlashMode(LdFlashMode mode) async => _flash = mode;

  @override
  Future<void> flip() async {
    _lens = _lens == LdLensDirection.back
        ? LdLensDirection.front
        : LdLensDirection.back;
  }

  @override
  Future<XFile> takePicture() async =>
      XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'shot.jpg');

  @override
  Future<void> dispose() async {}
}

class _FakeCamera implements LdCameraFacade {
  _FakeCamera({this.available = false});

  final bool available;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<LdCameraSession> createSession({
    LdLensDirection? lens,
    LdFlashMode flashMode = LdFlashMode.off,
  }) async {
    if (!available) {
      throw const LdCameraException('Camera unavailable in tests');
    }
    return _FakeCameraSession();
  }
}

class _FakeFiles implements LdFileFacade {
  List<LdFileEntry> picked = const [];
  List<LdFileEntry> scanned = const [];
  bool scanSupported = false;

  @override
  bool get documentScanSupported => scanSupported;

  @override
  Future<List<LdFileEntry>> pickFiles({bool allowMultiple = true}) async =>
      picked;

  @override
  Future<List<LdFileEntry>> scanDocument() async => scanned;
}

class _FakeLocation implements LdLocationFacade {
  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<LdPermissionState> requestPermission() async =>
      LdPermissionState.authorized;

  @override
  Future<LdGeoPosition?> currentPosition() async =>
      const LdGeoPosition(latitude: 48.1, longitude: 11.5, accuracyMeters: 5);

  @override
  Stream<LdGeoPosition> positionStream() => const Stream.empty();
}

class _FakePlaces implements LdPlaceSource {
  List<LdPlace> places = const [];

  @override
  Future<List<LdPlace>> nearby(LdGeoPosition origin) async => places;

  @override
  Future<List<LdPlace>> search(String query) async => places;
}

class _FakeRecentFiles implements LdRecentFilesSource {
  List<LdFileEntry> files = const [];

  @override
  Future<List<LdFileEntry>> recentFiles() async => files;
}

class _FakeContacts implements LdContactsFacade {
  _FakeContacts({this.contacts = const []});

  List<LdContactEntry> contacts;
  LdPermissionState permission = LdPermissionState.authorized;

  @override
  bool get isSupported => true;

  @override
  Future<LdPermissionState> permissionState() async => permission;

  @override
  Future<LdPermissionState> requestPermission() async => permission;

  @override
  Future<List<LdContactEntry>> loadContacts({String? query}) async => contacts;

  @override
  Future<List<int>?> avatar(LdContactEntry contact) async => null;
}

class _FakePermissions implements LdPermissionFacade {
  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<LdPermissionState> status(LdPermissionKind kind) async =>
      LdPermissionState.notDetermined;
}

class _FakeMap implements LdMapFacade {
  @override
  Widget buildMap(BuildContext context, LdMapRequest request) =>
      const SizedBox(key: ValueKey('ld-fake-map'));
}

LdAttachmentServices _services({
  _FakeMedia? media,
  _FakeCamera? camera,
  _FakeFiles? files,
  _FakeLocation? location,
  _FakeContacts? contacts,
  _FakePlaces? places,
  _FakeRecentFiles? recentFiles,
}) {
  return LdAttachmentServices(
    camera: camera ?? _FakeCamera(),
    media: media ?? _FakeMedia(),
    files: files ?? _FakeFiles(),
    location: location ?? _FakeLocation(),
    contacts: contacts ?? _FakeContacts(),
    permissions: _FakePermissions(),
    map: _FakeMap(),
    places: places ?? _FakePlaces(),
    recentFiles: recentFiles ?? _FakeRecentFiles(),
  );
}

LdMediaAsset _asset(
  String id, {
  LdAttachmentKind kind = LdAttachmentKind.image,
}) {
  return LdMediaAsset(id: id, kind: kind, width: 100, height: 100);
}

void main() {
  setUp(() => ldDisableAnimations = true);
  tearDown(() => ldDisableAnimations = false);

  testWidgets('shows only enabled tabs in the tab bar', (tester) async {
    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(),
          config: const LdAttachmentPickerConfig(
            allowedTypes: {LdAttachmentKind.file, LdAttachmentKind.location},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LdTabNavigation), findsOneWidget);
    expect(find.text('File'), findsWidgets);
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Gallery'), findsNothing);
    expect(find.text('Contacts'), findsNothing);
  });

  testWidgets('gallery shows permission prompt when denied', (tester) async {
    final media = _FakeMedia(permission: LdPermissionState.denied);
    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(media: media),
          config: const LdAttachmentPickerConfig(
            allowedTypes: {LdAttachmentKind.image, LdAttachmentKind.file},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Allow access to your photos to attach them.'),
      findsOneWidget,
    );
    expect(find.text('Open settings'), findsOneWidget);
  });

  testWidgets('gallery requests permission when not determined', (
    tester,
  ) async {
    final media = _FakeMedia(permission: LdPermissionState.notDetermined);
    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(media: media),
          config: const LdAttachmentPickerConfig(
            allowedTypes: {LdAttachmentKind.image, LdAttachmentKind.file},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Allow access'), findsOneWidget);
    await tester.tap(find.text('Allow access'));
    await tester.pumpAndSettle();
    expect(media.requestCount, 2);
  });

  testWidgets('multi-select gallery accumulates and confirms selection', (
    tester,
  ) async {
    final media = _FakeMedia(assets: [_asset('a1'), _asset('a2')]);
    List<LdPickedAttachment>? result;

    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(media: media),
          config: const LdAttachmentPickerConfig(
            allowedTypes: {LdAttachmentKind.image, LdAttachmentKind.file},
          ),
          onComplete: (value) => result = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LdAttachmentMediaTile), findsNWidgets(2));

    await tester.tap(find.byType(LdAttachmentMediaTile).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('ld-attach-confirm')), findsOneWidget);

    await tester.tap(find.byType(LdAttachmentMediaTile).last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('ld-attach-confirm')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.length, 2);
    expect(result!.first.kind, LdAttachmentKind.image);
  });

  testWidgets('single-select gallery completes immediately', (tester) async {
    final media = _FakeMedia(assets: [_asset('a1')]);
    List<LdPickedAttachment>? result;

    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(media: media),
          config: const LdAttachmentPickerConfig(
            multiple: false,
            allowedTypes: {LdAttachmentKind.image, LdAttachmentKind.file},
          ),
          onComplete: (value) => result = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LdAttachmentMediaTile).first);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.length, 1);
  });

  testWidgets('file tab picks a file', (tester) async {
    final file = _FakeFiles()
      ..picked = [
        LdFileEntry(
          name: 'notes.md',
          file: XFile.fromData(Uint8List.fromList([1]), name: 'notes.md'),
          size: 1,
          mimeType: 'text/markdown',
        ),
      ];
    List<LdPickedAttachment>? result;

    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(files: file),
          config: const LdAttachmentPickerConfig(
            multiple: false,
            allowedTypes: {LdAttachmentKind.file},
          ),
          onComplete: (value) => result = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LdAttachmentActionTile).first);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.single.name, 'notes.md');
    expect(result!.single.kind, LdAttachmentKind.file);
  });

  testWidgets('location tab sends the current location', (tester) async {
    List<LdPickedAttachment>? result;

    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(),
          config: const LdAttachmentPickerConfig(
            multiple: false,
            allowedTypes: {LdAttachmentKind.location},
          ),
          onComplete: (value) => result = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LdAttachmentActionTile).first);
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.single.kind, LdAttachmentKind.location);
    expect(result!.single.location!.latitude, 48.1);
  });

  testWidgets('contacts tab selects a contact', (tester) async {
    final contacts = _FakeContacts(
      contacts: const [
        LdContactEntry(
          id: 'c1',
          displayName: 'Ada Lovelace',
          phoneNumbers: ['123'],
        ),
      ],
    );
    List<LdPickedAttachment>? result;

    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(contacts: contacts),
          config: const LdAttachmentPickerConfig(
            multiple: false,
            allowedTypes: {LdAttachmentKind.contact},
          ),
          onComplete: (value) => result = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    await tester.tap(find.text('Ada Lovelace'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.single.kind, LdAttachmentKind.contact);
    expect(result!.single.contact!.displayName, 'Ada Lovelace');
  });

  testWidgets('camera tile is hidden when the camera is unavailable', (
    tester,
  ) async {
    final media = _FakeMedia(assets: [_asset('a1')]);
    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(media: media, camera: _FakeCamera()),
          config: const LdAttachmentPickerConfig(
            allowedTypes: {LdAttachmentKind.image, LdAttachmentKind.file},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.camera), findsNothing);
  });

  testWidgets('camera tile is shown when the camera is available', (
    tester,
  ) async {
    final media = _FakeMedia(assets: [_asset('a1')]);
    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(
            media: media,
            camera: _FakeCamera(available: true),
          ),
          config: const LdAttachmentPickerConfig(
            allowedTypes: {LdAttachmentKind.image, LdAttachmentKind.file},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.camera), findsOneWidget);
  });

  testWidgets('camera tile expands in place and closes back to the grid', (
    tester,
  ) async {
    final media = _FakeMedia(assets: [_asset('a1')]);
    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(
            media: media,
            camera: _FakeCamera(available: true),
          ),
          config: const LdAttachmentPickerConfig(
            allowedTypes: {LdAttachmentKind.image, LdAttachmentKind.file},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    expect(find.byType(LdCameraView), findsOneWidget);

    // Close either via the in-view control or the modal app bar close button.
    await tester.tap(find.byIcon(LucideIcons.x).first);
    await tester.pumpAndSettle();
    expect(find.byType(LdCameraView), findsNothing);
    expect(find.byType(LdAttachmentMediaTile), findsOneWidget);
  });

  testWidgets('gallery header shows camera plus four photos, then the grid', (
    tester,
  ) async {
    final media = _FakeMedia(
      assets: [for (var i = 0; i < 7; i++) _asset('a$i')],
    );
    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(
            media: media,
            camera: _FakeCamera(available: true),
          ),
          config: const LdAttachmentPickerConfig(
            allowedTypes: {LdAttachmentKind.image, LdAttachmentKind.file},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The header block lays out the four most recent photos beside the camera;
    // the remaining rows come from the lazy grid (visible ones may vary).
    expect(find.byType(LdAttachmentMediaTile), findsAtLeastNWidgets(4));
    expect(find.text('Camera'), findsOneWidget);
  });

  testWidgets('selecting a place completes the picker immediately', (
    tester,
  ) async {
    final places = _FakePlaces()
      ..places = const [
        LdPlace(name: 'Coffee House', latitude: 48.1, longitude: 11.5),
      ];
    List<LdPickedAttachment>? result;

    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(places: places),
          config: const LdAttachmentPickerConfig(
            // Multi-select, yet choosing a place should still finish the picker.
            multiple: true,
            allowedTypes: {LdAttachmentKind.location},
          ),
          onComplete: (value) => result = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Coffee House'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coffee House'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.single.name, 'Coffee House');
  });

  testWidgets('custom tab renders and emits a custom attachment', (
    tester,
  ) async {
    List<LdPickedAttachment>? result;

    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(),
          config: LdAttachmentPickerConfig(
            multiple: false,
            allowedTypes: const {LdAttachmentKind.file},
            customTabs: [
              LdAttachmentCustomTab(
                id: 'sticker',
                label: 'Sticker',
                icon: LucideIcons.smile,
                pageBuilder: (context, controller) => Center(
                  child: LdButton(
                    onPressed: () => controller.complete(
                      const LdPickedAttachment(
                        id: 'sticker:star',
                        kind: LdAttachmentKind.custom,
                        name: 'Star sticker',
                      ),
                    ),
                    child: const Text('Pick sticker'),
                  ),
                ),
              ),
            ],
          ),
          onComplete: (value) => result = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sticker'));
    await tester.pumpAndSettle();
    expect(find.text('Pick sticker'), findsOneWidget);

    await tester.tap(find.text('Pick sticker'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.single.kind, LdAttachmentKind.custom);
    expect(result!.single.name, 'Star sticker');
  });

  testWidgets('captured photo is reviewed before it is attached', (
    tester,
  ) async {
    List<LdPickedAttachment>? result;

    await tester.pumpWidget(
      _wrap(
        LdAttachmentPicker(
          services: _services(
            media: _FakeMedia(assets: [_asset('a1')]),
            camera: _FakeCamera(available: true),
          ),
          config: const LdAttachmentPickerConfig(
            multiple: false,
            allowedTypes: {LdAttachmentKind.image, LdAttachmentKind.file},
          ),
          onComplete: (value) => result = value,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('ld-camera-shutter')));
    await tester.pumpAndSettle();

    // Capture shows a review step; nothing is attached yet.
    expect(result, isNull);
    expect(find.byKey(const ValueKey('ld-capture-confirm')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('ld-capture-confirm')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.single.kind, LdAttachmentKind.image);
  });
}
