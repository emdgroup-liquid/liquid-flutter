import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';

void main() {
  // Sample exceptions to use for our tests
  final sampleErrorException = LdLocalizedException(
    message: 'Error occurred',
    type: LdHintType.error,
    moreInfo: 'Detailed error information',
  );

  final sampleWarningException = LdLocalizedException(
    message: 'Warning message',
    type: LdHintType.warning,
    moreInfo: 'Detailed warning information',
  );

  final sampleSuccessException = LdLocalizedException(
    message: 'Success with notice',
    type: LdHintType.success,
    moreInfo: 'Detailed success information',
  );

  Widget buildBasicExceptionView({
    required LdLocalizedException exception,
    LdRetryController? retryController,
    VoidCallback? retry,
    Axis direction = Axis.vertical,
  }) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Center(
        child: LdExceptionView(
          exception: exception,
          retryController: retryController,
          retry: retry,
          direction: direction,
        ),
      ),
    );
  }

  // Golden test
  testGoldens("LdExceptionView Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdExceptionView", {
      "Error Vertical": (tester, place) async {
        await place(
          buildBasicExceptionView(
            exception: sampleErrorException,
          ),
        );
        await tester.pumpAndSettle();
      },
      "Warning Vertical": (tester, place) async {
        await place(
          buildBasicExceptionView(
            exception: sampleWarningException,
          ),
        );
        await tester.pumpAndSettle();
      },
      "Success Vertical": (tester, place) async {
        await place(
          buildBasicExceptionView(
            exception: sampleSuccessException,
          ),
        );
        await tester.pumpAndSettle();
      },
      "Error Horizontal": (tester, place) async {
        await place(
          buildBasicExceptionView(
            exception: sampleErrorException,
            direction: Axis.horizontal,
          ),
        );
        await tester.pumpAndSettle();
      },
      "With RetryController": (tester, place) async {
        final retryController = LdRetryController(
          onRetry: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          config: LdRetryConfig.unlimitedManualRetries(),
        );

        await place(
          buildBasicExceptionView(
            exception: sampleErrorException,
            retryController: retryController,
          ),
        );
        await tester.pumpAndSettle();
      },
    });
  });
}
