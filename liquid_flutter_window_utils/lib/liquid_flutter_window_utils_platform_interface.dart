import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'liquid_flutter_window_utils_method_channel.dart';

abstract class LiquidFlutterWindowUtilsPlatform extends PlatformInterface {
  /// Constructs a LiquidFlutterWindowUtilsPlatform.
  LiquidFlutterWindowUtilsPlatform() : super(token: _token);

  static final Object _token = Object();

  static LiquidFlutterWindowUtilsPlatform _instance = MethodChannelLiquidFlutterWindowUtils();

  /// The default instance of [LiquidFlutterWindowUtilsPlatform] to use.
  ///
  /// Defaults to [MethodChannelLiquidFlutterWindowUtils].
  static LiquidFlutterWindowUtilsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LiquidFlutterWindowUtilsPlatform] when
  /// they register themselves.
  static set instance(LiquidFlutterWindowUtilsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
