import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/l10n/generated/liquid_localizations_en.dart';

class CounterProvider extends StatefulWidget {
  final Widget Function(BuildContext context, int counter) builder;
  const CounterProvider({super.key, required this.builder});
  @override
  State<CounterProvider> createState() => _CounterProviderState();
}

class _CounterProviderState extends State<CounterProvider> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LdButton(onPressed: () => setState(() => counter++), child: const Text("Increment")),
        widget.builder(context, counter),
      ],
    );
  }
}

void main() {
  ldDisableAnimations = true;

  test('LdSubmitController', () async {
    var completer = Completer<int>();

    final controller = LdSubmitController<int, void>(
      config: LdSubmitConfig(
        action: (arg) async {
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
          child: LdSubmit<int, void>(
            config: LdSubmitConfig(action: (_) async {
              return await completer.future;
            }),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LdSubmit<int, void>), findsOneWidget);

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
          child: Scaffold(
            body: LdSubmit<int, void>(
              config: LdSubmitConfig(action: (arg) async {
                return await completer.future;
              }),
              builder: const LdSubmitDialogBuilder<int, void>(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(LdSubmit<int, void>), findsOneWidget);
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

  testWidgets("LdSubmit with custom exception mapper", (WidgetTester tester) async {
    final customMapper = LdExceptionMapper(
      localizations: LiquidLocalizationsEn(),
      onException: (e, {stackTrace}) {
        return LdLocalizedException(
          message: "Custom exception",
          type: LdHintType.error,
        );
      },
    );

    final completer = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [LiquidLocalizations.delegate],
        home: LdThemeProvider(
          child: Scaffold(
            body: LdExceptionMapperProvider(
              exceptionMapper: customMapper,
              child: LdSubmit<int, void>(
                config: LdSubmitConfig(action: (arg) async {
                  await completer.future;
                  throw TimeoutException('Timeout');
                }),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.byType(LdSubmit<int, void>), findsOneWidget);
    expect(find.text("Submit"), findsOneWidget);

    // Trigger action that will fail
    await tester.tap(find.text("Submit"));
    await tester.pump();

    // Verify loading state
    expect(find.text("Loading..."), findsOneWidget);

    completer.complete();

    await tester.pumpAndSettle();

    // Verify error state
    expect(find.text("Custom exception"), findsOneWidget);
    expect(
      find.byType(LdButton),
      findsNWidgets(3),
    ); // Retry + More Info buttons
  });

  testWidgets("LdSubmit with retry config", (WidgetTester tester) async {
    int calls = 0;

    var completer = Completer<void>();

    final controller = LdSubmitController<int, void>(
      config: LdSubmitConfig(
        action: (arg) async {
          calls++;

          await completer.future;

          throw Exception('Intentional error');
        },
        retryConfig: LdRetryConfig(
          enableAutomaticRetries: true,
          maxAttempts: 2,
          baseDelay: const Duration(milliseconds: 100),
          hideManualRetryButton: true,
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [LiquidLocalizations.delegate],
        home: LdThemeProvider(
          child: Scaffold(
            body: LdSubmit<int, void>(
              controller: controller,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.byType(LdSubmit<int, void>), findsOneWidget);
    expect(find.text("Submit"), findsOneWidget);

    // Trigger action that will fail
    await tester.tap(find.text("Submit"));

    expect(calls, 1);

    await tester.pump();

    // Verify loading state
    expect(find.text("Loading..."), findsOneWidget);

    completer.complete();

    await tester.pump();

    // Complete with error

    await tester.pump();

    final retryButton = find.byKey(const Key('retry-button'));

    // Because we pass [disableRetryButton] to true, the retry button
    // should not be shown
    expect(retryButton, findsNothing);
    expect(find.byType(LdExceptionRetryIndicator), findsOneWidget);

    completer = Completer<void>();

    await tester.pump(controller.retryController.state.totalRetryDelay);
    await tester.pump(const Duration(milliseconds: 100));

    expect(calls, 2);

    // Verify automatic retry is triggered
    expect(find.text("Loading..."), findsOneWidget);

    completer.complete();

    await tester.pumpAndSettle();

    // Verify retry button is disabled again
    expect(retryButton, findsNothing);

    // There should now be no retry indicator, because we exceeded the max attempts
    expect(find.byType(LdExceptionRetryIndicator), findsNothing);
  });

  testWidgets("LdSubmit with arg", (WidgetTester tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        child: LdThemedAppBuilder(
          appBuilder: (context, theme) => MaterialApp(
            theme: theme,
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: CounterProvider(builder: (context, counter) {
              return LdSubmit<int, int>(
                arg: counter,
                config: LdSubmitConfig(action: (arg) async {
                  return arg! + 2;
                }),
                builder: LdSubmitInlineBuilder<int, int>(
                  resultBuilder: (context, result, controller) {
                    return Text("The result is $result");
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
    await tester.tap(find.text("Submit"));

    await tester.pumpAndSettle();

    expect(find.text("The result is 2"), findsOneWidget);

    await tester.tap(find.text("Increment"));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Submit"));

    await tester.pumpAndSettle();

    expect(find.text("The result is 3"), findsOneWidget);
  });

  testWidgets("LdSubmit with arg and auto submit re-submits when arg changes", (WidgetTester tester) async {
    await tester.pumpWidget(
      LdThemeProvider(
        child: LdThemedAppBuilder(
          appBuilder: (context, theme) => MaterialApp(
            theme: theme,
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: CounterProvider(builder: (context, counter) {
              return LdSubmit<int, int>(
                arg: counter,
                config: LdSubmitConfig(
                    autoTrigger: true,
                    action: (arg) async {
                      return arg! + 2;
                    }),
                builder: LdSubmitInlineBuilder<int, int>(
                  resultBuilder: (context, result, controller) {
                    return Text("The result is $result");
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("The result is 2"), findsOneWidget);

    await tester.tap(find.text("Increment"));

    await tester.pumpAndSettle();

    expect(find.text("The result is 3"), findsOneWidget);
  });
}
