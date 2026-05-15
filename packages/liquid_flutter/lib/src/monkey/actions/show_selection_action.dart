import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> showSelection<T extends Identifiable<IdType>, IdType>() => LdMonkeyBareChildAction<T, IdType>(
      onShortcutTrigger: (context) async {
        final selection = LdMonkeySelection.of<T, IdType>(context);

        if (selection.selection.isNotEmpty) {
          LdMonkeySelection.updateViewing<T, IdType>(context, selection.selection);
        }
      },
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterSecondary,
          minSelectionCount: 1,
          maxSelectionCount: null,
        ),
      },
      builder: (context) {
        final selection = LdMonkeySelection.of<T, IdType>(context);

        // Only show if selection exists and is different from viewing
        final shouldShow = selection.selection.isNotEmpty && !setEquals(selection.selection, selection.viewing);

        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        return LdAppBarAction(
          key: const Key('show_selection'),
          buttonMode: LdButtonMode.filled,
          leading: const Icon(LucideIcons.eye),
          preferLeadingOnMobile: false,
          child: const Text('Show Selection'),
          onPressed: () async {
            LdMonkeySelection.updateViewing<T, IdType>(context, selection.selection);
          },
        );
      },
    );
