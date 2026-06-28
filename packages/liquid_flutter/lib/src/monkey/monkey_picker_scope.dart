import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Ephemeral monkey picker: search, filter chips, and selection without
/// [GoRouter] or a detail route.
class LdMonkeyPickerScope<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyPickerScope({
    super.key,
    required this.repository,
    required this.itemBuilder,
    required this.initialSelection,
    required this.label,
    required this.multiple,
    required this.allowEmpty,
    this.filtersBuilder,
    this.sortOptionsBuilder,
    this.filterChipConfigs,
    this.buildList,
    this.actions = const [],
  });

  final LdListController<T, IdType> repository;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;
  final Set<IdType> initialSelection;
  final String label;
  final bool multiple;
  final bool allowEmpty;
  final LdMonkeyFiltersBuilder<T, IdType>? filtersBuilder;
  final LdMonkeySortOptionsBuilder<T, IdType>? sortOptionsBuilder;
  final List<LdFilterChipConfig<T, IdType>>? filterChipConfigs;
  final Widget Function(BuildContext context, LdListController<T, IdType> repository)? buildList;
  final List<LdMonkeyAction<T, IdType>> actions;

  @override
  State<LdMonkeyPickerScope<T, IdType>> createState() => _LdMonkeyPickerScopeState<T, IdType>();
}

class _LdMonkeyPickerScopeState<T extends Identifiable<IdType>, IdType>
    extends State<LdMonkeyPickerScope<T, IdType>> {
  late final LdEphemeralMonkeyController<T, IdType> _controller;
  LdMonkeyResolvedRouteDefinitions<T, IdType>? _lastResolved;

  @override
  void initState() {
    super.initState();
    _controller = LdEphemeralMonkeyController<T, IdType>(
      initialSelection: widget.initialSelection,
      showSelectionControls: true,
    );
  }

  void _applyResolved(LdMonkeyResolvedRouteDefinitions<T, IdType> resolved) {
    if (_lastResolved == resolved) {
      return;
    }
    _lastResolved = resolved;
    _controller.replaceDefinitions(
      filters: resolved.filters,
      sortOptions: resolved.sortOptions,
    );
  }

  Future<List<LdFilterOption<T, IdType>>> _defaultFiltersBuilder(BuildContext context) async => [];

  Future<List<LdSortOption<T, IdType>>> _defaultSortOptionsBuilder(BuildContext context) async => [];

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<LdListController<T, IdType>>.value(
      value: widget.repository,
      child: Provider<LdMonkeyInteractionMode>.value(
        value: LdMonkeyInteractionMode.pick,
        child: Provider<LdMonkeyActions<T, IdType>>.value(
          value: widget.actions,
          child: Provider<LdMonkeyActionScope<T, IdType>>(
            create: (_) => LdMonkeyActionScope<T, IdType>(),
            child: LdMonkeyRouteDefinitionsResolver<T, IdType>(
            filtersBuilder: widget.filtersBuilder ?? _defaultFiltersBuilder,
            sortOptionsBuilder: widget.sortOptionsBuilder ?? _defaultSortOptionsBuilder,
            child: (context, resolved) {
              _applyResolved(resolved);
              return LdEphemeralMonkeyAdapter<T, IdType>(
                controller: _controller,
                child: _LdMonkeyPickerPage<T, IdType>(
                  label: widget.label,
                  multiple: widget.multiple,
                  allowEmpty: widget.allowEmpty,
                  initialSelection: widget.initialSelection,
                  itemBuilder: widget.itemBuilder,
                  filterChipConfigs: widget.filterChipConfigs,
                  buildList: widget.buildList,
                ),
              );
            },
            ),
          ),
        ),
      ),
    );
  }
}

class _LdMonkeyPickerPage<T extends Identifiable<IdType>, IdType> extends StatelessWidget {
  const _LdMonkeyPickerPage({
    required this.label,
    required this.multiple,
    required this.allowEmpty,
    required this.initialSelection,
    required this.itemBuilder,
    required this.filterChipConfigs,
    required this.buildList,
  });

  final String label;
  final bool multiple;
  final bool allowEmpty;
  final Set<IdType> initialSelection;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;
  final List<LdFilterChipConfig<T, IdType>>? filterChipConfigs;
  final Widget Function(BuildContext context, LdListController<T, IdType> repository)? buildList;

  @override
  Widget build(BuildContext context) {
    final selection = context.watch<LdMonkeySelection<T, IdType>>();
    final canDismiss = ldChooseCanDismissPicker<IdType>(
      current: selection.selection,
      initial: initialSelection,
      allowEmpty: allowEmpty,
    );

    final bottom = filterChipConfigs == null
        ? null
        : LdFilterChipsBar<T, IdType>(configs: filterChipConfigs!);

    return PopScope(
      canPop: canDismiss,
      child: Provider<LdMonkeyEffectiveLayoutMode>.value(
        value: LdMonkeyEffectiveLayoutMode.master,
        child: LdScaffold(
          debugName: 'LdMonkeyPickerPage',
          body: LdMonkeyMasterPage<T, IdType>(
        allowMultipleSelection: multiple,
        primaryAppBarConfig: LdAppBarConfig(
          debugName: 'LdMonkeyPickerAppBar',
          title: Text(label),
          implyLeading: false,
          bottom: bottom,
        ),
        primaryAppBarAdditionalActions: [
          if (allowEmpty)
            LdButton.ghost(
              disabled: selection.selection.isEmpty,
              onPressed: () {
                LdMonkeySelection.updateSelection<T, IdType>(context, {});
              },
              child: const Text('Clear'),
            ),
          LdButton(
            key: const Key('ldChoose_done'),
            disabled: !ldChooseCanConfirmSelection<IdType>(
              current: selection.selection,
              initial: initialSelection,
            ),
            onPressed: () {
              maybePopContextMenu(context);
              Navigator.of(context).pop(selection.selection);
            },
            child: const Text('Done'),
          ),
        ],
        buildList: buildList,
        buildItem: (context, item) => itemBuilder(context, item, 0),
        ),
        ),
      ),
    );
  }
}
