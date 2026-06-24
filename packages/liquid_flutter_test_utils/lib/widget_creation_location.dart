import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test_api/src/backend/invoker.dart'; // ignore: implementation_imports, depend_on_referenced_packages

const _inspectorGroup = '_liquid_widget_tree_test';

/// Whether widget creation locations are available in the current build.
bool isWidgetCreationTracked() {
  return WidgetInspectorService.instance.isWidgetCreationTracked();
}

/// Returns the source file where [element]'s widget was instantiated.
///
/// Only available in debug builds with `--track-widget-creation` enabled
/// (the default for `flutter test`).
String? creationLocationFile(Element element) {
  if (!kDebugMode || !isWidgetCreationTracked()) {
    return null;
  }

  final service = WidgetInspectorService.instance;
  // ignore: invalid_use_of_protected_member
  service.setSelection(element, _inspectorGroup);
  try {
    final jsonObject = jsonDecode(
      // ignore: invalid_use_of_protected_member
      service.getSelectedWidget(null, _inspectorGroup),
    ) as Map<String, dynamic>;
    final creationLocation =
        jsonObject['creationLocation'] as Map<String, dynamic>?;
    return creationLocation?['file'] as String?;
  } catch (_) {
    return null;
  }
}

/// Scope describing the package whose widget instantiations should be shown
/// in widget tree goldens.
class FocusPackageScope {
  FocusPackageScope({
    required this.packageName,
    required this.packageRoot,
  });

  final String packageName;

  /// Absolute path to the package directory (contains `pubspec.yaml`).
  final String packageRoot;

  static final _cache = <String, FocusPackageScope?>{};

  /// Registers [packageRoot] with the widget inspector so creation locations
  /// resolve as local project files.
  void configurePubRootDirectories() {
    assert(() {
      WidgetInspectorService.instance
          // ignore: invalid_use_of_protected_member
          .addPubRootDirectories([packageRoot]);
      return true;
    }());
  }

  /// Whether [fileUri] points at a source file under this focus package.
  static bool isFocusPackageLocation(String? fileUri, FocusPackageScope scope) {
    if (fileUri == null || fileUri.isEmpty) {
      return false;
    }

    final normalized = _normalizeCreationPath(fileUri);
    final root = scope.packageRoot.replaceAll('\\', '/');

    if (normalized.startsWith(root)) {
      final relative = normalized.substring(root.length);
      if (relative.startsWith('/lib/') || relative.startsWith('/test/')) {
        return true;
      }
    }

    if (normalized.contains('/packages/${scope.packageName}/lib/')) {
      return true;
    }
    if (normalized.contains('/packages/${scope.packageName}/test/')) {
      return true;
    }

    if (normalized.startsWith('package:${scope.packageName}/')) {
      return true;
    }

    final appsLib = '/apps/${scope.packageName}/lib/';
    final appsTest = '/apps/${scope.packageName}/test/';
    if (normalized.contains(appsLib) || normalized.contains(appsTest)) {
      return true;
    }

    return false;
  }

  static String _normalizeCreationPath(String fileUri) {
    var normalized = fileUri.replaceAll('\\', '/');
    if (normalized.startsWith('file://')) {
      normalized = Uri.parse(normalized).toFilePath().replaceAll('\\', '/');
    }
    return normalized;
  }

  bool isFocusCreated(Element element) {
    return isFocusPackageLocation(creationLocationFile(element), this);
  }

  /// Resolves the focus package from [testFilePath] or the current test.
  static FocusPackageScope? resolveSync({
    String? testFilePath,
    String? focusPackageOverride,
  }) {
    final resolvedTestPath = testFilePath ?? currentTestFilePath();
    final cacheKey = '${resolvedTestPath ?? ''}:$focusPackageOverride';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    final scope = _resolveUncached(
      testFilePath: resolvedTestPath,
      focusPackageOverride: focusPackageOverride,
    );
    scope?.configurePubRootDirectories();
    _cache[cacheKey] = scope;
    return scope;
  }

