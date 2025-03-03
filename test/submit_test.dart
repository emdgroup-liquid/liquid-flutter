import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations_en.dart';

void main() {
  test('LdSubmitController', () async {
    var completer = Completer<int>();

    final controller = LdSubmitController<int>(
      exceptionMapper: LdExceptionMapper(
        localizations: LiquidLocalizationsEn(),
      ),
      config: LdSubmitConfig(
        action: () async {
          return await completer.future;
        },
      ),
    );

    expect(controller.state.type, LdSubmitStateType.idle);

    // Trigger the action

    controller.trigger();

    expect(controller.state.type, LdSubmitStateType.loading);

    // Complete the action

    completer.complete(42);

    await Future.delayed(Duration.zero);

    expect(controller.state.type, LdSubmitStateType.result);

    expect(controller.state.result, 42);

    // Reset the controller

    controller.reset();
    completer = Completer<int>();

    expect(controller.state.type, LdSubmitStateType.idle);

    // Trigger the action again
    controller.trigger().onError((error, stackTrace) {});

    expect(controller.state.type, LdSubmitStateType.loading);

    // Complete the action with an error

    completer.completeError(Exception('Error'));

    await Future.delayed(Duration.zero);

    expect(controller.state.type, LdSubmitStateType.error);

    expect(controller.state.error, isA<LdException>());
  });

  testWidgets("LdSubmit Inline", (WidgetTester tester) async {
    Completer<int> completer = Completer<int>();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [LiquidLocalizations.delegate],
        home: LdThemeProvider(
          child: LdSubmit<int>(
            config: LdSubmitConfig(action: () async {
              return await completer.future;
            }),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LdSubmit<int>), findsOneWidget);
    expect(find.byType(LdButton), findsOneWidget);
    expect(find.text("Submit"), findsOneWidget);

    // Trigger the action

    await tester.tap(find.text("Submit"));

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    expect(find.text("Loading..."), findsOneWidget);

    // Complete the action
    completer.complete(12);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text("Submit"), findsOneWidget);
  });

  testWidgets("LdSubmit Dialog", (WidgetTester tester) async {
    Completer<int> completer = Completer<int>();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [LiquidLocalizations.delegate],
        home: LdThemeProvider(
          child: LdPortal(
            child: Scaffold(
              body: Portal(
                child: LdSubmit<int>(
                  config: LdSubmitConfig(action: () async {
                    return await completer.future;
                  }),
                  builder: LdSubmitDialogBuilder<int>(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LdSubmit<int>), findsOneWidget);
    expect(find.byType(LdButton), findsOneWidget);
    expect(find.text("Submit"), findsOneWidget);

    // Trigger the action

    await tester.tap(find.text("Submit"));

    await tester.pump();

    expect(find.byType(LdLoader), findsOneWidget);

    expect(find.text("Loading..."), findsNWidgets(2));

    // Complete the action
    completer.complete(12);

    await tester.pumpAndSettle();

    expect(find.byType(LdLoader), findsNothing);
    expect(find.text("Submit"), findsOneWidget);
  });

  testWidgets("LdSubmit with custom exception mapper",
      (WidgetTester tester) async {
    final customMapper = LdExceptionMapper(
      localizations: LiquidLocalizationsEn(),
      onException: (e, {stackTrace}) {
        return LdException(
          message: "Custom exception",
          type: LdHintType.error,
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [LiquidLocalizations.delegate],
        home: LdThemeProvider(
          child: LdPortal(
            child: Scaffold(
              body: LdExceptionMapperProvider(
                exceptionMapper: customMapper,
                child: LdSubmit<int>(
                  config: LdSubmitConfig(action: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    throw TimeoutException('Timeout');
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.byType(LdSubmit<int>), findsOneWidget);
    expect(find.byType(LdButton), findsOneWidget);

    // Trigger action that will fail
    await tester.tap(find.byType(LdButton));
    await tester.pump();

    // Verify loading state
    expect(find.text("Loading..."), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));

    // Verify error state
    expect(find.text("Custom exception"), findsOneWidget);
    expect(
      find.byType(LdButton),
      findsNWidgets(2),
    ); // Retry + More Info buttons
  });

  testWidgets("LdSubmit with retry config", (WidgetTester tester) async {
    int calls = 0;

    final controller = LdSubmitController(
      exceptionMapper: LdExceptionMapper(
        localizations: LiquidLocalizationsEn(),
      ),
      config: LdSubmitConfig(
        action: () async {
          calls++;

          await Future.delayed(const Duration(milliseconds: 100));

          throw Exception('Intentional error');
        },
        retryConfig: LdSubmitRetryConfig(
          performAutomaticRetry: true,
          maxAttempts: 2,
          initialRetryCountdown: const Duration(milliseconds: 100),
          disableRetryButton: true,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [LiquidLocalizations.delegate],
        home: LdThemeProvider(
          child: LdPortal(
            child: Scaffold(
              body: LdSubmit<int>(
                controller: controller,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.byType(LdSubmit<int>), findsOneWidget);
    expect(find.byType(LdButton), findsOneWidget);

    // Trigger action that will fail
    await tester.tap(find.byType(LdButton));

    expect(calls, 1);

    await tester.pump();

    // Verify loading state
    expect(find.text("Loading..."), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));

    // Complete with error

    await tester.pump();

    final retryButton = find.byKey(const Key('retry-button'));

    // Because we pass [disableRetryButton] to true, the retry button
    // should not be shown

    expect(retryButton, findsNothing);

    expect(find.byType(LdExceptionRetryIndicator), findsOneWidget);

    // Wait for retry countdown (can be up to 2 seconds because of jitter)

    await tester.pump(controller.totalRetryTime);

    await tester.pump();

    expect(calls, 2);

    // Verify automatic retry is triggered
    expect(find.text("Loading..."), findsOneWidget);

    await tester.pumpAndSettle();

    // Verify retry button is disabled again
    expect(retryButton, findsNothing);

    // There should now be no retry indicator, because we exceeded the max attempts
    expect(find.byType(LdExceptionRetryIndicator), findsNothing);
  });
}
