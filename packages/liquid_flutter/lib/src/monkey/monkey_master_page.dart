import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyMasterPage<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyMasterPage({
    super.key,
    this.buildItem,
    this.primaryAppBarConfig,
    this.primaryAppBarAdditionalActions = const [],
    this.allowMultipleSelection = true,
    this.secondaryAppBarConfig,
    this.filterBarConfig,
    this.buildList,
  }) : assert(buildList != null || buildItem != null, "Either buildList or buildItem must be provided");

  final Widget Function(BuildContext context, LdRepository<T, IdType> repository)? buildList;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item)? buildItem;
  final List<LdFilterChipConfig<T, IdType>>? filterBarConfig;

  final LdAppBarConfig? primaryAppBarConfig;
  final LdAppBarConfig? secondaryAppBarConfig;
  final List<Widget> primaryAppBarAdditionalActions;

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

  Widget _buildList(
    BuildContext context,
    LdRepository<T, IdType> repository,
    LdMonkeyActions<T, IdType> actions,
  ) {
    if (widget.buildList != null) {
      return widget.buildList!(context, repository);
    }

    final selection = LdMonkeySelection.of<T, IdType>(context, listen: true);

    final interactionMode = context.read<LdMonkeyInteractionMode?>() ?? LdMonkeyInteractionMode.browse;

    return LdSelectableList<T, IdType>(
      key: _listKey,
      showSelectionControls: selection.showSelectionControls,
      paginator: repository,
      initialSelectedItems: selection.showSelectionControls ? selection.selection : selection.viewing,
      multiSelect: widget.allowMultipleSelection,
      onSelectionChange: (selected) async {
        await Future.delayed(Duration.zero);
        if (!context.mounted) {
          return;
        }
        if (interactionMode == LdMonkeyInteractionMode.pick || selected.length > 1 || selection.showSelectionControls) {
          LdMonkeySelection.updateSelection<T, IdType>(context, selected);
          LdMonkeySelection.updateShowSelectionControls<T, IdType>(context, true);
        } else {
          LdMonkeySelection.updateViewing<T, IdType>(context, selected);
        }
      },
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

  Widget _buildAppBarWrappedBody(Widget body) {
    return LdWrapConditional(
      condition: widget.primaryAppBarConfig != null,
      builder: (context, child) => LdAppBarConfigProvider(
        config: widget.primaryAppBarConfig!,
        child: child,
      ),
      child: LdMonkeyAppBar<T, IdType>(
        location: LdMonkeyActionLocation.masterAppBar,
        additionalActions: widget.primaryAppBarAdditionalActions,
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
          child: LdAppBarConfigProvider(
            config: widget.secondaryAppBarConfig ?? const LdAppBarConfig(),
            ignoreParent: true,
            child: LdMonkeyAppBar<T, IdType>(
              location: LdMonkeyActionLocation.masterSecondary,
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LdMonkeySelection.of<T, IdType>(context, listen: true);
    final repository = LdRepository.of<T, IdType>(context);
    final actions = context.read<LdMonkeyActions<T, IdType>>();

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
                LdAutoBackground(invert: true, child: _buildList(context, repository, actions)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
