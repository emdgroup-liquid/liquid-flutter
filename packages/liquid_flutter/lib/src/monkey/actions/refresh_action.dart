import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> refreshAction<T extends Identifiable<IdType>, IdType>() =>
    LdMonkeySubmitAction<T, IdType, void>(
      tooltip: (context) => LiquidLocalizations.of(context).refresh,
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          maxSelectionCount: null,
          isVisible: (context) {
            return LdTheme.of(context).platform.isDesktop;
          },
        ),
      },
      config: (context) => LdSubmitConfig(
        loadingText: LiquidLocalizations.of(context).loading,
        action: (_) async {
          final repository = LdRepository.of<T, IdType>(context);
          repository.refreshList(context: context, hard: true);
        },
      ),
      child: Builder(builder: (context) => Text(LiquidLocalizations.of(context).refresh)),
      icon: Icon(LucideIcons.refreshCcw),
    );
