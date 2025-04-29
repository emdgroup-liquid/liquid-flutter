import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ListItemDemo extends StatefulWidget {
  const ListItemDemo({super.key});

  @override
  State<ListItemDemo> createState() => _ListItemDemoState();
}

class _ListItemDemoState extends State<ListItemDemo> {
  bool _showSelectionControls = false;
  final Set<int> _selectedItems = {};

  void _setSelectionControls(bool value) {
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
      title: "LdListItem",
      demo: LdAutoSpace(
        children: [
          LdTextP("The LdListItem can be used to display information in a list format. It supports:"),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: LdTextP(
              "• Leading and trailing widgets\n"
              "• Selection controls (checkbox/radio)\n"
              "• Disabled state\n"
              "• Forward indicator\n"
              "• Title and subtitle\n"
              "• Custom tap handling",
            ),
          ),
          ldSpacerL,
          ComponentWell(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                LdListItem(
                  showSelectionControls: _showSelectionControls,
                  trailingForward: true,
                  isSelected: _selectedItems.contains(0),
                  onSelectionChange: (selected) => _selectItem(0),
                  leading: LdAvatar(
                    child: Text("A"),
                  ),
                  title: Text("Liquid Flutter List"),
                  subtitle: Text("This is a subtitle"),
                ),
                LdDivider(
                  height: 1,
                ),
                LdListItem(
                  leading: LdAvatar(
                    child: Text("B"),
                  ),
                  onTap: () {
                    LdNotificationsController.of(context).addNotification(
                      LdNotification(message: "You pressed the list item", type: LdNotificationType.success),
                    );
                  },
                  title: Text("Press me"),
                  subtitle: Text("I will  trade leading for selection control"),
                ),
                LdListSeperator(
                  child: Text("This is a separator"),
                ),
                LdListItem(
                  disabled: true,
                  showSelectionControls: _showSelectionControls,
                  isSelected: _selectedItems.contains(2),
                  trailing: LdTag(
                    child: Text("Hyper hyper"),
                  ),
                  onSelectionChange: (selected) => _selectItem(2),
                  leading: LdAvatar(
                    child: Text("C"),
                  ),
                  title: Text("You cant press me because I am disabled"),
                  subtitle: Text("This is another subtitle"),
                ),
                LdListItem(
                  leading: LdAvatar(
                    child: Text("D"),
                  ),
                  showSelectionControls: _showSelectionControls,
                  radioSelection: true,
                  isSelected: _selectedItems.contains(3),
                  onSelectionChange: (selected) => _selectItem(3),
                  title: Text("Very Good Option"),
                  subtitle: Text("This is another subtitle"),
                )
              ],
            ),
          ),
          ldSpacerM,
          Row(
            children: [
              Expanded(
                child: LdToggle(
                  label: "Show selection controls",
                  checked: _showSelectionControls,
                  onChanged: _setSelectionControls,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
