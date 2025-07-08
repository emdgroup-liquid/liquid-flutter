import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/ld_master_detail_selection.dart';
import 'package:provider/provider.dart';

class LdMasterDetailContextMenu<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatelessWidget {
  final Widget child;
  final LdPaginatorItem<T> item;

  const LdMasterDetailContextMenu({super.key, required this.child, required this.item});

  @override
  Widget build(BuildContext context) {
    final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);
    final listSelection = selection.items;

    final newSelection = listSelection.isEmpty ? {item.value!.id} : listSelection;

    final route = LdMasterDetailRoute.of<T, IdType, GroupingCriterion>(context);

    final actions =
        route.actions.where((e) => e.isVisible(context, location: LdMasterDetailActionLocation.context)).toList();

    return Provider.value(
      value: LdMasterDetailSelection<T, IdType, GroupingCriterion>(items: newSelection),
      child: LdContextMenu(
        child: child,
        disabled: (listSelection.length > 1 && !listSelection.contains(item.value!.id)) || actions.isEmpty,
        builder: (context, isOpen, open, child) => child!,
        menuProviders: (context) => [
          Provider<LdPaginatorItem<T>>.value(value: item),
          Provider<LdMasterDetailRoute<T, IdType, GroupingCriterion>>.value(value: route),
          Provider<LdMasterDetailSelection<T, IdType, GroupingCriterion>>.value(value: selection),
          Provider<List<LdMasterDetailAction<T, IdType, GroupingCriterion>>>.value(value: actions),
        ],
        menuBuilder: (context, menuBuilder) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions
                .map(
                  (action) => LdListItem(
                    title: Text(action.label(context)),
                    leading: action.icon(context),
                    onTap: () {
                      LdContextMenuDissmissNotification().dispatch(context);
                      action.onPressed(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
