import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/ld_master_detail_selection.dart';
import 'package:provider/provider.dart';

class LdMasterDetailAppBarActions<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatelessWidget {
  final LdMasterDetailActionLocation location;

  const LdMasterDetailAppBarActions({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final route = LdMasterDetailRoute.of<T, IdType, GroupingCriterion>(context);

    return StreamBuilder(
      stream: route.repository.updatedItems,
      builder: (context, _) {
        final actions = route.actions.where((e) => e.visibility.any((v) => v.location == location)).toList();

        final hasActions = actions.any((e) => e.isVisible(context, location: location));

        print('actions: $actions');

        final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);

        // Check if we have a search filter
        final searchFilter =
            route.repository.filters.firstWhereOrNull((e) => e is LdFilterSearchOption<T, IdType, dynamic>)
                as LdFilterSearchOption<T, IdType, dynamic>?;

        return LayoutBuilder(builder: (context, constraints) {
          final bool showSearch = searchFilter != null && location == LdMasterDetailActionLocation.masterSecondary;

          return LdReveal.quick(
            revealed: hasActions || searchFilter != null,
            child: Provider.value(
              value: location,
              child: Row(
                children: [
                  if (showSearch)
                    Flexible(
                      fit: FlexFit.loose,
                      child: LdFilterSearchWidget<T, IdType, dynamic>(
                        filter: searchFilter,
                        onFilterChanged: (filter) {
                          route.repository.updateFilter(filter);
                        },
                      ),
                    ),
                  if (hasActions)
                    Flexible(
                      fit: FlexFit.loose,
                      child: LdAppBarActions(
                        actions: actions,
                        menuProviders: (context) => [
                          Provider<LdMasterDetailRoute<T, IdType, GroupingCriterion>>.value(value: route),
                          Provider<LdMasterDetailSelection<T, IdType, GroupingCriterion>>.value(value: selection),
                          Provider<LdMasterContext<T, IdType, GroupingCriterion>>.value(
                              value: LdMasterContext.of(context)),
                          Provider<LdMasterDetailActionLocation>.value(value: location),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
