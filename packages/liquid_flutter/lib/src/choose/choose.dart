import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../liquid_flutter.dart';

/// Whether the picker Done button should be enabled.
bool ldChooseCanConfirmSelection<IdType>({
  required Set<IdType> selection,
  required bool allowEmpty,
}) {
  if (allowEmpty) {
    return true;
  }
  return selection.isNotEmpty;
}

/// Whether the picker can be dismissed via back gesture or modal backdrop.
bool ldChooseCanDismissPicker<IdType>({
  required Set<IdType> initial,
  required bool allowEmpty,
}) {
  if (allowEmpty) {
    return true;
  }
  if (initial.isEmpty) {
    return true;
  }
  return false;
}

Future<void> ldChoosePrefetchPickerData<T extends Identifiable<IdType>, IdType>({
  required BuildContext context,
  required LdListController<T, IdType> repository,
  required Set<IdType> initialSelection,
}) async {
  if (!context.mounted) {
    return;
  }
  if (repository.model.isGreedy) {
    await repository.ensureGreedyLoaded(context);
    return;
  }
}

Future<void> ldChooseScrollToInitialSelection<T extends Identifiable<IdType>, IdType>({
  required BuildContext context,
  required LdListController<T, IdType> repository,
  required Set<IdType> initialSelection,
}) async {
  if (initialSelection.isEmpty || !context.mounted) {
    return;
  }
  await ldChoosePrefetchPickerData<T, IdType>(
    context: context,
    repository: repository,
    initialSelection: initialSelection,
  );
  if (!context.mounted) {
    return;
  }

  final id = initialSelection.first;
  for (var attempt = 0; attempt < 60 && context.mounted; attempt++) {
    if (repository.getItemIndexById(id) != null) {
      break;
    }
    await Future<void>.delayed(Duration.zero);
  }
  if (!context.mounted || repository.getItemIndexById(id) == null) {
    return;
  }

  repository.requestScrollToItem(id);
}

LdFilterSearch<T, IdType, String> _ldChooseDefaultSearchFilter<T extends Identifiable<IdType>, IdType>({
  Future<List<String>> Function(String query)? getSuggestions,
}) {
  return LdFilterSearch<T, IdType, String>(
    name: 'search',
    label: (context) => LiquidLocalizations.of(context).search,
    icon: (context) => const Icon(LucideIcons.search),
    getSuggestions: getSuggestions,
    buildSuggestion: getSuggestions == null
        ? null
        : (context, suggestion) {
            return LdListItem(
              title: Text(suggestion),
              onPressed: () {
                LdSearchAcceptSuggestion(suggestion: suggestion).dispatch(context);
              },
            );
          },
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
  final Widget hint;
  final LdSize size;
  final bool disabled;
  final Widget Function(BuildContext context, T item) selectedItemBuilder;

  /// Called when a single item should be removed from the selection.
  /// Triggers `onChanged` on the parent [LdChoose] with the item removed.
  /// Only non-null when [LdChoose] has a non-null `value`.
  final void Function(IdType id)? onRemoveItem;

  /// Whether removing all items is permitted.
  /// Mirrors [LdChoose.allowEmpty].
  final bool allowEmpty;

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
    this.onRemoveItem,
    this.allowEmpty = false,
  });
}

typedef LdChooseTriggerBuilder<T extends Identifiable<IdType>, IdType> = Widget Function(
  BuildContext context,
  LdChooseTriggerConfig<T, IdType> config,
);

/// A widget that presents a dropdown in a seperate page.
class LdChoose<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final LdListController<T, IdType>? repository;
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

  /// Filter definitions for the picker ([LdMonkeyPickerScope]).
  ///
  /// When [searchText] is set and this list does not already include a search
  /// filter, a default search filter is prepended.
  final LdMonkeyFiltersBuilder<T, IdType>? filtersBuilder;

  /// Sort options for the picker.
  final LdMonkeySortOptionsBuilder<T, IdType>? sortOptionsBuilder;

  /// Chip bar configs for the picker.
  final List<LdFilterChipConfig<T, IdType>>? filterChipConfigs;

  /// Extracts searchable text for [fromList] / fuzzy local filtering.
  final LdSearchTextExtractor<T>? searchText;

  /// Actions shown in the picker's app bar.
  final List<LdMonkeyAction<T, IdType>> actions;

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
    this.actions = const [],
    super.key,
  })  : assert(items != null || repository != null, 'Either items or repository must be provided'),
        assert(items == null || repository == null, 'Cannot provide both items and repository');

  /// Convenience constructor that creates an LdChoose from a static list.
  ///
  /// Builds an in-memory repository via [LdCallbackModel.fromList].
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
      itemBuilder: itemBuilder,
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

  static LdSearchTextExtractor<LdSelectItem<T>>? _selectItemSearchText<T>(
    List<LdSelectItem<T>> items,
  ) {
    final hasSearchStrings = items.any(
      (item) => item.searchString?.isNotEmpty ?? false,
    );
    if (!hasSearchStrings) {
      return null;
    }
    return (item) => item.searchString ?? '';
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
      searchText: searchText ?? _selectItemSearchText(items),
      key: key,
    );
  }

  @override
  State<LdChoose<T, IdType>> createState() => _LdChooseState<T, IdType>();
}

