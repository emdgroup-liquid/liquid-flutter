import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

F? findMonkeyFilterByName<T extends Identifiable<IdType>, IdType, F extends LdFilterOption<T, IdType>>(
  BuildContext context, {
  required String filterName,
  bool listen = false,
}) {
  final filterState = LdMonkeySortAndFilterState.of<T, IdType>(context, listen: listen);
  for (final filter in filterState.filters) {
    if (filter.name == filterName && filter is F) {
      return filter;
    }
  }
  return null;
}

Widget? _ldFilterChipTrailing({
  required bool selected,
  required bool showChevron,
  required bool showClearIcon,
}) {
  if (showChevron) {
    return const Icon(LucideIcons.chevronDown);
  }
  if (selected && showClearIcon) {
    return const Icon(LucideIcons.x);
  }
  return null;
}

Widget ldFilterChipButton({
  required bool selected,
  required VoidCallback onPressed,
  required Widget child,
  bool showChevron = false,
  bool showClearIcon = true,
}) {
  final trailing = _ldFilterChipTrailing(
    selected: selected,
    showChevron: showChevron,
    showClearIcon: showClearIcon,
  );
  return selected
      ? LdButton.outline(
          size: LdSize.s,
          active: true,
          onPressed: onPressed,
          trailing: trailing,
          child: child,
        )
      : LdButton.vague(
          size: LdSize.s,
          onPressed: onPressed,
          trailing: trailing,
          child: child,
        );
}

bool isEmptyFilterChipGroup(Widget widget) {
  if (widget is! SizedBox) {
    return false;
  }
  final width = widget.width;
  final height = widget.height;
  return (width == null || width == 0) && (height == null || height == 0);
}
