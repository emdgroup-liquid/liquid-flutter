import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class _Person {
  String name;
  int age;
  _Person(this.name, this.age);
}

void main() {
  testWidgets('LdTable', (WidgetTester test) async {
    var theme = LdTheme();

    var rows = [
      _Person("John", 20),
      _Person("Jane", 21),
      _Person("Jack", 22),
    ];

    bool selectedCalled = false;
    onSelectChange(_Person person, bool selected) {
      selectedCalled = true;
    }

    await test.pumpWidget(LdThemeProvider(
        theme: theme,
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
                child: LdTable<_Person>(
              columns: [
                LdCol(
                  title: "Name",
                  sort: (a, b) {
                    return a.name.compareTo(b.name);
                  },
                ),
                LdCol(title: "Age")
              ],
              rows: rows,
              onSelectChange: onSelectChange,
              rowCount: rows.length,
              buildRow: (row) {
                return [Text(row.name), Text(row.age.toString())];
              },
            )))));

    await test.pumpAndSettle();

    expect(find.byType(LdTable<_Person>), findsOneWidget);

    expect(find.text("Name"), findsOneWidget);
    expect(find.text("Age"), findsOneWidget);

    expect(find.text("John"), findsOneWidget);
    expect(find.text("Jane"), findsOneWidget);
    expect(find.text("Jack"), findsOneWidget);

    expect(find.text("20"), findsOneWidget);
    expect(find.text("21"), findsOneWidget);
    expect(find.text("22"), findsOneWidget);

    await test.tap(find.byKey(const ValueKey("sort-0")));

    await test.pumpAndSettle();

    var firstRow = find.descendant(
        of: find.byKey(const ValueKey("row-0")), matching: find.byType(Text));

    expect((test.firstWidget(firstRow) as Text).data, "Jack");

    await test.tap(find.byKey(const ValueKey("select-0")));

    expect(selectedCalled, true);
  });
}
