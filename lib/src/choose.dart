import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/touchable/input_color.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../liquid_flutter.dart';

enum LdChooseMode {
  page,
  modal,
  auto,
}

/// A widget that presents a dropdown in a seperate page.
class LdChoose<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final LdRepository<T, IdType>? repository;
  final List<T>? items;
  final Widget Function(
      BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;
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
  final Text? placeholder;
  final Widget Function(
    BuildContext context,
    List<T> selectedItems,
    VoidCallback onTap,
    bool isLoading,
    LdException? error,
  )? triggerBuilder;

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
    this.placeholder,
    this.size = LdSize.m,
    this.truncateDisplay,
    this.value,
    this.triggerBuilder,
    super.key,
  })  : assert(items != null || repository != null,
            'Either items or repository must be provided'),
        assert(items == null || repository == null,
            'Cannot provide both items and repository');

  /// Convenience constructor that creates an LdChoose from a list of LdSelectItem.
  ///
  /// This constructor automatically creates a repository from the items and
  /// uses the child widget from each LdSelectItem for rendering.
  static fromList<T extends Identifiable<IdType>, IdType>({
    required List<T> items,
    required Function(Set<IdType>) onChanged,
    required Widget Function(
            BuildContext context, LdPaginatorItem<T> item, int index)
        itemBuilder,
    required Widget Function(BuildContext context, T item) selectedItemBuilder,
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
    Widget Function(
      BuildContext context,
      List<T> selectedItems,
      VoidCallback onTap,
      bool isLoading,
      LdException? error,
    )? triggerBuilder,
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
      placeholder: placeholder,
      size: size,
      truncateDisplay: truncateDisplay,
      value: value,
      triggerBuilder: triggerBuilder,
      key: key,
    );
  }

  static fromSelectItems<T>({
    required List<LdSelectItem<T>> items,
    required Function(Set<T>) onChanged,
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
    Widget Function(
      BuildContext context,
      List<LdSelectItem<T>> selectedItems,
      VoidCallback onTap,
      bool isLoading,
      LdException? error,
    )? triggerBuilder,
    Key? key,
  }) {
    return fromList(
      items: items,
      onChanged: onChanged,
      itemBuilder: (context, item, index) {
        return LdListItem(
          title: item.value?.child,
          disabled: !(item.value?.enabled ?? true),
        );
      },
      selectedItemBuilder: (context, item) {
        return LdTag(child: item.child);
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

class _LdChooseState<T extends Identifiable<IdType>, IdType>
    extends State<LdChoose<T, IdType>> {
  late LdRepository<T, IdType> _repository;
  bool _ownsRepository = false;

  @override
  void initState() {
    super.initState();
    if (widget.items != null && widget.repository == null) {
      _repository = LdRepository.fromList<T, IdType>(
        list: widget.items!,
        filters: {
          LdFilterSearchOption<T, IdType, dynamic>(
            name: 'search',
            label: (context) => 'Search',
            icon: (context) => const Icon(Icons.search),
            optimisticFilter: (item, searchText) {
              if (item is LdSelectItem<dynamic>) {
                return (item as LdSelectItem<dynamic>)
                        .searchString
                        ?.contains(searchText) ??
                    false;
              }

              return item.toString().contains(searchText);
            },
          ),
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
    final nav = widget.useRootNavigator
        ? Navigator.of(context, rootNavigator: true)
        : Navigator.of(context);

    final shouldUsePage = widget.mode == LdChooseMode.page ||
        (widget.mode == LdChooseMode.auto && _repository.totalItems > 10);

    final result = await (shouldUsePage
        ? nav.push<Set<IdType>>(
            MaterialPageRoute(
              builder: ((context) => _LdChoosePage<T, IdType>(
                    repository: _repository,
                    itemBuilder: widget.itemBuilder,
                    initialSelectedItems: widget.value ?? <IdType>{},
                    multiple: widget.multiple,
                    allowEmpty: widget.allowEmpty,
                    label:
                        widget.label ?? LiquidLocalizations.of(context).choose,
                  )),
            ),
          )
        : nav.push<Set<IdType>>(
            LdModalRoute(
              context: context,
              pageBuilder: (context) => _LdChoosePage<T, IdType>(
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

  Widget _buildSelectedItem(BuildContext context, T item) {
    return widget.selectedItemBuilder(context, item);
  }

  int _getDisplayItems(List<IdType> ids) {
    return min(ids.length, widget.truncateDisplay ?? ids.length);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = widget.value?.toList() ?? <IdType>[];

    return LdSubmit(
      arg: widget.value,
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
          final isLoading = stateType == LdSubmitStateType.loading;
          final error = controller.state.error;

          // Use custom trigger builder if provided
          if (widget.triggerBuilder != null) {
            return widget.triggerBuilder!(
              context,
              selectedItems,
              () => _onTap(context),
              isLoading,
              error,
            );
          }

          // Default trigger builder
          return _buildDefaultTrigger(
            context,
            selectedItems,
            selectedIds,
            isLoading,
            error,
          );
        },
      ),
    );
  }

  Widget _buildDefaultTrigger(
    BuildContext context,
    List<T> selectedItems,
    List<IdType> selectedIds,
    bool isLoading,
    LdException? error,
  ) {
    var theme = LdTheme.of(context, listen: true);
    final selectedItemsCount = selectedIds.length;

    int displayItems = selectedItemsCount;
    int left = 0;

    if (widget.truncateDisplay != null) {
      displayItems = min(displayItems, widget.truncateDisplay!);
      left = selectedItemsCount - displayItems;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LdFormLabel(
          label: widget.label,
          size: widget.size,
        ),
        LdTouchableSurface(
          disabled: widget.disabled,
          key: const Key("ldChoose_trigger"),
          onPressed: () => _onTap(context),
          mode: LdTouchableSurfaceMode.neutralGhost,
          child: Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: widget.disabled ? 0.5 : 1,
                  child: _buildSelectedItemsDisplay(
                    context,
                    selectedItems,
                    left,
                    isLoading,
                    error,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: theme.labelSize(widget.size),
                color: theme.primaryColor,
              ),
            ],
          ),
          color: theme.palette.primary,
          builder: (contxt, _, status, child) {
            final colorBundle = inputColor(
              theme,
              status,
              isValid: true,
              onSurface: LdSurfaceInfo.of(context).isSurface,
            );

            return Container(
              child: child!,
              padding: theme.balPad(widget.size),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: theme.radius(LdSize.s),
                color: colorBundle.surface,
                border: Border.all(
                  color: colorBundle.border,
                  width: theme.borderWidth,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedItemsDisplay(
    BuildContext context,
    List<T> selectedItems,
    int left,
    bool isLoading,
    LdException? error,
  ) {
    if (isLoading) {
      return const Center(child: LdLoader(size: 12));
    }

    if (error != null) {
      return LdExceptionView(
        exception: error.localize(context),
        direction: Axis.horizontal,
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (selectedItems.isEmpty)
          LdMute(
            child: LdText.ls("No items selected"),
          ),
        if (selectedItems.isNotEmpty)
          ...selectedItems
              .map((item) => _buildSelectedItem(context, item))
              .toList(),
        if (selectedItems.isNotEmpty && left > 0)
          LdText(
            "+$left",
            type: LdTextType.label,
          ),
      ],
    );
  }
}

class _LdChoosePage<T extends Identifiable<IdType>, IdType>
    extends StatefulWidget {
  final LdRepository<T, IdType> repository;
  final Widget Function(
      BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;
  final Set<IdType> initialSelectedItems;
  final bool multiple;
  final bool allowEmpty;
  final String label;

  const _LdChoosePage({
    required this.repository,
    required this.itemBuilder,
    required this.initialSelectedItems,
    required this.multiple,
    required this.allowEmpty,
    required this.label,
    super.key,
  });

  @override
  State<_LdChoosePage<T, IdType>> createState() =>
      _LdChoosePageState<T, IdType>();
}

class _LdChoosePageState<T extends Identifiable<IdType>, IdType>
    extends State<_LdChoosePage<T, IdType>> {
  late Set<IdType> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = Set.from(widget.initialSelectedItems);
  }

  void _handleSelectionChange(Set<IdType> selectedItems) {
    // Enforce allowEmpty constraint
    if (!widget.allowEmpty &&
        selectedItems.isEmpty &&
        _selectedItems.isNotEmpty) {
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
      appBar: LdAppBar(
        debugName: "LdChoosePageAppBar",
        title: Text(widget.label),
        implyCloseModalButton: false,
        actions: [
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
            onPressed: () {
              maybePopContextMenu(context);
              Navigator.of(context).pop(_selectedItems);
            },
            child: const Text("Done"),
          ),
        ],
      ),
      secondaryAppBar: searchConfig != null
          ? LdAppBar(
              searchConfig: searchConfig,
            )
          : null,
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
