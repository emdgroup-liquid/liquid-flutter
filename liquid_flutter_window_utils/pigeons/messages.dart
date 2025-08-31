import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/messages.g.dart',
    dartOptions: DartOptions(),
    swiftOut: 'macos/Classes/Messages.swift',
    swiftOptions: SwiftOptions(),
  ),
)
@HostApi()
abstract class WindowUtilsApi {
  bool setWindowSize(int width, int height);
  void setWindowTitle(String title);
  bool setWindowPosition(int x, int y);
  void startDragging();
  void configureWindow();
}
