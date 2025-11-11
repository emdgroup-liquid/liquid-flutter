import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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
    final searchFilter = repository.filters.values.firstWhereOrNull((filter) => filter is LdFilterSearchOption)
        as LdFilterSearchOption<T, IdType, dynamic>?;

    if (searchFilter != null) {
      searchConfig = LdSearchConfig(
        getSuggestions: searchFilter.getSuggestions,
        buildSuggestion: searchFilter.buildSuggestion,
        onSearch: (query) {
          repository.updateFilter(searchFilter.name, (filter) {
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

  Widget _buildList(
    BuildContext context,
    LdRepository<T, IdType> repository,
    LdMonkeyShellState<T, IdType> shellState,
  ) {
    if (widget.buildList != null) {
      return widget.buildList!(context, repository);
    }
    return LdSelectableList<T, IdType>(
      showSelectionControls: shellState.showSelectionControls,
      paginator: repository,
      initialSelectedItems: shellState.selectedItems,
      multiSelect: true,
      onSelectionChange: (selected) => shellState.setSelectedItems(selected),
      itemBuilder: (context, item, index) => LdMonkeySingleShortcuts(
        item: item.value!.id,
        actions: shellState.actions,
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

    return LdNotificationProvider(
      child: LdNotificationPortal(
        child: StreamBuilder<Set<IdType>>(
          stream: shellState.selectedItemsStream,
          initialData: shellState.selectedItems,
          builder: (context, selectionSnapshot) {
            return LdMonkeyMultiShortcuts(
              actions: shellState.actions,
              child: Builder(
                builder: (context) {
                  return LdScaffold(
                    appBar: widget.appBar ?? LdMonkeyAppBar<T, IdType>(location: LdMonkeyActionLocation.masterAppBar),
                    secondaryAppBar: widget.secondaryAppBar ??
                        LdMonkeyAppBar<T, IdType>(location: LdMonkeyActionLocation.masterSecondary),
                    body: _buildList(context, repository, shellState),
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
