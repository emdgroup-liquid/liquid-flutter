import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyContextMenu<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatelessWidget {
  final Widget child;
  final LdPaginatorItem<T> item;

  const LdMonkeyContextMenu({super.key, required this.child, required this.item});

  @override
  Widget build(BuildContext context) {
    final selection = LdMonkeySelection.of<T, IdType, GroupingCriterion>(context);
    final listSelection = selection.items;

    final newSelection = !listSelection.contains(item.value!.id) ? {item.value!.id} : listSelection;

    final route = LdMonkey.of<T, IdType, GroupingCriterion>(context);

    return Provider.value(
      value: LdMonkeySelection<T, IdType, GroupingCriterion>(items: newSelection),
      child: Provider.value(
        value: newSelection,
        child: Builder(builder: (newContext) {
          final actions = route.actions.where((e) => e.isVisible(newContext, location: LdMonkeyActionLocation.context));
          return LdContextMenu(
            child: child,
            disabled: (listSelection.length > 1 && !listSelection.contains(item.value!.id)) || actions.isEmpty,
            builder: (context, isOpen, open, child) => child!,
            menuProviders: (context) => [
              Provider<LdPaginatorItem<T>>.value(value: item),
              Provider<LdMonkey<T, IdType, GroupingCriterion>>.value(value: route),
              Provider<LdMonkeySelection<T, IdType, GroupingCriterion>>.value(
                value: LdMonkeySelection(items: newSelection),
              ),
              Provider<List<LdMonkeyAction<T, IdType, GroupingCriterion>>>.value(
                value: actions.toList(),
              ),
              Provider<LdMonkeyContext<T, IdType, GroupingCriterion>>.value(
                value: LdMonkeyContext.fromRoute(route, newContext),
              ),
            ],
            menuBuilder: (context, menuBuilder) => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: actions
                    .where((e) => e.isVisible(context, location: LdMonkeyActionLocation.context))
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
          );
        }),
      ),
    );
  }
}
