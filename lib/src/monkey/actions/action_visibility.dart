import 'package:liquid_flutter/liquid_flutter.dart';

class LdMonkeyActionVisibility {
  final LdMonkeyActionLocation location;
  final int minSelectionCount;
  final int? maxSelectionCount;
  final bool? visibleWhenShowingSelectionControls;
  final Set<LdMonkeyEffectiveLayoutMode> layoutModes;

  final Set<String> applyFilters;

  LdMonkeyActionVisibility({
    required this.location,
    this.minSelectionCount = 0,
    this.maxSelectionCount,
    this.applyFilters = const {},
    this.layoutModes = const {
      LdMonkeyEffectiveLayoutMode.master,
      LdMonkeyEffectiveLayoutMode.detail,
      LdMonkeyEffectiveLayoutMode.sideBySide,
    },
    this.visibleWhenShowingSelectionControls,
  });
}
