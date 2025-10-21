import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterSearchOption<T extends Identifiable<IdType>, IdType, Suggestion> extends LdFilterOption<T, IdType> {
  final String searchText;
  final bool Function(T item, String searchText) _optimisticFilter;
  final Future<List<Suggestion>> Function(String)? getSuggestions;
  final Widget Function(BuildContext context, dynamic suggestion)? buildSuggestion;
  final Duration debounceDelay;
  final String? hint;

  LdSearchConfig? get searchConfig => LdSearchConfig(
        getSuggestions: getSuggestions,
        buildSuggestion: buildSuggestion,
        onSearch: (query) {
          // This will be handled by the parent component using copyWith
        },
      );

  LdFilterSearchOption({
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
  LdFilterSearchOption<T, IdType, Suggestion> marshalSerialized(String value) {
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
  LdFilterSearchOption<T, IdType, Suggestion> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    String? searchText,
    String? hint,
    bool Function(T item, String searchText)? optimisticFilter,
    Future<List<Suggestion>> Function(String)? getSuggestions,
    Widget Function(BuildContext context, dynamic suggestion)? buildSuggestion,
    Duration? debounceDelay,
  }) {
    return LdFilterSearchOption<T, IdType, Suggestion>(
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
}
