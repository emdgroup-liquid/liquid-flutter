import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../liquid_flutter.dart';
import 'choose_lightweight_scope.dart';

/// Whether the picker Done button should be enabled.
bool ldChooseCanConfirmSelection<IdType>({
  required Set<IdType> current,
  required Set<IdType> initial,
}) {
  if (!setEquals(current, initial)) {
    return true;
  }
  return current.isNotEmpty;
}

/// Whether the picker can be dismissed via back gesture or modal backdrop.
bool ldChooseCanDismissPicker<IdType>({
  required Set<IdType> current,
  required Set<IdType> initial,
  required bool allowEmpty,
}) {
  if (allowEmpty) {
    return true;
  }
  return ldChooseCanConfirmSelection<IdType>(
    current: current,
    initial: initial,
  );
}

enum LdChooseMode {
  page,
  modal,
  auto,
}

class LdChooseTriggerConfig<T extends Identifiable<IdType>, IdType> {
  final List<T> selectedItems;
  final List<IdType> selectedIds;
  final LdSubmitState<List<T>> state;
  final VoidCallback onTap;
  final int truncateDisplay;
  final String label;
  final Widget? hint;
  final LdSize size;
  final bool disabled;
  final Widget Function(BuildContext context, T item) selectedItemBuilder;

  const LdChooseTriggerConfig({
    required this.selectedItems,
    required this.selectedIds,
    required this.state,
    required this.onTap,
    required this.truncateDisplay,
    required this.label,
    required this.hint,
    required this.size,
    required this.disabled,
    required this.selectedItemBuilder,
  });
}

typedef LdChooseTriggerBuilder<T extends Identifiable<IdType>, IdType> = Widget Function(
  BuildContext context,
  LdChooseTriggerConfig<T, IdType> config,
);

/// A widget that presents a dropdown in a seperate page.
class LdChoose<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final LdRepository<T, IdType>? repository;
  final List<T>? items;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;
  final Widget Function(BuildContext context, T item) selectedItemBuilder;
  final bool disabled;
  final bool allowEmpty;
  final LdChooseMode mode;
  final bool useRootNavigator;

  final bool multiple;
  final Set<IdType>? value;
  final Function(Set<IdType>) onChanged;
  final int? truncateDisplay;
  final LdSize size;
  final String? label;
  final Text? hint;
  final LdChooseTriggerBuilder<T, IdType>? triggerBuilder;
  final dynamic Function(T)? groupingCriterion;
  final Widget Function(BuildContext context, dynamic criterion, List<LdPaginatorItem<T>>)? groupHeaderBuilder;

  /// Filter definitions for repository-backed pickers ([LdMonkeyPickerScope]).
  final LdMonkeyFiltersBuilder<T, IdType>? filtersBuilder;

  /// Sort options for repository-backed pickers.
  final LdMonkeySortOptionsBuilder<T, IdType>? sortOptionsBuilder;

  /// Chip bar configs for repository-backed pickers.
  final List<LdFilterChipConfig<T, IdType>>? filterChipConfigs;

  /// Extracts searchable text for [fromList] / fuzzy local filtering.
  final LdSearchTextExtractor<T>? searchText;

  const LdChoose({
    this.repository,
    this.items,
    required this.itemBuilder,
    required this.selectedItemBuilder,
    this.allowEmpty = false,
    this.useRootNavigator = true,
    this.disabled = false,
    this.label,
    this.multiple = false,
    this.groupHeaderBuilder,
    this.groupingCriterion,
    this.mode = LdChooseMode.auto,
    required this.onChanged,
    this.hint,
    this.size = LdSize.m,
    this.truncateDisplay,
    this.value,
    this.triggerBuilder,
    this.filtersBuilder,
    this.sortOptionsBuilder,
    this.filterChipConfigs,
    this.searchText,
    super.key,
  })  : assert(items != null || repository != null, 'Either items or repository must be provided'),
        assert(items == null || repository == null, 'Cannot provide both items and repository');

  /// Convenience constructor that creates an LdChoose from a list of LdSelectItem.
  ///
  /// This constructor automatically creates a repository from the items and
  /// uses the child widget from each LdSelectItem for rendering.
  static LdChoose<T, IdType> fromList<T extends Identifiable<IdType>, IdType>({
    required List<T> items,
    required Function(Set<IdType>) onChanged,
    required Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder,
    required Widget Function(BuildContext context, T item) selectedItemBuilder,
    LdChooseTriggerBuilder<T, IdType>? triggerBuilder,
    Set<IdType>? value,
    bool allowEmpty = false,
    bool useRootNavigator = true,
    bool disabled = false,
    String? label,
    bool multiple = false,
    LdChooseMode mode = LdChooseMode.auto,
    Text? placeholder,
    LdSize size = LdSize.m,
    int? truncateDisplay,
    LdSearchTextExtractor<T>? searchText,
    Key? key,
  }) {
    return LdChoose<T, IdType>(
      items: items,
      itemBuilder: (context, item, index) {
        return itemBuilder(context, item, index);
      },
      selectedItemBuilder: selectedItemBuilder,
      value: value,
      allowEmpty: allowEmpty,
      useRootNavigator: useRootNavigator,
      disabled: disabled,
      label: label,
      multiple: multiple,
      mode: mode,
      onChanged: onChanged,
      hint: placeholder,
      size: size,
      truncateDisplay: truncateDisplay,
      triggerBuilder: triggerBuilder,
      searchText: searchText,
      key: key,
    );
  }

  static LdChoose<LdSelectItem<T>, T> fromSelectItems<T>({
    required List<LdSelectItem<T>> items,
    required void Function(Set<T>) onChanged,
    Set<T>? value,
    bool allowEmpty = false,
    bool useRootNavigator = true,
    bool disabled = false,
    String? label,
    bool multiple = false,
    LdChooseMode mode = LdChooseMode.auto,
    Text? placeholder,
    LdSize size = LdSize.m,
    int? truncateDisplay,
    LdChooseTriggerBuilder<LdSelectItem<T>, T>? triggerBuilder,
    LdSearchTextExtractor<LdSelectItem<T>>? searchText,
    Key? key,
  }) {
    return fromList<LdSelectItem<T>, T>(
      items: items,
      onChanged: onChanged,
      itemBuilder: (context, item, index) {
        return LdListItem(
          title: item.value?.child,
          disabled: !(item.value?.enabled ?? true),
        );
      },
      selectedItemBuilder: (context, item) {
        return item.child;
      },
      value: value,
      allowEmpty: allowEmpty,
      useRootNavigator: useRootNavigator,
      disabled: disabled,
      label: label,
      multiple: multiple,
      mode: mode,
      placeholder: placeholder,
      size: size,
      truncateDisplay: truncateDisplay,
      triggerBuilder: triggerBuilder,
      searchText: searchText,
      key: key,
    );
  }

  bool get _usesMonkeyPicker => repository != null && filtersBuilder != null;

  @override
  State<LdChoose<T, IdType>> createState() => _LdChooseState<T, IdType>();
}

