import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';

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
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: LdModalBuilder(
                      builder: (context, open) {
                        return Center(
                          child: LdAutoSpace(
                            children: [
                              LdButton(
                                onPressed: open,
                                child: const Text("Open dialog"),
                              ),
                            ],
                          ),
                        );
                      },
                      modal: LdModalRoute(
                        context: context,
                        pageBuilder: (context) => LdScaffold(
                          body: LdAppBar(
                            title: Text("Dialog title"),
                            child: LdScaffoldBody(children: [LdText("Dialog content")]),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        "LdModal Open": (tester, place) async {
          await place(
            SizedBox(
              height: 200,
              width: 500,
              child: Builder(
                builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: LdModalBuilder(
                        builder: (context, open) {
                          return LdAutoSpace(
                            children: [
                              LdButton(
                                onPressed: open,
                                child: const Text("Open dialog"),
                              ),
                            ],
                          );
                        },
                        modal: LdModalRoute(
                          context: context,
                          pageBuilder: (context) => LdScaffold(
                            body: LdAppBar(
                              title: Text("Dialog title"),
                              child: LdScaffoldBody(children: [LdText("Dialog content")]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      },
      frameScenarios: const [LdFrameOptions(width: 500, height: 500)],
    );
  });
}
