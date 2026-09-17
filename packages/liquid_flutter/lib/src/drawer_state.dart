import 'package:flutter/foundation.dart';

class LdDrawerState {
  final bool isOpen;
  final bool isSideBySide;

  /// Whether the drawer can be hidden by the user. When false, a side-by-side
  /// drawer is kept permanently open and no close toggle is offered.
  final bool isCollapsible;

  const LdDrawerState({
    required this.isOpen,
    required this.isSideBySide,
    this.isCollapsible = true,
  });

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(FlagProperty('isOpen', value: isOpen, ifTrue: 'open'));
    properties.add(FlagProperty('isSideBySide', value: isSideBySide, ifTrue: 'enabled'));
    properties.add(FlagProperty('isCollapsible', value: isCollapsible, ifTrue: 'collapsible'));
  }
}
