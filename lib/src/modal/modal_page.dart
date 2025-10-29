import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/modal/modal.dart';

class LdModalPage extends Page {
  final LdModal modal;

  const LdModalPage({
    super.key,
    super.name,
    required this.modal,
  });

  @override
  Route<void> createRoute(BuildContext context) {
    return modal.asRoute(this, context);
  }
}
