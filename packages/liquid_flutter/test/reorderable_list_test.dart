import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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
                    paginator: paginator,
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
  });
}
