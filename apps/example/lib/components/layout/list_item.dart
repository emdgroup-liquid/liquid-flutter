import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class _SlidableDemoItem {
  const _SlidableDemoItem({required this.id, required this.title, required this.subtitle});

  final int id;
  final String title;
  final String subtitle;
}

class ListItemDemo extends StatefulWidget {
  const ListItemDemo({super.key});

  @override
  State<ListItemDemo> createState() => _ListItemDemoState();
}

class _ListItemDemoState extends State<ListItemDemo> {
  LdSelectionControl _showSelectionControls = LdSelectionControl.none;
  final Set<int> _selectedItems = {};
  bool _toggleValue = false;
  List<_SlidableDemoItem> _slidableItems = [
    const _SlidableDemoItem(id: 1, title: 'Inbox message', subtitle: 'Swipe left for actions'),
    const _SlidableDemoItem(id: 2, title: 'Team update', subtitle: 'Full swipe triggers without tapping'),
    const _SlidableDemoItem(id: 3, title: 'Reminder', subtitle: 'Delete collapses the row'),
  ];
  void _setSelectionControls(LdSelectionControl value) {
    setState(() {
      _showSelectionControls = value;
    });
  }

  void _selectItem(int index) {
    setState(() {
      _selectedItems.add(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/layout/list_item.dart",
      title: "LdListItem",
      demo: LdAutoSpace(
        children: [
          LdText.p("The LdListItem can be used to display information in a list format. It supports:"),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: LdText.p(
              "• Leading and trailing widgets\n"
              "• Selection controls (checkbox/radio)\n"
              "• Disabled state\n"
              "• Forward indicator\n"
              "• Title and subtitle\n"
              "• Custom tap handling",
            ),
          ),
          ldSpacerL,
          LdText.caption("Title only"),
          ComponentWell(
            padding: EdgeInsets.zero,
            child: Column(
              children: [LdListItem(title: Text("Just a title"), onPressed: () {})],
            ),
          ),

          ComponentWell(
            onSurface: true,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LdListItem(title: Text("Just a title"), onPressed: () {}),
                LdDivider(),
                LdListItem(
                  selectionControl: _showSelectionControls,
                  isSelected: _selectedItems.contains(0),
                  onSelectionChanged: (selected) => _selectItem(0),
                  leading: LdAvatar(child: Text("A")),
                  title: Text("Liquid Flutter List"),
                  subtitle: Text("This is a subtitle"),
                ),
                LdDivider(),
                LdListItem(
                  leading: LdAvatar(child: Text("B")),
                  onPressed: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(message: "You pressed the list item", type: LdNotificationType.success),
                    );
                  },
                  title: Text("Press me"),
                  subtitle: Text("I will  trade leading for selection control"),
                ),
                LdListSeperator(child: LdText.caption("This is a separator")),
                LdListItem(
                  disabled: true,
                  selectionControl: _showSelectionControls,
                  isSelected: _selectedItems.contains(2),
                  trailing: LdTag(child: Text("Hyper hyper")),
                  onSelectionChanged: (selected) => _selectItem(2),
                  leading: LdAvatar(child: Text("C")),
                  title: Text("You cant press me because I am disabled"),
                  subtitle: Text("This is another subtitle"),
                ),
                LdListItem(
                  leading: LdAvatar(child: Text("D")),
                  selectionControl: _showSelectionControls,
                  isSelected: _selectedItems.contains(3),
                  onSelectionChanged: (selected) => _selectItem(3),
                  title: Text("Very Good Option"),
                  subtitle: Text("This is another subtitle"),
                ),
              ],
            ),
          ),
          ldSpacerM,
          LdSwitch<LdSelectionControl>(
            children: const {
              LdSelectionControl.none: Text("None"),
              LdSelectionControl.checkbox: Text("Checkbox"),
              LdSelectionControl.radio: Text("Radio"),
            },
            value: _showSelectionControls,
            onChanged: _setSelectionControls,
          ),
          ComponentWell(
            title: LdText.h("LdSlidableListItem"),
            description: LdText.p(
              "Swipe a row to reveal actions. Swipe fully into an action to trigger it, or tap a revealed action. "
              "Delete uses a dismiss animation before removing the row.",
            ),
            onSurface: true,
            padding: EdgeInsets.zero,
            child: LdSlidableGroup(
              child: Column(
                children: [
                  for (var i = 0; i < _slidableItems.length; i++) ...[
                    LdSlidableListItem(
                      startActionPane: LdSlideActionPane(
                        actions: [
                          LdSlideAction(
                            icon: LucideIcons.archive,
                            label: 'Archive',
                            color: LdTheme.of(context).palette.primary,
                            onTriggered: (context) {
                              LdNotificationsController.of(context).addNotification(
                                LdNotification(
                                  message: 'Archived ${_slidableItems[i].title}',
                                  type: LdNotificationType.success,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      endActionPane: LdSlideActionPane(
                        actions: [
                          LdSlideAction(
                            icon: LucideIcons.trash2,
                            label: 'Delete',
                            color: LdTheme.of(context).palette.error,
                            dismissBehavior: LdSlideActionDismissBehavior.dismiss,
                            onTriggered: (context) {
                              setState(() {
                                _slidableItems = _slidableItems
                                    .where((entry) => entry.id != _slidableItems[i].id)
                                    .toList(growable: false);
                              });
                            },
                          ),
                        ],
                      ),
                      child: LdListItem(
                        leading: LdAvatar(child: Text(_slidableItems[i].title.substring(0, 1))),
                        title: Text(_slidableItems[i].title),
                        subtitle: Text(_slidableItems[i].subtitle),
                      ),
                    ),
                    if (i < _slidableItems.length - 1) const LdDivider(height: 1),
                  ],
                ],
              ),
            ),
          ),
          ComponentWell(
            title: LdText.h("LdListItemToggle"),
            description: LdText.p(
              "The LdListItemToggle is a convenient wrapper around LdListItem and LdToggle. It is used to toggle the value of a boolean variable.",
            ),
            onSurface: true,
            child: Column(
              children: [
                LdListItemToggle(
                  checked: _toggleValue,
                  borderRadius: LdTheme.of(context).radius(LdSize.m),
                  onChanged: (value) {
                    setState(() {
                      _toggleValue = value;
                    });
                  },
                  title: Text("Toggle me"),
                  subtitle: Text("I will toggle the value"),
                ),
              ],
            ),
          ),
          ComponentWell(
            title: LdText.h("LdListItemLoading"),
            description: LdText.p("Show some skeleton while waiting for the data to load."),
            onSurface: true,
            child: LdAutoSpace(
              children: [
                LdText.p("With leading and subtitle"),
                LdListItemLoading(hasLeading: true, hasSubtitle: true),
                LdText.p("With leading"),
                LdListItemLoading(hasLeading: true),
                LdText.p("With leading and trailing"),
                LdListItemLoading(hasLeading: true, hasTrailing: true),
                LdText.p("With leading and trailing and subtitle"),
                LdListItemLoading(hasLeading: true, hasTrailing: true, hasSubtitle: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
