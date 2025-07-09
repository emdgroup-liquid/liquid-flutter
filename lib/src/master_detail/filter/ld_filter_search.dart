import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdFilterSearchOption<T extends Identifiable<IdType>, IdType, S> extends LdFilterOption<T, IdType> {
  String searchText;
  final bool Function(T item, String searchText) _optimisticFilter;
  final Future<List<S>> Function(String)? getSuggestions;
  final Duration debounceDelay;

  LdFilterSearchOption({
    required super.name,
    required super.label,
    required super.icon,
    super.isOn = false,
    this.searchText = '',
    required bool Function(T item, String searchText) optimisticFilter,
    this.getSuggestions,
    this.debounceDelay = const Duration(milliseconds: 300),
  }) : _optimisticFilter = optimisticFilter;

  @override
  String serialize() {
    if (!isOn || searchText.isEmpty) return '';
    return searchText;
  }

  @override
  void marshalSerialized(MapEntry<String, String> entry) {
    searchText = entry.value;
    isOn = searchText.isNotEmpty;
  }

  @override
  bool optimisticFilter(T item) {
    if (!isOn || searchText.isEmpty) return true;
    return _optimisticFilter(item, searchText);
  }
}
