import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/filter_modal.dart';
import 'package:liquid_flutter/src/master_detail/ld_master_detail_selection.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

LdMasterDetailAction<T, IdType, GroupingCriterion>
    toggleFilters<T extends Identifiable<IdType>, IdType, GroupingCriterion>() =>
        LdMasterDetailAction<T, IdType, GroupingCriterion>(
          visibility: {
            LdMasterDetailActionVisibility(
              location: LdMasterDetailActionLocation.masterAppBar,
              minSelectionCount: 0,
              maxSelectionCount: null,
            ),
          },
          buildLabel: (context, selection) {
            return LiquidLocalizations.of(context).filter;
          },
          buildIcon: (context, selection) {
            final route = context.watch<LdMasterDetailRoute<T, IdType, GroupingCriterion>>();

            final activeFilters = route.repository.filters.where((e) => e.isOn).toList();

            if (activeFilters.isNotEmpty) {
              return Center(
                child: Stack(
                  children: [
                    const Center(child: Icon(LucideIcons.listFilter)),
                    Transform.scale(
                      alignment: Alignment.topRight,
                      scale: 0.5,
                      child: LdBadge(
                        color: LdTheme.of(context).warning,
                        child: Text(activeFilters.length.toString()),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Icon(LucideIcons.listFilter);
          },
          submitType: LdLabeledActionSubmitType.contextMenu,
          buildMenuProviders: (context) => [
            Provider.value(value: context.read<LdMasterDetailRoute<T, IdType, GroupingCriterion>>()),
            Provider.value(value: context.read<LdMasterDetailSelection<T, IdType, GroupingCriterion>>()),
          ],
          buildContextMenu: (context, close) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: LdFilterModal(
              route: context.read<LdMasterDetailRoute<T, IdType, GroupingCriterion>>(),
            ),
          ),
          action: (context, selection) {},
        );
