import 'package:flutter/material.dart';

class LdSearchConfig {
  final Future<List<dynamic>> Function(String)? getSuggestions;
  final Widget Function(BuildContext context, dynamic suggestion)? buildSuggestion;
  final void Function(String text) onSearch;
  final String? hint;
  final String? initialQuery;

  LdSearchConfig({
    this.getSuggestions,
    this.buildSuggestion,
    required this.onSearch,
    FocusNode? inputFocusNode,
    this.hint,
    this.initialQuery,
  });
}
