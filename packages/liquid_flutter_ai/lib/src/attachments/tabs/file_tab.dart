import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../attachment_models.dart';
import '../attachment_picker_controller.dart';
import '../attachment_result.dart';
import '../widgets/action_tile.dart';
import '../widgets/section_header.dart';

/// File tab: pick from gallery/files, scan a document, and browse recently
/// sent files.
class LdFileTab extends StatefulWidget {
  const LdFileTab({super.key, required this.controller});

  final LdAttachmentPickerController controller;

  @override
  State<LdFileTab> createState() => _LdFileTabState();
}

class _LdFileTabState extends State<LdFileTab> {
  List<LdFileEntry> _recent = const [];
  bool _loadingRecent = true;
  bool _busy = false;

  LdAttachmentPickerController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    try {
      final files = await _controller.services.recentFiles.recentFiles();
      if (!mounted) {
        return;
      }
      setState(() {
        _recent = files;
        _loadingRecent = false;
      });
    } catch (error, stackTrace) {
      debugPrint('LdFileTab: failed to load recent files: $error\n$stackTrace');
      if (mounted) {
        setState(() => _loadingRecent = false);
      }
    }
  }

  Future<void> _pickFiles() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final files = await _controller.services.files.pickFiles(
        allowMultiple: _controller.multiple,
      );
      _emit(files);
    } catch (error, stackTrace) {
      debugPrint('LdFileTab: file picker failed: $error\n$stackTrace');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _scanDocument() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final files = await _controller.services.files.scanDocument();
      _emit(files);
    } catch (error, stackTrace) {
      debugPrint('LdFileTab: document scan failed: $error\n$stackTrace');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _emit(List<LdFileEntry> files) {
    if (!mounted || files.isEmpty) {
      return;
    }
    if (!_controller.multiple) {
      _controller.pickAndConfirm(_toAttachment(files.first));
      return;
    }
    for (final entry in files) {
      _controller.pickAndConfirm(_toAttachment(entry));
    }
  }

  LdPickedAttachment _toAttachment(LdFileEntry entry) {
    return LdPickedAttachment(
      id: 'file:${entry.file.path}',
      kind: _kindFor(entry.mimeType, entry.name),
      name: entry.name,
      file: entry.file,
      mimeType: entry.mimeType,
      size: entry.size,
    );
  }

  LdAttachmentKind _kindFor(String? mimeType, String name) {
    if (mimeType?.startsWith('image/') == true) {
      return LdAttachmentKind.image;
    }
    if (mimeType?.startsWith('video/') == true) {
      return LdAttachmentKind.video;
    }
    return LdAttachmentKind.file;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final labels = _controller.labels;
    final scanSupported =
        _controller.services.files.documentScanSupported &&
        _controller.config.scanDocumentEnabled;

    return LdScaffoldBody(
      shrinkWrap: true,
      children: [
        LdAutoSpace(
          children: [
            LdAttachmentActionTile(
              icon: LucideIcons.folderOpen,
              title: labels.selectFromFiles,
              onTap: _busy ? null : _pickFiles,
            ),
            if (scanSupported)
              LdAttachmentActionTile(
                icon: LucideIcons.scanLine,
                title: labels.scanDocument,
                onTap: _busy ? null : _scanDocument,
              ),
          ],
        ),
        ldSpacerL,
        LdAttachmentSectionHeader(label: labels.recentlySentFiles),
        if (_loadingRecent)
          const LdListItemLoading(hasLeading: true, hasSubtitle: true)
        else if (_recent.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: theme.paddingSize(size: LdSize.s),
            ),
            child: LdText.ps(labels.noRecentFiles),
          )
        else
          LdCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final entry in _recent)
                  LdListItem(
                    leading: const LdAvatar(child: Icon(LucideIcons.file)),
                    title: LdText.l(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: entry.size == null
                        ? null
                        : LdText.ps(ldFormatBytes(entry.size!)),
                    onPressed: () => _emit([entry]),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
