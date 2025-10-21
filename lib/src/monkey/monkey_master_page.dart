import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/device_info.dart';

import 'package:provider/provider.dart';

class LdMonkeyMasterPage<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final LdMonkey<T, IdType> route;

  const LdMonkeyMasterPage({
    super.key,
    required this.route,
  });

  @override
  State<LdMonkeyMasterPage<T, IdType>> createState() => _LdMonkeyMasterPageState<T, IdType>();
}

class _LdMonkeyMasterPageState<T extends Identifiable<IdType>, IdType> extends State<LdMonkeyMasterPage<T, IdType>> {
  @override
  void dispose() {
    super.dispose();
  }

  LdSearchConfig? searchConfig;

  @override
  void initState() {
    super.initState();
    final searchFilter = widget.route.repository.filters.values
        .firstWhereOrNull((filter) => filter is LdFilterSearchOption) as LdFilterSearchOption<T, IdType, dynamic>?;

    if (searchFilter != null) {
      searchConfig = LdSearchConfig(
        getSuggestions: searchFilter.getSuggestions,
        buildSuggestion: searchFilter.buildSuggestion,
        onSearch: (query) {
          widget.route.repository.updateFilter(searchFilter.name, (filter) {
            filter as LdFilterSearchOption<T, IdType, dynamic>;
            return filter.copyWith(
              isOn: query.isNotEmpty,
              searchText: query,
            );
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LdNotificationProvider(
      child: LdNotificationPortal(
        child: StreamBuilder(
            stream: widget.route.stateStream,
            initialData: widget.route.state,
            builder: (context, asyncSnapshot) {
              final state = asyncSnapshot.data!;
              // Provide  the state of the route to the list builder

              return Provider.value(
                value: LdMonkeySelection<T, IdType>(items: state.selectedItems),
                child: LdMonkeyMultiShortcuts(
                  actions: widget.route.actions,
                  child: Builder(builder: (context) {
                    final primaryActions = LdMonkeyAppBarActions.getActionsAndProviders<T, IdType>(
                      context,
                      LdMonkeyActionLocation.masterAppBar,
                    );

                    final secondaryActions = LdMonkeyAppBarActions.getActionsAndProviders<T, IdType>(
                      context,
                      LdMonkeyActionLocation.masterSecondary,
                    );

                    return LdScaffold(
                      appBar: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Provider.value(
                            value: LdMonkeyActionLocation.masterAppBar,
                            child: LdAppBar(
                              title: Text(widget.route.repository.pluralItemTitle),
                              actions: primaryActions.actions,
                              overflowMenuProviders: primaryActions.menuProviders,
                            ),
                          ),
                        ],
                      ),
                      secondaryNavigationBar: (secondaryActions.hasActions || searchConfig != null)
                          ? Provider.value(
                              value: LdMonkeyActionLocation.masterSecondary,
                              child: LayoutBuilder(builder: (context, constraints) {
                                return LdAppBar(
                                  implyLeading: false,
                                  actions: secondaryActions.actions,
                                  overflowMenuProviders: secondaryActions.menuProviders,
                                  searchConfig: searchConfig,
                                );
                              }),
                            )
                          : null,
                      body: widget.route.listBuilder(
                        widget.route,
                        state,
                        (selection) {
                          widget.route.setSelectedItems(selection);
                        },
                      ),
                    );
                  }),
                ),
              );
            }),
      ),
    );
  }
}
