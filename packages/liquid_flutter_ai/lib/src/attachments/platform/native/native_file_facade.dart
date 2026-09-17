import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';

import '../../attachment_models.dart';
import '../file_facade.dart';

/// Bundled [LdFileFacade] backed by `package:file_picker` and
/// `package:flutter_doc_scanner`.
class LdNativeFileFacade implements LdFileFacade {
  @override
  bool get documentScanSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<List<LdFileEntry>> pickFiles({bool allowMultiple = true}) async {
    final result = await FilePicker.pickFiles(
      allowMultiple: allowMultiple,
      withData: kIsWeb,
    );
    if (result == null) {
      return const [];
    }
    return result.files
        .map(_toEntry)
        .whereType<LdFileEntry>()
        .toList(growable: false);
  }

  @override
  Future<List<LdFileEntry>> scanDocument() async {
    if (!documentScanSupported) {
      return const [];
    }
    try {
      final result = await FlutterDocScanner().getScannedDocumentAsImages();
      if (result == null) {
        return const [];
      }
      return result.images
          .map(
            (path) => LdFileEntry(
              name: _basename(path),
              file: XFile(path),
              mimeType: 'image/jpeg',
            ),
          )
          .toList(growable: false);
    } catch (error, stackTrace) {
      debugPrint(
        'LdNativeFileFacade: document scan failed: $error\n$stackTrace',
      );
      return const [];
    }
  }

  LdFileEntry? _toEntry(PlatformFile file) {
    final xfile = _xfile(file);
    if (xfile == null) {
      return null;
    }
    return LdFileEntry(
      name: file.name,
      file: xfile,
      size: file.size,
      mimeType: _mimeFromName(file.name),
    );
  }

  XFile? _xfile(PlatformFile file) {
    final path = file.path;
    if (path != null && path.isNotEmpty) {
      return XFile(path);
    }
    final bytes = file.bytes;
    if (bytes != null) {
      return XFile.fromData(bytes, name: file.name, length: file.size);
    }
    return null;
  }

  String _basename(String path) {
    final normalized = path.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index < 0 ? normalized : normalized.substring(index + 1);
  }

  String? _mimeFromName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) {
      return null;
    }
    return switch (name.substring(dot + 1).toLowerCase()) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'pdf' => 'application/pdf',
      'txt' => 'text/plain',
      'md' => 'text/markdown',
      _ => null,
    };
  }
}
