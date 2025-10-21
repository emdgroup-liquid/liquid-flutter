import 'package:flutter/material.dart';

class LdSearchConfig {
  final Future<List<dynamic>> Function(String)? getSuggestions;
  final Widget Function(BuildContext context, dynamic suggestion)? buildSuggestion;
  final void Function(String text) onSearch;

  late final FocusNode inputFocusNode;
  late final TextEditingController inputController;

  LdSearchConfig({
    this.getSuggestions,
    this.buildSuggestion,
    required this.onSearch,
    FocusNode? inputFocusNode,
    TextEditingController? inputController,
  }) {
    this.inputFocusNode = inputFocusNode ?? FocusNode();
    this.inputController = inputController ?? TextEditingController();
  }

  void dispose() {
    inputFocusNode.dispose();
    inputController.dispose();
  }
}
