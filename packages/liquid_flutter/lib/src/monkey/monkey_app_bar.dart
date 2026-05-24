import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyAppBar<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  final Widget? title;
  final LdMonkeyActionLocation location;
  final String? debugName;
  final List<Widget> additionalActions;
  final Widget? leading;
  final LdAppBarPositionMode? positionMode;
  final LdAppBarBackgroundMode? backgroundMode;
  final bool? implyLeading;
  final LdAppBarShadowMode? shadowMode;
  final LdAppBarBorderMode? borderMode;

  /// The subtree that this app bar wraps.
  ///
  /// When provided, the bar uses the new wrapper-based composition model and
  /// passes [child] down to [LdAppBarWidget]. When null, the bar renders the bar
  /// surface only (legacy / used when the bar is placed inside
  /// [LdScaffold.appBars] — deprecated path).
  final Widget? child;

  const LdMonkeyAppBar({
    super.key,
    this.title,
    this.additionalActions = const [],
    this.positionMode,
    required this.location,
    this.leading,
    this.debugName,
    this.backgroundMode,
    this.shadowMode,
    this.borderMode,
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
    context.watch<LdMonkeySelection<T, IdType>>();

    final effectiveLayout = context.watch<LdMonkeyEffectiveLayoutMode>();
    final searchFilter = _getSearchFilter(context);
    final showSearch = searchFilter != null && location == LdMonkeyActionLocation.masterAppBar;

    return Provider.value(
      value: location,
      child: Builder(builder: (context) {
        final actions = ldMonkeyAppBarActionsForLocation<T, IdType>(
          context,
          location,
        );

        if (showSearch == false && actions.isEmpty && additionalActions.isEmpty && title == null) {
          return child ?? const SizedBox.shrink();
        }

        final effectivePositionMode = positionMode ??
            switch (location) {
              LdMonkeyActionLocation.masterAppBar || LdMonkeyActionLocation.detailAppBar => LdAppBarPositionMode.top,
              LdMonkeyActionLocation.masterSecondary ||
              LdMonkeyActionLocation.detailSecondary =>
                LdAppBarPositionMode.bottom,
              _ => LdAppBarPositionMode.top,
            };

        return LdAppBarWidget(
            debugName: debugName,
            backgroundMode: backgroundMode ?? LdAppBarBackgroundMode.adaptive,
            borderMode: borderMode ?? LdAppBarBorderMode.adaptive,
            leading: leading,
            positionMode: effectivePositionMode,
            shadowMode: shadowMode ??
                switch (location) {
                  LdMonkeyActionLocation.masterAppBar ||
                  LdMonkeyActionLocation.masterSecondary =>
                    LdAppBarShadowMode.hidden,
                  _ => LdAppBarShadowMode.whenScrolled,
                },
            implyLeading: implyLeading ??
                switch (location) {
                  LdMonkeyActionLocation.detailAppBar => effectiveLayout == LdMonkeyEffectiveLayoutMode.detail,
                  _ => null,
                },
            attachedMode: switch (location) {
              LdMonkeyActionLocation.masterSecondary => LdAppBarAttachedMode.floating,
              _ => LdAppBarAttachedMode.adaptive,
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
            title: title,
            overflowMenuProviders: (context) => [
                  ListenableProvider.value(value: LdRepository.of<T, IdType>(context)),
                  Provider.value(value: context.watch<LdMonkeyActionLocation>()),
                  Provider.value(value: context.watch<LdMonkeyEffectiveLayoutMode>()),
                  Provider.value(value: context.watch<LdMonkeySelection<T, IdType>>())
                ],
            actions: [
              ...actions.map((e) => e.build(context)),
              ...additionalActions,
            ],
            child: child);
      }),
    );
  }
}
