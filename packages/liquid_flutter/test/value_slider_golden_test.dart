import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

void main() {
  testGoldens("LdSlider Golden", (WidgetTester tester) async {
    await multiGolden(
      tester,
      "LdSlider",
      {
        // ---- Single mode at each size ----
        "Single XS": (tester, place) async {
          await place(
            SizedBox(
              width: 300,
              child: LdSlider(
                value: 0.5,
                size: LdSize.xs,
                min: 0.0,
                max: 100.0,
                onChanged: (_) {},
              ),
            ),
          );
        },
        "Single S": (tester, place) async {
          await place(
            SizedBox(
              width: 300,
              child: LdSlider(
                value: 0.5,
                size: LdSize.s,
                min: 0.0,
                max: 100.0,
                onChanged: (_) {},
              ),
            ),
          );
        },
        "Single M": (tester, place) async {
          await place(
            SizedBox(
              width: 300,
              child: LdSlider(
                value: 50.0,
                size: LdSize.m,
                min: 0.0,
                max: 100.0,
                onChanged: (_) {},
              ),
            ),
          );
        },
        "Single L": (tester, place) async {
          await place(
            SizedBox(
              width: 300,
              child: LdSlider(
                value: 50.0,
                size: LdSize.l,
                min: 0.0,
                max: 100.0,
                onChanged: (_) {},
              ),
            ),
          );
        },

        // ---- Range mid-range ----
        "Range Mid": (tester, place) async {
          await place(
            SizedBox(
              width: 300,
              child: LdSlider.range(
                lowValue: 25.0,
                highValue: 75.0,
                min: 0.0,
                max: 100.0,
                onRangeChanged: (_, __) {},
              ),
            ),
          );
        },

        // ---- Disabled single ----
        "Disabled Single": (tester, place) async {
          await place(
            SizedBox(
              width: 300,
              child: LdSlider(
                value: 50.0,
                min: 0.0,
                max: 100.0,
                disabled: true,
                onChanged: (_) {},
              ),
            ),
          );
        },

        // ---- Disabled range ----
        "Disabled Range": (tester, place) async {
          await place(
            SizedBox(
              width: 300,
              child: LdSlider.range(
                lowValue: 25.0,
                highValue: 75.0,
                min: 0.0,
                max: 100.0,
                disabled: true,
                onRangeChanged: (_, __) {},
              ),
            ),
          );
        },

        // ---- Vertical orientation ----
        "Vertical": (tester, place) async {
          await place(
            SizedBox(
              width: 60,
              height: 200,
              child: LdSlider(
                value: 50.0,
                min: 0.0,
                max: 100.0,
                direction: Axis.vertical,
                onChanged: (_) {},
              ),
            ),
          );
        },

        // ---- Custom color (error) ----
        "Custom Error Color": (tester, place) async {
          await place(
            Builder(
              builder: (context) => SizedBox(
                width: 300,
                child: LdSlider(
                  value: 50.0,
                  min: 0.0,
                  max: 100.0,
                  color: LdTheme.of(context).palette.error,
                  onChanged: (_) {},
                ),
              ),
            ),
          );
        },
      },
      frameScenarios: const [LdFrameOptions(width: 400)],
      // Test all sizes and both light/dark themes
      themeSizeScenarios: LdThemeSize.values,
      brightnessScenarios: Brightness.values,
    );
  });
}
