import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'liquid_flutter_window_utils_platform_interface.dart';

/// An implementation of [LiquidFlutterWindowUtilsPlatform] that uses method channels.
class MethodChannelLiquidFlutterWindowUtils extends LiquidFlutterWindowUtilsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('liquid_flutter_window_utils');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