class _LdChooseState<T extends Identifiable<IdType>, IdType> extends State<LdChoose<T, IdType>> {
  late LdRepository<T, IdType> _repository;
  bool _ownsRepository = false;
  LdSearchTextExtractor<T>? _effectiveSearchText;

  @override
  void initState() {
    super.initState();
    _effectiveSearchText = _resolveSearchText();
    if (widget.items != null && widget.repository == null) {
      final items = widget.items!;
      final searchText = _effectiveSearchText;
      _repository = LdRepository.greedy<T, IdType>(
        getById: (id) async => items.firstWhere((item) => item.id == id),
        fetchListWithParameters: (parameters) async {
          var filtered = items.toList();
          final filters = parameters.filters;
          if (searchText != null && filters.isNotEmpty) {
            filtered = ldFuzzySearchFromFilters<T, IdType>(
              items: filtered,
              filters: filters,
              searchText: searchText,
            );
          }
          return LdListPage<T>(
            newItems: filtered.skip(parameters.offset).take(parameters.pageSize).toList(),
            hasMore: parameters.offset + parameters.pageSize < filtered.length,
            total: filtered.length,
          );
        },
      );
      _repository.initialOffset = 0;
      _ownsRepository = true;
    } else {
      _repository = widget.repository!;
      _ownsRepository = false;
    }
  }

  LdSearchTextExtractor<T>? _resolveSearchText() {
    if (widget.searchText != null) {
      return widget.searchText;
    }
    if (widget.items == null) {
      return null;
    }
    final hasSearchStrings = widget.items!.any((item) {
      if (item is LdSelectItem<dynamic>) {
        return (item as LdSelectItem<dynamic>).searchString?.isNotEmpty ?? false;
      }
      return false;
    });
    if (!hasSearchStrings) {
      return null;
    }
    return (item) {
      if (item is LdSelectItem<dynamic>) {
        return (item as LdSelectItem<dynamic>).searchString ?? '';
      }
      return item.toString();
    };
  }

  Future<List<T>> _fetchSelectedItems(List<IdType> ids) async {
    return Future.wait(ids.map((id) => _repository.getById(id)));
  }

  @override
  void dispose() {
    if (_ownsRepository) {
      _repository.dispose();
    }
    super.dispose();
  }

