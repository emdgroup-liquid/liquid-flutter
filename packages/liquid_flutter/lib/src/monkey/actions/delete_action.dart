import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';
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

        final confirmed = await ldConfirmModal(
          context: ctx.appContext,
          title: Text(LiquidLocalizations.of(ctx.appContext).deleteSelected),
          description: LiquidLocalizations.of(ctx.appContext).deleteConfirmBody(deletedIds.length),
          confirmColor: LdTheme.of(ctx.appContext).error,
          cancelColor: LdTheme.of(ctx.appContext).primary,
          indicatorType: LdIndicatorType.error,
          positive: Text(LiquidLocalizations.of(ctx.appContext).delete),
          negative: Text(LiquidLocalizations.of(ctx.appContext).cancel),
          useRootNavigator: true,
          allowDismiss: true,
        );
        if (confirmed != true) {
          return;
        }
        if (!ctx.appContext.mounted) {
          return;
        }

        // Update route state first so hydration and detail routing do not
        // target items that are about to be removed.
        ctx.updateViewing(nextViewing);
        ctx.updateSelection(nextSelection);
        if (nextSelection.isEmpty) {
          ctx.updateShowSelectionControls(false);
        }

        await ctx.appContext.read<LdModel<T, IdType, Object?, Object?>>().deleteBatch(
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
