import '../attachment_models.dart';

/// Facade over file selection and document scanning.
///
/// Host apps can replace the bundled native implementation; tests supply a
/// fake. No file-plugin type appears here.
abstract interface class LdFileFacade {
  /// Whether "Scan Document" can be offered on this platform.
  bool get documentScanSupported;

  /// Opens the system file picker. Returns an empty list when cancelled.
  Future<List<LdFileEntry>> pickFiles({bool allowMultiple = true});

  /// Opens the document scanner. Returns an empty list when cancelled or
  /// unsupported.
  Future<List<LdFileEntry>> scanDocument();
}

/// Facade over a source of "recently sent" files.
///
/// This is app-owned data rather than a native capability, but it lives behind
/// the same seam so hosts (and tests) can supply it.
abstract interface class LdRecentFilesSource {
  Future<List<LdFileEntry>> recentFiles();
}

/// Default [LdRecentFilesSource] that returns nothing.
class LdEmptyRecentFilesSource implements LdRecentFilesSource {
  const LdEmptyRecentFilesSource();

  @override
  Future<List<LdFileEntry>> recentFiles() async => const [];
}
