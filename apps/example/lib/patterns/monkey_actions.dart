import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/layout/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MonkeyActionsDemo extends StatelessWidget {
  const MonkeyActionsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/patterns/monkey_actions.dart",
      category: "Patterns",
      title: "LdMonkey - Actions",
      demo: LdAutoSpace(children: [
        LdText.h("LdMonkey Actions"),
        LdText.p(
            "Actions in the monkey pattern allow users to perform operations on selected items. Actions can appear in different locations throughout the interface and have various visibility conditions."),
        ComponentsAccordion(components: {"LdMonkeyAction", "LdMonkeyActionVisibility"}),
        LdText.hs("1. Basic Action Structure"),
        LdText.p(
            "Actions are defined using LdMonkeySubmitAction (for submit-based actions) or LdMonkeyBareChildAction (for custom widgets). Actions have visibility conditions, labels, icons, and action logic."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction(
  // Where the action should appear
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.masterAppBar,
    ),
  },
  
  // Keyboard shortcuts
  shortcutActivators: {
    SingleActivator(LogicalKeyboardKey.keyN, meta: true),
  },
  
  // UI elements
  child: Text("New Task"),
  icon: Icon(LucideIcons.plus),
  
  // The actual action logic
  config: (context) => LdSubmitConfig(
    loadingText: "Creating new task",
    action: (_) async {
      // Your action implementation here
      // Access selection using: LdMonkeySelection.of<Task, int>(context).items
    },
  ),
)''',
        ),
        LdText.hs("2. Action Locations"),
        LdText.p("Actions can be placed in different locations throughout the monkey pattern interface:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("LdMonkeyActionLocation.masterAppBar"),
            child: LdText.p("Primary app bar in the master view - typically for create actions"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.masterSecondary"),
            child: LdText.p("Secondary app bar in the master view - for search, filters, and bulk operations"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.detailAppBar"),
            child: LdText.p("Primary app bar in the detail view - for item-specific actions"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.detailSecondary"),
            child: LdText.p("Secondary app bar in the detail view - for additional item actions"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.context"),
            child: LdText.p("Context menu when right-clicking on items - for quick actions"),
          ),
        ]),
        LdText.hs("3. Action Visibility Conditions"),
        LdText.p("Control when actions are visible using various conditions:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeyActionVisibility(
  location: LdMonkeyActionLocation.detailAppBar,
  
  // Selection count constraints
  minSelectionCount: 1,        // Minimum selected items
  maxSelectionCount: 5,        // Maximum selected items (null = unlimited)
  
  // Apply filters to selection
  applyFilters: {"todo"},      // Only show when "todo" filter is active
  
  // Layout modes where action is visible
  layoutModes: {
    LdMonkeyEffectiveLayoutMode.sideBySide,
    LdMonkeyEffectiveLayoutMode.detail,
  },
  
  // Show only when selection controls are visible
  visibleWhenShowingSelectionControls: true,
)''',
        ),
        LdText.hs("4. Create Action Example"),
        LdText.p("A typical create action that appears in the master app bar:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction(
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.masterAppBar,
    ),
  },
  shortcutActivators: {
    SingleActivator(LogicalKeyboardKey.keyN, meta: true),
  },
  child: Text("New Task"),
  icon: Icon(LucideIcons.plus),
  config: (context) => LdSubmitConfig(
    loadingText: "Creating new task",
    action: (_) async {
      final shellState = LdMonkeyShellState.of<Task, int>(context);
      
      // Show input dialog
      final newTaskText = await ldEnterTextModal(
        context: context,
        initialValue: "New task",
        inputHint: "New Task",
        inputLabel: "Task",
        useRootNavigator: true,
      );
      
      if (newTaskText == null) return;
      
      // Create the new item
      final newTask = Task(
        testData.length + 1,
        newTaskText,
        DateTime.now().add(const Duration(days: 1)),
        false,
        DateTime.now(),
      );
      
      await taskRepository.create(newTask);
      
      // Select the new item
      shellState.setSelectedItems({newTask.id});
    },
  ),
)''',
        ),
        LdText.hs("5. Delete Action Example"),
        LdText.p("A delete action that appears in multiple locations with different conditions:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction(
  visibility: {
    // Show in detail app bar when items are selected
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.detailAppBar,
      minSelectionCount: 1,
      maxSelectionCount: null,
    ),
    // Show in context menu when items are selected
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.context,
      minSelectionCount: 1,
      maxSelectionCount: null,
    ),
    // Show in master secondary when items are selected (only in master layout)
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.masterSecondary,
      minSelectionCount: 1,
      maxSelectionCount: null,
      layoutModes: {LdMonkeyEffectiveLayoutMode.master},
    ),
  },
  shortcutActivators: {
    SingleActivator(LogicalKeyboardKey.delete),
    SingleActivator(LogicalKeyboardKey.backspace),
  },
  color: LdTheme.of(context).error, // Use error color for destructive actions
  child: Builder(builder: (context) {
    final selection = LdMonkeySelection.of<Task, int>(context);
    return Text(
      LiquidLocalizations.of(context).deleteNItems(selection.items.length),
    );
  }),
  icon: Icon(LucideIcons.trash2),
  config: (context) => LdSubmitConfig(
    loadingText: "Deleting",
    action: (_) async {
      final selection = LdMonkeySelection.of<Task, int>(context);
      await taskRepository.deleteBatch(selection.items);
    },
  ),
)''',
        ),
        LdText.hs("6. Conditional Actions"),
        LdText.p("Actions that only appear under certain conditions, like when specific filters are active:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction(
  visibility: {
    // Only show for todo items
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.detailAppBar,
      minSelectionCount: 1,
      maxSelectionCount: null,
      applyFilters: {"todo"}, // Only when "todo" filter is active
    ),
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.context,
      minSelectionCount: 1,
      maxSelectionCount: null,
      applyFilters: {"todo"},
    ),
  },
  shortcutActivators: {
    SingleActivator(LogicalKeyboardKey.keyD),
  },
  child: Text("Done"),
  icon: Icon(LucideIcons.check),
  config: (context) => LdSubmitConfig(
    loadingText: "Marking as done",
    allowResubmit: true,
    action: (_) async {
      final updatedItems = <Task>{};
      final selection = LdMonkeySelection.of<Task, int>(context);
      
      for (final id in selection.items) {
        final item = await taskRepository.getById(id);
        updatedItems.add(item.copyWith(done: true));
      }
      
      await taskRepository.updateBatch(updatedItems);
    },
  ),
)''',
        ),
        LdText.hs("7. Single Item Actions"),
        LdText.p("Actions that work on exactly one item at a time:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction(
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.detailAppBar,
      minSelectionCount: 1,
      maxSelectionCount: 1, // Exactly one item
    ),
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.context,
      minSelectionCount: 1,
      maxSelectionCount: 1,
    ),
  },
  shortcutActivators: {
    SingleActivator(LogicalKeyboardKey.keyD, meta: true),
  },
  child: Text("Duplicate"),
  icon: Icon(LucideIcons.copy),
  multiSelect: false, // Explicitly disable multi-select
  config: (context) => LdSubmitConfig(
    loadingText: "Duplicating",
    action: (_) async {
      final shellState = LdMonkeyShellState.of<Task, int>(context);
      final selection = LdMonkeySelection.of<Task, int>(context);
      final item = await taskRepository.getById(selection.items.first);
      
      final newItem = item.copyWith(
        id: testData.length + 1,
        task: "\${item.task} (copy)",
      );
      
      await taskRepository.create(newItem);
      shellState.setSelectedItems({newItem.id});
    },
  ),
)''',
        ),
        LdText.hs("8. Built-in Actions"),
        LdText.p("The monkey pattern provides some built-in actions for common operations:"),
        CodeBlock(
          language: "dart",
          code: '''actions: [
  // Your custom actions...
  
  // Toggle selection controls (checkboxes)
  toggleSelectionControls<Task, int>(),
  
  // Toggle filter panel
  toggleFilters<Task, int>(),
],''',
        ),
        LdText.hs("9. Action Properties"),
        LdText.p("Additional properties you can configure on LdMonkeySubmitAction:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("config"),
            child: LdText.p("LdSubmitConfig function that provides loadingText and action logic"),
          ),
          LdCard(
            header: Text("child"),
            child: LdText.p("Widget to display as the action label (typically Text)"),
          ),
          LdCard(
            header: Text("icon"),
            child: LdText.p("Icon widget to display with the action"),
          ),
          LdCard(
            header: Text("color"),
            child: LdText.p("Color for the action button (useful for destructive actions)"),
          ),
          LdCard(
            header: Text("multiSelect"),
            child: LdText.p("Whether the action supports multiple selection (default: true)"),
          ),
        ]),
        LdText.hs("10. Keyboard Shortcuts"),
        LdText.p("Actions can have keyboard shortcuts using Flutter's ShortcutActivator system:"),
        CodeBlock(
          language: "dart",
          code: '''shortcutActivators: {
  // Single key
  SingleActivator(LogicalKeyboardKey.delete),
  
  // Key combination
  SingleActivator(LogicalKeyboardKey.keyN, meta: true), // Cmd+N
  
  // Multiple shortcuts for the same action
  SingleActivator(LogicalKeyboardKey.delete),
  SingleActivator(LogicalKeyboardKey.backspace),
},''',
        ),
        LdText.hs("11. Complete Actions Example"),
        LdText.p("Here's a complete set of actions for a task management system:"),
        CodeBlock(
          language: "dart",
          code: '''actions: [
  // Create new task
  LdMonkeySubmitAction(
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.masterAppBar,
      ),
    },
    shortcutActivators: {
      SingleActivator(LogicalKeyboardKey.keyN, meta: true),
    },
    child: Text("New Task"),
    icon: Icon(LucideIcons.plus),
    config: (context) => LdSubmitConfig(
      loadingText: "Creating new task",
      action: (_) async {
        final shellState = LdMonkeyShellState.of<Task, int>(context);
        // Create logic
      },
    ),
  ),
  
  // Mark as done (only for todo items)
  LdMonkeySubmitAction(
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        applyFilters: {"todo"},
      ),
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.context,
        minSelectionCount: 1,
        applyFilters: {"todo"},
      ),
    },
    shortcutActivators: {
      SingleActivator(LogicalKeyboardKey.keyD),
    },
    child: Text("Done"),
    icon: Icon(LucideIcons.check),
    config: (context) => LdSubmitConfig(
      loadingText: "Marking as done",
      action: (_) async {
        final selection = LdMonkeySelection.of<Task, int>(context);
        // Mark as done logic
      },
    ),
  ),
  
  // Delete action
  LdMonkeySubmitAction(
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
      ),
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.context,
        minSelectionCount: 1,
      ),
    },
    shortcutActivators: {
      SingleActivator(LogicalKeyboardKey.delete),
    },
    child: Text("Delete"),
    icon: Icon(LucideIcons.trash2),
    color: LdTheme.of(context).error,
    config: (context) => LdSubmitConfig(
      loadingText: "Deleting",
      action: (_) async {
        final selection = LdMonkeySelection.of<Task, int>(context);
        // Delete logic
      },
    ),
  ),
  
  // Built-in actions
  toggleSelectionControls<Task, int>(),
  toggleFilters<Task, int>(),
],''',
        ),
      ]),
    );
  }
}
