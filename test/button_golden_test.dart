import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("Button Golden", (WidgetTester tester) async {
    ldDisableAnimations = true;
    await multiGolden(tester, "LdButton", {
      "LdButton": (tester, place) async {
        await place(LdButton(
          child: const Text("Hello"),
          onPressed: () {},
        ));
        return null;
      },
      "LdButtonOutline": (tester, place) async {
        await place(LdButtonOutline(
          child: const Text("Hello"),
          onPressed: () {},
        ));
        return null;
      },
      "LdButtonGhost": (tester, place) async {
        await place(LdButtonGhost(
          child: const Text("Hello"),
          onPressed: () {},
        ));
        return null;
      },
      "LdButton loading": (tester, place) async {
        await place(LdButton(
          child: const Text("Hello"),
          loading: true,
          onPressed: () {},
        ));
        return null;
      },
      "LdButton fullwidth": (tester, place) async {
        await place(LdButton(
          child: const Text("Hello"),
          width: double.infinity,
          onPressed: () {},
        ));
        return null;
      },
      "LdButton disabled": (tester, place) async {
        await place(LdButton(
          child: const Text("Hello"),
          disabled: true,
          onPressed: () {},
        ));
        return null;
      },
      "LdButton active": (tester, place) async {
        await place(LdButton(
          child: const Text("Hello"),
          active: true,
          onPressed: () {},
        ));
        return null;
      },
    });
  });
}
