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
            "Actions use [LdMonkeyActionContext] for selection, list controller, and app-level providers. Use `ctx.appContext` for modals and feature providers; use `ctx.selectedIds` and `ctx.listController` for monkey data."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction(
  id: 'create-task',
  tooltip: (_) => 'Create new task',
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
  submitConfig: (_) => const LdMonkeySubmitConfig(
    loadingText: "Creating new task",
  ),
  onSubmit: (ctx) async {
    // ctx.selectedIds, ctx.listController, app providers via ctx.appContext
  },
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
  id: 'create-task',
  tooltip: (_) => 'Create new task',
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
  submitConfig: (_) => const LdMonkeySubmitConfig(
    loadingText: "Creating new task",
  ),
  onSubmit: (ctx) async {
    final newTaskText = await ldEnterTextModal(
      context: ctx.appContext,
      initialValue: "New task",
      inputHint: "New Task",
      inputLabel: "Task",
      useRootNavigator: true,
    );
    if (newTaskText == null) return;
    final newTask = Task(/* ... */);
    await ctx.model<LdCallbackModel<Task, int>>().create(ctx.appContext, newTask);
    if (ctx.appContext.mounted) {
      ctx.updateViewing({newTask.id});
    }
  },
)''',
        ),
        LdText.hs("5. Delete Action Example"),
        LdText.p("A delete action that appears in multiple locations with different conditions:"),
        CodeBlock(
          language: "dart",
          code: '''deleteAction<Task, int>()''',
        ),
        LdText.hs("6. Conditional Actions"),
        LdText.p("Actions that only appear under certain conditions, like when specific filters are active:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction(
  id: 'mark-done',
  tooltip: (_) => 'Mark as done',
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.detailAppBar,
      minSelectionCount: 1,
      applyFilters: {"todo"},
    ),
  },
  child: Text("Done"),
  icon: Icon(LucideIcons.check),
  submitConfig: (_) => const LdMonkeySubmitConfig(
    loadingText: "Marking as done",
    allowResubmit: true,
  ),
  onSubmit: (ctx) async {
    final items = await ctx.getSelectedItems();
    await ctx.model<LdCallbackModel<Task, int>>().updateBatch(
      ctx.appContext,
      items.map((item) => item.copyWith(done: true)).toSet(),
    );
  },
)''',
        ),
        LdText.hs("7. Single Item Actions"),
        LdText.p("Actions that work on exactly one item at a time:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction(
  id: 'duplicate',
  tooltip: (_) => 'Duplicate',
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.detailAppBar,
      minSelectionCount: 1,
      maxSelectionCount: 1,
    ),
  },
  multiSelect: false,
  child: Text("Duplicate"),
  icon: Icon(LucideIcons.copy),
  submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Duplicating"),
  onSubmit: (ctx) async {
    final item = (await ctx.getSelectedItems()).first;
    final newItem = item.copyWith(id: testData.length + 1);
    await ctx.model<LdCallbackModel<Task, int>>().create(ctx.appContext, newItem);
    if (ctx.appContext.mounted) {
      ctx.updateViewing({newItem.id});
    }
  },
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
  LdMonkeySubmitAction(
    id: 'create-task',
    tooltip: (_) => 'New Task',
    visibility: {
      LdMonkeyActionVisibility(location: LdMonkeyActionLocation.masterAppBar),
    },
    child: Text("New Task"),
    icon: Icon(LucideIcons.plus),
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Creating new task"),
    onSubmit: (ctx) async { /* create logic */ },
  ),
  LdMonkeySubmitAction(
    id: 'mark-done',
    tooltip: (_) => 'Done',
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
        applyFilters: {"todo"},
      ),
    },
    child: Text("Done"),
    icon: Icon(LucideIcons.check),
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Marking as done"),
    onSubmit: (ctx) async { /* mark done logic */ },
  ),
  LdMonkeySubmitAction(
    id: 'delete',
    tooltip: (_) => 'Delete',
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
      ),
    },
    child: Text("Delete"),
    icon: Icon(LucideIcons.trash2),
    color: LdColor.error,
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Deleting"),
    onSubmit: (ctx) async { /* delete logic */ },
  ),
  toggleSelectionControls<Task, int>(),
  toggleFilters<Task, int>(),
],''',
        ),
      ]),
    );
  }
}
