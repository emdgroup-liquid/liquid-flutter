import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/input_color_bundle.dart';

import '../liquid_flutter.dart';

enum LdChooseMode {
  page,
  modal,
  auto,
}

/// A widget that presents a dropdown in a seperate page.
class LdChoose<T> extends StatefulWidget {
  final Iterable<LdSelectItem<T>> items;
  final bool disabled;
  final bool allowEmpty;
  final LdChooseMode mode;

  final bool multiple;
  final Set<T>? value;
  final Function(Set<T>) onChange;
  final int? truncateDisplay;
  final LdSize size;
  final String? label;
  final Text? placeholder;
  final NavigatorState? navigator;
  final bool? enableSearch;
  const LdChoose({
    required this.items,
    this.allowEmpty = false,
    this.disabled = false,
    this.label,
    this.multiple = false,
    this.mode = LdChooseMode.auto,
    this.navigator,
    required this.onChange,
    this.placeholder,
    this.size = LdSize.m,
    this.truncateDisplay,
    this.enableSearch,
    this.value,
    super.key,
  });

  @override
  State<LdChoose<T>> createState() => _LdChooseState<T>();
}

class _LdChooseState<T> extends State<LdChoose<T>> {
  late final Key _sheetKey = UniqueKey();

  late bool _enableSearch;

  @override
  initState() {
    if (widget.enableSearch != null) {
      _enableSearch = widget.enableSearch!;
    } else {
      _enableSearch = widget.items.length > 10;
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTap(BuildContext context, VoidCallback openDialog) async {
    Set<T> result = widget.value ?? {};

    onChange(Set<T> value) {
      result = value;
    }

    final nav = widget.navigator ?? Navigator.of(context);

    if (widget.mode == LdChooseMode.page ||
        (widget.mode == LdChooseMode.auto && widget.items.length > 10)) {
      await nav.push(MaterialPageRoute(builder: ((context) {
        return _LdChoosePage(
          label: widget.label ?? LiquidLocalizations.of(context).choose,
          child: _LdChooseList(
            onChange: onChange,
            items: widget.items,
            enableSearch: _enableSearch,
            value: widget.value,
            onDismiss: () {
              nav.pop();
            },
            multiple: widget.multiple,
            allowEmpty: widget.allowEmpty,
          ),
        );
      })));
      widget.onChange(result);
    } else {
      openDialog();
      //LdPortalController.of(context).openEntry(_sheetKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);

    final choices = widget.items
        .where((element) => widget.value?.contains(element.value) == true)
        .toList();

    int displayItems = choices.length;
    int left = 0;

    if (widget.truncateDisplay != null) {
      displayItems = min(displayItems, widget.truncateDisplay!);
      left = choices.length - displayItems;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LdFormLabel(
          label: widget.label,
          size: widget.size,
        ),
        LdModalBuilder(
            modal: LdModal(
              key: _sheetKey,
              title:
                  Text(widget.label ?? LiquidLocalizations.of(context).choose),
              actions: (context) => [
                LdButtonGhost(
                  child: Text(
                    LiquidLocalizations.of(context).done,
                  ),
                  onPressed: Navigator.of(context).pop,
                )
              ],
              padding: EdgeInsets.zero,
              contentSlivers: (context) {
                return [
                  _LdChooseList<T>(
                    onChange: widget.onChange,
                    items: widget.items,
                    value: widget.value,
                    onDismiss: () => Navigator.of(context).pop(),
                    enableSearch: _enableSearch,
                    multiple: widget.multiple,
                    allowEmpty: widget.allowEmpty,
                  )
                ];
              },
            ),
            builder: (context, open) {
              return LdTouchableSurface(
                disabled: widget.disabled,
                onTap: () => _onTap(context, open),
                mode: LdTouchableSurfaceMode.neutralGhost,
                color: theme.palette.primary,
                builder: (contxt, _, status) {
                  final colorBundle = LdInputColorBundle.fromTheme(
                    theme,
                    onSurface: LdSurfaceInfo.of(context).isSurface,
                  ).fromTouchableStatus(status);

                  return Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: widget.disabled ? 0.5 : 1,
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Selected items
                                ...choices
                                    .sublist(0, displayItems)
                                    .map(
                                      (e) => widget.multiple
                                          ? LdTag(child: e.child)
                                          : DefaultTextStyle(
                                              child: e.child,
                                              style: TextStyle(
                                                height: 1,
                                                color: theme.palette.text,
                                                package:
                                                    theme.fontFamilyPackage,
                                                fontFamily: theme.fontFamily,
                                              ),
                                            ),
                                    )
                                    .toList(),
                                // Show a +n indicator
                                if (left != 0)
                                  LdText(
                                    "+$left",
                                    color: colorBundle.text,
                                    type: LdTextType.label,
                                  ),
                                // Placeholder if empty
                                if (choices.isEmpty &&
                                    widget.placeholder != null)
                                  DefaultTextStyle(
                                    style: ldBuildTextStyle(
                                      theme,
                                      LdTextType.label,
                                      widget.size,
                                      color: colorBundle.placeholder,
                                    ),
                                    child: widget.placeholder!,
                                  )
                              ],
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: theme.labelSize(widget.size),
                            color: theme.primaryColor)
                      ],
                    ),
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
              );
            }),
      ],
    );
  }
}

