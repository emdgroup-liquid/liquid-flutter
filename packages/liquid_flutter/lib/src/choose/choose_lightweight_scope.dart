import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// Lightweight ephemeral picker for static [fromList] / [fromSelectItems] flows.
class LdChooseLightweightScope<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdChooseLightweightScope({
    super.key,
    required this.repository,
    required this.itemBuilder,
    required this.initialSelection,
    required this.label,
    required this.multiple,
    required this.allowEmpty,
    required this.searchText,
    this.searchSourceItems,
    this.groupingCriterion,
    this.groupHeaderBuilder,
  });

  final LdListController<T, IdType> repository;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;
  final Set<IdType> initialSelection;
  final String label;
  final bool multiple;
  final bool allowEmpty;
  final LdSearchTextExtractor<T>? searchText;
  final List<T>? searchSourceItems;
  final dynamic Function(T)? groupingCriterion;
  final Widget Function(BuildContext context, dynamic criterion, List<LdPaginatorItem<T>>)? groupHeaderBuilder;

  @override
  State<LdChooseLightweightScope<T, IdType>> createState() => _LdChooseLightweightScopeState<T, IdType>();
}

class _LdChooseLightweightScopeState<T extends Identifiable<IdType>, IdType>
    extends State<LdChooseLightweightScope<T, IdType>> {
  late final LdEphemeralMonkeyController<T, IdType> _controller;

  @override
  void initState() {
    super.initState();
    _controller = LdEphemeralMonkeyController<T, IdType>(
      initialSelection: widget.initialSelection,
      showSelectionControls: true,
      filters: _buildInitialFilters(),
    );
  }

  Set<LdFilterOption<T, IdType>> _buildInitialFilters() {
    if (widget.searchText == null) {
      return {};
    }
    return {
      LdFilterSearch<T, IdType, String>(
        name: 'search',
        label: (context) => LiquidLocalizations.of(context).search,
        icon: (context) => const Icon(LucideIcons.search),
        getSuggestions: _getSearchSuggestions,
        buildSuggestion: (context, suggestion) {
          return LdListItem(
            title: Text(suggestion),
            onPressed: () {
              LdSearchAcceptSuggestion(suggestion: suggestion).dispatch(context);
            },
          );
        },
      ),
    };
  }

  Future<List<String>> _getSearchSuggestions(String query) async {
    final searchText = widget.searchText;
    final sourceItems = widget.searchSourceItems;
    if (searchText == null || sourceItems == null || query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase();
    final seen = <String>{};
    final suggestions = <String>[];

    for (final item in sourceItems) {
      final text = searchText(item);
      if (text.isEmpty) {
        continue;
      }
      if (text.toLowerCase().startsWith(lowerQuery) && seen.add(text)) {
        suggestions.add(text);
      }
    }

    return suggestions;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<LdListController<T, IdType>>.value(
      value: widget.repository,
      child: LdEphemeralMonkeyAdapter<T, IdType>(
        controller: _controller,
        child: LdChoosePage<T, IdType>(
          repository: widget.repository,
          itemBuilder: widget.itemBuilder,
          initialSelectedItems: widget.initialSelection,
          multiple: widget.multiple,
          allowEmpty: widget.allowEmpty,
          label: widget.label,
          groupingCriterion: widget.groupingCriterion,
          groupHeaderBuilder: widget.groupHeaderBuilder,
          useMonkeySearch: widget.searchText != null,
        ),
      ),
    );
  }
}

LdFilterSearch<T, IdType, dynamic>? ldChooseSearchFilter<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
) {
  return findMonkeyFilterByName<T, IdType, LdFilterSearch<T, IdType, dynamic>>(
    context,
    filterName: 'search',
    listen: true,
  );
}

LdFilterSearch<T, IdType, dynamic> ldChooseDefaultSearchFilter<T extends Identifiable<IdType>, IdType>() {
  return LdFilterSearch<T, IdType, String>(
    name: 'search',
    label: (context) => LiquidLocalizations.of(context).search,
    icon: (context) => const Icon(LucideIcons.search),
  );
}
