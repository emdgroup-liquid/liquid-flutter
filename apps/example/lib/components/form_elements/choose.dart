import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChooseDemo extends StatefulWidget {
  const ChooseDemo({super.key});

  @override
  State<ChooseDemo> createState() => _ChooseDemoState();
}

class _ChooseDemoState extends State<ChooseDemo> {
  Set<String> _value = {"strawberry"};

  bool _onSurface = false;
  bool _allowEmpty = false;
  bool _disabled = false;
  bool _multiple = false;
  bool _enableSearch = false;
  LdChooseMode _mode = LdChooseMode.auto;

  void _onChange(Set<String> value) {
    setState(() {
      _value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/choose.dart",
      title: "LdChoose",
      apiComponents: ["LdChoose", "LdSelectItem"],
      demo: LdAutoSpace(
        children: [
          LdText.p(
            "LdChoose is a selection component that allows users to select one or multiple items from a list of options. It supports both single and multiple selection modes, can be configured to require a selection or allow empty values, and adapts its appearance based on the platform and context.",
          ),
          ComponentWell(
            padding: EdgeInsets.all(32),
            onSurface: _onSurface,
            minHeight: 300,
            child: Center(
              child: LdAutoSpace(
                children: [
                  LdChoose.fromSelectItems(
                    label: "Your pie choice",
                    allowEmpty: _allowEmpty,
                    disabled: _disabled,
                    multiple: _multiple,
                    placeholder: const Text("Choose a pie"),
                    value: _value,
                    truncateDisplay: 3,
                    mode: _mode,
                    onChanged: _onChange,
                    searchText: _enableSearch ? (item) => item.searchString ?? '' : null,
                    items: pies,
                  ),
                  LdText.p("List item trigger"),
                  LdCard(
                    padding: EdgeInsets.zero,
                    child: LdChoose.fromSelectItems<String>(
                      items: pies,
                      onChanged: _onChange,
                      label: "Your pie choice",
                      allowEmpty: _allowEmpty,
                      disabled: _disabled,
                      multiple: _multiple,
                      placeholder: const Text("Choose a pie"),
                      value: _value,
                      truncateDisplay: 3,
                      mode: _mode,
                      triggerBuilder: (context, config) {
                        return LdChooseListItemTrigger<LdSelectItem<String>, String>(config: config);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          ldSpacerM,
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              LdSelect<LdChooseMode>(
                value: _mode,
                onChanged: (p0) {
                  setState(() {
                    _mode = p0;
                  });
                },
                items: const [
                  LdSelectItem(child: Text("Auto (uses page for 10+ items)"), value: LdChooseMode.auto),
                  LdSelectItem(child: Text("Page"), value: LdChooseMode.page),
                  LdSelectItem(child: Text("Sheet"), value: LdChooseMode.modal),
                ],
              ),
              LdButton(
                child: const Text("Add Strawberry pie"),
                onPressed: () {
                  setState(() {
                    _value.add("strawberry");
                  });
                },
              ),
              LdToggle(
                checked: _multiple,
                onChanged: (p0) {
                  setState(() {
                    _multiple = p0;
                  });
                },
                label: "Allow multiple",
              ),
              LdToggle(
                checked: _onSurface,
                onChanged: (p0) {
                  setState(() {
                    _onSurface = p0;
                  });
                },
                label: "On surface",
              ),
              LdToggle(
                checked: _allowEmpty,
                onChanged: (p0) {
                  setState(() {
                    _allowEmpty = p0;
                  });
                },
                label: "Allow empty",
              ),
              LdToggle(
                checked: _disabled,
                onChanged: (p0) {
                  setState(() {
                    _disabled = !_disabled;
                  });
                },
                label: "Disabled",
              ),
              LdToggle(
                checked: _enableSearch,
                onChanged: (p0) {
                  setState(() {
                    _enableSearch = p0;
                  });
                },
                label: "Enable search",
              ),
            ],
          ),
          ldSpacerM,
          const _LinkedListTriggerSection(),
          ldSpacerM,
          const _TagSelectorSection(),
          ldSpacerM,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Linked-list trigger demo
// ---------------------------------------------------------------------------

class _LinkedListTriggerSection extends StatefulWidget {
  const _LinkedListTriggerSection();

  @override
  State<_LinkedListTriggerSection> createState() => _LinkedListTriggerSectionState();
}

class _LinkedListTriggerSectionState extends State<_LinkedListTriggerSection> {
  Set<String> _selected = {'strawberry', 'blueberry'};

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        LdText.h('Linked-list trigger'),
        LdText.p(
          'Renders each selected item as a swipeable list row. '
          'Swipe a row left to remove it. '
          'Tap a row to "view" the item (shows a notification). '
          'The Add row at the bottom opens the picker.',
        ),
        ComponentWell(
          padding: EdgeInsets.zero,
          child: LdChoose.fromSelectItems<String>(
            items: pies,
            multiple: true,
            allowEmpty: true,
            label: 'Linked pies',
            placeholder: const Text('No pies linked yet'),
            value: _selected,
            onChanged: (ids) => setState(() => _selected = ids),
            triggerBuilder: (context, config) {
              return LdChooseLinkedListTrigger(
                config: config,
                addLabel: 'Link a pie',
                removeLabel: 'Unlink',
                onItemPressed: (ctx, item) {
                  LdNotificationsController.of(ctx).addNotification(
                    LdNotification(
                      type: LdNotificationType.info,
                      message: 'Navigating to "${item.child is Text ? (item.child as Text).data : item.id}"',
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tag selector demo — dynamic "add on the fly" via a monkey action
// ---------------------------------------------------------------------------

class _TagSelectorSection extends StatefulWidget {
  const _TagSelectorSection();

  @override
  State<_TagSelectorSection> createState() => _TagSelectorSectionState();
}

class _TagSelectorSectionState extends State<_TagSelectorSection> {
  // Mutable in-memory tag list — closed over by the model callbacks below so
  // both fetchListWithParameters and createItem always see the latest state.
  final List<LdSelectItem<String>> _tags = [
    LdSelectItem(value: 'flutter', searchString: 'flutter', child: Text('flutter')),
    LdSelectItem(value: 'dart', searchString: 'dart', child: Text('dart')),
    LdSelectItem(value: 'mobile', searchString: 'mobile', child: Text('mobile')),
    LdSelectItem(value: 'ui', searchString: 'ui', child: Text('ui')),
    LdSelectItem(value: 'design', searchString: 'design', child: Text('design')),
  ];

  Set<String> _selected = {'flutter', 'dart'};

  late final LdCallbackModel<LdSelectItem<String>, String, LdSelectItem<String>, LdSelectItem<String>> _model;
  late final LdListController<LdSelectItem<String>, String> _repo;

  @override
  void initState() {
    super.initState();
    _model = LdCallbackModel.greedy<LdSelectItem<String>, String, LdSelectItem<String>, LdSelectItem<String>>(
      getById: (context, id) async => _tags.firstWhere((item) => item.id == id),
      fetchListWithParameters: (params) async {
        final page = _tags.skip(params.offset).take(params.pageSize).toList();
        return LdListPage<LdSelectItem<String>>(
          newItems: page,
          hasMore: params.offset + params.pageSize < _tags.length,
          total: _tags.length,
        );
      },
      // createItem appends to the in-memory list and returns the new item.
      // LdListController.createFromModel handles the optimistic insert and
      // calls confirmItemCreation once this future resolves.
      createItem: (context, newItem) async {
        _tags.add(newItem);
        return newItem;
      },
    );
    _repo = LdListController(_model);
  }

  Future<void> _addTag(BuildContext appContext) async {
    final name = await ldEnterTextModal(
      context: appContext,
      title: const Text('New tag'),
      inputHint: 'Tag name',
      validate: (input) {
        final trimmed = input.trim().toLowerCase();
        return trimmed.isNotEmpty && !_tags.any((t) => t.value == trimmed);
      },
    );

    if (name == null || !appContext.mounted) return;

    final trimmed = name.trim().toLowerCase();
    final newTag = LdSelectItem<String>(value: trimmed, searchString: trimmed, child: Text(trimmed));

    await _repo.createFromModel(appContext, _model, newTag);

    if (!appContext.mounted) return;
    setState(() => _selected = {..._selected, trimmed});
  }

  @override
  void dispose() {
    _repo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        LdText.h('Tag selector — add tags on the fly'),
        LdText.p(
          'This demo shows how to pass a monkey action to LdChoose so that '
          'users can create new tags directly from inside the picker. '
          'Tap the picker trigger, then press "New tag" in the app bar.',
        ),
        ComponentWell(
          padding: const EdgeInsets.all(32),
          minHeight: 160,
          child: LdAutoSpace(
            children: [
              LdChoose<LdSelectItem<String>, String>(
                repository: _repo,
                multiple: true,
                label: 'Tags',
                value: _selected,
                onChanged: (ids) => setState(() => _selected = ids),
                filtersBuilder: (_) async => [],
                actions: [
                  LdMonkeyBareChildAction<LdSelectItem<String>, String>(
                    appBarOverflowMode: LdAppBarActionOverflowMode.pinned,
                    visibility: {LdMonkeyActionVisibility(location: LdMonkeyActionLocation.masterAppBar)},
                    builder: (ctx, trigger) => LdButton(
                      leading: const Icon(LucideIcons.plus),
                      onPressed: trigger,
                      child: const Text('New tag'),
                    ),
                    onTrigger: (ctx) => _addTag(ctx.appContext),
                  ),
                ],
                itemBuilder: (context, item, _) => LdListItem(title: item.value?.child),
                selectedItemBuilder: (context, item) => item.child,
              ),
              if (_selected.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selected.map((id) {
                    final item = _tags.firstWhere(
                      (t) => t.value == id,
                      orElse: () => LdSelectItem<String>(value: id, child: Text(id)),
                    );
                    return LdTag(
                      child: item.child,
                      onDismiss: () => setState(() => _selected = {..._selected}..remove(id)),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

var pies = [
  LdSelectItem(child: Text("Raspberry pie"), value: "raspberry", searchString: "Raspberry pie"),
  LdSelectItem(child: Text("Strawberry pie"), value: "strawberry", searchString: "Strawberry pie"),
  LdSelectItem(child: Text("Apple pie"), enabled: false, value: "apple", searchString: "Apple pie"),
  LdSelectItem(child: Text("Blueberry pie"), value: "blueberry", searchString: "Blueberry pie"),
  LdSelectItem(child: Text("Cherry pie"), value: "cherry", searchString: "Cherry pie"),
  LdSelectItem(child: Text("Peach pie"), value: "peach", searchString: "Peach pie"),
  LdSelectItem(child: Text("Chocolate pie"), value: "chocolate", searchString: "Chocolate pie"),
  LdSelectItem(child: Text("Banana bread"), value: "banana", searchString: "Banana bread"),
  LdSelectItem(child: Text("Pumpkin pie"), value: "pumpkin", searchString: "Pumpkin pie"),
  LdSelectItem(child: Text("Lemon pie"), value: "lemon", searchString: "Lemon pie"),
];
