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
  final Text? placeholder;

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
    super.key,
  })  : assert(items != null || repository != null, 'Either items or repository must be provided'),
        assert(items == null || repository == null, 'Cannot provide both items and repository');

  /// Convenience constructor that creates an LdChoose from a list of LdSelectItem.
  ///
  /// This constructor automatically creates a repository from the items and
  /// uses the child widget from each LdSelectItem for rendering.
  static fromList<T extends Identifiable<IdType>, IdType>({
    required List<T> items,
    required Function(Set<IdType>) onChanged,
    required Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder,
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
          LdFilterSearchOption<T, IdType, dynamic>(
            name: 'search',
            label: (context) => 'Search',
            icon: (context) => const Icon(Icons.search),
            optimisticFilter: (item, searchText) {
              if (item is LdSelectItem<dynamic>) {
                return (item as LdSelectItem<dynamic>).searchString?.contains(searchText) ?? false;
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
    final nav = widget.useRootNavigator ? Navigator.of(context, rootNavigator: true) : Navigator.of(context);

    final shouldUsePage =
        widget.mode == LdChooseMode.page || (widget.mode == LdChooseMode.auto && _repository.totalItems > 10);

    final result = await (shouldUsePage
        ? nav.push<Set<IdType>>(
            MaterialPageRoute(
              builder: ((context) => _LdChoosePage<T, IdType>(
                    repository: _repository,
                    itemBuilder: widget.itemBuilder,
                    initialSelectedItems: widget.value ?? <IdType>{},
                    multiple: widget.multiple,
                    allowEmpty: widget.allowEmpty,
                    label: widget.label ?? LiquidLocalizations.of(context).choose,
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
  }

  Widget _buildSelectedItem(BuildContext context, T item) {
    return widget.selectedItemBuilder(context, item);
  }

  int _getDisplayItems(List<IdType> ids) {
    return min(ids.length, widget.truncateDisplay ?? ids.length);
  }

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);

    final selectedIds = widget.value?.toList() ?? <IdType>[];
    final selectedItems = selectedIds.length;

    int displayItems = selectedItems;
    int left = 0;

    if (widget.truncateDisplay != null) {
      displayItems = min(displayItems, widget.truncateDisplay!);
      left = selectedItems - displayItems;
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
                  child: LdSubmit(
                    arg: widget.value?.toSet(),
                    config: LdSubmitConfig<List<T>, Set<IdType>>(
                      autoTrigger: true,
                      action: (ids) async {
                        final allItems = await _fetchSelectedItems(
                          ids!.toList().sublist(0, _getDisplayItems(ids.toList())),
                        );

                        return allItems;
                      },
                    ),
                    builder: LdSubmitCustomBuilder<List<T>, Set<IdType>>(builder: (context, controller, stateType) {
                      if (stateType == LdSubmitStateType.result) {
                        return Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ...controller.state.result!.map((item) => _buildSelectedItem(context, item)).toList(),
                            if (left > 0)
                              LdText(
                                "+$left",
                                type: LdTextType.label,
                              )
                          ],
                        );
                      }
                      if (stateType == LdSubmitStateType.error) {
                        return LdExceptionView(
                          exception: controller.state.error!.localize(context),
                          direction: Axis.horizontal,
                          retryController: controller.retryController,
                        );
                      }
                      return const Center(child: LdLoader(size: 12));
                    }),
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
}

class _LdChoosePage<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final LdRepository<T, IdType> repository;
  final Widget Function(BuildContext context, LdPaginatorItem<T> item, int index) itemBuilder;
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
  State<_LdChoosePage<T, IdType>> createState() => _LdChoosePageState<T, IdType>();
}

class _LdChoosePageState<T extends Identifiable<IdType>, IdType> extends State<_LdChoosePage<T, IdType>> {
  late Set<IdType> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = Set.from(widget.initialSelectedItems);
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
