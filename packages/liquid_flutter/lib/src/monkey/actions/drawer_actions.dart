import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';

class OpenDrawerAction extends Action<OpenDrawerIntent> {
  final VoidCallback onOpenDrawer;

  OpenDrawerAction({required this.onOpenDrawer});

  @override
  void invoke(OpenDrawerIntent intent) {
    onOpenDrawer();
  }
}

class CloseDrawerAction extends Action<CloseDrawerIntent> {
  final VoidCallback onCloseDrawer;

  CloseDrawerAction({required this.onCloseDrawer});

  @override
  void invoke(CloseDrawerIntent intent) {
    onCloseDrawer();
  }
}

class ToggleDrawerAction extends Action<ToggleDrawerIntent> {
  final VoidCallback onToggleDrawer;

  final bool _isActionEnabled;

  ToggleDrawerAction({required this.onToggleDrawer, bool isActionEnabled = true}) : _isActionEnabled = isActionEnabled;

  @override
  bool get isActionEnabled {
    return _isActionEnabled;
  }

  @override
  void invoke(ToggleDrawerIntent intent) {
    onToggleDrawer();
  }
}
