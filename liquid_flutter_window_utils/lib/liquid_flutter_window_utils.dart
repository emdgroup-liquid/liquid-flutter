import 'package:flutter/foundation.dart';
import 'package:liquid_flutter_window_utils/messages.g.dart';

/// An implementation of [LiquidFlutterWindowUtilsPlatform] that uses Pigeon.
class LiquidFlutterWindowUtils {
  late final WindowUtilsApi? _api;

  static final LiquidFlutterWindowUtils _instance =
      LiquidFlutterWindowUtils._();

  LiquidFlutterWindowUtils._() {
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      _api = WindowUtilsApi();
    } else {
      _api = null;
    }
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
}
