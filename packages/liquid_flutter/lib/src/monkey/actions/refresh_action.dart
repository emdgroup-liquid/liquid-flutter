import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> refreshAction<T extends Identifiable<IdType>, IdType>() =>
    LdMonkeySubmitAction<T, IdType, void>(
      id: 'refresh',
      tooltip: (context) => LiquidLocalizations.of(context).refresh,
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
          minSelectionCount: 0,
          visibleWhenShowingSelectionControls: false,
          maxSelectionCount: null,
          isVisible: (ctx) {
            return LdTheme.of(ctx.appContext).platform.isDesktop;
          },
        ),
      },
      submitConfig: (appContext) => LdMonkeySubmitConfig(
        loadingText: LiquidLocalizations.of(appContext).loading,
      ),
      onSubmit: (ctx) async {
        ctx.listController.refreshList(context: ctx.appContext, reason: LdFetchReason.refresh);
      },
      childBuilder: (context) => Text(LiquidLocalizations.of(context).refresh),
      icon: Icon(LucideIcons.refreshCcw),
    );
