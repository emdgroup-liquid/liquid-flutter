import 'dart:async';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Defines the behaviour of a [LdLabeledAction] when it is pressed
enum LdLabeledActionType { none, notification, dialog, contextMenu }

// A class that represents an action that can be displayed in toolbars and menus
mixin LdLabeledAction {
  String label(BuildContext context);
  Widget? icon(BuildContext context);
  String? loadingText(BuildContext context);
  bool isActive(BuildContext context) => false;

  Widget? buildContextMenu(BuildContext context, VoidCallback close) => null;

  bool isVisible(BuildContext context) => true;

  FutureOr<void> onPressed(BuildContext context);

  LdColor? color(BuildContext context) => null;

  LdLabeledActionType get type => LdLabeledActionType.notification;
}

typedef LdLabeledActionActiveFunction = bool Function(BuildContext context);

typedef LdLabeledActionContextMenuFunction = Widget Function(BuildContext context, VoidCallback close);

typedef LdBoolPredicate = bool Function(BuildContext context);
typedef StringBuilder = String Function(BuildContext context);

class LdLabeledActionBuilder with LdLabeledAction {
  final StringBuilder _buildLabel;
  final WidgetBuilder? _buildIcon;
  final FutureOr<void> Function(BuildContext context) _action;
  final StringBuilder? _buildLoadingText;
  final LdLabeledActionType _submitType;
  final LdColor? _color;
  final LdLabeledActionContextMenuFunction? _buildContextMenu;
  final LdBoolPredicate? _isActive;

  LdLabeledActionBuilder({
    required StringBuilder buildLabel,
    required FutureOr<void> Function(BuildContext context) action,
    required LdLabeledActionType submitType,
    WidgetBuilder? buildIcon,
    LdLabeledActionContextMenuFunction? buildContextMenu,
    StringBuilder? buildLoadingText,
    LdBoolPredicate? isActive,
    LdColor? color,
  })  : _buildLabel = buildLabel,
        _buildIcon = buildIcon,
        _color = color,
        _buildContextMenu = buildContextMenu,
        _action = action,
        _buildLoadingText = buildLoadingText,
        _submitType = submitType,
        _isActive = isActive;

  @override
  bool isActive(BuildContext context) {
    return _isActive?.call(context) ?? false;
  }

  @override
  String label(BuildContext context) {
    return _buildLabel.call(context);
  }

  @override
  Widget? icon(BuildContext context) {
    return _buildIcon?.call(context);
  }

  @override
  String? loadingText(BuildContext context) {
    return _buildLoadingText?.call(context);
  }

  @override
  LdColor? color(BuildContext context) {
    return _color;
  }

  @override
  LdLabeledActionType get type => _submitType;

  @override
  FutureOr<void> onPressed(BuildContext context) {
    return _action.call(context);
  }

  @override
  Widget? buildContextMenu(BuildContext context, VoidCallback close) {
    return _buildContextMenu?.call(context, close);
  }
}
