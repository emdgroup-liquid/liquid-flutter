import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AttachmentPickerDemo extends StatefulWidget {
  const AttachmentPickerDemo({super.key});

  @override
  State<AttachmentPickerDemo> createState() => _AttachmentPickerDemoState();
}

class _AttachmentPickerDemoState extends State<AttachmentPickerDemo> {
  List<LdPickedAttachment> _picked = const [];

  /// Native services with demo-owned place + recent-file sources so the
  /// location and file tabs have something to show.
  LdAttachmentServices get _services =>
      LdAttachmentServices.native(places: _DemoPlaceSource(), recentFiles: _DemoRecentFilesSource());

  Future<void> _open({LdAttachmentPickerConfig config = const LdAttachmentPickerConfig()}) async {
    final result = await showLdAttachmentPicker(context, services: _services, config: config);
    if (result != null) {
      setState(() => _picked = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: 'lib/components/form_elements/attachment_picker.dart',
      title: 'LdAttachmentPicker',
      apiComponents: const [
        'LdAttachmentPicker',
        'showLdAttachmentPicker',
        'LdAttachmentServices',
        'LdAttachmentCustomTab',
      ],
      demo: LdAutoSpace(
        children: [
          LdText.p(
            'LdAttachmentPicker is a rich, Telegram-style attachment picker '
            'with gallery, file, location, and contact tabs. Native '
            'capabilities are resolved through LdAttachmentServices, so hosts '
            'can swap or fake any platform integration.',
          ),
          ComponentWell(
            title: const Text('Multi-select picker'),
            description: const Text(
              'Allow several attachments at once. Tabs shown depend on '
              'LdAttachmentPickerConfig.allowedTypes. The location and file '
              'tabs are backed by demo sources.',
            ),
            child: Center(
              child: LdButton(onPressed: () => _open(), child: const Text('Open attachment picker')),
            ),
          ),
          ComponentWell(
            title: const Text('Files only, single select'),
            description: const Text('Restrict the picker to files and complete on the first pick.'),
            child: Center(
              child: LdButton.outline(
                onPressed: () => _open(
                  config: const LdAttachmentPickerConfig(multiple: false, allowedTypes: {LdAttachmentKind.file}),
                ),
                child: const Text('Pick a file'),
              ),
            ),
          ),
          ComponentWell(
            title: const Text('Custom tab'),
            description: const Text(
              'Register a host-provided tab with LdAttachmentCustomTab: an '
              'icon, a label, and a page that reports results through '
              'LdAttachmentCustomController.',
            ),
            child: Center(
              child: LdButton.ghost(
                onPressed: () => _open(
                  config: LdAttachmentPickerConfig(
                    customTabs: [
                      LdAttachmentCustomTab(
                        id: 'sticker',
                        label: 'Sticker',
                        icon: LucideIcons.smile,
                        pageBuilder: (context, controller) => _StickerTab(controller: controller),
                      ),
                    ],
                  ),
                ),
                child: const Text('Open with sticker tab'),
              ),
            ),
          ),
          if (_picked.isNotEmpty)
            ComponentWell(
              title: Text('Picked (${_picked.length})'),
              description: const Text('Result returned by the picker.'),
              child: LdCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final attachment in _picked)
                      LdListItem(
                        leading: LdAvatar(child: Icon(_iconFor(attachment.kind))),
                        title: LdText.l(attachment.name),
                        subtitle: LdText.ps(attachment.kind.name),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(LdAttachmentKind kind) => switch (kind) {
    LdAttachmentKind.image => LucideIcons.image,
    LdAttachmentKind.video => LucideIcons.film,
    LdAttachmentKind.file => LucideIcons.file,
    LdAttachmentKind.location => LucideIcons.mapPin,
    LdAttachmentKind.contact => LucideIcons.user,
    LdAttachmentKind.custom => LucideIcons.sparkles,
  };
}

/// A demo custom tab: pick a "sticker" to attach.
class _StickerTab extends StatelessWidget {
  const _StickerTab({required this.controller});

  final LdAttachmentCustomController controller;

  static const _stickers = <(String, String)>[
    ('⭐️', 'Star'),
    ('🔥', 'Fire'),
    ('🎉', 'Party'),
    ('👍', 'Thumbs up'),
    ('🚀', 'Rocket'),
    ('💡', 'Idea'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return GridView.count(
      padding: EdgeInsets.all(theme.paddingSize(size: LdSize.xs)),
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        for (final (emoji, label) in _stickers)
          LdTouchableSurface(
            onPressed: () => controller.pick(
              LdPickedAttachment(id: 'sticker:$label', kind: LdAttachmentKind.custom, name: '$label sticker'),
            ),
            builder: (context, status, child) => DecoratedBox(
              decoration: BoxDecoration(
                color: theme.neutralShade(theme.isDark ? 2 : 1),
                borderRadius: theme.radius(LdSize.m),
              ),
              child: child,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 30)),
                  ldSpacerXS,
                  LdText.ls(label, maxLines: 1),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DemoPlaceSource implements LdPlaceSource {
  static const _places = <LdPlace>[
    LdPlace(name: 'Home', subtitle: 'Liquid HQ', latitude: 48.1372, longitude: 11.5755),
    LdPlace(name: 'Coffee House', subtitle: 'Main Street 12', latitude: 48.1390, longitude: 11.5790),
    LdPlace(name: 'Central Park', subtitle: 'North entrance', latitude: 48.1420, longitude: 11.5820),
    LdPlace(name: 'Airport', subtitle: 'Terminal 2', latitude: 48.3538, longitude: 11.7861),
  ];

  @override
  Future<List<LdPlace>> nearby(LdGeoPosition origin) async => _places;

  @override
  Future<List<LdPlace>> search(String query) async {
    final q = query.toLowerCase();
    return _places
        .where((p) => p.name.toLowerCase().contains(q) || (p.subtitle?.toLowerCase().contains(q) ?? false))
        .toList();
  }
}

class _DemoRecentFilesSource implements LdRecentFilesSource {
  @override
  Future<List<LdFileEntry>> recentFiles() async => [
    LdFileEntry(
      name: 'project-notes.md',
      file: XFile.fromData(Uint8List.fromList(List.filled(32, 7)), name: 'project-notes.md'),
      size: 2048,
      mimeType: 'text/markdown',
    ),
    LdFileEntry(
      name: 'screenshot.png',
      file: XFile.fromData(Uint8List.fromList(List.filled(64, 3)), name: 'screenshot.png'),
      size: 102400,
      mimeType: 'image/png',
    ),
  ];
}
