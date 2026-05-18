import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

void main() {
  testGoldens(
    "LdAvatar Golden",
    (WidgetTester tester) async {
      await multiGolden(tester, "LdAvatar", {
        'default': (tester, place) async {
          await place(Center(
            child: const LdAvatar(
              child: Text('A'),
            ),
          ));
        },
        'with_icon': (tester, place) async {
          await place(Center(
            child: const LdAvatar(
              child: Icon(LucideIcons.user),
            ),
          ));
        },
        'with_custom_color': (tester, place) async {
          await place(Center(
            child: const LdAvatar(
              color: shadRed,
              child: Text('E'),
            ),
          ));
        },
      });
    },
  );
}
