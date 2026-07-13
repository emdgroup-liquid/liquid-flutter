import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyMasterPage<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyMasterPage({
    super.key,
    this.buildItem,
    this.allowMultipleSelection = true,
    this.filterBarConfig,
    this.buildList,
  });

  final Widget Function(BuildContext context, LdListController<T, IdType> repository)? buildList;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item)? buildItem;
  final List<LdFilterChipConfig<T, IdType>>? filterBarConfig;

  final bool allowMultipleSelection;

  @override
  State<LdMonkeyMasterPage<T, IdType>> createState() => _LdMonkeyMasterPageState<T, IdType>();
}

class _LdMonkeyMasterPageState<T extends Identifiable<IdType>, IdType> extends State<LdMonkeyMasterPage<T, IdType>> {
  final _listKey = GlobalKey(debugLabel: 'master_page_list');

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildListItemContent(
    BuildContext context,
    LdPaginatorItem<T> item,
    LdMonkeyActions<T, IdType> actions, {
    required bool canReorder,
  }) {
    final content = LdListItemAnimation(
      state: item.state,
      child: widget.buildItem?.call(context, item) ??
          LdListItem(
            title: Text(item.value!.toString()),
          ),
    );

    if (canReorder) {
      return content;
    }

    return LdMonkeySingleShortcuts<T, IdType>(
      item: item.value!.id,
      actions: actions,
      child: LdMonkeyContextMenu<T, IdType>(
        item: item,
        child: content,
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    LdListController<T, IdType> repository,
    LdMonkeyActions<T, IdType> actions,
  ) {
    if (widget.buildList != null) {
      return widget.buildList!(context, repository);
    }

    final selection = LdMonkeySelection.of<T, IdType>(context, listen: true);
    final sortState = LdMonkeySortAndFilterState.of<T, IdType>(context);
    final reorderHandler = context.read<LdMonkeyReorderHandler<T, IdType>?>();

    final interactionMode = context.read<LdMonkeyInteractionMode?>() ?? LdMonkeyInteractionMode.browse;

    final canReorder = sortState.canReorder &&
        selection.selection.length <= 1 &&
        !selection.showSelectionControls &&
        interactionMode != LdMonkeyInteractionMode.pick &&
        reorderHandler != null;

    return LdListConfigProvider<T, IdType>(
      config: LdListConfig<T, IdType>(
        paginator: repository,
        itemBuilder: (context, item, index) => _buildListItemContent(
          context,
          LdPaginatorItem(value: item.value, state: item.state),
          actions,
          canReorder: canReorder,
        ),
        emptyBuilder: (context, onRefresh) {
          final filterState = LdMonkeySortAndFilterState.of<T, IdType>(context);
          final hasActiveFilters = filterState.activeFilters.isNotEmpty;
          return LdListEmpty(
            hasActiveFilters: hasActiveFilters,
            onClearFilters: hasActiveFilters
                ? () async {
                    for (final filter in filterState.activeFilters) {
                      LdMonkeySortAndFilterState.updateFilter<T, IdType>(
                        context,
                        filter.copyWith(isOn: false),
                      );
                    }
                  }
                : null,
            onRefresh: hasActiveFilters ? null : () => onRefresh(context),
          );
        },
      ),
      child: LdSelectableList<T, IdType>(
        key: _listKey,
        showSelectionControls: selection.showSelectionControls,
        listController: repository,
        initialSelectedItems: selection.showSelectionControls ? selection.selection : selection.viewing,
        multiSelect: widget.allowMultipleSelection,
        disableDragGestures: canReorder,
        child: canReorder
            ? LdListReorderScope<T, IdType>(
                onReorder: (id, from, to) => repository.reorder(
                  context,
                  id: id,
                  fromIndex: from,
                  toIndex: to,
                  reorderHandler: reorderHandler,
                ),
                child: LdList<T, IdType>(),
              )
            : LdList<T, IdType>(),
        onSelectionChange: (selected) async {
          await Future.delayed(Duration.zero);
          if (!context.mounted) {
            return;
          }
          if (interactionMode == LdMonkeyInteractionMode.pick ||
              selected.length > 1 ||
              selection.showSelectionControls) {
            LdMonkeySelection.updateSelection<T, IdType>(context, selected);
            LdMonkeySelection.updateShowSelectionControls<T, IdType>(context, true);
          } else {
            LdMonkeySelection.updateViewing<T, IdType>(context, selected);
          }
        },
      ),
    );
  }

  Widget _buildAppBarWrappedBody(Widget body) {
    return LdMonkeyAppBar<T, IdType>(
      location: LdMonkeyActionLocation.masterAppBar,
      child: LdWrapConditional(
        condition: widget.filterBarConfig != null,
        builder: (context, child) => LdAppBarConfigProvider(
          config: LdAppBarConfig(),
          ignoreParent: true,
          child: LdAppBar(
            leading: Expanded(
              child: LdFilterChipsBar<T, IdType>(
                configs: widget.filterBarConfig!,
              ),
            ),
            child: child,
          ),
        ),
        child: LdMonkeyAppBar<T, IdType>(
          location: LdMonkeyActionLocation.masterSecondary,
          child: LdScrollEdgeFade(child: body),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LdMonkeySelection.of<T, IdType>(context, listen: true);
    final repository = LdListController.of<T, IdType>(context);
    final actions = context.watch<LdMonkeyActions<T, IdType>>();

    return LdNotificationProvider(
      child: LdNotificationPortal(
        child: LdMonkeyMultiShortcuts(
          actions: actions,
          child: LdScaffold(
            body: LdListItemConfigProvider(
              config: LdListItemConfig(
                padding: MediaQuery.of(context).padding,
              ),
              child: _buildAppBarWrappedBody(
                _buildList(context, repository, actions),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
