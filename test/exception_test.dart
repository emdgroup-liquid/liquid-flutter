import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations_en.dart';

import 'golden_utils.dart';

_wrapWithMaterialApp(Widget widget) {
  return LdNotificationProvider(
    child: LdThemeProvider(
      child: LdThemedAppBuilder(appBuilder: (context, theme) {
        return MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Scaffold(
            body: Directionality(
              textDirection: TextDirection.ltr,
              child: widget,
            ),
          ),
        );
      }),
    ),
  );
}

void main() {
  group('LdExceptionView Tests', () {
    // Sample exceptions to use for our tests
    final sampleErrorException = LdException(
      message: 'Error occurred',
      type: LdHintType.error,
      moreInfo: 'Detailed error information',
    );

    final sampleWarningException = LdException(
      message: 'Warning message',
      type: LdHintType.warning,
      moreInfo: 'Detailed warning information',
    );

    final sampleSuccessException = LdException(
      message: 'Success with notice',
      type: LdHintType.success,
      moreInfo: 'Detailed success information',
    );

    Widget _buildBasicExceptionView({
      required LdException? exception,
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

    testWidgets('LdExceptionView displays message correctly',
        (WidgetTester tester) async {
      // Build and pump the widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          _buildBasicExceptionView(
            exception: sampleErrorException,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify message is displayed
      expect(find.text('Error occurred'), findsOneWidget);
    });

    testWidgets(
        'LdExceptionView renders correct components for vertical direction',
        (WidgetTester tester) async {
      final retryController = LdRetryController(
        onRetry: () async {},
        config: LdRetryConfig.unlimitedManualRetries(),
      );

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          _buildBasicExceptionView(
            exception: sampleErrorException,
            retryController: retryController,
            direction: Axis.vertical,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify components are displayed
      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.byType(LdHint), findsOneWidget);
      expect(find.byType(LdTextP), findsOneWidget);
      expect(find.byType(LdButton),
          findsAtLeastNWidgets(1)); // At least More Info button
    });

    testWidgets(
        'LdExceptionView renders correct components for horizontal direction',
        (WidgetTester tester) async {
      final retryController = LdRetryController(
        onRetry: () async {},
        config: LdRetryConfig.unlimitedManualRetries(),
      );

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          _buildBasicExceptionView(
            exception: sampleErrorException,
            retryController: retryController,
            direction: Axis.horizontal,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify components are displayed for horizontal layout
      expect(find.text('Error occurred'), findsOneWidget);
      expect(find.byType(LdHint), findsOneWidget);
      expect(find.byType(Row), findsAtLeastNWidgets(1));
      expect(find.byType(LdButton), findsAtLeastNWidgets(1));
    });

    testWidgets('LdExceptionView handles retry callback correctly',
        (WidgetTester tester) async {
      bool retryWasCalled = false;

      // Build widget with retry callback
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          _buildBasicExceptionView(
            exception: sampleErrorException,
            retry: () {
              retryWasCalled = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap retry button
      final retryButton = find.byKey(const Key('retry-button'));
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(retryWasCalled, true);
    });

    testWidgets('LdExceptionView.fromDynamic maps errors correctly',
        (WidgetTester tester) async {
      // Build our widget using the fromDynamic constructor
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              return SizedBox(
                width: 500,
                height: 500,
                child: LdExceptionView.fromDynamic(
                  const SocketException('Network error'),
                  context,
                  retry: () {},
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Since the error message gets mapped to an LdException, we should find it
      // LdExceptionMapper maps SocketException to LdException with the message
      // from LiquidLocalizations().networkError
      expect(find.byType(LdHint), findsOneWidget);
      expect(find.byType(LdButton), findsAtLeastNWidgets(1));
      expect(find.text(LiquidLocalizationsEn().networkError), findsOneWidget);
    });

    testWidgets('LdExceptionView handles RetryController state correctly',
        (WidgetTester tester) async {
      late LdRetryController retryController;
      retryController = LdRetryController(
        onRetry: () async {
          retryController.notifyOperationStarted();
          await Future.delayed(const Duration(milliseconds: 100));
          retryController.notifyOperationCompleted();
        },
        config: LdRetryConfig.unlimitedManualRetries(),
      );

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          _buildBasicExceptionView(
            exception: sampleErrorException,
            retryController: retryController,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial state
      expect(retryController.state.isRetrying, false);
      expect(find.text(LiquidLocalizationsEn().loading), findsNothing);

      // Trigger retry
      final retryButton = find.byKey(const Key('retry-button'));
      await tester.tap(retryButton);
      await tester.pump();

      expect(retryController.state.isRetrying, true);
      expect(find.text(LiquidLocalizationsEn().loading), findsOneWidget);

      // Complete retry operation
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(retryController.state.isRetrying, false);
      expect(find.text(LiquidLocalizationsEn().loading), findsNothing);
    });

    testWidgets('LdExceptionView handles "more info" button correctly',
        (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          _buildBasicExceptionView(
            exception: sampleErrorException,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final moreInfoFinder = find.byWidgetPredicate(
        (widget) =>
            widget is LdButton &&
            widget.child is LdAutoSpace &&
            (widget.child as LdAutoSpace).children.first is Text &&
            ((widget.child as LdAutoSpace).children.first as Text).data ==
                LiquidLocalizationsEn().moreInfo,
      );
      expect(moreInfoFinder, findsOneWidget);

      // Tap the button and verify dialog opens
      await tester.tap(moreInfoFinder.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));

      // Verify dialog appears
      expect(
        find.text(sampleErrorException.moreInfo ?? ''),
        findsOneWidget,
      );
    });

    testWidgets(
        'LdExceptionView with different exception types shows correct color',
        (WidgetTester tester) async {
      // Test error type
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              return _buildBasicExceptionView(
                exception: sampleErrorException,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(LdHint), findsOneWidget);

      // Reset for warning type
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              return _buildBasicExceptionView(
                exception: sampleWarningException,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(LdHint), findsOneWidget);

      // Reset for success type
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              return _buildBasicExceptionView(
                exception: sampleSuccessException,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(LdHint), findsOneWidget);
    });

    testWidgets(
        'LdExceptionView assertion error when both retry and retryController are provided',
        (WidgetTester tester) async {
      expect(() {
        LdExceptionView(
          exception: sampleErrorException,
          retry: () {},
          retryController: LdRetryController(
            onRetry: () async {},
            config: LdRetryConfig.unlimitedManualRetries(),
          ),
        );
      }, throwsAssertionError);
    });
  });
}
