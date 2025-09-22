import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyContextMenu<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget child;
  final LdPaginatorItem<T> item;

  const LdMonkeyContextMenu({super.key, required this.child, required this.item});

  @override
  Widget build(BuildContext context) {
    final selection = LdMonkeySelection.of<T, IdType>(context);
    final listSelection = selection.items;

    final newSelection = !listSelection.contains(item.value!.id) ? {item.value!.id} : listSelection;

    final route = LdMonkey.of<T, IdType>(context);

    return Provider.value(
      value: LdMonkeySelection<T, IdType>(items: newSelection),
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
              Provider<LdMonkey<T, IdType>>.value(value: route),
              Provider<LdMonkeySelection<T, IdType>>.value(
                value: LdMonkeySelection(items: newSelection),
              ),
              Provider<List<LdMonkeyAction<T, IdType>>>.value(
                value: actions.toList(),
              ),
              Provider<LdMonkeyContext<T, IdType>>.value(
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
                        borderRadius: LdTheme.of(context).radius(LdSize.s),
                        onPressed: () {
                          LdContextMenuDissmissNotification().dispatch(context);
                          action.onPressed(context);
                        },
                      ),
                    )
                    .toList(),
              ).padS(),
            ),
          );
        }),
      ),
    );
  }
}
