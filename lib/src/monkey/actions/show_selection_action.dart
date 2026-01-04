import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> showSelection<T extends Identifiable<IdType>, IdType>() => LdMonkeyBareChildAction<T, IdType>(
      onShortcutTrigger: (context) async {
        final shellState = LdMonkeyShellState.of<T, IdType>(context);
        final selection = LdMonkeySelection.of<T, IdType>(context);

        if (selection.selection.isNotEmpty) {
          await shellState.setViewingItems(selection.selection);
        }
      },
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 1,
          maxSelectionCount: null,
        ),
      },
      builder: (context) {
        final shellState = LdMonkeyShellState.of<T, IdType>(context);
        final selection = LdMonkeySelection.of<T, IdType>(context);

        // Only show if selection exists and is different from viewing
        final shouldShow = selection.selection.isNotEmpty && !setEquals(selection.selection, selection.viewing);

        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        return LdAppBarAction(
          buttonMode: LdButtonMode.filled,
          leading: const Icon(LucideIcons.eye),
          child: const Text('Show Selection'),
          onPressed: () async {
            await shellState.setViewingItems(selection.selection);
          },
        );
      },
    );