class _LdChooseState<T extends Identifiable<IdType>, IdType> extends State<LdChoose<T, IdType>> {
  late LdListController<T, IdType> _repository;
  bool _ownsRepository = false;

  @override
  void initState() {
    super.initState();
    if (widget.items != null && widget.repository == null) {
      _repository = LdListController(
        LdCallbackModel.fromList<T, IdType>(
          list: widget.items!,
          searchText: widget.searchText,
        ),
      );
      _repository.initialOffset = 0;
      _ownsRepository = true;
    } else {
      _repository = widget.repository!;
      _ownsRepository = false;
    }
  }

  Future<List<T>> _fetchSelectedItems(List<IdType> ids) async {
    return Future.wait(ids.map((id) => _repository.getById(context, id)));
  }

  @override
  void dispose() {
    if (_ownsRepository) {
      _repository.dispose();
    }
    super.dispose();
  }

  Future<List<String>> _getSearchSuggestions(String query) async {
    final searchText = widget.searchText;
    final sourceItems = widget.items;
    if (searchText == null || sourceItems == null || query.trim().isEmpty) {
      return [];
    }

    final lowerQuery = query.toLowerCase();
    final seen = <String>{};
    final suggestions = <String>[];

    for (final item in sourceItems) {
      final text = searchText(item);
      if (text.isEmpty) {
        continue;
      }
      if (text.toLowerCase().startsWith(lowerQuery) && seen.add(text)) {
        suggestions.add(text);
      }
    }

    return suggestions;
  }

  Future<List<LdFilterOption<T, IdType>>> _effectiveFiltersBuilder(BuildContext context) async {
    final userFilters =
        widget.filtersBuilder == null ? <LdFilterOption<T, IdType>>[] : await widget.filtersBuilder!(context);
    if (widget.searchText == null) {
      return userFilters;
    }
    final hasSearch = userFilters.any(
      (filter) => filter is LdFilterSearch<T, IdType, dynamic>,
    );
    if (hasSearch) {
      return userFilters;
    }
    return [
      _ldChooseDefaultSearchFilter<T, IdType>(
        getSuggestions: widget.items == null ? null : _getSearchSuggestions,
      ),
      ...userFilters,
    ];
  }

  Widget _buildPickerPage(BuildContext context) {
    final label = widget.label ?? LiquidLocalizations.of(context).choose;

    return LdMonkeyPickerScope<T, IdType>(
      repository: _repository,
      itemBuilder: widget.itemBuilder,
      initialSelection: widget.value ?? <IdType>{},
      multiple: widget.multiple,
      allowEmpty: widget.allowEmpty,
      label: label,
      filtersBuilder: _effectiveFiltersBuilder,
      sortOptionsBuilder: widget.sortOptionsBuilder,
      filterChipConfigs: widget.filterChipConfigs,
      actions: widget.actions,
      buildList: widget.groupingCriterion == null
          ? null
          : (context, repository) {
              return LdListConfigProvider<T, IdType>(
                config: LdListConfig<T, IdType>(
                  paginator: repository,
                  separatorBuilder: (_) {
                    return LdDivider(
                      insetForLeading: true,
                    );
                  },
                  itemBuilder: (ctx, item, index) => widget.itemBuilder(
                    ctx,
                    LdPaginatorItem(value: item.value, state: item.state),
                    index,
                  ),
                  groupingCriterion: widget.groupingCriterion,
                  groupHeaderBuilder: widget.groupHeaderBuilder,
                  padding: MediaQuery.paddingOf(context),
                ),
                child: LdSelectableList<T, IdType>(
                  listController: repository,
                  initialSelectedItems: widget.value ?? <IdType>{},
                  multiSelect: widget.multiple,
                  showSelectionControls: true,
                  onSelectionChange: (selected) {
                    LdMonkeySelection.updateSelection<T, IdType>(context, selected);
                  },
                  child: LdList<T, IdType>(),
                ),
              );
            },
    );
  }

  Future<void> _onTap(BuildContext context) async {
    final initialSelection = widget.value ?? <IdType>{};
    await ldChoosePrefetchPickerData<T, IdType>(
      context: context,
      repository: _repository,
      initialSelection: initialSelection,
    );
    if (!context.mounted) {
      return;
    }
    if (initialSelection.isNotEmpty) {
      _repository.requestScrollToItem(initialSelection.first);
    }

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
      hint: widget.hint ?? Text(LiquidLocalizations.of(context).choose),
      selectedIds: selectedIds,
      state: state,
      onTap: () => _onTap(context),
      truncateDisplay: widget.truncateDisplay ?? 3,
      label: widget.label ?? LiquidLocalizations.of(context).choose,
      size: widget.size,
      disabled: widget.disabled,
      selectedItemBuilder: widget.selectedItemBuilder,
      allowEmpty: widget.allowEmpty,
      onRemoveItem: widget.value == null
          ? null
          : (id) {
              final next = widget.value!.where((v) => v != id).toSet();
              widget.onChanged(next);
            },
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
