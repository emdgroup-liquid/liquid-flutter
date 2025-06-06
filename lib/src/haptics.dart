import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:haptic_feedback/haptic_feedback.dart';

class LdHaptics {
  static Future<void> vibrate(HapticsType type) async {
    if (kIsWeb) {
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await Haptics.vibrate(type);
      return;
    }
  }
}
