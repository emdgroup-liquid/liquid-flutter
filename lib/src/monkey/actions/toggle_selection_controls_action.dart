import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> toggleSelectionControls<T extends Identifiable<IdType>, IdType>() =>
    LdMonkeyBareChildAction<T, IdType>(
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
        ),
      },
      onShortcutTrigger: (context) async {
        final route = LdMonkey.of<T, IdType>(context);
        route.setShowSelectionControls(!route.state.showSelectionControls);
      },
      builder: (context) {
        final route = LdMonkey.of<T, IdType>(context);
        return LdButton(
          child: const Icon(LucideIcons.pen),
          active: route.state.showSelectionControls,
          onPressed: () async {
            route.setShowSelectionControls(!route.state.showSelectionControls);
          },
        );
      },
    );
