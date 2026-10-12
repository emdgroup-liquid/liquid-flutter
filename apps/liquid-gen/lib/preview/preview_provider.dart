import 'package:flutter/foundation.dart';

import 'package:liquid_flutter_test_utils/ld_frame_options.dart';
import 'package:liquid_flutter_test_utils/system_ui/iphone_16_pro.dart';
import 'package:liquid_flutter_test_utils/system_ui/ipad_11_pro.dart';
import 'package:liquid_flutter_test_utils/system_ui/fairphone_6.dart';

enum DeviceFrameType {
  iphone16Pro,
  ipadPro11,
  fairphone6,
}

class PreviewProvider extends ChangeNotifier {
  DeviceFrameType _selectedFrame = DeviceFrameType.iphone16Pro;
  final Set<String> _surfaceIds = {};

  DeviceFrameType get selectedFrame => _selectedFrame;
  Set<String> get surfaceIds => Set.unmodifiable(_surfaceIds);

  void setSelectedFrame(DeviceFrameType frame) {
    if (_selectedFrame != frame) {
      _selectedFrame = frame;
      notifyListeners();
    }
  }

  void setSurfaceIds(Set<String> surfaceIds) {
    _surfaceIds.clear();
    _surfaceIds.addAll(surfaceIds);
    notifyListeners();
  }

  LdFrameOptions getFrameOptions() {
    switch (_selectedFrame) {
      case DeviceFrameType.iphone16Pro:
        return iPhone16Pro;
      case DeviceFrameType.ipadPro11:
        return iPadPro11;
      case DeviceFrameType.fairphone6:
        return fairphone6;
    }
  }

  String getFrameLabel() {
    switch (_selectedFrame) {
      case DeviceFrameType.iphone16Pro:
        return 'iPhone 16 Pro';
      case DeviceFrameType.ipadPro11:
        return 'iPad Pro 11';
      case DeviceFrameType.fairphone6:
        return 'Fairphone 6';
    }
  }
}
