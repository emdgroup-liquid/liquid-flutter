import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'golden_utils.dart';

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

  Widget _buildBasicExceptionView({
    required LdLocalizedException? exception,
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
          _buildBasicExceptionView(
            exception: sampleErrorException,
          ),
        );
        await tester.pumpAndSettle();
        return null;
      },
      "Warning Vertical": (tester, place) async {
        await place(
          _buildBasicExceptionView(
            exception: sampleWarningException,
          ),
        );
        await tester.pumpAndSettle();
        return null;
      },
      "Success Vertical": (tester, place) async {
        await place(
          _buildBasicExceptionView(
            exception: sampleSuccessException,
          ),
        );
        await tester.pumpAndSettle();
        return null;
      },
      "Error Horizontal": (tester, place) async {
        await place(
          _buildBasicExceptionView(
            exception: sampleErrorException,
            direction: Axis.horizontal,
          ),
        );
        await tester.pumpAndSettle();
        return null;
      },
      "With RetryController": (tester, place) async {
        final retryController = LdRetryController(
          onRetry: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          config: LdRetryConfig.unlimitedManualRetries(),
        );

        await place(
          _buildBasicExceptionView(
            exception: sampleErrorException,
            retryController: retryController,
          ),
        );
        await tester.pumpAndSettle();
        return null;
      },
      "Null Exception": (tester, place) async {
        await place(
          _buildBasicExceptionView(
            exception: null,
            retry: () {},
          ),
        );
        await tester.pumpAndSettle();
        return null;
      },
    });
  });
}

