import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/ld_master_detail_selection.dart';
import 'package:provider/provider.dart';

class LdMasterDetailActionVisibility {
  final LdMasterDetailActionLocation location;
  final int minSelectionCount;
  final int? maxSelectionCount;
  final bool visibleInSplitView;
  final Set<String> applyFilters;

  LdMasterDetailActionVisibility({
    required this.location,
    this.minSelectionCount = 0,
    this.maxSelectionCount,
    this.visibleInSplitView = true,
    this.applyFilters = const {},
  });
}

enum LdMasterDetailActionLocation {
  masterAppBar,
  masterSecondary,
  detailAppBar,
  detailSecondary,
  context,
}

class LdMasterDetailAction<T extends Identifiable<IdType>, IdType, GroupingCriterion> with LdLabeledAction {
  final Set<LdMasterDetailActionVisibility> visibility;

  final String Function(BuildContext context, Set<IdType> selection) buildLabel;
  final Widget Function(BuildContext context, Set<IdType> selection)? buildIcon;
  final FutureOr<void> Function(BuildContext context, Set<IdType> selection) action;
  final String Function(BuildContext context, Set<IdType> selection)? buildLoadingText;

  @override
  String? loadingText(BuildContext context) {
    final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);
    return buildLoadingText?.call(context, selection.items);
  }

  @override
  String label(BuildContext context) {
    final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);
    return buildLabel(context, selection.items);
  }

  @override
  Widget? icon(BuildContext context) {
    final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);
    return buildIcon?.call(context, selection.items);
  }

  @override
  void onPressed(BuildContext context) async {
    final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context, listen: false);
    await action(context, selection.items);
  }

  @override
  bool isVisible(BuildContext context, {LdMasterDetailActionLocation? location}) {
    location ??= context.read<LdMasterDetailActionLocation>();

    final isSplit = LdMasterContext.of<T, IdType, GroupingCriterion>(context).isSplit;

    final route = LdMasterDetailRoute.of<T, IdType, GroupingCriterion>(context);

    final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);

    final selectedItemCount = selection.items.length;

    if (!visibility.any((e) => e.location == location)) {
      return false;
    }

    final selectedItems =
        selection.items.map((e) => route.repository.getItemById(e)).whereType<LdPaginatorItem<T>>().toList();

    for (final visibility in this.visibility) {
      if (visibility.location != location) continue;

      if (!isSplit && !visibility.visibleInSplitView) {
        continue;
      }

      if (visibility.applyFilters.isNotEmpty) {
        final filters = visibility.applyFilters.map(
          (filterName) => route.repository.filters.firstWhere((e) => e.name == filterName),
        );

        for (final filter in filters) {
          if (selectedItems.any((e) => !filter.optimisticFilter(e.value!))) {
            return false;
          }
        }
      }

      if ((visibility.maxSelectionCount == null || selectedItemCount <= visibility.maxSelectionCount!) &&
          selectedItemCount >= visibility.minSelectionCount) {
        return true;
      }
    }

    return false;
  }

  final bool multiSelect;

  final LdLabeledActionSubmitType _submitType;

  @override
  LdLabeledActionSubmitType get submitType => _submitType;

  final LdColor? _color;

  @override
  LdColor? color(BuildContext context) {
    return _color;
  }

  LdMasterDetailAction({
    required this.visibility,
    required this.buildLabel,
    this.buildLoadingText,
    LdColor? color,
    this.buildIcon,
    required this.action,
    this.multiSelect = true,
    LdLabeledActionSubmitType submitType = LdLabeledActionSubmitType.notification,
    this.shortcutActivators = const {},
  })  : _color = color,
        _submitType = submitType;

  final Set<ShortcutActivator> shortcutActivators;

  LdMasterDetailAction<T, IdType, GroupingCriterion> copyWith({
    Set<LdMasterDetailActionVisibility>? visibility,
    String Function(BuildContext context, Set<IdType> selection)? buildLabel,
    Widget Function(BuildContext context, Set<IdType> selection)? buildIcon,
    Future<void> Function(BuildContext context, Set<IdType> selection)? action,
  }) {
    return LdMasterDetailAction(
      visibility: visibility ?? this.visibility,
      buildLabel: buildLabel ?? this.buildLabel,
      buildIcon: buildIcon ?? this.buildIcon,
      action: action ?? this.action,
    );
  }
}
