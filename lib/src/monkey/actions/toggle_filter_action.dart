import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

LdMonkeyAction<T, IdType> toggleFilters<T extends Identifiable<IdType>, IdType>() => LdMonkeyBareChildAction<T, IdType>(
      onShortcutTrigger: (context) {},
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
        ),
      },
      builder: (context) {
        final route = context.watch<LdMonkey<T, IdType>>();

        final activeFilters = route.repository.activeFilters;

        Widget icon;

        if (activeFilters.isNotEmpty) {
          icon = Center(
            child: Stack(
              children: [
                const Center(child: Icon(LucideIcons.listFilter)),
                Transform.scale(
                  alignment: Alignment.topRight,
                  scale: 0.8,
                  child: Transform.translate(
                    offset: const Offset(8, -8),
                    child: LdBadge(
                      color: LdTheme.of(context).warning,
                      child: Text(activeFilters.length.toString()),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          icon = const Icon(LucideIcons.listFilter);
        }
        return LdContextMenu(
          menuProviders: (context) {
            return [
              Provider<LdMonkey<T, IdType>>.value(value: route),
            ];
          },
          builder: (context, isOpen, open, child) => LdButton(child: icon, onPressed: open),
          menuBuilder: (context, onDismiss) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: LdFilterModal(route: route),
          ),
        );
      },
    );