class _LdChoosePage<T> extends StatelessWidget {
  final Widget child;
  final String label;

  const _LdChoosePage({required this.child, required this.label, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);
    return Scaffold(
      appBar: LdAppBar(
        context: context,
        title: Text(label),
      ),
      backgroundColor: theme.background,
      body: CustomScrollView(slivers: [child]),
    );
  }
}

class _LdChooseList<T> extends StatefulWidget {
  final Iterable<LdSelectItem<T>> items;
  final Set<T>? value;
  final bool multiple;
  final bool shrinkWrap;
  final VoidCallback onDismiss;

  final Function(Set<T>)? onChange;

  final bool enableSearch;
  final bool allowEmpty;

  const _LdChooseList(
      {required this.items,
      required this.value,
      required this.multiple,
      required this.onChange,
      required this.allowEmpty,
      required this.onDismiss,
      this.shrinkWrap = false,
      this.enableSearch = true,
      Key? key})
      : super(key: key);

  @override
  State<_LdChooseList<T>> createState() => _LdChooseListState();
}

class _LdChooseListState<T> extends State<_LdChooseList<T>> {
  Set<T> _value = {};
  late TextEditingController _searchController;

  List<LdSelectItem<T>>? _searchResults;

  late final Fuzzy<LdSelectItem<T>> _fuze;

  void _onSearchQueryChanged(String? query) {
    if (query == null || query.isEmpty) {
      setState(() {
        _searchResults = null;
      });
      return;
    }

    setState(() {
      _searchResults = _fuze.search(query).map((e) => e.item).toList();
    });
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    if (widget.enableSearch) {
      _fuze = Fuzzy<LdSelectItem<T>>(widget.items.toList(),
          options: FuzzyOptions(keys: [
            WeightedKey(
                name: "value",
                getter: (e) => e.searchString ?? e.value.toString(),
                weight: 1)
          ]));
    }
    _value = widget.value ?? {};
    super.initState();
  }

  @override
  dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTap(BuildContext context, LdSelectItem<T> item) {
    if (item.value == null) {
      return;
    }

    if (widget.multiple == true) {
      if (_value.contains(item.value)) {
        // Prevent deselecting last item
        if (_value.length == 1 && !widget.allowEmpty) {
          return;
        }
        _value.remove(item.value);
      } else {
        _value.add(item.value!);
      }
    } else {
      if (_value.contains(item.value) == true) {
        // Prevent deselecting last item

        if (!widget.allowEmpty) {
          return;
        }
        _value.clear();
      } else {
        _value = {item.value!};
      }
    }

    widget.onChange!(_value);

    setState(() {});

    if (widget.multiple == false) {
      widget.onDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _searchResults ?? widget.items;

    final list = SliverList.separated(
      separatorBuilder: (context, index) => const LdDivider(
        height: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        var item = items.elementAt(index);

        return LdListItem(
          key: item.key ?? ValueKey(item.value),
          title: item.child,
          disabled: !item.enabled,
          isSelected: _value.contains(item.value),
          radioSelection: !widget.multiple,
          showSelectionControls: true,
          onSelectionChange: (_) => _onTap(context, item),
        );
      },
    );

    if (widget.enableSearch) {
      return SliverStickyHeader(
        header: ColoredBox(
          color: LdTheme.of(context).surface,
          child: LdInput(
            autofocus: true,
            hint: LiquidLocalizations.of(context).search,
            onChanged: _onSearchQueryChanged,
          ).padM(),
        ),
        sliver: list,
      );
    }

    return list;
  }
}
