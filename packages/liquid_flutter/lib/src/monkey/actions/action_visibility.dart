import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyActionVisibility<T extends Identifiable<IdType>, IdType> {
  final LdMonkeyActionLocation location;
  final int minSelectionCount;
  final int? maxSelectionCount;
  final bool? visibleWhenShowingSelectionControls;
  final Set<LdMonkeyEffectiveLayoutMode> layoutModes;

  /// Custom visibility predicate.
  ///
  /// Receives an up-to-date [LdMonkeyActionContext] that is bound to the
  /// selection and the [LdListController], so the predicate is re-evaluated
  /// whenever the selection or the underlying items change.
  final bool Function(LdMonkeyActionContext<T, IdType> context)? isVisible;

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

  bool isVisibleInContext(BuildContext context, {LdMonkeyActionLocation? location}) {
    location ??= context.read<LdMonkeyActionLocation>();
    final predicate = isVisible;
    if (predicate != null) {
      final actionContext = LdMonkeyActionContext.of<T, IdType>(
        context,
        appContext: context,
        listen: true,
      );
      if (!predicate(actionContext)) {
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
