import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyMasterPage<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyMasterPage({
    super.key,
    this.buildItem,
    this.appBar,
    this.allowMultipleSelection = true,
    this.secondaryAppBar,
    this.buildList,
  }) : assert(buildList != null || buildItem != null, "Either buildList or buildItem must be provided");

  final Widget Function(BuildContext context, LdRepository<T, IdType> repository)? buildList;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item)? buildItem;

  final Widget? appBar;
  final Widget? secondaryAppBar;

  final bool allowMultipleSelection;

  @override
  State<LdMonkeyMasterPage<T, IdType>> createState() => _LdMonkeyMasterPageState<T, IdType>();
}

class _LdMonkeyMasterPageState<T extends Identifiable<IdType>, IdType> extends State<LdMonkeyMasterPage<T, IdType>> {
  Widget _buildList(
    BuildContext context,
    LdRepository<T, IdType> repository,
    LdMonkeyActions<T, IdType> actions,
  ) {
    if (widget.buildList != null) {
      return widget.buildList!(context, repository);
    }

    final selection = LdMonkeySelection.of<T, IdType>(context, listen: true);

    return LdSelectableList<T, IdType>(
      showSelectionControls: selection.showSelectionControls,
      paginator: repository,
      initialSelectedItems: selection.showSelectionControls ? selection.selection : selection.viewing,
      multiSelect: widget.allowMultipleSelection,
      onSelectionChange: (selected) async {
        await Future.delayed(Duration.zero);
        if (!context.mounted) {
          return;
        }
        if (selected.length > 1 || selection.showSelectionControls) {
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

  @override
  Widget build(BuildContext context) {
    LdMonkeySelection.of<T, IdType>(context, listen: true);
    final repository = LdRepository.of<T, IdType>(context);
    final actions = context.read<LdMonkeyActions<T, IdType>>();

    return LdNotificationProvider(
      child: LdNotificationPortal(
        child: LdMonkeyMultiShortcuts(
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
                  actions,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
