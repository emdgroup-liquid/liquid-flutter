import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/master_detail/ld_master_detail_selection.dart';

/// The shortcuts for multiple items. Will only apply the shortcuts if the user
/// is currently selecting multiple items.
class LdMasterDetailMultiShortcuts<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatelessWidget {
  final List<LdMasterDetailAction<T, IdType, GroupingCriterion>> actions;
  final Widget child;

  const LdMasterDetailMultiShortcuts({super.key, required this.actions, required this.child});

  @override
  Widget build(BuildContext context) {
    final bindings = <ShortcutActivator, VoidCallback>{};

    final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);

    for (final action in actions) {
      for (final activator in action.shortcutActivators) {
        if (bindings[activator] != null) {
          throw Exception(
            "Shortcut activator already in use: $activator",
          );
        }

        if (selection.items.length > 1 && action.multiSelect) {
          bindings[activator] = () {
            action.action(context, selection.items);
          };
        }
      }
    }

    return CallbackShortcuts(
      bindings: bindings,
      child: child,
    );
  }
}

/// The shortcuts for a single item. Will only apply the shortcuts if the user
/// is currently not selecting multiple items.
class LdMasterDetailSingleShortcuts<T extends Identifiable<IdType>, IdType, GroupingCriterion> extends StatelessWidget {
  final List<LdMasterDetailAction<T, IdType, GroupingCriterion>> actions;
  final Widget child;
  final IdType item;

  const LdMasterDetailSingleShortcuts({super.key, required this.actions, required this.child, required this.item});

  @override
  Widget build(BuildContext context) {
    final bindings = <ShortcutActivator, VoidCallback>{};
    final selection = LdMasterDetailSelection.of<T, IdType, GroupingCriterion>(context);

    if (selection.items.length > 1) {
      return child;
    }

    for (final action in actions) {
      for (final activator in action.shortcutActivators) {
        if (bindings[activator] != null) {
          throw Exception(
            "Shortcut activator already in use: $activator",
          );
        }

        bindings[activator] = () {
          action.action(context, {item});
        };
      }
    }

    return CallbackShortcuts(
      bindings: bindings,
      child: child,
    );
  }
}
