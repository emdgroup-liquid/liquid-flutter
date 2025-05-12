import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdAvatar Golden", (WidgetTester tester) async {
    await multiGolden(
      tester,
      "LdAvatar",
      {
        'default': (tester, place) async {
          await place(const LdAvatar(
            child: Text('A'),
          ));
          return null;
        },
        'with_icon': (tester, place) async {
          await place(const LdAvatar(
            child: Icon(LucideIcons.user),
          ));
          return null;
        },
        'with_custom_color': (tester, place) async {
          await place(const LdAvatar(
            color: shadRed,
            child: Text('E'),
          ));
          return null;
        },
      },
    );
  });
}
