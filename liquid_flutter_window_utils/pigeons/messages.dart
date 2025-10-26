import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/messages.g.dart',
    dartOptions: DartOptions(),
    swiftOut: 'macos/Classes/Messages.swift',
    swiftOptions: SwiftOptions(),
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
}

@FlutterApi()
abstract class WindowStateEventApi {
  void onWindowStateChanged(WindowState state);
  void onWindowReady();
}
