import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyActionVisibility {
  final LdMonkeyActionLocation location;
  final int minSelectionCount;
  final int? maxSelectionCount;
  final bool? visibleWhenShowingSelectionControls;
  final Set<LdMonkeyEffectiveLayoutMode> layoutModes;

  final bool Function(BuildContext context)? isVisible;

  LdMonkeyActionVisibility({
    required this.location,
    this.minSelectionCount = 0,
    this.maxSelectionCount,
    this.layoutModes = const {
      LdMonkeyEffectiveLayoutMode.master,
      LdMonkeyEffectiveLayoutMode.detail,
      LdMonkeyEffectiveLayoutMode.sideBySide,
    },
    this.visibleWhenShowingSelectionControls,
    this.isVisible,
  });

  bool isVisibleInContext<T extends Identifiable<IdType>, IdType>(BuildContext context,
      {LdMonkeyActionLocation? location}) {
    location ??= context.read<LdMonkeyActionLocation>();
    if (isVisible != null) {
      if (!isVisible!(context)) {
        return false;
      }
    }
    if (location != this.location) {
      return false;
    }

    final selection = LdMonkeySelection.of<T, IdType>(context);
    final selectedItems = LdMonkeySelection.adaptive<T, IdType>(context, location: location);

    if (!layoutModes.contains(context.read<LdMonkeyEffectiveLayoutMode>())) {
      return false;
    }

    if (visibleWhenShowingSelectionControls == false && selection.showSelectionControls) {
      return false;
    }

    if ((maxSelectionCount != null && selectedItems.length > maxSelectionCount!) ||
        (minSelectionCount != 0 && selectedItems.length < minSelectionCount)) {
      return false;
    }

    return true;
  }
}
