import 'package:flutter/foundation.dart';

class LdDrawerState {
  final bool isOpen;
  final bool isSideBySide;

  const LdDrawerState({required this.isOpen, required this.isSideBySide});

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(FlagProperty('isOpen', value: isOpen, ifTrue: 'open'));
    properties.add(FlagProperty('isSideBySide', value: isSideBySide, ifTrue: 'enabled'));
  }
}
