import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _ReorderItem with Identifiable<int> {
  _ReorderItem(this.id, this.label);

  @override
  final int id;
  final String label;
}

void main() {
  group('LdListReorderScope', () {
    testWidgets('renders wrapped list items', (WidgetTester tester) async {
      final items = [
        _ReorderItem(1, 'Alpha'),
        _ReorderItem(2, 'Beta'),
        _ReorderItem(3, 'Gamma'),
      ];
      final paginator = LdPaginator<_ReorderItem, int>.fromList(items);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: LdThemeProvider(
            child: Scaffold(
              body: SizedBox(
                height: 400,
                child: LdListConfigProvider<_ReorderItem, int>(
                  config: LdListConfig<_ReorderItem, int>(
                    paginator: paginator,
                    itemBuilder: (context, item, index) => LdListItem(
                      title: Text(item.value.label),
                    ),
                  ),
                  child: LdListReorderScope<_ReorderItem, int>(
                    onReorder: (_, __, ___) async {},
                    child: LdList<_ReorderItem, int>(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
    });

    testWidgets('list items keep unique focus nodes after reorder', (WidgetTester tester) async {
      final items = [
        _ReorderItem(1, 'Alpha'),
        _ReorderItem(2, 'Beta'),
        _ReorderItem(3, 'Gamma'),
      ];
      final paginator = LdPaginator<_ReorderItem, int>.fromList(items);

      final theme = LdTheme()..platform = LdPlatform.macos;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: LdThemeProvider(
            theme: theme,
            child: Scaffold(
              body: SizedBox(
                height: 400,
                child: LdListConfigProvider<_ReorderItem, int>(
                  config: LdListConfig<_ReorderItem, int>(
                    paginator: paginator,
                    itemBuilder: (context, item, index) => LdListItem(
                      title: Text(item.value.label),
                    ),
                  ),
                  child: LdSelectableList<_ReorderItem, int>(
                    listController: paginator,
                    disableDragGestures: true,
                    child: LdListReorderScope<_ReorderItem, int>(
                      onReorder: (id, from, to) async {
                        paginator.reorderIndices(from, to);
                      },
                      child: LdList<_ReorderItem, int>(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      FocusNode? focusNodeFor(String label) {
        final focusFinder = find
            .ancestor(
              of: find.text(label),
              matching: find.byWidgetPredicate(
                (widget) => widget is Focus && widget.focusNode != null,
              ),
            )
            .first;
        return tester.widget<Focus>(focusFinder).focusNode;
      }

      final alphaFocusBefore = focusNodeFor('Alpha');
      final betaFocusBefore = focusNodeFor('Beta');
      final gammaFocusBefore = focusNodeFor('Gamma');

      expect(alphaFocusBefore, isNot(same(betaFocusBefore)));
      expect(betaFocusBefore, isNot(same(gammaFocusBefore)));
      expect(alphaFocusBefore, isNot(same(gammaFocusBefore)));

      paginator.reorderIndices(0, 2);
      await tester.pumpAndSettle();

      final alphaFocusAfter = focusNodeFor('Alpha');
      final betaFocusAfter = focusNodeFor('Beta');
      final gammaFocusAfter = focusNodeFor('Gamma');

      expect(alphaFocusAfter, same(alphaFocusBefore));
      expect(betaFocusAfter, same(betaFocusBefore));
      expect(gammaFocusAfter, same(gammaFocusBefore));

      expect(alphaFocusAfter, isNot(same(betaFocusAfter)));
      expect(betaFocusAfter, isNot(same(gammaFocusAfter)));
      expect(alphaFocusAfter, isNot(same(gammaFocusAfter)));
    });

    testWidgets('auto-scrolls the list while dragging near the bottom edge', (WidgetTester tester) async {
      final items = List.generate(40, (i) => _ReorderItem(i, 'Item $i'));
      final paginator = LdPaginator<_ReorderItem, int>.fromList(items);
      final scrollController = ScrollController();

      addTearDown(() {
        scrollController.dispose();
        paginator.dispose();
      });

      await tester.pumpWidget(
        LdThemeProvider(
          theme: LdTheme()..platform = LdPlatform.macos,
          child: MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: Scaffold(
              body: SizedBox(
                height: 300,
                child: LdListConfigProvider<_ReorderItem, int>(
                  config: LdListConfig<_ReorderItem, int>(
                    paginator: paginator,
                    scrollController: scrollController,
                    itemBuilder: (context, item, index) => LdListItem(
                      title: Text(item.value.label),
                    ),
                  ),
                  child: LdListReorderScope<_ReorderItem, int>(
                    onReorder: (id, from, to) async {},
                    child: LdList<_ReorderItem, int>(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0);

      // Start dragging the grip of the first visible item.
      final gripFinder = find.byIcon(LucideIcons.gripHorizontal).first;
      final gesture = await tester.startGesture(tester.getCenter(gripFinder));
      await tester.pump(const Duration(milliseconds: 20));

      // Hold the pointer in the bottom edge zone so auto-scroll engages:
      // the pointer stays still while the viewport scrolls underneath it.
      final scrollableRect = tester.getRect(find.byType(Scrollable).first);
      await gesture.moveTo(Offset(scrollableRect.center.dx, scrollableRect.bottom - 10));
      await tester.pump(const Duration(milliseconds: 100));

      expect(scrollController.offset, greaterThan(0), reason: 'holding near the bottom edge must auto-scroll');

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('does not auto-scroll while dragging at the viewport center', (WidgetTester tester) async {
      final items = List.generate(40, (i) => _ReorderItem(i, 'Item $i'));
      final paginator = LdPaginator<_ReorderItem, int>.fromList(items);
      final scrollController = ScrollController();

      addTearDown(() {
        scrollController.dispose();
        paginator.dispose();
      });

      await tester.pumpWidget(
        LdThemeProvider(
          theme: LdTheme()..platform = LdPlatform.macos,
          child: MaterialApp(
            localizationsDelegates: const [LiquidLocalizations.delegate],
            home: Scaffold(
              body: SizedBox(
                height: 300,
                child: LdListConfigProvider<_ReorderItem, int>(
                  config: LdListConfig<_ReorderItem, int>(
                    paginator: paginator,
                    scrollController: scrollController,
                    itemBuilder: (context, item, index) => LdListItem(
                      title: Text(item.value.label),
                    ),
                  ),
                  child: LdListReorderScope<_ReorderItem, int>(
                    onReorder: (id, from, to) async {},
                    child: LdList<_ReorderItem, int>(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gripFinder = find.byIcon(LucideIcons.gripHorizontal).first;
      final gesture = await tester.startGesture(tester.getCenter(gripFinder));
      await tester.pump(const Duration(milliseconds: 20));

      final scrollableRect = tester.getRect(find.byType(Scrollable).first);
      await gesture.moveTo(Offset(scrollableRect.center.dx, scrollableRect.center.dy));
      await tester.pump(const Duration(milliseconds: 300));

      expect(scrollController.offset, 0, reason: 'dragging away from the edges must not scroll');

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}
