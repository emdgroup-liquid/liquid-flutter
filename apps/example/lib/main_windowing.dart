import 'package:flutter/widgets.dart';
import 'package:liquid/main.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_window_utils/screen_radius_defaults.dart';

/// Windowed entry point for the example app.
///
/// Run it after enabling the experimental Flutter windowing flag:
///
/// ```sh
/// flutter config --enable-windowing
/// flutter run -d macos -t lib/main_windowing.dart
/// ```
///
/// On mobile, web, or when the flag is off, [LdWindowRoot] falls back to the
/// implicit view, so the same entry point still works everywhere.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final screenRadius = await getScreenRadius();

  runWidget(
    LdWindowRoot(
      title: 'Liquid Design Demo',
      size: const Size(1280, 900),
      constraints: const BoxConstraints(minWidth: 900, minHeight: 600),
      child: LiquidExample(screenRadius: screenRadius),
    ),
  );
}
