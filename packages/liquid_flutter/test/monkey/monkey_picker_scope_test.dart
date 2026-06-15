import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets('LdMonkeyPickerScope Done pops selection', (tester) async {
    final items = [
      _PickerItem(1, 'Alpha'),
      _PickerItem(2, 'Beta'),
    ];
    final repository = LdRepository.fromList<_PickerItem, int>(list: items);

    Set<int>? result;
    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              return LdButton(
                child: const Text('Open'),
                onPressed: () async {
                  result = await Navigator.of(context).push<Set<int>>(
                    MaterialPageRoute<Set<int>>(
                      builder: (context) => LdMonkeyPickerScope<_PickerItem, int>(
                        repository: repository,
                        label: 'Pick',
                        multiple: true,
                        allowEmpty: true,
                        initialSelection: const {1},
                        itemBuilder: (context, item, index) {
                          return LdListItem(title: Text(item.value!.label));
                        },
                        filtersBuilder: (_) async => [
                          LdFilterSearch<_PickerItem, int, String>(
                            name: 'search',
                            label: (context) => 'Search',
                            icon: (context) => const Icon(LucideIcons.search),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Alpha'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ldChoose_done')));
    await tester.pumpAndSettle();

    expect(result, {1});
  });
}

class _PickerItem with Identifiable<int> {
  _PickerItem(this.id, this.label);

  @override
  final int id;
  final String label;
}
