import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// The shortcuts for multiple items. Will only apply the shortcuts if the user
/// is currently selecting multiple items.
class LdMonkeyMultiShortcuts<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final List<LdMonkeyAction<T, IdType>> actions;
  final Widget child;

  const LdMonkeyMultiShortcuts({super.key, required this.actions, required this.child});

  @override
  Widget build(BuildContext context) {
    final bindings = <ShortcutActivator, VoidCallback>{};

    final selection = LdMonkeySelection.of<T, IdType>(context);

    for (final action in actions) {
      for (final activator in action.shortcutActivators) {
        if (bindings[activator] != null) {
          throw Exception(
            "Shortcut activator already in use: $activator",
          );
        }

        if (selection.items.length > 1 && action.multiSelect) {
          bindings[activator] = () {
            action.onShortcutPressed(context);
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
class LdMonkeySingleShortcuts<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final List<LdMonkeyAction<T, IdType>> actions;
  final Widget child;
  final IdType item;

  const LdMonkeySingleShortcuts({super.key, required this.actions, required this.child, required this.item});

  @override
  Widget build(BuildContext context) {
    final bindings = <ShortcutActivator, VoidCallback>{};
    final selection = LdMonkeySelection.of<T, IdType>(context);

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
          action.onShortcutPressed(context);
        };
      }
    }

    return CallbackShortcuts(
      bindings: bindings,
      child: child,
    );
  }
}
