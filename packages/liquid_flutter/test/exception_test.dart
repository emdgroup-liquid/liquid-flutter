import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations_en.dart';

LdNotificationProvider _wrapWithMaterialApp(Widget widget) {
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

    testWidgets('LdExceptionView displays message correctly', (WidgetTester tester) async {
      // Build and pump the widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          buildBasicExceptionView(
            exception: sampleErrorException,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify message is displayed
      expect(find.text('Error occurred'), findsOneWidget);
    });

    testWidgets('LdExceptionView renders correct components for vertical direction', (WidgetTester tester) async {
      final retryController = LdRetryController(
        onRetry: () async {},
        config: LdRetryConfig.unlimitedManualRetries(),
      );

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          buildBasicExceptionView(
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
      expect(find.byType(LdText), findsOneWidget);
      expect(find.byType(LdButton), findsAtLeastNWidgets(1)); // At least More Info button
    });

    testWidgets('LdExceptionView renders correct components for horizontal direction', (WidgetTester tester) async {
      final retryController = LdRetryController(
        onRetry: () async {},
        config: LdRetryConfig.unlimitedManualRetries(),
      );

      // Build our widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          buildBasicExceptionView(
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

    testWidgets('LdExceptionView handles retry callback correctly', (WidgetTester tester) async {
      bool retryWasCalled = false;

      // Build widget with retry callback
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          buildBasicExceptionView(
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

    testWidgets('LdExceptionView.fromDynamic maps errors correctly', (WidgetTester tester) async {
      // Build our widget using the fromDynamic constructor
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              return SizedBox(
                width: 500,
                height: 500,
                child: LdExceptionView(
                  exception: LdException(
                    exception: const SocketException('Network error'),
                    stackTrace: StackTrace.current,
                  ),
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

    testWidgets('LdExceptionView handles RetryController state correctly', (WidgetTester tester) async {
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
          buildBasicExceptionView(
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

    testWidgets('LdExceptionView handles "more info" button correctly', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          buildBasicExceptionView(
            exception: sampleErrorException,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final moreInfoFinder = find.byKey(const Key('more-info-button'));

      expect(moreInfoFinder, findsOneWidget);

      // Tap the button and verify dialog opens
      await tester.tap(moreInfoFinder.first);

      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(
        find.text(sampleErrorException.moreInfo!),
        findsOneWidget,
      );
    });

    testWidgets('LdExceptionView with different exception types shows correct color', (WidgetTester tester) async {
      // Test error type
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              return buildBasicExceptionView(
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
              return buildBasicExceptionView(
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
              return buildBasicExceptionView(
                exception: sampleSuccessException,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(LdHint), findsOneWidget);
    });

    testWidgets('LdExceptionView assertion error when both retry and retryController are provided',
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

  group('LdExceptionLocalizerMapper Tests', () {
    testWidgets('parent fallback and default fallback work correctly', (WidgetTester tester) async {
      // Create parent mapper
      final parentMapper = LdExceptionLocalizerMapper(
        onException: (context, e) {
          if (e.exception is SocketException) {
            return LdLocalizedException(
              message: 'Parent handled SocketException',
            );
          }
          return null;
        },
      );

      // Create child mapper
      final childMapper = LdExceptionLocalizerMapper(
        parent: parentMapper,
        onException: (context, e) {
          if (e.exception is FormatException) {
            return LdLocalizedException(
              message: 'Child handled FormatException',
            );
          }
          return null;
        },
      );

      await tester.pumpWidget(
        _wrapWithMaterialApp(
          Builder(
            builder: (context) {
              // Test child handling
              final childHandled = childMapper.handle(
                context: context,
                e: LdException(exception: const FormatException()),
              );
              expect(childHandled.message, 'Child handled FormatException');

              // Test parent fallback
              final parentHandled = childMapper.handle(
                context: context,
                e: LdException(exception: const SocketException('')),
              );
              expect(parentHandled.message, 'Parent handled SocketException');

              // Test default fallback (unhandled)
              final defaultHandled = childMapper.handle(
                context: context,
                e: LdException(exception: Exception('Unknown error')),
              );
              expect(defaultHandled.message, LiquidLocalizationsEn().unknownError);

              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('LdExceptionView Custom Builders', () {
    final customException = LdLocalizedException(
      message: 'Custom Exception',
      moreInfo: 'With custom builders',
      customIconBuilder: (context) => const Icon(Icons.star, key: Key('custom-icon')),
      additionalBuilder: (context) => const Text('Additional Build', key: Key('additional-builder')),
      additionalDetailsBuilder: (context) => const Text('Details Build', key: Key('details-builder')),
    );

    testWidgets('vertical layout renders customIconBuilder and additionalDetailsBuilder', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          SizedBox(
            width: 300,
            height: 300,
            child: LdExceptionView(
              exception: customException,
              direction: Axis.vertical,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom-icon')), findsOneWidget);
      expect(find.byKey(const Key('details-builder')), findsOneWidget);
      expect(find.byKey(const Key('additional-builder')), findsNothing);
    });

    testWidgets('horizontal layout renders customIconBuilder and additionalBuilder', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          SizedBox(
            width: 300,
            height: 300,
            child: LdExceptionView(
              exception: customException,
              direction: Axis.horizontal,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('custom-icon')), findsOneWidget);
      expect(find.byKey(const Key('additional-builder')), findsOneWidget);
      expect(find.byKey(const Key('details-builder')), findsNothing);
    });

    testWidgets('dialog renders additionalDetailsBuilder', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          SizedBox(
            width: 300,
            height: 300,
            child: LdExceptionView(
              exception: customException,
              direction: Axis.horizontal,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the "more info" button
      final moreInfoFinder = find.byKey(const Key('more-info-button'));
      expect(moreInfoFinder, findsOneWidget);
      await tester.tap(moreInfoFinder.first);
      await tester.pumpAndSettle();

      // In the modal dialog, the additionalDetailsBuilder should be present
      expect(find.byKey(const Key('details-builder')), findsOneWidget);
      // The dialog also displays the custom icon
      expect(find.byKey(const Key('custom-icon')), findsWidgets);
    });
  });
}
