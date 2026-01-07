import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyMasterPage<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyMasterPage({
    super.key,
    this.buildItem,
    this.appBar,
    this.secondaryAppBar,
    this.buildList,
  }) : assert(buildList != null || buildItem != null, "Either buildList or buildItem must be provided");

  final Widget Function(BuildContext context, LdRepository<T, IdType> repository)? buildList;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item)? buildItem;

  final Widget? appBar;
  final Widget? secondaryAppBar;

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
    final repository = LdRepository.of<T, IdType>(context);
    final searchFilter = repository.filters.values.firstWhereOrNull((filter) => filter is LdFilterSearch)
        as LdFilterSearch<T, IdType, dynamic>?;

    if (searchFilter != null) {
      searchConfig = LdSearchConfig(
        getSuggestions: searchFilter.getSuggestions,
        buildSuggestion: searchFilter.buildSuggestion,
        initialQuery: searchFilter.searchText,
        hint: searchFilter.hint,
        onSearch: (query) {
          repository.updateFilter(searchFilter.name, (filter) {
            filter as LdFilterSearch<T, IdType, dynamic>;
            return filter.copyWith(
              isOn: query.isNotEmpty,
              searchText: query,
            );
          });
        },
      );
    }
  }

  Widget _buildList(
    BuildContext context,
    LdRepository<T, IdType> repository,
    LdMonkeyShellState<T, IdType> shellState,
    LdMonkeyActions<T, IdType> actions,
  ) {
    if (widget.buildList != null) {
      return widget.buildList!(context, repository);
    }
    return LdSelectableList<T, IdType>(
      showSelectionControls: shellState.showSelectionControls,
      paginator: repository,
      initialSelectedItems: shellState.selectedItems,
      multiSelect: shellState.allowMultipleSelection,
      onSelectionChange: (selected) => shellState.setSelectedItems(selected),
      itemBuilder: (context, item, index) => LdMonkeySingleShortcuts<T, IdType>(
        item: item.value!.id,
        actions: actions,
        child: LdMonkeyContextMenu<T, IdType>(
          item: item,
          child: LdListItemAnimation(
            state: item.state,
            child: widget.buildItem?.call(context, item) ??
                LdListItem(
                  title: Text(item.value!.toString()),
                ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shellState = LdMonkeyShellState.of<T, IdType>(context, watch: true);
    final repository = LdRepository.of<T, IdType>(context);
    final actions = context.read<LdMonkeyActions<T, IdType>>();

    return LdNotificationProvider(
      child: LdNotificationPortal(
        child: ListenableBuilder(
          listenable: shellState,
          builder: (context, _) {
            return LdMonkeyMultiShortcuts(
              actions: actions,
              child: Builder(
                builder: (context) {
                  return LdScaffold(
                    appBars: [
                      widget.appBar ??
                          LdMonkeyAppBar<T, IdType>(
                            location: LdMonkeyActionLocation.masterAppBar,
                            debugName: "Master App Bar",
                          ),
                      widget.secondaryAppBar ??
                          LdMonkeyAppBar<T, IdType>(
                            location: LdMonkeyActionLocation.masterSecondary,
                            debugName: "Master Secondary App Bar",
                          ),
                    ],
                    body: _buildList(
                      context,
                      repository,
                      shellState,
                      actions,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
