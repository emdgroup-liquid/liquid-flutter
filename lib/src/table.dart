import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:collection/collection.dart';

enum LdTableDensity { compact, normal, relaxed, squeezed }

class LdCol<T> {
  String title;
  int Function(T a, T b)? sort;
  double weight;
  LdCol({
    required this.title,
    this.sort,
    this.weight = 1,
  });
}

class LdTable<T> extends StatefulWidget {
  final List<LdCol<T>> columns;
  final List<T> rows;
  final List<Widget> Function(T row) buildRow;

  final Function(T item, bool selected)? onSelectChange;
  final Set<T> selectedRows;
  final bool allowSort;
  final Widget? header;
  final int rowCount;

  final LdTableDensity density;

  const LdTable(
      {Key? key,
      required this.columns,
      required this.rows,
      required this.buildRow,
      this.onSelectChange,
      this.selectedRows = const {},
      this.header,
      this.allowSort = true,
      required this.rowCount,
      this.density = LdTableDensity.normal})
      : super(key: key);

  @override
  State<LdTable> createState() => _LdTableState<T>();
}

class _LdTableState<T> extends State<LdTable<T>> {
  double width = 0;

  int _sortByCol = 0;
  bool _sortDir = false;

  late List<T> _sortedRows;

  @override
  void initState() {
    _resort();

    super.initState();
  }

  void _resort() {
    if (widget.columns[_sortByCol].sort != null) {
      var sortFn = widget.columns[_sortByCol].sort;
      setState(() {
        _sortedRows = widget.rows.sorted(sortFn!);
      });
    } else {
      _sortedRows = widget.rows;
    }
  }

  double get _rowPadding {
    switch (widget.density) {
      case LdTableDensity.squeezed:
        return 2;
      case LdTableDensity.compact:
        return 4;
      case LdTableDensity.normal:
        return 6;
      case LdTableDensity.relaxed:
        return 8;
    }
  }

  LdSize get _checkboxSize {
    switch (widget.density) {
      case LdTableDensity.squeezed:
        return LdSize.xs;
      case LdTableDensity.compact:
        return LdSize.s;
      case LdTableDensity.normal:
        return LdSize.m;
      case LdTableDensity.relaxed:
        return LdSize.m;
    }
  }

  bool get selectable => widget.onSelectChange != null;

  double _colWidth(int index) {
    var availableWidth = selectable ? width - 48 : width;

    return max(availableWidth / widget.columns.length, 1);
  }

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth - 3 != width) {
        width = constraints.maxWidth - 3;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null)
            Container(
                decoration: BoxDecoration(
                    color: theme.surface,
                    border: Border(
                        bottom: BorderSide(color: theme.border, width: 1.5))),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: widget.header),
          Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: theme.border, width: 1.5))),
            child: Row(
              children: [
                SizedBox(
                  width: selectable ? 48 : 0,
                ),
                Row(
                  children: widget.columns.mapIndexed((index, e) {
                    return Container(
                      width: _colWidth((index)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: _rowPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: LdTextL(
                              e.title,
                            ),
                          ),
                          LdButton(
                            key: ValueKey("sort-$index"),
                            mode: LdButtonMode.ghost,
                            size: LdSize.s,
                            onPressed: () {
                              if (_sortByCol == index) {
                                _sortDir = !_sortDir;
                              }
                              _sortByCol = index;
                              _resort();
                            },
                            child: Icon(
                              _sortByCol == index
                                  ? _sortDir
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward
                                  : Icons.swap_vert,
                              size: 16,
                              color: theme.palette.primary.idle(theme.isDark),
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          ListView.separated(
            itemCount: _sortedRows.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return const LdDivider();
            },
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              var row = _sortDir
                  ? _sortedRows[index]
                  : _sortedRows.reversed.elementAt(index);
              return Row(
                  key: ValueKey("row-$index"),
                  children: widget
                      .buildRow(row)
                      .map<Widget>((e) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: _rowPadding),
                          width: _colWidth(index),
                          child: e))
                      .toList()
                    ..insert(
                        0,
                        selectable
                            ? Container(
                                width: 48,
                                padding: const EdgeInsets.only(left: 12),
                                child: LdCheckbox(
                                  key: ValueKey("select-$index"),
                                  size: _checkboxSize,
                                  onChanged: (p0) {
                                    widget.onSelectChange!(row, p0);
                                  },
                                  checked: widget.selectedRows.contains(row),
                                ),
                              )
                            : Container()));
            },
          )
        ],
      );
    });
  }
}
