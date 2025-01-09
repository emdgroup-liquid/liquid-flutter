import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

void main() {
  testGoldens("LdModal Golden", (WidgetTester tester) async {
    await multiGolden(
      tester,
      "LdModal",
      {
        "LdModal Closed": (tester, place) async {
          await place(
            SizedBox(
              height: 200,
              width: 500,
              child: Scaffold(
                body: Center(
                    child: LdModalBuilder(
                  builder: (context, open) {
                    return LdButton(
                      child: const Text("Open dialog"),
                      onPressed: open,
                    );
                  },
                  modal: LdModal(
                      title: const Text("Dialog title"),
                      modalContent: (context) {
                        return const LdText("Dialog content");
                      }),
                )),
              ),
            ),
          );
          return null;
        },
        "LdModal Open": (tester, place) async {
          await place(
            SizedBox(
              height: 200,
              width: 500,
              child: Scaffold(
                body: Center(
                    child: LdModalBuilder(
                  builder: (context, open) {
                    return LdButton(
                      child: const Text("Open dialog"),
                      onPressed: open,
                    );
                  },
                  modal: LdModal(
                      title: const Text("Dialog title"),
                      modalContent: (context) {
                        return const LdText("Dialog content");
                      }),
                )),
              ),
            ),
          );

          await tester.tap(find.text("Open dialog"));

          await tester.pumpAndSettle();

          return null;
        },
      },
      height: 500,
    );
  });
}
