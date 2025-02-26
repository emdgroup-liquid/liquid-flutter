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

  testWidgets("LdSubmit Automatic Retries", (WidgetTester tester) async {
    Completer<int> completer = Completer<int>();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [LiquidLocalizations.delegate],
        home: LdThemeProvider(
          child: LdPortal(
            child: Scaffold(
              body: Portal(
                child: LdSubmit<int>(
                  config: LdSubmitConfig(
                    action: () async {
                      return await completer.future;
                    },
                    retryConfig: const LdSubmitRetryConfig(
                      performAutomaticRetry: true,
                      maxRetryAttempts: 3,
                      initialRetryCountdown: 1000,
                    ),
                  ),
                  builder: const LdSubmitInlineBuilder<int>(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Ensure the UI is ready

    expect(find.byType(LdSubmit<int>), findsOneWidget);
    expect(find.byType(LdButton), findsOneWidget);
    expect(find.text("Submit"), findsOneWidget);

    // Trigger the action
    await tester.tap(find.text("Submit"));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text("Loading..."), findsOneWidget);

    // Simulate failure and automatic retry
    completer.completeError(Exception('Error'));
    // first retry will happen after 1 second, so we check if the "Retry in"
    // text is there after 0.5 seconds
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining("Retry in"), findsOneWidget);
    completer = Completer<int>();
    // wait a bit more until the retry happens
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text("Loading..."), findsOneWidget);

    // Second retry
    completer.completeError(Exception('Error'));
    // second retry will happen after 2 seconds, so we check if the "Retry in"
    // text is still there after 1.5 seconds
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.textContaining("Retry in"), findsOneWidget);
    completer = Completer<int>();
    // wait a bit more until the retry happens
    await tester.pump(const Duration(milliseconds: 3000));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text("Loading..."), findsOneWidget);

    // Third retry
    completer.completeError(Exception('Error'));
    // third retry will happen after 4 seconds, so we check if the "Retry in"
    // text is still there after 3 seconds
    await tester.pump(const Duration(milliseconds: 3000));
    expect(find.textContaining("Retry in"), findsOneWidget);
    completer = Completer<int>();
    // wait a bit more until the retry happens
    await tester.pump(const Duration(milliseconds: 5000));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text("Loading..."), findsOneWidget);

    // Success case
    completer.complete(42);
    await tester.pumpAndSettle();
    expect(find.text("Submit"), findsOneWidget);
  });
}
