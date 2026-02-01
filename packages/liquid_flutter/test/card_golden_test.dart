import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

void main() {
  testGoldens("LdCard Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdCard", {
      "LdCard": (tester, place) async {
        await place(LdCard(
          header: LdText.p("Header"),
          footer: LdText.p("Footer"),
          child: LdText.p("Hello"),
        ).padL());
      },
      "LdCard on surface": (tester, place) async {
        await place(LdAutoBackground(
          child: LdCard(
            header: LdText.p("Header"),
            footer: LdText.p("Footer"),
            child: LdText.p("Hello"),
          ).padL(),
        ));
      },
    });
  });
}
