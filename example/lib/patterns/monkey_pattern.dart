import 'package:flutter/material.dart';
import 'package:liquid/code_block.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/layout/components_accordion.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class MonkeyPatternDemo extends StatelessWidget {
  const MonkeyPatternDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/patterns/monkey_pattern.dart",
      category: "Patterns",
      title: "LdMonkey - Pattern Configuration",
      demo: LdAutoSpace(children: [
        LdTextH("LdMonkey Pattern Configuration"),
        LdTextP(
            "The LdMonkey class is the main configuration class for the monkey pattern. It defines how your master-detail interface behaves, including routing, selection, actions, and layout."),
        ComponentsAccordion(components: {"LdMonkey"}),
        LdTextHs("1. Basic Configuration"),
        LdTextP(
            "Start by creating an LdMonkey instance with the required parameters. This defines the core behavior of your pattern."),
        CodeBlock(
          language: "dart",
          code: '''final taskDemo = LdMonkey<Task, int, bool>(
  // Required: Base path for your monkey pattern
  path: "/task-demo",
  
  // Required: How to parse ID from URL string
  parseId: (id) => int.parse(id),
  
  // Required: How to build detail path from selected items
  detailPath: (items) => "/task-demo/\${items.join(",")}",
  
  // Required: Repository builder function
  buildRepository: (context) => taskRepository,
  
  // Required: Detail widget builder
  buildDetail: (context, item) => TaskDetail(task: item),
  
  // Required: List builder function
  listBuilder: (route, initialSelection, onSelectionChange) {
    return LdSelectableList<Task, int, bool>(
      // ... list configuration
    );
  },
);''',
        ),
        LdTextHs("2. Selection Configuration"),
        LdTextP(
            "Configure how selection works in your monkey pattern. This includes multi-selection, selection controls, and selection persistence."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkey<Task, int, bool>(
  // Enable/disable multiple selection
  allowMultipleSelection: true,
  
  // Show multi-select items in the detail view
  showMultiSelectItems: true,
  
  // Optional: Custom selection parser for URL state
  parseSelected: (selected) {
    return selected.split(',').map(int.parse).toSet();
  },
  
  // ... other configuration
);''',
        ),
        LdTextHs("3. Layout Configuration"),
        LdTextP(
            "Control how your monkey pattern responds to different screen sizes and layouts."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkey<Task, int, bool>(
  // Breakpoint for responsive reflow (default: 600)
  reflowBreakpoint: 600,
  
  // Layout mode for detail view
  layoutMode: MonkeyLayoutMode.auto, // auto, sideBySide, neverSideBySide
  
  // Flex ratio for detail view in side-by-side layout (default: 2)
  detailFlex: 2,
  
  // How detail view is presented
  presentationMode: MonkeyDetailVariant.page, // page, dialog
  
  // ... other configuration
);''',
        ),
        LdTextHs("4. Actions Configuration"),
        LdTextP(
            "Define actions that users can perform on items. Actions can appear in different locations and have various visibility conditions. See the Actions documentation for detailed examples."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkey<Task, int, bool>(
  actions: [
    // Your custom actions here
    // See Actions documentation for detailed examples
  ],
  
  // ... other configuration
);''',
        ),
        LdTextHs("5. List Builder Configuration"),
        LdTextP(
            "The listBuilder function is where you define how your selectable list behaves. This includes the list widget, item builder, and selection handling."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkey<Task, int, bool>(
  listBuilder: (route, initialSelection, onSelectionChange) {
    return LdSelectableList<Task, int, bool>(
      // Show selection controls (checkboxes, etc.)
      showSelectionControls: route.state.showSelectionControls,
      
      // List widget builder
      listBuilder: (context, scrollController, itemBuilder) {
        return LdList(
          paginator: route.repository,
          itemBuilder: itemBuilder,
          scrollController: scrollController,
          assumedItemHeight: 50,
        );
      },
      
      // Paginator for data
      paginator: route.repository,
      
      // Initial selection state
      initialSelectedItems: route.state.selectedItems,
      
      // Enable multi-selection
      multiSelect: true,
      
      // Selection change callback
      onSelectionChange: (selected) => onSelectionChange(selected),
      
      // Individual item builder
      itemBuilder: (context, item, index, config) => LdMonkeySingleShortcuts(
        item: item.value!.id,
        actions: route.actions,
        child: LdMonkeyContextMenu<Task, int, bool>(
          item: item,
          child: LdListItemAnimation(
            state: item.state,
            child: LdListItem.fromConfig(
              config.copyWith(
                title: Text(item.value!.task),
                subtitle: Text("Due: \${item.value!.due}"),
                trailingForward: LdMonkeyContext.of<Task, int, bool>(context).isSideBySide,
              ),
            ),
          ),
        ),
      ),
    );
  },
  
  // ... other configuration
);''',
        ),
        LdTextHs("6. Shell Wrapper"),
        LdTextP(
            "Optionally wrap your monkey pattern with a custom shell widget for additional functionality like navigation, headers, or sidebars."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkey<Task, int, bool>(
  // Optional shell wrapper
  wrapShell: (context, child) {
    return LdDrawer(
      child: child,
    );
  },
  
  // ... other configuration
);''',
        ),
        LdTextHs("7. Integration with GoRouter"),
        LdTextP(
            "Finally, integrate your monkey pattern with GoRouter by calling the buildRoute() method."),
        CodeBlock(
          language: "dart",
          code: '''final router = GoRouter(
  routes: [
    // Your other routes...
    
    // Add monkey pattern routes
    ...taskDemo.buildRoute(),
    
    // Or mount at a specific path
    GoRoute(
      path: "/tasks",
      routes: taskDemo.buildRoute(),
    ),
  ],
);''',
        ),
        LdTextHs("8. Complete Example"),
        LdTextP(
            "Here's a complete example of a task management monkey pattern:"),
        CodeBlock(
          language: "dart",
          code: '''final taskDemo = LdMonkey<Task, int, bool>(
  path: "/task-demo",
  allowMultipleSelection: true,
  presentationMode: MonkeyDetailVariant.page,
  layoutMode: MonkeyLayoutMode.auto,
  showMultiSelectItems: true,
  parseId: (id) => int.parse(id),
  detailPath: (items) => "/task-demo/\${items.join(",")}",
  buildRepository: (context) => taskRepository,
  buildDetail: (context, item) => TaskDetail(task: item),
  listBuilder: (route, initialSelection, onSelectionChange) {
    return LdSelectableList<Task, int, bool>(
      showSelectionControls: route.state.showSelectionControls,
      listBuilder: (context, scrollController, itemBuilder) {
        return LdList(
          paginator: route.repository,
          itemBuilder: itemBuilder,
          scrollController: scrollController,
          assumedItemHeight: 50,
        );
      },
      paginator: route.repository,
      initialSelectedItems: route.state.selectedItems,
      multiSelect: true,
      onSelectionChange: (selected) => onSelectionChange(selected),
      itemBuilder: (context, item, index, config) => LdMonkeySingleShortcuts(
        item: item.value!.id,
        actions: route.actions,
        child: LdMonkeyContextMenu<Task, int, bool>(
          item: item,
          child: LdListItemAnimation(
            state: item.state,
            child: LdListItem.fromConfig(
              config.copyWith(
                title: Text(item.value!.task),
                subtitle: Text("Due: \${item.value!.due}"),
                trailingForward: LdMonkeyContext.of<Task, int, bool>(context).isSideBySide,
              ),
            ),
          ),
        ),
      ),
    );
  },
  actions: [
    // Your actions here - see Actions documentation for examples
  ],
);''',
        ),
        LdTextHs("9. Related Documentation"),
        LdTextP(
            "For more detailed information on specific aspects of the monkey pattern:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("Repository"),
            child: LdTextP(
                "Learn how to set up the data repository with sorting and filtering"),
          ),
          LdCard(
            header: Text("Actions"),
            child:
                LdTextP("Detailed guide to creating and configuring actions"),
          ),
          LdCard(
            header: Text("Sorting & Filtering"),
            child: LdTextP("Advanced sorting and filtering configuration"),
          ),
        ]),
      ]),
    );
  }
}
