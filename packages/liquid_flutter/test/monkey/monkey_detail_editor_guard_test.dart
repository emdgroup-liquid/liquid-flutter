import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

Widget _wrapViewingGuardTest({
  required TestSortAndFilterState<TestItem, int> shellState,
  required bool isDirty,
  required bool isSaving,
  required Future<bool> Function() onConfirmDiscard,
  required Widget child,
}) {
  return LdThemeProvider(
    child: MaterialApp(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      home: ListenableProvider<TestSortAndFilterState<TestItem, int>>.value(
        value: shellState,
        child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
          value: shellState.controllerDelegate,
          child: Builder(
            builder: (context) {
              context.watch<TestSortAndFilterState<TestItem, int>>();
              return Provider<LdMonkeySelection<TestItem, int>>.value(
                value: shellState.selection,
                child: LdMonkeyViewingGuard<TestItem, int>(
                  isDirty: isDirty,
                  isSaving: isSaving,
                  onConfirmDiscard: onConfirmDiscard,
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => ldDisableAnimations = true);
  tearDown(() => ldDisableAnimations = false);

  group('LdMonkeyUnsavedGuard', () {
    Future<void> _openGuardedPage(
      WidgetTester tester, {
      required bool isDirty,
      required bool isSaving,
      required Future<bool> Function() onConfirmDiscard,
    }) async {
      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp(
            home: Builder(
              builder: (outerContext) => LdButton(
                child: const Text('Open'),
                onPressed: () {
                  Navigator.of(outerContext).push<void>(
                    MaterialPageRoute<void>(
                      builder: (context) => LdMonkeyUnsavedGuard(
                        isDirty: isDirty,
                        isSaving: isSaving,
                        onConfirmDiscard: onConfirmDiscard,
                        child: Builder(
                          builder: (context) => LdButton(
                            child: const Text('Close'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('allows pop when pristine', (tester) async {
      await _openGuardedPage(
        tester,
        isDirty: false,
        isSaving: false,
        onConfirmDiscard: () async => true,
      );

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('allows pop after discard is confirmed', (tester) async {
      await _openGuardedPage(
        tester,
        isDirty: true,
        isSaving: false,
        onConfirmDiscard: () async => true,
      );

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Close'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('keeps page open when discard is cancelled', (tester) async {
      await _openGuardedPage(
        tester,
        isDirty: true,
        isSaving: false,
        onConfirmDiscard: () async => false,
      );

      await tester.tap(find.text('Close'));
      await tester.pump();

      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('blocks pop while saving without discard prompt', (tester) async {
      var discardPrompted = false;

      await _openGuardedPage(
        tester,
        isDirty: true,
        isSaving: true,
        onConfirmDiscard: () async {
          discardPrompted = true;
          return true;
        },
      );

      await tester.tap(find.text('Close'));
      await tester.pump();

      expect(discardPrompted, isFalse);
      expect(find.text('Close'), findsOneWidget);
    });
  });

  group('LdMonkeyViewingGuard', () {
    testWidgets('allows viewing change when pristine', (tester) async {
      final shellState = TestSortAndFilterState<TestItem, int>()..updateViewing(MockBuildContext(), {1});

      await tester.pumpWidget(
        _wrapViewingGuardTest(
          shellState: shellState,
          isDirty: false,
          isSaving: false,
          onConfirmDiscard: () async => true,
          child: const Text('detail'),
        ),
      );

      shellState.updateViewing(MockBuildContext(), {2});
      await tester.pump();

      expect(shellState.currentViewing, {2});
    });

    testWidgets('restores viewing when dirty and discard is cancelled', (tester) async {
      final shellState = TestSortAndFilterState<TestItem, int>()..updateViewing(MockBuildContext(), {1});

      await tester.pumpWidget(
        _wrapViewingGuardTest(
          shellState: shellState,
          isDirty: true,
          isSaving: false,
          onConfirmDiscard: () async => false,
          child: const Text('detail'),
        ),
      );

      shellState.updateViewing(MockBuildContext(), {2});
      await tester.pump();
      await tester.pump();

      expect(shellState.currentViewing, {1});
    });

    testWidgets('allows viewing change when dirty and discard is confirmed', (tester) async {
      final shellState = TestSortAndFilterState<TestItem, int>()..updateViewing(MockBuildContext(), {1});

      await tester.pumpWidget(
        _wrapViewingGuardTest(
          shellState: shellState,
          isDirty: true,
          isSaving: false,
          onConfirmDiscard: () async => true,
          child: const Text('detail'),
        ),
      );

      shellState.updateViewing(MockBuildContext(), {2});
      await tester.pump();
      await tester.pump();

      expect(shellState.currentViewing, {2});
    });

    testWidgets('reverts viewing change while saving', (tester) async {
      final shellState = TestSortAndFilterState<TestItem, int>()..updateViewing(MockBuildContext(), {1});

      await tester.pumpWidget(
        _wrapViewingGuardTest(
          shellState: shellState,
          isDirty: true,
          isSaving: true,
          onConfirmDiscard: () async => true,
          child: const Text('detail'),
        ),
      );

      shellState.updateViewing(MockBuildContext(), {2});
      await tester.pump();
      await tester.pump();

      expect(shellState.currentViewing, {1});
    });
  });
}
