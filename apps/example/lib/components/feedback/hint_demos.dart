import 'package:flutter/material.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdHintVariantsDemo extends StatelessWidget {
  const LdHintVariantsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentWell(
      onSurface: true,
      child: LdAutoSpace(
        children: [
          LdHint(type: LdHintType.info, child: const Text('Info')),
          LdHint(type: LdHintType.warning, child: const Text('Warning')),
          LdHint(type: LdHintType.success, child: const Text('Success')),
          LdHint(type: LdHintType.error, child: const Text('Error')),
          LdHint(type: LdHintType.canceled, child: const Text('Canceled')),
          LdHint(type: LdHintType.loading, child: const Text('Loading')),
          LdHint(type: LdHintType.pending, child: const Text('Pending')),
          LdHint(type: LdHintType.ongoing, child: const Text('Ongoing')),
        ],
      ),
    );
  }
}

class LdHintWithBackgroundDemo extends StatelessWidget {
  const LdHintWithBackgroundDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentWell(
      onSurface: true,
      child: LdAutoSpace(
        children: [
          LdHint(type: LdHintType.info, withBackground: true, child: const Text('Info')),
          LdHint(type: LdHintType.warning, withBackground: true, child: const Text('Warning')),
          LdHint(type: LdHintType.success, withBackground: true, child: const Text('Success')),
          LdHint(type: LdHintType.error, withBackground: true, child: const Text('Error')),
          LdHint(type: LdHintType.canceled, withBackground: true, child: const Text('Canceled')),
          LdHint(type: LdHintType.loading, withBackground: true, child: const Text('Loading')),
          LdHint(type: LdHintType.pending, withBackground: true, child: const Text('Pending')),
          LdHint(type: LdHintType.ongoing, withBackground: true, child: const Text('Ongoing')),
        ],
      ),
    );
  }
}
