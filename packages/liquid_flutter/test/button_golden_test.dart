import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

void main() {
  testGoldens("Button Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdButton", {
      "LdButton": (tester, place) async {
        await place(LdButton(
          child: const Text("Hello"),
          onPressed: () {},
        ));
      },
      "LdButtonOutline": (tester, place) async {
        await place(LdButton.outline(
          child: const Text("Hello"),
          onPressed: () {},
        ));
      },
      "LdButtonGhost": (tester, place) async {
        await place(LdButton.ghost(
          child: const Text("Hello"),
          onPressed: () {},
        ));
      },
      "LdButton loading": (tester, place) async {
        await place(LdButton(
          loading: true,
          onPressed: () {},
          child: const Text("Hello"),
        ));
      },
      "LdButton fullwidth": (tester, place) async {
        await place(LdButton(
          width: double.infinity,
          onPressed: () {},
          child: const Text("Hello"),
        ));
      },
      "LdButton disabled": (tester, place) async {
        await place(LdButton(
          disabled: true,
          onPressed: () {},
          child: const Text("Hello"),
        ));
      },
      "LdButton active": (tester, place) async {
        await place(LdButton(
          active: true,
          onPressed: () {},
          child: const Text("Hello"),
        ));
      },
    });
  });
}
