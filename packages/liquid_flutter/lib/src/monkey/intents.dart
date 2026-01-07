import 'package:flutter/widgets.dart';

class SearchIntent extends Intent {
  const SearchIntent();
}

class SearchAction extends Action<SearchIntent> {
  final FocusNode searchFocusNode;

  SearchAction({required this.searchFocusNode});

  @override
  void invoke(SearchIntent intent) {
    searchFocusNode.requestFocus();
  }
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class SelectAllIntent extends Intent {
  const SelectAllIntent();
}

class OpenDrawerIntent extends Intent {
  const OpenDrawerIntent();
}

class CloseDrawerIntent extends Intent {
  const CloseDrawerIntent();
}

class ToggleDrawerIntent extends Intent {
  const ToggleDrawerIntent();
}
