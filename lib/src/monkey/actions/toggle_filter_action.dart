import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

LdMonkeyAction<T, IdType> toggleFilters<T extends Identifiable<IdType>, IdType>() => LdMonkeyAction<T, IdType>(
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
        ),
      },
      buildLabel: (context) {
        return LiquidLocalizations.of(context).filter;
      },
      buildIcon: (context) {
        final route = context.watch<LdMonkey<T, IdType>>();

        final activeFilters = route.repository.filters.where((e) => e.isOn).toList();

        if (activeFilters.isNotEmpty) {
          return Center(
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
        }
        return const Icon(LucideIcons.listFilter);
      },
      submitType: LdLabeledActionType.contextMenu,
      buildContextMenu: (context, close) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: LdFilterModal(
          route: context.read<LdMonkey<T, IdType>>(),
        ),
      ),
      action: (context) {},
    );
