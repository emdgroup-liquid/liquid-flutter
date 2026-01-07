import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../liquid_flutter.dart';

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
    this.mode = LdChooseMode.auto,
    required this.onChanged,
    this.hint,
    this.size = LdSize.m,
    this.truncateDisplay,
    this.value,
    this.triggerBuilder,
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
    Key? key,
  }) {
    return LdChoose<T, IdType>(
      items: items,
      itemBuilder: (context, item, index) {
        return itemBuilder(context, item, index);
      },
      selectedItemBuilder: selectedItemBuilder,
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
      value: value,
      triggerBuilder: triggerBuilder,
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
      key: key,
    );
  }

  @override
  State<LdChoose<T, IdType>> createState() => _LdChooseState<T, IdType>();
}

class _LdChooseState<T extends Identifiable<IdType>, IdType> extends State<LdChoose<T, IdType>> {
  late LdRepository<T, IdType> _repository;
  bool _ownsRepository = false;

  @override
  void initState() {
    super.initState();
    if (widget.items != null && widget.repository == null) {
      _repository = LdRepository.fromList<T, IdType>(
        list: widget.items!,
        filters: {
          LdFilterSearch<T, IdType, LdSelectItem<dynamic>>(
              name: 'search',
              label: (context) => 'Search',
              icon: (context) => const Icon(Icons.search),
              optimisticFilter: (item, searchText) {
                if (item is LdSelectItem<dynamic>) {
                  return (item as LdSelectItem<dynamic>)
                          .searchString
                          ?.toLowerCase()
                          .contains(searchText.toLowerCase()) ??
                      false;
                }

                return item.toString().toLowerCase().contains(searchText.toLowerCase());
              },
              buildSuggestion: (context, suggestion) {
                final item = suggestion as LdSelectItem<dynamic>;
                return LdListItem(
                  title: suggestion.child,
                  onPressed: () {
                    LdSearchAcceptSuggestion(suggestion: item.searchString).dispatch(context);
                  },
                );
              },
              getSuggestions: (searchText) async {
                return (widget.items! as List<LdSelectItem<dynamic>>).where((item) {
                  return (item).searchString?.toLowerCase().contains(searchText.toLowerCase()) ?? false;
                }).toList();
              }),
        },
      );
      _repository.initialOffset = 0;
      _repository.fetchItemsAtOffset(0);
      _ownsRepository = true;
    } else {
      _repository = widget.repository!;
      _ownsRepository = false;
    }
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

  Future<void> _onTap(BuildContext context) async {
    final nav = widget.useRootNavigator ? Navigator.of(context, rootNavigator: true) : Navigator.of(context);

    final shouldUsePage = switch (widget.mode) {
      LdChooseMode.page => true,
      LdChooseMode.modal => false,
      LdChooseMode.auto => _repository.totalItems > 10 && LdTheme.of(context).platform.isMobile,
    };

    final result = await (shouldUsePage
        ? nav.push<Set<IdType>>(
            MaterialPageRoute<Set<IdType>>(
              builder: (context) => LdChoosePage<T, IdType>(
                repository: _repository,
                itemBuilder: widget.itemBuilder,
                initialSelectedItems: widget.value ?? <IdType>{},
                multiple: widget.multiple,
                allowEmpty: widget.allowEmpty,
                label: widget.label ?? LiquidLocalizations.of(context).choose,
              ),
            ),
          )
        : nav.push<Set<IdType>>(
            LdModalRoute<Set<IdType>>(
              context: context,
              pageBuilder: (context) => LdChoosePage<T, IdType>(
                repository: _repository,
                itemBuilder: widget.itemBuilder,
                initialSelectedItems: widget.value ?? <IdType>{},
                multiple: widget.multiple,
                allowEmpty: widget.allowEmpty,
                label: widget.label ?? LiquidLocalizations.of(context).choose,
              ),
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

  @override
  Widget build(BuildContext context) {
    final selectedIds = widget.value?.toList() ?? <IdType>[];

    return LdSubmit(
      arg: widget.value,
      argEquals: (oldArg, newArg) {
        bool equals = setEquals(oldArg, newArg);
        return equals;
      },
      config: LdSubmitConfig<List<T>, Set<IdType>?>(
        autoTrigger: true,
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
      builder: LdSubmitCustomBuilder<List<T>, Set<IdType>?>(
        builder: (context, controller, stateType) {
          final selectedItems = controller.state.result ?? <T>[];

          final triggerConfig = LdChooseTriggerConfig<T, IdType>(
            selectedItems: selectedItems,
            hint: widget.hint,
            selectedIds: selectedIds,
            state: controller.state,
            onTap: () => _onTap(context),
            truncateDisplay: widget.truncateDisplay ?? 3,
            label: widget.label ?? LiquidLocalizations.of(context).choose,
            size: widget.size,
            disabled: widget.disabled,
            selectedItemBuilder: widget.selectedItemBuilder,
          );

          // Use custom trigger builder if provided
          if (widget.triggerBuilder != null) {
            return widget.triggerBuilder!(context, triggerConfig);
          }

          // Default trigger builder
          return LdChooseInputTrigger(
            config: triggerConfig,
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
  final String label;

  const LdChoosePage({
    required this.repository,
    required this.itemBuilder,
    required this.initialSelectedItems,
    required this.multiple,
    required this.allowEmpty,
    required this.label,
    super.key,
  });

  @override
  State<LdChoosePage<T, IdType>> createState() => _LdChoosePageState<T, IdType>();
}

class _LdChoosePageState<T extends Identifiable<IdType>, IdType> extends State<LdChoosePage<T, IdType>> {
  late Set<IdType> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = Set<IdType>.from(widget.initialSelectedItems);
  }

  void _handleSelectionChange(Set<IdType> selectedItems) {
    // Enforce allowEmpty constraint
    if (!widget.allowEmpty && selectedItems.isEmpty && _selectedItems.isNotEmpty) {
      return; // Prevent clearing selection if allowEmpty is false
    }

    setState(() {
      _selectedItems = selectedItems;
    });

    // // For single select, dismiss immediately when selection changes
    // if (!widget.multiple && selectedItems.length == 1) {
    //   Navigator.of(context).pop(selectedItems);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final searchConfig = widget.repository.getSearchConfig();
    return LdScaffold(
      debugName: "LdChoosePage",
      appBars: [
        LdAppBar(
          debugName: "LdChoosePageAppBar",
          title: Text(widget.label),
          order: 0,
          implyCloseModalButton: false,
          actions: [
            if (widget.allowEmpty)
              LdButton.ghost(
                disabled: _selectedItems.isEmpty,
                onPressed: () {
                  setState(() {
                    _selectedItems = {};
                  });
                },
                child: const Text("Clear"),
              ),
            LdButton(
              disabled: _selectedItems.isEmpty && !widget.allowEmpty,
              key: const Key("ldChoose_done"),
              onPressed: () {
                maybePopContextMenu(context);
                Navigator.of(context).pop(_selectedItems);
              },
              child: const Text("Done"),
            ),
          ],
        ),
        if (searchConfig != null)
          LdAppBar.top(
            order: 1,
            debugName: "LdChoosePageSearchAppBar",
            searchConfig: searchConfig,
          ),
      ],
      body: Builder(builder: (context) {
        return LdSelectableList<T, IdType>(
            paginator: widget.repository,
            itemBuilder: widget.itemBuilder,
            initialSelectedItems: _selectedItems,
            multiSelect: widget.multiple,
            showSelectionControls: true,
            onSelectionChange: _handleSelectionChange,
            listBuilder: (context, itemBuilder) {
              return LdList(
                paginator: widget.repository,
                padding: MediaQuery.paddingOf(context),
                itemBuilder: itemBuilder,
              );
            });
      }),
    );
  }
}
