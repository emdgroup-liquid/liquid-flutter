import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class LdMonkeyAppBar<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final LdMonkeyActionLocation location;
  final String? debugName;
  final List<Widget> additionalActions;
  final bool? implyLeading;

  /// The subtree that this app bar wraps.
  ///
  /// When provided, the bar uses the new wrapper-based composition model and
  /// passes [child] down to [LdAppBarWidget]. When null, the bar renders the bar
  /// surface only (legacy / used when the bar is placed inside
  /// [LdScaffold.appBars] — deprecated path).
  final Widget? child;

  const LdMonkeyAppBar({
    super.key,
    this.additionalActions = const [],
    required this.location,
    this.debugName,
    this.implyLeading,
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
    final appBarConfig = Provider.of<LdAppBarConfig?>(context, listen: true);
    final searchFilter = _getSearchFilter(context);

    final selectionControlsVisible = selection.showSelectionControls;

    final showClearSelectionButton = selectionControlsVisible && location == LdMonkeyActionLocation.masterSecondary;

    return Provider.value(
      value: location,
      child: Builder(builder: (innerCtx) {
        final actions = ldMonkeyAppBarActionsForLocation<T, IdType>(
          innerCtx,
          location,
        );

        if ((searchFilter == null || location != LdMonkeyActionLocation.masterAppBar) &&
            actions.isEmpty &&
            additionalActions.isEmpty &&
            appBarConfig?.title == null &&
            appBarConfig?.bottom == null &&
            !showClearSelectionButton) {
          return child ?? const SizedBox.shrink();
        }

        final effectivePositionMode = appBarConfig?.positionMode ??
            switch (location) {
              LdMonkeyActionLocation.masterAppBar || LdMonkeyActionLocation.detailAppBar => LdAppBarPositionMode.top,
              LdMonkeyActionLocation.masterSecondary ||
              LdMonkeyActionLocation.detailSecondary =>
                LdAppBarPositionMode.bottom,
              _ => LdAppBarPositionMode.top,
            };

        return LdAppBar(
            leading: showClearSelectionButton
                ? LdButton.vague(
                    child: const Icon(LucideIcons.x),
                    onPressed: () {
                      LdMonkeySelection.maybeClearSelection<T, IdType>(context);
                    },
                  ).animate().scaleXY()
                : null,
            title: showClearSelectionButton
                ? LdCounterText.template(
                    LiquidLocalizations.of(context).nItemsSelected(selection.selection.length),
                    value: selection.selection.length.toDouble(),
                  )
                : null,
            debugName: debugName ?? appBarConfig?.debugName,
            showWindowControls: appBarConfig?.showWindowControls ?? true,
            positionMode: effectivePositionMode,
            autoAttachToKeyboard: true,
            implyLeading: implyLeading ??
                appBarConfig?.implyLeading ??
                switch (location) {
                  LdMonkeyActionLocation.detailAppBar => effectiveLayout == LdMonkeyEffectiveLayoutMode.detail,
                  _ => true,
                },
            searchConfig: switch (location) {
              LdMonkeyActionLocation.masterAppBar => searchFilter?.searchConfig((query) {
                  searchFilter.update(
                    context,
                    searchFilter.copyWith(
                      isOn: query.isNotEmpty,
                      searchText: query,
                    ),
                  );
                }),
              _ => null,
            },
            overflowMenuProviders: (context) => [
                  ListenableProvider.value(value: LdRepository.of<T, IdType>(context)),
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
              ...additionalActions,
            ],
            child: child);
      }),
    );
  }
}
