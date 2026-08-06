import 'package:flutter/material.dart';
import 'package:liquid/demos/task_demo/demo_data.dart';
import 'package:liquid/demos/task_demo/task.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

List<LdFilterOption<Task, int>> taskFilters = [
  LdFilterSearch<Task, int, String>(
    name: "search",
    label: (context) => "Search",
    icon: (context) => Icon(LucideIcons.search),
    getSuggestions: (searchText) async {
      await Future.delayed(const Duration(milliseconds: 1000));
      return testData
          .where((element) => element.task.toLowerCase().startsWith(searchText.toLowerCase()))
          .map((e) => e.task)
          .toList();
    },
    buildSuggestion: (context, suggestion) {
      return LdListItem(
        title: Text(suggestion),
        onPressed: () {
          LdSearchAcceptSuggestion(suggestion: suggestion).dispatch(context);
        },
      );
    },
  ),
  LdFilterBool<Task, int>(
    isEnabled: (context) {
      final filters = Provider.of<LdMonkeySortAndFilterState<Task, int>>(context);
      return !filters.filters.any((e) => e.name == "todo" && e.isOn);
    },
    name: "done",
    label: (context) => "Done",
    icon: (context) => Icon(LucideIcons.check),
    affectedByUpdate: (before, after) => before?.done != after?.done,
  ),
  LdFilterBool<Task, int>(
    isEnabled: (context) {
      final filters = Provider.of<LdMonkeySortAndFilterState<Task, int>>(context);

      return !filters.filters.any((e) => e.name == "done" && e.isOn);
    },
    name: "todo",
    label: (context) => "To do",
    icon: (context) => Icon(LucideIcons.hourglass),
    affectedByUpdate: (before, after) => before?.done != after?.done,
  ),
];
