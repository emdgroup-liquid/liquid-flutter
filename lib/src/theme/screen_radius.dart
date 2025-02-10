import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

Future<double> getScreenRadius() async {
  if (kIsWeb) {
    return 0.0;
  }

  if (Platform.isMacOS) {
    return 12;
  }

  if (Platform.isIOS) {
    // Switch device type
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final iosInfo = await deviceInfoPlugin.iosInfo;
    final deviceType = iosInfo.utsname.machine;

    if (iosRadiusMap.containsKey(deviceType)) {
      return iosRadiusMap[deviceType]!;
    }
  }

  return 0.0;
}

final iosRadiusMap = {
  "iPhone11,2": 39.0,
  "iPhone11,4": 39.0,
  "iPhone11,8": 41.5,
  "iPhone12,1": 41.5,
  "iPhone12,3": 39.0,
  "iPhone12,5": 39.0,
  "iPhone12,8": 0.0,
  "iPhone13,1": 44.0,
  "iPhone13,2": 47.33000183105469,
  "iPhone13,3": 47.33000183105469,
  "iPhone13,4": 53.33000183105469,
  "iPhone14,2": 47.33000183105469,
  "iPhone14,3": 53.33000183105469,
  "iPhone14,4": 44.0,
  "iPhone14,5": 47.33000183105469,
  "iPhone14,6": 0.0,
  "iPhone14,7": 47.33000183105469,
  "iPhone14,8": 53.33000183105469,
  "iPhone15,2": 55.0,
  "iPhone15,3": 55.0,
  "iPhone15,4": 55.0,
  "iPhone15,5": 55.0,
  "iPhone16,1": 55.0,
  "iPhone16,2": 55.0,
  "iPhone17,1": 62.0,
  "iPhone17,2": 62.0,
  "iPhone17,3": 55.0,
  "iPhone17,4": 55.0,
  "iPad7,12": 0.0,
  "iPad8,1": 18.0,
  "iPad8,5": 18.0,
  "iPad8,9": 18.0,
  "iPad8,12": 18.0,
  "iPad11,1": 0.0,
  "iPad11,3": 0.0,
  "iPad11,7": 0.0,
  "iPad12,2": 0.0,
  "iPad13,2": 18.0,
  "iPad13,5": 18.0,
  "iPad13,10": 18.0,
  "iPad13,17": 18.0,
  "iPad13,18": 25.0,
  "iPad14,1": 21.5,
  "iPad14,3": 18.0,
  "iPad14,4": 18.0,
  "iPad14,5": 18.0,
  "iPad14,9": 18.0,
  "iPad14,11": 18.0,
  "iPad16,2": 21.5,
  "iPad16,4": 30.0,
  "iPad16,6": 30.0,
};
