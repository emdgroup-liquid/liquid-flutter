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
        child: Text(LiquidLocalizations.of(context).filter),
        active: LdRepository.of<T, IdType>(context).activeFilters.isNotEmpty,
        leading: const Icon(LucideIcons.listFilter),
        onPressed: () {
          Navigator.push(context, ldFilterModal<T, IdType>(context));
        },
      ),
    );
