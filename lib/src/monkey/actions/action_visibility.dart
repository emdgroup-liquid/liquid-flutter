import 'package:liquid_flutter/liquid_flutter.dart';

class LdMonkeyActionVisibility {
  final LdMonkeyActionLocation location;
  final int minSelectionCount;
  final int? maxSelectionCount;
  final bool visibleInSplitView;
  final Set<String> applyFilters;

  LdMonkeyActionVisibility({
    required this.location,
    this.minSelectionCount = 0,
    this.maxSelectionCount,
    this.visibleInSplitView = true,
    this.applyFilters = const {},
  });
}
