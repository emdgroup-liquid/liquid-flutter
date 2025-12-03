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

    final shell = LdMonkeyShellState.of<T, IdType>(context);
    final actions = context.read<LdMonkeyActions<T, IdType>>();

    return Provider.value(
      value: LdMonkeySelection<IdType>(items: newSelection),
      child: Provider.value(
        value: newSelection,
        child: Builder(builder: (newContext) {
          final visibleActions =
              actions.where((e) => e.isVisible(context, location: LdMonkeyActionLocation.context)).toList();

          return LdContextMenu(
            child: child,
            disabled: (listSelection.length > 1 && !listSelection.contains(item.value!.id)) || visibleActions.isEmpty,
            builder: (context, isOpen, open, child) => child!,
            menuProviders: (context) => [
              Provider<LdPaginatorItem<T>>.value(value: item),
              ChangeNotifierProvider<LdMonkeyShellState<T, IdType>>.value(value: shell),
              Provider.value(
                value: context.read<LdMonkeyEffectiveLayoutMode>(),
              ),
              Provider<LdMonkeySelection<IdType>>.value(
                value: LdMonkeySelection(items: newSelection),
              ),
              ListenableProvider.value(
                value: LdRepository.of<T, IdType>(context),
              ),
              Provider<List<LdMonkeyAction<T, IdType>>>.value(
                value: visibleActions,
              ),
            ],
            menuBuilder: (context) => ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: visibleActions
                    .map(
                      (action) => LdButtonConfigProvider(
                          const LdButtonConfig(
                            borderRadius: BorderRadius.zero,
                            disableSqueeze: true,
                            alignment: MainAxisAlignment.start,
                            autoLoading: false,

                            //color: LdTheme.of(context).palette.neutral,
                            width: double.infinity,
                            mode: LdButtonMode.ghost,
                          ),
                          action.build(context)),
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
