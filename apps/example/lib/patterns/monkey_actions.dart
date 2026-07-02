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
            "Actions use [LdMonkeyActionContext] for selection, list controller, and app-level providers. "
            "Use ctx.appContext for modals and feature providers; use ctx.selectedIds and ctx.model<...>() for monkey data."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction<Task, int, void>(
  id: 'create-task',           // required unique identifier
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
    // ctx.selectedIds, ctx.model<LdCallbackModel<Task, int>>(), providers via ctx.appContext
  },
)''',
        ),
        LdText.hs("2. Action Locations"),
        LdText.p("Actions can be placed in different locations throughout the monkey pattern interface:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("LdMonkeyActionLocation.masterAppBar"),
            child: LdText.p("Primary app bar in the master view — typically for create and filter actions"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.masterSecondary"),
            child: LdText.p("Secondary app bar in the master view — for bulk operations and selection controls"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.detailAppBar"),
            child: LdText.p("Primary app bar in the detail view — for item-specific actions"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.detailSecondary"),
            child: LdText.p("Secondary app bar in the detail view — for additional item actions"),
          ),
          LdCard(
            header: Text("LdMonkeyActionLocation.context"),
            child: LdText.p("Context menu when right-clicking or long-pressing items — for quick actions"),
          ),
        ]),
        LdText.hs("3. Action Visibility Conditions"),
        LdText.p("Control when actions are visible using LdMonkeyActionVisibility:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeyActionVisibility(
  location: LdMonkeyActionLocation.detailAppBar,
  
  // Selection count constraints
  minSelectionCount: 1,        // minimum selected items
  maxSelectionCount: 5,        // maximum selected items (null = unlimited)
  
  // Layout modes where action is visible (default: all three)
  layoutModes: {
    LdMonkeyEffectiveLayoutMode.sideBySide,
    LdMonkeyEffectiveLayoutMode.detail,
  },
  
  // Show only when selection controls (checkboxes) are or are not shown
  visibleWhenShowingSelectionControls: true,  // null = always
  
  // Custom predicate — receives the full LdMonkeyActionContext
  isVisible: (ctx) => ctx.selectedIds.length == 1,
)''',
        ),
        LdText.hs("4. Create Action Example"),
        LdText.p(
            "A typical create action that appears in the master app bar. "
            "Use reactiveCreateAction if you have a dedicated create route."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction<Task, int, void>(
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
)

// Alternative: use reactiveCreateAction for a dedicated create route
reactiveCreateAction<Task, int>(routeConfig: taskRouteConfig)''',
        ),
        LdText.hs("5. Delete Action"),
        LdText.p(
            "Use the built-in deleteAction factory for standard item deletion. "
            "It handles confirmation, batch deletion, and selection cleanup automatically."),
        CodeBlock(
          language: "dart",
          code: '''deleteAction<Task, int>()''',
        ),
        LdText.hs("6. Conditional Actions"),
        LdText.p(
            "Use isVisible on LdMonkeyActionVisibility to gate actions on custom logic, "
            "such as the state of the selected items:"),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeySubmitAction<Task, int, void>(
  id: 'mark-done',
  tooltip: (_) => 'Mark as done',
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.detailAppBar,
      minSelectionCount: 1,
      isVisible: (ctx) {
        // Only show when at least one selected item is not done
        return ctx.selection.any((id) {
          final item = ctx.listController.itemForId(id);
          return item?.done == false;
        });
      },
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
          code: '''LdMonkeySubmitAction<Task, int, void>(
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
    final newItem = item.copyWith(id: nextId());
    await ctx.model<LdCallbackModel<Task, int>>().create(ctx.appContext, newItem);
    if (ctx.appContext.mounted) {
      ctx.updateViewing({newItem.id});
    }
  },
)''',
        ),
        LdText.hs("8. Built-in Actions"),
        LdText.p("The monkey pattern provides factory functions for common actions:"),
        CodeBlock(
          language: "dart",
          code: '''actions: [
  // Toggle checkbox selection mode
  toggleSelectionControls<Task, int>(),
  
  // Show filter dropdown or modal
  showFilterContextMenu<Task, int>(),  // popover
  showFilterModal<Task, int>(),        // full modal
  
  // Desktop-only refresh button
  refreshAction<Task, int>(),
  
  // Built-in delete with confirmation
  deleteAction<Task, int>(),
  
  // Push to the create route (requires createPage on buildMonkeyRoutes)
  reactiveCreateAction<Task, int>(routeConfig: taskRouteConfig),
],''',
        ),
        LdText.hs("9. Action Properties"),
        LdText.p("Key properties on LdMonkeySubmitAction:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("id"),
            child: LdText.p("Required unique Object (String or enum) — coordinates the offstage LdSubmit host with app bar triggers"),
          ),
          LdCard(
            header: Text("submitConfig"),
            child: LdText.p("Function(BuildContext) returning LdMonkeySubmitConfig with loadingText and other submit options"),
          ),
          LdCard(
            header: Text("child / childBuilder"),
            child: LdText.p("Static label widget (child) or reactive builder (childBuilder) for the action button"),
          ),
          LdCard(
            header: Text("icon"),
            child: LdText.p("Icon widget displayed with the action"),
          ),
          LdCard(
            header: Text("color"),
            child: LdText.p("LdColor for the action button — use LdColor.error for destructive actions"),
          ),
          LdCard(
            header: Text("multiSelect"),
            child: LdText.p("Whether the action applies to multi-item selections (default: true)"),
          ),
          LdCard(
            header: Text("appBarOverflowMode"),
            child: LdText.p("LdAppBarActionOverflowMode controlling whether this action can move into the app bar overflow menu"),
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
        LdText.hs("11. Custom Button Actions (LdMonkeyBareChildAction)"),
        LdText.p(
            "For actions that render a fully custom widget rather than a submit button, "
            "use LdMonkeyBareChildAction. builder receives ctx and a trigger function — "
            "wire onPressed: trigger so press-time snapshots stay fresh."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeyBareChildAction<Task, int>(
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.masterAppBar,
      minSelectionCount: 0,
    ),
  },
  shortcutActivators: { SingleActivator(LogicalKeyboardKey.keyN, meta: true) },
  builder: (ctx, trigger) => LdAppBarAction(
    leading: const Icon(LucideIcons.plus),
    onPressed: trigger,
    child: const Text('New'),
  ),
  onTrigger: (ctx) async {
    // Action logic — also invoked for keyboard shortcut
  },
)''',
        ),
        LdText.hs("12. Complete Actions Example"),
        LdText.p("A complete set of actions for a task management system:"),
        CodeBlock(
          language: "dart",
          code: '''actions: [
  reactiveCreateAction<Task, int>(routeConfig: taskRouteConfig),
  LdMonkeySubmitAction<Task, int, void>(
    id: 'mark-done',
    tooltip: (_) => 'Done',
    visibility: {
      LdMonkeyActionVisibility(
        location: LdMonkeyActionLocation.detailAppBar,
        minSelectionCount: 1,
      ),
    },
    child: Text("Done"),
    icon: Icon(LucideIcons.check),
    submitConfig: (_) => const LdMonkeySubmitConfig(loadingText: "Marking as done"),
    onSubmit: (ctx) async { /* mark done logic */ },
  ),
  deleteAction<Task, int>(),
  toggleSelectionControls<Task, int>(),
  showFilterContextMenu<Task, int>(),
  refreshAction<Task, int>(),
],''',
        ),
      ]),
    );
  }
}
