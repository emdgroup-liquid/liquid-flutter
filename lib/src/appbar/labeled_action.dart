import 'dart:async';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

mixin LdLabeledAction {
  String label(BuildContext context);
  Widget? icon(BuildContext context);
  String? loadingText(BuildContext context);

  Widget? contextMenu(BuildContext context);

  bool isVisible(BuildContext context) {
    return true;
  }

  FutureOr<void> onPressed(BuildContext context);

  LdColor? color(BuildContext context) {
    return null;
  }

  LdLabeledActionSubmitType get submitType => LdLabeledActionSubmitType.notification;
}

enum LdLabeledActionSubmitType { none, notification, dialog, contextMenu }

class LdAppBarAction with LdLabeledAction {
  final String _label;
  final Widget? _icon;
  final FutureOr<void> Function(BuildContext context) _onPressed;
  final String? _loadingText;
  final LdLabeledActionSubmitType _submitType;
  final LdColor? _color;
  final Widget Function(BuildContext context)? _contextMenu;

  LdAppBarAction({
    required String label,
    required FutureOr<void> Function(BuildContext context) onPressed,
    Widget? icon,
    required LdLabeledActionSubmitType submitType,
    Widget Function(BuildContext context)? contextMenu,
    String? loadingText,
    LdColor? color,
  })  : _label = label,
        _icon = icon,
        _color = color,
        _contextMenu = contextMenu,
        _onPressed = onPressed,
        _loadingText = loadingText,
        _submitType = submitType;

  @override
  String label(BuildContext context) {
    return _label;
  }

  @override
  Widget? icon(BuildContext context) {
    return _icon;
  }

  @override
  String? loadingText(BuildContext context) {
    return _loadingText;
  }

  @override
  LdColor? color(BuildContext context) {
    return _color;
  }

  @override
  LdLabeledActionSubmitType get submitType => _submitType;

  @override
  FutureOr<void> onPressed(BuildContext context) {
    return _onPressed.call(context);
  }

  @override
  Widget? contextMenu(BuildContext context) {
    return _contextMenu?.call(context);
  }
}
