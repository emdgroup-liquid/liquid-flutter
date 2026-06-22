import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class _EphemeralItem with Identifiable<int> {
  _EphemeralItem(this.id);

  @override
  final int id;
}

void main() {
  testWidgets('first selection update does not refresh repository filters', (tester) async {
    var fetchCount = 0;
    final repository = LdRepository<_EphemeralItem, int>(
      getById: (id) async => _EphemeralItem(id),
      fetchListWithParameters: (parameters) async {
        fetchCount++;
        return LdListPage(
          newItems: List.generate(5, (index) => _EphemeralItem(index)),
          hasMore: false,
          total: 5,
        );
      },
    );

    final controller = LdEphemeralMonkeyController<_EphemeralItem, int>(
      initialSelection: {0},
    );

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          home: ListenableProvider<LdRepository<_EphemeralItem, int>>.value(
            value: repository,
            child: LdEphemeralMonkeyAdapter<_EphemeralItem, int>(
              controller: controller,
              child: Builder(
                builder: (context) {
                  return LdButton(
                    onPressed: () {
                      controller.updateSelection({1});
                    },
                    child: const Text('select'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    fetchCount = 0;
    await tester.tap(find.text('select'));
    await tester.pumpAndSettle();

    expect(fetchCount, 0);
  });
}
