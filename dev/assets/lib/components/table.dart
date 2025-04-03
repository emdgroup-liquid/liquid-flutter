import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';
import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class _Person {
  final String name;
  final int age;
  final String email;
  const _Person({required this.name, required this.age, required this.email});
}

var people = const [
  _Person(name: "John", age: 20, email: "john.appleseed@example.com"),
  _Person(name: "Amy", age: 30, email: "amy.pear@example.com"),
  _Person(name: "Charles", age: 50, email: "charles.orange@example.com"),
];

class TableDemo extends StatefulWidget {
  const TableDemo({Key? key}) : super(key: key);

  @override
  State<TableDemo> createState() => _TableDemoState();
}

class _TableDemoState extends State<TableDemo> {
  LdTableDensity _density = LdTableDensity.normal;

  final Set<_Person> _selectedRows = {};

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdTable",
      demo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdCard(
            padding: EdgeInsets.zero,
            child: LdTable<_Person>(
              selectedRows: _selectedRows,
              density: _density,
              rows: people,
              header: Row(children: [
                LdButton(
                  leading: const Icon(LdIcons.filter),
                  child: const Text("Filter"),
                  size: LdSize.m,
                  onPressed: () {},
                )
              ]),
              columns: [
                LdCol(
                  title: "Name",
                  sort: (a, b) => a.name.compareTo(b.name),
                ),
                LdCol(title: "Age", sort: (a, b) => a.age.compareTo(b.age)),
                LdCol(
                    title: "Email", sort: (a, b) => a.email.compareTo(b.email))
              ],
              rowCount: 3,
              onSelectChange: (item, selected) {
                setState(() {
                  if (selected) {
                    _selectedRows.add(item);
                  } else {
                    _selectedRows.remove(item);
                  }
                });
              },
              buildRow: (row) {
                return [
                  Text(row.name),
                  Text(row.age.toString()),
                  Text(row.email)
                ];
              },
            ),
          ),
          ldSpacerL,
          const LdTextH(
            "Visual density",
          ),
          ldSpacerM,
          LdSwitch<LdTableDensity>(
            children: const {
              LdTableDensity.relaxed: Text("Relaxed"),
              LdTableDensity.normal: Text("Normal"),
              LdTableDensity.compact: Text("Compact"),
              LdTableDensity.squeezed: Text("Squeezed"),
            },
            value: _density,
            onChanged: (p0) {
              setState(() {
                _density = p0;
              });
            },
          ),
          ldSpacerM,
          const LdTextH(
            "Selected items:",
          ),
          ldSpacerM,
          Wrap(
            spacing: 8,
            children:
                _selectedRows.map((e) => LdTag(child: Text(e.name))).toList(),
          )
        ],
      ),
    );
  }
}
