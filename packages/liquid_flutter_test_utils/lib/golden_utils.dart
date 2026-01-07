import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter_test_utils/gen/fonts.gen.dart';
import 'package:liquid_flutter_test_utils/local_file_comparator_with_threshold.dart';

/// The localizations delegates to be used in golden tests.
List<LocalizationsDelegate> ldGoldenLocalizationsDelegates = [];

/// Setup the golden test environment.
Future<void> setupGoldenTest({
  /// The localizations delegates to be used in golden tests.
  List<LocalizationsDelegate> localizationsDelegates = const [],

  /// The threshold for the golden file comparator.
  /// Must be between 0 and 1.
  double fileComparatorThreshold = 0.05, // gracefully accept 5% difference
}) async {
  assert(fileComparatorThreshold >= 0 && fileComparatorThreshold <= 1);

  ldGoldenLocalizationsDelegates = [
    ...localizationsDelegates,
  ];

  // Ensure the binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Setup the golden file comparator
  const directory = 'test/goldens';
  goldenFileComparator = LocalFileComparatorWithThreshold(
      Uri.directory(directory), fileComparatorThreshold);

  // Load the fonts
  await loadAppFonts();
  final fonts = <String, String>{
    FontFamily.lato: 'packages/liquid_flutter/fonts/Lato-Regular.ttf',
  };
  for (final entry in fonts.entries) {
    final fontLoader = FontLoader(entry.key)
      ..addFont(rootBundle.load(entry.value));
    await fontLoader.load();
  }
}
