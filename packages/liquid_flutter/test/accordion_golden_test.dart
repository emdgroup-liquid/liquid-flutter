import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart' hide loadAppFonts;
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

void main() {
  testGoldens("LdAccordion looks correct", (tester) async {
    await multiGolden(tester, "LdAccordion", {
      "Collapsed": (tester, place) async {
        await place(LdAccordion(
          childBuilder: (context, n) {
            return SizedBox(height: 50, child: LdText.p("Test $n"));
          },
          itemCount: 2,
          initialOpenIndex: const {},
          headerBuilder: (context, n) {
            return Text("Header $n");
          },
        ));
      },
      "Initially Open": (tester, place) async {
        await place(
          LdAccordion(
            childBuilder: (context, n) {
              return SizedBox(height: 50, child: LdText.p("Test $n"));
            },
            itemCount: 2,
            initialOpenIndex: const {0},
            headerBuilder: (context, n) {
              return Text("Header $n");
            },
          ),
        );
      },
      "Elevated": (tester, place) async {
        await place(
          LdAccordion(
            childBuilder: (context, n) {
              return SizedBox(height: 50, child: LdText.p("Test $n"));
            },
            itemCount: 2,
            wrapActiveInCard: true,
            initialOpenIndex: const {0},
            headerBuilder: (context, n) {
              return Text("Header $n");
            },
          ),
        );
      },
      "Double open": (tester, place) async {
        await place(LdAccordion(
          childBuilder: (context, n) {
            return SizedBox(height: 50, child: LdText.p("Test $n"));
          },
          itemCount: 2,
          wrapActiveInCard: true,
          initialOpenIndex: const {0, 1},
          headerBuilder: (context, n) {
            return Text("Header $n");
          },
        ));
      },
    });
  });
}
