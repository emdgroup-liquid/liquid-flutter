import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/modal/modal.dart';

class LdModalPage extends Page {
  final LdModal builder;

  const LdModalPage({
    super.key,
    super.name,
    required this.builder,
  });

  @override
  Route<void> createRoute(BuildContext context) {
    return builder.asRoute(this);
  }
}
