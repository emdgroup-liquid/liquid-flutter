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
        final shell = LdMonkeyShellState.of<T, IdType>(context);
        final repository = LdRepository.of<T, IdType>(context);
        final activeFilters = repository.activeFilters;

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
              ChangeNotifierProvider.value(value: shell),
              ListenableProvider<LdRepository<T, IdType>>.value(value: repository),
            ];
          },
          builder: (context, isOpen, open, child) => LdButton(child: icon, onPressed: open),
          menuBuilder: (context, onDismiss) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: LdFilterModal<T, IdType>(),
          ),
        );
      },
    );
