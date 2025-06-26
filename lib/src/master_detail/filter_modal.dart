import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

LdModal ldFilterModal(BuildContext context) {
  return LdModal(
    title: LiquidLocalizations.of(context).filter,
  );
}

class LdFilterModal extends StatelessWidget {
  const LdFilterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return LdModal(child: const Text("Filter"));
  }
}
