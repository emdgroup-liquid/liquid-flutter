import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> showFilterContextMenu<T extends Identifiable<IdType>, IdType>() =>
    LdMonkeyBareChildAction<T, IdType>(
      onShortcutTrigger: (context) {},
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
        ),
      },
      builder: (context) {
        return LdFilterContextMenu<T, IdType>();
      },
    );

LdMonkeyAction<T, IdType> showFilterModal<T extends Identifiable<IdType>, IdType>() =>
    LdMonkeyBareChildAction<T, IdType>(
      onShortcutTrigger: (context) {},
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
        ),
      },
      builder: (context) => LdAppBarAction(
        active: LdMonkeySortAndFilterState.of<T, IdType>(context).activeFilters.isNotEmpty ||
            LdMonkeySortAndFilterState.of<T, IdType>(context).activeSortOptions.isNotEmpty,
        leading: const Icon(LucideIcons.listFilter),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(
            ldFilterModal<T, IdType>(context),
          );
        },
        child: Text(LiquidLocalizations.of(context).filter),
      ),
    );