  Widget _buildPickerPage(BuildContext context) {
    final label = widget.label ?? LiquidLocalizations.of(context).choose;

    if (widget._usesMonkeyPicker) {
      return LdMonkeyPickerScope<T, IdType>(
        repository: _repository,
        itemBuilder: widget.itemBuilder,
        initialSelection: widget.value ?? <IdType>{},
        multiple: widget.multiple,
        allowEmpty: widget.allowEmpty,
        label: label,
        filtersBuilder: widget.filtersBuilder,
        sortOptionsBuilder: widget.sortOptionsBuilder,
        filterChipConfigs: widget.filterChipConfigs,
        buildList: widget.groupingCriterion == null
            ? null
            : (context, repository) {
                return LdSelectableList<T, IdType>(
                  paginator: repository,
                  itemBuilder: widget.itemBuilder,
                  initialSelectedItems: context.read<LdMonkeySelection<T, IdType>>().selection,
                  multiSelect: widget.multiple,
                  showSelectionControls: true,
                  onSelectionChange: (selected) {
                    LdMonkeySelection.updateSelection<T, IdType>(context, selected);
                    LdMonkeySelection.updateShowSelectionControls<T, IdType>(context, true);
                  },
                  listBuilder: (context, itemBuilder) {
                    return LdList(
                      groupingCriterion: widget.groupingCriterion,
                      groupHeaderBuilder: widget.groupHeaderBuilder,
                      paginator: repository,
                      padding: MediaQuery.paddingOf(context),
                      itemBuilder: itemBuilder,
                    );
                  },
                );
              },
      );
    }

    return LdChooseLightweightScope<T, IdType>(
      repository: _repository,
      itemBuilder: widget.itemBuilder,
      initialSelection: widget.value ?? <IdType>{},
      multiple: widget.multiple,
      allowEmpty: widget.allowEmpty,
      label: label,
      searchText: _effectiveSearchText,
      searchSourceItems: widget.items,
      groupingCriterion: widget.groupingCriterion,
      groupHeaderBuilder: widget.groupHeaderBuilder,
    );
  }

  Future<void> _onTap(BuildContext context) async {
    final nav = widget.useRootNavigator ? Navigator.of(context, rootNavigator: true) : Navigator.of(context);

    final shouldUsePage = switch (widget.mode) {
      LdChooseMode.page => true,
      LdChooseMode.modal => false,
      LdChooseMode.auto => _repository.totalItems > 10 && LdTheme.of(context).platform.isMobile,
    };

    final pickerPage = _buildPickerPage(context);

    final result = await (shouldUsePage
        ? nav.push<Set<IdType>>(
            MaterialPageRoute<Set<IdType>>(
              builder: (context) => pickerPage,
            ),
          )
        : nav.push<Set<IdType>>(
            LdModalRoute<Set<IdType>>(
              context: context,
              barrierDismissible: widget.allowEmpty,
              pageBuilder: (context) => pickerPage,
            ),
          ));

    if (result != null) {
      widget.onChanged(result);
    }
    setState(() {});
  }

  int _getDisplayItems(List<IdType> ids) {
    return min(ids.length, widget.truncateDisplay ?? ids.length);
  }

  List<T> _selectedItemsFromStaticList() {
    final value = widget.value;
    if (value == null || value.isEmpty || widget.items == null) {
      return [];
    }

    return widget.items!.where((item) => value.contains(item.id)).take(_getDisplayItems(value.toList())).toList();
  }

  Widget _buildTrigger({
    required List<IdType> selectedIds,
    required List<T> selectedItems,
    required LdSubmitState<List<T>> state,
  }) {
    final triggerConfig = LdChooseTriggerConfig<T, IdType>(
      selectedItems: selectedItems,
      hint: widget.hint,
      selectedIds: selectedIds,
      state: state,
      onTap: () => _onTap(context),
      truncateDisplay: widget.truncateDisplay ?? 3,
      label: widget.label ?? LiquidLocalizations.of(context).choose,
      size: widget.size,
      disabled: widget.disabled,
      selectedItemBuilder: widget.selectedItemBuilder,
    );

    if (widget.triggerBuilder != null) {
      return widget.triggerBuilder!(context, triggerConfig);
    }

    return LdChooseInputTrigger(
      config: triggerConfig,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = widget.value?.toList() ?? <IdType>[];

    if (widget.items != null) {
      return _buildTrigger(
        selectedIds: selectedIds,
        selectedItems: _selectedItemsFromStaticList(),
        state: LdSubmitState<List<T>>(
          type: LdSubmitStateType.result,
          result: _selectedItemsFromStaticList(),
        ),
      );
    }

    return LdSubmit(
      arg: widget.value,
      argEquals: (oldArg, newArg) {
        bool equals = setEquals(oldArg, newArg);
        return equals;
      },
      config: LdSubmitConfig<List<T>, Set<IdType>?>(
        autoTrigger: true,
        allowResubmit: true,
        action: (ids) async {
          if (ids == null) {
            return [];
          }

          final allItems = await _fetchSelectedItems(
            ids.toList().sublist(0, _getDisplayItems(ids.toList())),
          );

          return allItems;
        },
      ),
      child: LdSubmitCustomBuilder<List<T>, Set<IdType>?>(
        builder: (context, controller, stateType) {
          final selectedItems = controller.state.result ?? <T>[];

          return _buildTrigger(
            selectedIds: selectedIds,
            selectedItems: selectedItems,
            state: controller.state,
          );
        },
      ),
    );
  }
}

class LdChoosePage<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final LdRepository<T, IdType> repository;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;
  final Set<IdType> initialSelectedItems;
  final bool multiple;
  final bool allowEmpty;
  final dynamic Function(T)? groupingCriterion;
  final Widget Function(BuildContext context, dynamic criterion, List<LdPaginatorItem<T>>)? groupHeaderBuilder;
  final String label;
  final bool useMonkeySearch;

