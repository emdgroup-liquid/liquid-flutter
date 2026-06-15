import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter_window_utils/messages.g.dart';

/// An implementation of [LiquidFlutterWindowUtilsPlatform] that uses Pigeon.
class LiquidFlutterWindowUtils implements WindowStateEventApi {
  late final WindowUtilsApi? _api;

  static final LiquidFlutterWindowUtils _instance =
      LiquidFlutterWindowUtils._();

  LiquidFlutterWindowUtils._() {
    if (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      _api = WindowUtilsApi();
      if (defaultTargetPlatform == TargetPlatform.macOS) {
        _setupFlutterApi();
      }
    } else {
      _api = null;
    }
  }

  void _setupFlutterApi() {
    // Set up the FlutterApi to receive window state changes from Swift
    WindowStateEventApi.setup(
      this,
      binaryMessenger: ServicesBinding.instance.defaultBinaryMessenger,
    );
  }

  static LiquidFlutterWindowUtils get instance => _instance;

  Future<bool> setWindowSize(int width, int height) async {
    return await _api?.setWindowSize(width, height) ?? false;
  }

  Future<void> setWindowTitle(String title) async {
    return await _api?.setWindowTitle(title);
  }

  Future<bool> setWindowPosition(int x, int y) async {
    return await _api?.setWindowPosition(x, y) ?? false;
  }

  Future<void> startDragging() async {
    return await _api?.startDragging();
  }

  Future<void> configureWindow() async {
    return await _api?.configureWindow();
  }

  Future<void> closeWindow() async {
    return await _api?.closeWindow();
  }

  Future<void> minimizeWindow() async {
    return await _api?.minimizeWindow();
  }

  Future<void> maximizeWindow() async {
    return await _api?.maximizeWindow();
  }

  Future<bool> isWindowMaximized() async {
    return await _api?.isWindowMaximized() ?? false;
  }

  Future<WindowState> getWindowState() async {
    return await _api?.getWindowState() ??
        WindowState(
          x: 0,
          y: 0,
          width: 0,
          height: 0,
          isMaximized: false,
          isMinimized: false,
        );
  }

  Future<double> getScreenRadius() async {
    return await _api?.getScreenRadius() ?? 0.0;
  }

  Future<void> setSystemGestureExclusionRects(List<Rect> rects) async {
    if (_api != null && defaultTargetPlatform == TargetPlatform.android) {
      return await _api.setSystemGestureExclusionRects(rects);
    }
  }

  /// Stream of window state changes. Emits the current state when first listened to.
  Stream<WindowState> get windowStateStream {
    return _windowStateController.stream;
  }

  /// Whether the window is maximized. Emits the current state when first listened to.
  Stream<bool> get windowMaximizedStream {
    return windowStateStream.map((state) => state.isMaximized);
  }

  late final StreamController<WindowState> _windowStateController =
      StreamController<WindowState>.broadcast(
    onListen: () async {
      _windowStateController.add(await getWindowState());
    },
  );

  // MARK: - WindowStateEventApi Implementation

  @override
  void onWindowStateChanged(WindowState state) {
    _windowStateController.add(state);
  }

  @override
  void onWindowReady() {
    _windowReadyController.add(true);
  }

  /// Stream for window ready events
  Stream<bool> get windowReadyStream {
    return _windowReadyController.stream;
  }

  static final StreamController<bool> _windowReadyController =
      StreamController<bool>.broadcast();
}
