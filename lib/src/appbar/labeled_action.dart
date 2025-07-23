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