  const LdChoosePage({
    required this.repository,
    required this.itemBuilder,
    required this.initialSelectedItems,
    required this.multiple,
    required this.allowEmpty,
    required this.label,
    required this.groupingCriterion,
    required this.groupHeaderBuilder,
    this.useMonkeySearch = false,
    super.key,
  });

  @override
  State<LdChoosePage<T, IdType>> createState() => LdChoosePageState<T, IdType>();
}

class LdChoosePageState<T extends Identifiable<IdType>, IdType> extends State<LdChoosePage<T, IdType>> {
  @override
  Widget build(BuildContext context) {
    final searchFilter = widget.useMonkeySearch ? ldChooseSearchFilter<T, IdType>(context) : null;
    final selection = context.watch<LdMonkeySelection<T, IdType>?>();

    final selectedItems = selection?.selection ?? widget.initialSelectedItems;
    final canDismiss = ldChooseCanDismissPicker<IdType>(
      current: selectedItems,
      initial: widget.initialSelectedItems,
      allowEmpty: widget.allowEmpty,
    );

    final body = LdSelectableList<T, IdType>(
      paginator: widget.repository,
      itemBuilder: widget.itemBuilder,
      initialSelectedItems: selectedItems,
      multiSelect: widget.multiple,
      showSelectionControls: true,
      onSelectionChange: (items) {
        LdMonkeySelection.updateSelection<T, IdType>(context, items);
        LdMonkeySelection.updateShowSelectionControls<T, IdType>(context, true);
      },
      listBuilder: widget.groupingCriterion == null
          ? null
          : (context, itemBuilder) {
              return LdList(
                groupingCriterion: widget.groupingCriterion,
                groupHeaderBuilder: widget.groupHeaderBuilder,
                paginator: widget.repository,
                padding: MediaQuery.paddingOf(context),
                itemBuilder: itemBuilder,
              );
            },
    );

    return PopScope(
      canPop: canDismiss,
      child: LdScaffold(
        debugName: 'LdChoosePage',
        body: LdAppBar(
          debugName: 'LdChoosePageAppBar',
          title: Text(widget.label),
          implyCloseModalButton: false,
          searchConfig: searchFilter?.searchConfig((query) {
            searchFilter.update(
              context,
              searchFilter.copyWith(
                isOn: query.isNotEmpty,
                searchText: query,
              ),
            );
          }),
          actions: [
            if (widget.allowEmpty)
              LdAppBarAction(
                overflowMode: LdAppBarActionOverflowMode.pinned,
                buttonMode: LdButtonMode.ghost,
                disabled: selectedItems.isEmpty,
                onPressed: () {
                  LdMonkeySelection.updateSelection<T, IdType>(context, {});
                },
                child: const Text('Clear'),
              ),
            LdAppBarAction(
              overflowMode: LdAppBarActionOverflowMode.pinned,
              disabled: !ldChooseCanConfirmSelection<IdType>(
                current: selectedItems,
                initial: widget.initialSelectedItems,
              ),
              key: const Key('ldChoose_done'),
              onPressed: () {
                maybePopContextMenu(context);
                Navigator.of(context).pop(selectedItems);
              },
              child: const Text('Done'),
            ),
          ],
          child: body,
        ),
      ),
    );
  }

  static LdChoosePageState<T, IdType>? of<T extends Identifiable<IdType>, IdType>(BuildContext context) {
    return context.findAncestorStateOfType<LdChoosePageState<T, IdType>>();
  }
}
