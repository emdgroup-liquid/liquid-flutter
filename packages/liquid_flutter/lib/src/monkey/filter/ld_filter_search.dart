import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterSearch<T extends Identifiable<IdType>, IdType, Suggestion> extends LdFilterOption<T, IdType> {
  final String searchText;
  final bool Function(T item, String searchText) _optimisticFilter;
  final Future<List<Suggestion>> Function(String)? getSuggestions;
  final LdListItem Function(BuildContext context, dynamic suggestion)? buildSuggestion;
  final Duration debounceDelay;
  final String? hint;

  LdSearchConfig searchConfig(Function(String query) onSearch) => LdSearchConfig(
        getSuggestions: getSuggestions,
        buildSuggestion: buildSuggestion,
        initialQuery: searchText,
        hint: hint,
        onSearch: onSearch,
      );

  LdFilterSearch({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    this.searchText = '',
    this.hint,
    required bool Function(T item, String searchText) optimisticFilter,
    this.getSuggestions,
    this.buildSuggestion,
    this.debounceDelay = const Duration(milliseconds: 300),
  }) : _optimisticFilter = optimisticFilter;

  @override
  String serialize() {
    if (!isOn || searchText.isEmpty) return '';
    return searchText;
  }

  @override
  LdFilterSearch<T, IdType, Suggestion> marshalSerialized(String value) {
    return copyWith(
      searchText: value,
      isOn: value.isNotEmpty,
    );
  }

  @override
  bool optimisticFilter(T item) {
    if (!isOn || searchText.isEmpty) return true;
    return _optimisticFilter(item, searchText);
  }

  @override
  LdFilterSearch<T, IdType, Suggestion> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    String? searchText,
    String? hint,
    bool Function(T item, String searchText)? optimisticFilter,
    Future<List<Suggestion>> Function(String)? getSuggestions,
    LdListItem Function(BuildContext context, dynamic suggestion)? buildSuggestion,
    Duration? debounceDelay,
  }) {
    return LdFilterSearch<T, IdType, Suggestion>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      searchText: searchText ?? this.searchText,
      hint: hint ?? this.hint,
      optimisticFilter: optimisticFilter ?? _optimisticFilter,
      getSuggestions: getSuggestions ?? this.getSuggestions,
      buildSuggestion: buildSuggestion ?? this.buildSuggestion,
      debounceDelay: debounceDelay ?? this.debounceDelay,
    );
  }

  @override
  Widget build(BuildContext context, LdRepository<T, IdType> repository) {
    return LdSearchInput(
        fullWidth: true,
        searchConfig: searchConfig(
          (query) {
            repository.updateFilter(
              name,
              (filter) => (filter as LdFilterSearch<T, IdType, Suggestion>).copyWith(
                isOn: query.trim().isNotEmpty,
                searchText: query,
              ),
            );
          },
        ));
  }
}