  static FocusPackageScope? _resolveUncached({
    required String? testFilePath,
    String? focusPackageOverride,
  }) {
    if (focusPackageOverride != null && testFilePath == null) {
      final root = _findPackageRootByName(focusPackageOverride);
      if (root != null) {
        return FocusPackageScope(
          packageName: focusPackageOverride,
          packageRoot: root,
        );
      }
    }

    if (testFilePath == null) {
      return null;
    }

    final normalized = testFilePath.replaceAll('\\', '/');
    final packagesMatch =
        RegExp(r'packages/([^/]+)/test/').firstMatch(normalized);
    final appsMatch = RegExp(r'apps/([^/]+)/test/').firstMatch(normalized);

    final segment = packagesMatch != null
        ? 'packages/${packagesMatch.group(1)}'
        : appsMatch != null
            ? 'apps/${appsMatch.group(1)}'
            : null;

    if (segment == null) {
      return null;
    }

    final packageRoot = _findPackageRootFromTestPath(normalized, segment);
    if (packageRoot == null) {
      return null;
    }

    final packageName =
        focusPackageOverride ?? _readPubspecName(packageRoot);
    if (packageName == null) {
      return null;
    }

    return FocusPackageScope(
      packageName: packageName,
      packageRoot: packageRoot,
    );
  }

  static String? _findPackageRootFromTestPath(
    String testFilePath,
    String packageSegment,
  ) {
    final index = testFilePath.indexOf('$packageSegment/');
    if (index == -1) {
      return null;
    }
    return testFilePath.substring(0, index + packageSegment.length);
  }

  static String? _findPackageRootByName(String packageName) {
    var dir = Directory.current;
    while (true) {
      final cwd = dir.path.replaceAll('\\', '/');
      for (final sub in ['packages', 'apps']) {
        final candidate = '$cwd/$sub/$packageName';
        if (_hasPubspec(candidate)) {
          final name = _readPubspecName(candidate);
          if (name == packageName) {
            return candidate;
          }
        }
      }
      if (_hasPubspec(cwd)) {
        final name = _readPubspecName(cwd);
        if (name == packageName) {
          return cwd;
        }
      }
      final parent = dir.parent;
      if (parent.path == dir.path) {
        break;
      }
      dir = parent;
    }
    return null;
  }

  static bool _hasPubspec(String dir) {
    return File('$dir/pubspec.yaml').existsSync();
  }

  static String? _readPubspecName(String packageRoot) {
    final pubspecFile = File('$packageRoot/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      return null;
    }
    final content = pubspecFile.readAsStringSync();
    final nameMatch = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(
      content,
    );
    return nameMatch?.group(1);
  }
}

/// Returns the file path of the currently running test, when available.
String? currentTestFilePath() {
  final invoker = Invoker.current;
  if (invoker == null) {
    return null;
  }

  final test = invoker.liveTest.test;
  if (test is LocalTest && test.location != null) {
    final uri = test.location!.uri;
    if (uri.scheme == 'file') {
      return uri.toFilePath();
    }
    return uri.path;
  }

  final suitePath = invoker.liveTest.suite.path;
  if (suitePath != null && suitePath.isNotEmpty) {
    return suitePath;
  }

  final trace = test.trace;
  if (trace != null) {
    return _testFilePathFromTrace(trace);
  }

  return null;
}

String? _testFilePathFromTrace(Trace trace) {
  final pattern = RegExp(
    r'(?:file://)?([^\s\)]+/(?:packages|apps)/[^/\s\)]+/test/[^\s\)]+_test\.dart)',
  );
  for (final frame in trace.frames) {
    final uri = frame.uri;
    final path = uri.scheme == 'file' ? uri.toFilePath() : uri.path;
    if (pattern.hasMatch(path)) {
      return path;
    }
  }
  return null;
}

/// Clears cached focus package scopes (for tests).
void clearFocusPackageScopeCache() {
  FocusPackageScope._cache.clear();
}
