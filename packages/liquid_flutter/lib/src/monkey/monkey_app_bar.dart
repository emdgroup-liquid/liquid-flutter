import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

sealed class LdMonkeyAppbarConfig {
  final LdAppBarConfig? appbarConfig;
  final List<Widget> additionalActions;
  final String? debugName;

  const LdMonkeyAppbarConfig({
    this.appbarConfig,
    this.additionalActions = const [],
    this.debugName,
  });
}

class LdMonkeyMasterAppbarConfig extends LdMonkeyAppbarConfig {
  LdMonkeyMasterAppbarConfig({
    super.appbarConfig,
    super.additionalActions,
    super.debugName,
  });
}

class LdMonkeyMasterSecondaryAppbarConfig extends LdMonkeyAppbarConfig {
  LdMonkeyMasterSecondaryAppbarConfig({
    super.appbarConfig,
    super.additionalActions,
    super.debugName,
  });
}

class LdMonkeyDetailAppbarConfig extends LdMonkeyAppbarConfig {
  LdMonkeyDetailAppbarConfig({
    super.appbarConfig,
    super.additionalActions,
    super.debugName,
  });
}

class LdMonkeyDetailSecondaryAppbarConfig extends LdMonkeyAppbarConfig {
  LdMonkeyDetailSecondaryAppbarConfig({
    super.appbarConfig,
    super.additionalActions,
    super.debugName,
  });
}

class LdMonkeyAppBar<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final LdMonkeyActionLocation location;
  final String? debugName;
  final LdMonkeyAppbarConfig? config;

  /// The subtree that this app bar wraps.
  ///
  /// When provided, the bar uses the new wrapper-based composition model and
  /// passes [child] down to [LdAppBarWidget]. When null, the bar renders the bar
  /// surface only (legacy / used when the bar is placed inside
  /// [LdScaffold.appBars] — deprecated path).
  final Widget? child;

  const LdMonkeyAppBar({
    super.key,
    this.config,
    required this.location,
    this.debugName,
    this.child,
  });

  LdFilterSearch<T, IdType, dynamic>? _getSearchFilter(BuildContext context) {
    final filterState = context.watch<LdMonkeySortAndFilterState<T, IdType>>();
    final searchFilter = filterState.filters.whereType<LdFilterSearch<T, IdType, dynamic>>().firstOrNull;
    return searchFilter;
  }

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<LdMonkeySelection<T, IdType>>();

    final effectiveLayout = context.watch<LdMonkeyEffectiveLayoutMode>();

    final searchFilter = _getSearchFilter(context);

    final selectionControlsVisible = selection.showSelectionControls;

    final showClearSelectionButton = selectionControlsVisible && location == LdMonkeyActionLocation.masterSecondary;

    final monkeyBarConfig = config ??
        switch (location) {
          LdMonkeyActionLocation.masterAppBar => context.watch<LdMonkeyMasterAppbarConfig?>(),
          LdMonkeyActionLocation.detailAppBar => context.watch<LdMonkeyDetailAppbarConfig?>(),
          LdMonkeyActionLocation.masterSecondary => context.watch<LdMonkeyMasterSecondaryAppbarConfig?>(),
          LdMonkeyActionLocation.detailSecondary => context.watch<LdMonkeyDetailSecondaryAppbarConfig?>(),
          _ => null,
        };

    final appBarConfig = monkeyBarConfig?.appbarConfig ?? context.watch<LdAppBarConfig?>();

    return Provider.value(
      value: location,
      child: Builder(builder: (innerCtx) {
        final actions = ldMonkeyAppBarActionsForLocation<T, IdType>(
          innerCtx,
          location,
        );

        final searchConfig = switch (location) {
          LdMonkeyActionLocation.masterAppBar => searchFilter?.searchConfig(
              (query) {
                searchFilter.update(
                  context,
                  searchFilter.copyWith(
                    isOn: query.isNotEmpty,
                    searchText: query,
                  ),
                );
              },
              inputFocusNode: context.watch<LdMonkeySearchFocusNode>().focusNode,
            ),
          _ => null,
        };

        final barEmpty = actions.isEmpty &&
            searchConfig == null &&
            (monkeyBarConfig?.additionalActions.isEmpty ?? true) &&
            appBarConfig?.title == null &&
            appBarConfig?.bottom == null &&
            !showClearSelectionButton;

        final showBar = switch (location) {
          LdMonkeyActionLocation.masterAppBar => true,
          LdMonkeyActionLocation.detailAppBar => true,
          _ => !barEmpty,
        };

        final effectivePositionMode = appBarConfig?.positionMode ??
            switch (location) {
              LdMonkeyActionLocation.masterAppBar || LdMonkeyActionLocation.detailAppBar => LdAppBarPositionMode.top,
              LdMonkeyActionLocation.masterSecondary ||
              LdMonkeyActionLocation.detailSecondary =>
                LdAppBarPositionMode.bottom,
              _ => LdAppBarPositionMode.top,
            };

        return LdAppBar(
            leading: switch (showClearSelectionButton) {
              true => LdButton.vague(
                  child: const Icon(LucideIcons.x),
                  onPressed: () {
                    LdMonkeySelection.maybeClearSelection<T, IdType>(context);
                  },
                ).animate().scaleXY(),
              false => null,
            },
            title: showClearSelectionButton
                ? LdCounterText.template(
                    LiquidLocalizations.of(context).nItemsSelected(selection.selection.length),
                    value: selection.selection.length.toDouble(),
                  )
                : appBarConfig?.title,
            debugName: debugName ?? appBarConfig?.debugName ?? location.name,
            positionMode: effectivePositionMode,
            scrollBehavior: showBar ? null : LdAppBarScrollBehavior.hidden,
            autoAttachToKeyboard: true,
            searchConfig: searchConfig,
            implyFeatures: appBarConfig?.implyFeatures,
            overflowMenuProviders: (context) => [
                  ListenableProvider.value(value: LdListController.of<T, IdType>(context)),
                  Provider.value(value: location),
                  Provider.value(value: effectiveLayout),
                  Provider.value(value: selection)
                ],
            actions: [
              ...actions.map(
                (e) {
                  final trigger = e.buildTrigger(
                    innerCtx,
                    LdMonkeyActionScope.of<T, IdType>(innerCtx),
                  );
                  return switch (e.appBarOverflowMode) {
                    LdAppBarActionOverflowMode.pinned => LdOverflowPinnedChild(child: trigger),
                    LdAppBarActionOverflowMode.overflowable => trigger,
                  };
                },
              ),
              ...monkeyBarConfig?.additionalActions ?? [],
            ],
            child: child);
      }),
    );
  }
}
