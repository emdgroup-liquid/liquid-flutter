import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterSearch<T extends Identifiable<IdType>, IdType, Suggestion> extends LdFilterOption<T, IdType> {
  final String searchText;
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
    this.getSuggestions,
    this.buildSuggestion,
    this.debounceDelay = const Duration(milliseconds: 300),
    super.isEnabled,
    super.affectedByUpdate,
    @Deprecated('Use affectedByUpdate') super.mutationAffectsCache,
  });

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
  LdFilterSearch<T, IdType, Suggestion> copyWith({
    String Function(BuildContext context)? label,
    Widget Function(BuildContext context)? icon,
    String? name,
    bool? isOn,
    String? searchText,
    String? hint,
    Future<List<Suggestion>> Function(String)? getSuggestions,
    LdListItem Function(BuildContext context, dynamic suggestion)? buildSuggestion,
    Duration? debounceDelay,
    bool Function(BuildContext context)? isEnabled,
    LdAffectedByUpdate<T>? affectedByUpdate,
    @Deprecated('Use affectedByUpdate') LdAffectedByUpdate<T>? mutationAffectsCache,
  }) {
    return LdFilterSearch<T, IdType, Suggestion>(
      name: name ?? this.name,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOn: isOn ?? this.isOn,
      searchText: searchText ?? this.searchText,
      hint: hint ?? this.hint,
      getSuggestions: getSuggestions ?? this.getSuggestions,
      buildSuggestion: buildSuggestion ?? this.buildSuggestion,
      debounceDelay: debounceDelay ?? this.debounceDelay,
      isEnabled: isEnabled ?? this.isEnabled,
      affectedByUpdate: affectedByUpdate ?? mutationAffectsCache ?? this.affectedByUpdate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdSearchInput(
        fullWidth: true,
        searchConfig: searchConfig(
          (query) {
            update(
              context,
              copyWith(
                isOn: query.trim().isNotEmpty,
                searchText: query,
              ),
            );
          },
        ));
  }
}
