import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

LdMonkeyAction<T, IdType> deleteAction<T extends Identifiable<IdType>, IdType>({
  LdMonkeyActionLocation detailLocation = LdMonkeyActionLocation.detailAppBar,
}) =>
    LdMonkeySubmitAction<T, IdType, void>(
      id: 'delete',
      tooltip: (context) => LiquidLocalizations.of(context).deleteSelected,
      visibility: {
        LdMonkeyActionVisibility(
          location: detailLocation,
          minSelectionCount: 1,
          maxSelectionCount: null,
        ),
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.context,
          minSelectionCount: 1,
          maxSelectionCount: null,
        ),
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterSecondary,
          minSelectionCount: 1,
          maxSelectionCount: null,
          layoutModes: {LdMonkeyEffectiveLayoutMode.sideBySide},
        ),
      },
      shortcutActivators: {
        SingleActivator(LogicalKeyboardKey.delete),
        SingleActivator(LogicalKeyboardKey.backspace),
      },
      submitConfig: (appContext) => LdMonkeySubmitConfig(
        loadingText: LiquidLocalizations.of(appContext).loading,
      ),
      onSubmit: (ctx) async {
        final deletedIds = {...ctx.selectedIds};
        final nextViewing = ctx.selection.viewing.difference(deletedIds);
        final nextSelection = ctx.selection.selection.difference(deletedIds);

        // Update route state first so hydration and detail routing do not
        // target items that are about to be removed.
        ctx.updateViewing(nextViewing);
        ctx.updateSelection(nextSelection);
        if (nextSelection.isEmpty) {
          ctx.updateShowSelectionControls(false);
        }

        await ctx.repository.deleteBatch(
          context: ctx.appContext,
          ids: deletedIds,
        );
      },
      childBuilder: (context) {
        return Text(
          LiquidLocalizations.of(context).deleteNItems(
            LdMonkeySelection.adaptive<T, IdType>(context, listen: true).length,
          ),
        );
      },
      color: (context) => LdTheme.of(context).error,
      icon: Icon(LucideIcons.trash2),
    );
