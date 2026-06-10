import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> showFilterContextMenu<T extends Identifiable<IdType>, IdType>() =>
    LdMonkeyBareChildAction<T, IdType>(
      onTrigger: (_) async {},
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
        ),
      },
      builder: (ctx, trigger) {
        return LdFilterContextMenu<T, IdType>();
      },
    );

LdMonkeyAction<T, IdType> showFilterModal<T extends Identifiable<IdType>, IdType>() =>
    LdMonkeyBareChildAction<T, IdType>(
      onTrigger: (_) async {},
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
        ),
      },
      builder: (ctx, trigger) {
        final filterState = LdMonkeySortAndFilterState.of<T, IdType>(ctx.appContext);
        return LdAppBarAction(
          active: filterState.activeFilters.isNotEmpty || filterState.activeSortOptions.isNotEmpty,
          leading: const Icon(LucideIcons.listFilter),
          onPressed: () {
            Navigator.of(ctx.appContext, rootNavigator: true).push(
              ldFilterModal<T, IdType>(ctx.appContext),
            );
          },
          child: Text(LiquidLocalizations.of(ctx.appContext).filter),
        );
      },
    );
