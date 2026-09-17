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
    final listSelection = selection.selection;

    final newSelection = !listSelection.contains(item.value!.id) ? {item.value!.id} : listSelection;

    final actions = context.read<LdMonkeyActions<T, IdType>>();

    return Provider.value(
      value: LdMonkeySelection<T, IdType>(
        selection: newSelection,
        viewing: selection.viewing,
        showSelectionControls: false,
      ),
      child: Provider.value(
        value: LdMonkeyActionLocation.context,
        child: Provider.value(
          value: newSelection,
          child: Builder(builder: (newContext) {
            final visibleActions = actions
                .where(
                  (e) => e.isVisible(
                    newContext,
                    location: LdMonkeyActionLocation.context,
                  ),
                )
                .toList();

            return LdContextMenu(
              disabled: (listSelection.length > 1 && !listSelection.contains(item.value!.id)) || visibleActions.isEmpty,
              builder: (context, isShuttle, open, isOpen, child) => LdListItemConfigProvider(
                config: LdListItemConfig(active: isOpen ? true : null),
                child: LdButtonConfigProvider(
                  config: LdButtonConfig(active: isOpen),
                  child: child!,
                ),
              ),
              menuProviders: (context) => [
                Provider<LdPaginatorItem<T>>.value(value: item),
                Provider.value(
                  value: context.read<LdMonkeyEffectiveLayoutMode>(),
                ),
                Provider.value(
                  value: LdMonkeyActionLocation.context,
                ),
                Provider<LdMonkeySelection<T, IdType>>.value(
                  value: LdMonkeySelection(
                    selection: newSelection,
                    viewing: selection.viewing,
                    showSelectionControls: selection.showSelectionControls,
                  ),
                ),
                ListenableProvider.value(
                  value: LdListController.of<T, IdType>(context),
                ),
                Provider<List<LdMonkeyAction<T, IdType>>>.value(
                  value: visibleActions,
                ),
                ChangeNotifierProvider<LdMonkeyActionScope<T, IdType>>.value(
                  value: context.read<LdMonkeyActionScope<T, IdType>>(),
                ),
              ],
              menuBuilder: (menuContext) => ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Builder(builder: (context) {
                  final scope = context.read<LdMonkeyActionScope<T, IdType>>();
                  const buttonConfig = LdButtonConfig(
                    borderRadius: BorderRadius.zero,
                    disableSqueeze: true,
                    alignment: MainAxisAlignment.start,
                    autoLoading: false,
                    width: double.infinity,
                    mode: LdButtonMode.ghost,
                  );
                  final menuItems = <Widget>[];
                  for (var i = 0; i < visibleActions.length; i++) {
                    if (i > 0 &&
                        (visibleActions[i] is LdMonkeyActionGroup<T, IdType> ||
                            visibleActions[i - 1] is LdMonkeyActionGroup<T, IdType>)) {
                      menuItems.add(const LdDivider());
                    }
                    final action = visibleActions[i];
                    final triggers = action is LdMonkeyActionGroup<T, IdType>
                        ? action.visibleActions(context).map((child) => child.buildTrigger(context, scope))
                        : [action.buildTrigger(context, scope)];
                    for (final trigger in triggers) {
                      menuItems.add(
                        LdButtonConfigProvider(
                          config: buttonConfig,
                          child: trigger,
                        ),
                      );
                    }
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: menuItems,
                  );
                }),
              ),
              child: child,
            );
          }),
        ),
      ),
    );
  }
}
