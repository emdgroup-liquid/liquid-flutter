import 'package:liquid_flutter_test_utils/widget_creation_location.dart';

/// Cached resolver for [FocusPackageScope] used during widget tree golden tests.
class WidgetTreePackageIndex {
  WidgetTreePackageIndex._();

  static final Map<String, FocusPackageScope?> _cache = {};

  /// Resolves and caches the focus package for the current or given test file.
  static FocusPackageScope? resolveForTest({
    String? testFilePath,
    String? focusPackageOverride,
  }) {
    final resolvedTestPath = testFilePath ?? currentTestFilePath();
    final cacheKey = '${resolvedTestPath ?? ''}:$focusPackageOverride';

    return _cache.putIfAbsent(cacheKey, () {
      return FocusPackageScope.resolveSync(
        testFilePath: resolvedTestPath,
        focusPackageOverride: focusPackageOverride,
      );
    });
  }

  /// Clears cached focus package scopes (for tests).
  static void clear() {
    _cache.clear();
    clearFocusPackageScopeCache();
  }
}
