import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Wraps [body] inside [bar] when [bar] is a [LdMonkeyAppBar]; otherwise
/// renders [bar] standalone and places [body] below it in a [Column].
///
/// This lets monkey pages work correctly with both:
/// - The new wrapper-based pattern (LdMonkeyAppBar with child).
/// - Legacy / test usages that pass arbitrary widgets as bars.
Widget _wrapBodyWithBar<T extends Identifiable<IdType>, IdType>(Widget bar, Widget body) {
  if (bar is LdMonkeyAppBar<T, IdType>) {
    return LdMonkeyAppBar<T, IdType>(
      key: bar.key,
      title: bar.title,
      additionalActions: bar.additionalActions,
      positionMode: bar.positionMode,
      location: bar.location,
      leading: bar.leading,
      debugName: bar.debugName,
      backgroundMode: bar.backgroundMode,
      shadowMode: bar.shadowMode,
      borderMode: bar.borderMode,
      implyLeading: bar.implyLeading,
      bottom: bar.bottom,
      child: body,
    );
  }
  // Fallback: stack the bar and body in a Column for non-LdMonkeyAppBar widgets.
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [bar, Expanded(child: body)],
  );
}

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
              final body = _buildList(context, repository, actions);

              final primaryBar = widget.appBar ??
                  LdMonkeyAppBar<T, IdType>(
                    location: LdMonkeyActionLocation.masterAppBar,
                    debugName: "Master App Bar",
                  );

              final secondaryBar = widget.secondaryAppBar ??
                  LdMonkeyAppBar<T, IdType>(
                    location: LdMonkeyActionLocation.masterSecondary,
                    debugName: "Master Secondary App Bar",
                  );

              // New wrapper-based composition: secondary bar wraps the body,
              // then primary bar wraps the secondary+body subtree.
              final wrapped = _wrapBodyWithBar<T, IdType>(
                primaryBar,
                _wrapBodyWithBar<T, IdType>(secondaryBar, body),
              );

              return LdScaffold(body: wrapped);
            },
          ),
        ),
      ),
    );
  }
}
