import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_window_utils/liquid_flutter_window_utils.dart';
import 'package:liquid_flutter_window_utils/liquid_flutter_window_utils_platform_interface.dart';
import 'package:liquid_flutter_window_utils/liquid_flutter_window_utils_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLiquidFlutterWindowUtilsPlatform
    with MockPlatformInterfaceMixin
    implements LiquidFlutterWindowUtilsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LiquidFlutterWindowUtilsPlatform initialPlatform = LiquidFlutterWindowUtilsPlatform.instance;

  test('$MethodChannelLiquidFlutterWindowUtils is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLiquidFlutterWindowUtils>());
  });

  test('getPlatformVersion', () async {
    LiquidFlutterWindowUtils liquidFlutterWindowUtilsPlugin = LiquidFlutterWindowUtils();
    MockLiquidFlutterWindowUtilsPlatform fakePlatform = MockLiquidFlutterWindowUtilsPlatform();
    LiquidFlutterWindowUtilsPlatform.instance = fakePlatform;

    expect(await liquidFlutterWindowUtilsPlugin.getPlatformVersion(), '42');
  });
}
