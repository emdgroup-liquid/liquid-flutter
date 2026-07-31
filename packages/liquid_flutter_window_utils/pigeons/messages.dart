import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/messages.g.dart',
    dartOptions: DartOptions(),
    swiftOut:
        'macos/liquid_flutter_window_utils/Sources/liquid_flutter_window_utils/Messages.swift',
    swiftOptions: SwiftOptions(),
    kotlinOut:
        'android/src/main/kotlin/com/liquid/flutter/window_utils/Messages.kt',
    kotlinOptions: KotlinOptions(
      package: 'com.liquid.flutter.window_utils',
    ),
  ),
)
class WindowState {
  final int x;
  final int y;
  final int width;
  final int height;
  final bool isMaximized;
  final bool isMinimized;

  const WindowState({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.isMaximized,
    required this.isMinimized,
  });
}

class Rect {
  final int left;
  final int top;
  final int right;
  final int bottom;

  const Rect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });
}

@HostApi()
abstract class WindowUtilsApi {
  bool setWindowSize(int width, int height);
  void setWindowTitle(String title);
  bool setWindowPosition(int x, int y);
  void startDragging();
  void configureWindow();
  void closeWindow();
  void minimizeWindow();
  void maximizeWindow();
  bool isWindowMaximized();
  WindowState getWindowState();
  /// Display corner radius in logical pixels (Flutter layout units).
  ///
  /// On Android API 31+, the native [RoundedCorner] radius is divided by
  /// [displayMetrics.density] before returning.
  double getScreenRadius();
  /// Detailed corner readout for debugging. Values are in physical pixels unless
  /// noted as logical.
  String getScreenCornerRadiiDebugLog();
  void setSystemGestureExclusionRects(List<Rect> rects);
}

@FlutterApi()
abstract class WindowStateEventApi {
  void onWindowStateChanged(WindowState state);
  void onWindowReady();
}
