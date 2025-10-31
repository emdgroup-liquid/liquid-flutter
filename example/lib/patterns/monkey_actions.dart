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
        ComponentsAccordion(
            components: {"LdMonkeyAction", "LdMonkeyActionVisibility"}),
        LdText.hs("1. Basic Action Structure"),
        LdText.p(
            "Every action is defined using the LdMonkeyAction class with visibility conditions, labels, icons, and the action logic."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeyAction(
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
  buildLabel: (context, selection) => "New Task",
  buildIcon: (context, selection) => const Icon(LucideIcons.plus),
  
  // The actual action logic
  action: (context, selection) async {
    // Your action implementation here
  },
)''',
        ),
        LdText.hs("2. Action Locations"),
        LdText.p(
            "Actions can be placed in different locations throughout the monkey pattern interface:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("LdMonkeyActionLocation.masterAppBar"),
            child: LdText.p(
                "Primary app bar in the master view - typically for create actions"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.masterSecondary"),
            child: LdText.p(
                "Secondary app bar in the master view - for search, filters, and bulk operations"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.detailAppBar"),
            child: LdText.p(
                "Primary app bar in the detail view - for item-specific actions"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.detailSecondary"),
            child: LdText.p(
                "Secondary app bar in the detail view - for additional item actions"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.context"),
            child: LdText.p(
                "Context menu when right-clicking on items - for quick actions"),
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
  
  // Visibility in split view
  visibleInSplitView: true,    // Show in side-by-side layout
  
  // Custom visibility function
  visible: (context, selection, filters) {
    return selection.length > 0;
  },
)''',
        ),
        LdText.hs("4. Create Action Example"),
        LdText.p("A typical create action that appears in the master app bar:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeyAction(
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.masterAppBar,
    ),
  },
  shortcutActivators: {
    SingleActivator(LogicalKeyboardKey.keyN, meta: true),
  },
  buildLoadingText: (context, selection) => "Creating new task",
  buildLabel: (context, selection) => "New Task",
  buildIcon: (context, selection) => const Icon(LucideIcons.plus),
  action: (context, selection) async {
    final route = LdMonkey.of<Task, int, bool>(context);
    
    // Show input dialog
    final newTaskNotification = LdNotificationsController.of(context)
        .enterText(
            message: "New task",
            inputHint: "New Task",
            inputLabel: "Task");
    
    final newTaskText = await newTaskNotification.inputCompleter.future;
    
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
    route.setSelectedItems({newTask.id});
  },
)''',
        ),
        LdText.hs("5. Delete Action Example"),
        LdText.p(
            "A delete action that appears in multiple locations with different conditions:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeyAction(
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
    // Show in master secondary when items are selected (not in split view)
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.masterSecondary,
      minSelectionCount: 1,
      maxSelectionCount: null,
      visibleInSplitView: false,
    ),
  },
  shortcutActivators: {
    SingleActivator(LogicalKeyboardKey.delete),
    SingleActivator(LogicalKeyboardKey.backspace),
  },
  buildLoadingText: (context, selection) =>
      "Deleting \${selection.length} \${selection.length == 1 ? "item" : "items"}",
  buildLabel: (context, selection) =>
      "Delete \${selection.length} \${selection.length == 1 ? "item" : "items"}",
  buildIcon: (context, selection) => const Icon(LucideIcons.trash2),
  color: shadRed, // Use error color for destructive actions
  action: (context, selection) async {
    await taskRepository.deleteBatch(selection);
  },
)''',
        ),
        LdText.hs("6. Conditional Actions"),
        LdText.p(
            "Actions that only appear under certain conditions, like when specific filters are active:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeyAction(
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
  buildLoadingText: (context, selection) => "Marking as done",
  buildLabel: (context, selection) => "Done",
  buildIcon: (context, selection) => const Icon(LucideIcons.check),
  action: (context, selection) async {
    final updatedItems = <Task>{};
    
    for (final id in selection) {
      final item = await taskRepository.getById(id);
      updatedItems.add(item.copyWith(done: true));
    }
    
    await taskRepository.updateBatch(updatedItems);
  },
)''',
        ),
        LdText.hs("7. Single Item Actions"),
        LdText.p("Actions that work on exactly one item at a time:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeyAction(
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
  buildLoadingText: (context, selection) => "Duplicating",
  buildLabel: (context, selection) => "Duplicate",
  buildIcon: (context, selection) => const Icon(LucideIcons.copy),
  multiSelect: false, // Explicitly disable multi-select
  action: (context, selection) async {
    final route = LdMonkey.of<Task, int, bool>(context);
    final item = await taskRepository.getById(selection.first);
    
    final newItem = item.copyWith(
      id: testData.length + 1,
      task: "\${item.task} (copy)",
    );
    
    await taskRepository.create(newItem);
    route.setSelectedItems({newItem.id});
  },
)''',
        ),
        LdText.hs("8. Built-in Actions"),
        LdText.p(
            "The monkey pattern provides some built-in actions for common operations:"),
        CodeBlock(
          language: "dart",
          code: '''actions: [
  // Your custom actions...
  
  // Toggle selection controls (checkboxes)
  toggleSelectionControls<Task, int, bool>(),
  
  // Toggle filter panel
  toggleFilters<Task, int, bool>(),
],''',
        ),
        LdText.hs("9. Action Properties"),
        LdText.p("Additional properties you can configure on actions:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("buildLoadingText"),
            child: LdText.p("Text shown while the action is executing"),
          ),
          LdCard(
            header: Text("color"),
            child: LdText.p(
                "Color for the action button (useful for destructive actions)"),
          ),
          LdCard(
            header: Text("multiSelect"),
            child: LdText.p(
                "Whether the action supports multiple selection (default: true)"),
          ),
          LdCard(
            header: Text("submitType"),
            child: LdText.p(
                "How the action should be submitted (none, primary, etc.)"),
          ),
        ]),
        LdText.hs("10. Keyboard Shortcuts"),
        LdText.p(
            "Actions can have keyboard shortcuts using Flutter's ShortcutActivator system:"),
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
        LdText.p(
            "Here's a complete set of actions for a task management system:"),
        CodeBlock(
          language: "dart",
          code: '''actions: [
  // Create new task
  LdMonkeyAction(
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.masterAppBar,
      ),
    },
    shortcutActivators: {
      SingleActivator(LogicalKeyboardKey.keyN, meta: true),
    },
    buildLabel: (context, selection) => "New Task",
    buildIcon: (context, selection) => const Icon(LucideIcons.plus),
    action: (context, selection) async {
      // Create logic
    },
  ),
  
  // Mark as done (only for todo items)
  LdMonkeyAction(
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
    buildLabel: (context, selection) => "Done",
    buildIcon: (context, selection) => const Icon(LucideIcons.check),
    action: (context, selection) async {
      // Mark as done logic
    },
  ),
  
  // Delete action
  LdMonkeyAction(
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
    buildLabel: (context, selection) => "Delete",
    buildIcon: (context, selection) => const Icon(LucideIcons.trash2),
    color: shadRed,
    action: (context, selection) async {
      // Delete logic
    },
  ),
  
  // Built-in actions
  toggleSelectionControls<Task, int, bool>(),
  toggleFilters<Task, int, bool>(),
],''',
        ),
      ]),
    );
  }
}
