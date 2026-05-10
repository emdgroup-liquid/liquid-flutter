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
        LdText.h("LdMonkey Pattern Configuration"),
        LdText.p(
            "The monkey pattern is configured using the buildMonkeyRoutes function and LdMonkeyShell widget. This defines how your master-detail interface behaves, including routing, selection, actions, and layout."),
        ComponentsAccordion(components: {"LdMonkeyShell", "buildMonkeyRoutes"}),
        LdText.hs("1. Basic Configuration"),
        LdText.p(
            "Start by creating master and detail page widgets, then use buildMonkeyRoutes to integrate them with GoRouter."),
        CodeBlock(
          language: "dart",
          code: '''// Create your master page widget
class TaskMasterPage extends StatelessWidget {
  const TaskMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<Task, int>(
      appBar: LdMonkeyAppBar<Task, int>(
        location: LdMonkeyActionLocation.masterAppBar,
        title: Text("Tasks"),
      ),
      buildItem: (context, item) => LdListItem(
        title: Text(item.value!.task),
        subtitle: Text("Due: \${item.value!.due}"),
      ),
    );
  }
}

// Create your detail page widget
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<Task, int>.scrollable(
      primaryAppBar: LdMonkeyAppBar<Task, int>(
        location: LdMonkeyActionLocation.detailAppBar,
        title: Text("Task"),
      ),
      buildDetail: (context, item) => TaskDetail(task: item),
    );
  }
}''',
        ),
        LdText.hs("2. Selection Configuration"),
        LdText.p(
            "Selection is handled automatically by LdMonkeyShell. You can access and modify selection state using LdMonkeyShellState."),
        CodeBlock(
          language: "dart",
          code: '''// In your shell widget or actions
final shellState = LdMonkeyShellState.of<Task, int>(context);

// Get current selection
final selectedItems = shellState.selectedItems;

// Set selection
shellState.setSelectedItems({taskId});

// Parse selected items from URL (used in buildMonkeyRoutes)
parseSelected: (selected) {
  return selected.split(',').map(int.parse).toSet();
},''',
        ),
        LdText.hs("3. Layout Configuration"),
        LdText.p("Control how your monkey pattern responds to different screen sizes and layouts."),
        CodeBlock(
          language: "dart",
          code: '''final taskRouteConfig = LdMonkeyRouteConfig.identifiableInt<Task>(itemName: "task");

...buildMonkeyRoutes<Task, int>(
  masterPath: "/task-demo",
  routeConfig: taskRouteConfig,
  masterPage: TaskMasterPage(),
  detailPage: TaskDetailPage(),
  repositoryBuilder: (context) => taskRepository(context),
  filters: taskFilters,
  sortOptions: taskSortOptions,
  actions: taskActions,
  detailInDialog: false,
  shellBuilder: (context, state, child) => LdMonkeyShell<Task, int>(
    layoutMode: LdMonkeyLayoutMode.auto,
    masterPage: TaskMasterPage(),
    reflowBreakpoint: 600,
    detailPanelFlex: 2,
    actions: [],
    child: child,
  ),
),''',
        ),
        LdText.hs("4. Actions Configuration"),
        LdText.p(
            "Define actions that users can perform on items. Actions are passed to LdMonkeyShell. See the Actions documentation for detailed examples."),
        CodeBlock(
          language: "dart",
          code: '''LdMonkeyShell<Task, int>(
  // ... other configuration
  actions: [
    LdMonkeySubmitAction(
      visibility: {
        LdMonkeyActionVisibility(
          location: LdMonkeyActionLocation.masterAppBar,
        ),
      },
      child: Text("New Task"),
      icon: Icon(LucideIcons.plus),
      config: (context) => LdSubmitConfig(
        loadingText: "Creating new task",
        action: (_) async {
          // Your action implementation
        },
      ),
    ),
    // See Actions documentation for more examples
  ],
),''',
        ),
        LdText.hs("5. Master Page Configuration"),
        LdText.p(
            "The master page displays the list of items. Use LdMonkeyMasterPage to integrate with the monkey pattern."),
        CodeBlock(
          language: "dart",
          code: '''class TaskMasterPage extends StatelessWidget {
  const TaskMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<Task, int>(
      appBar: LdMonkeyAppBar<Task, int>(
        location: LdMonkeyActionLocation.masterAppBar,
        title: Text("Tasks"),
      ),
      buildItem: (context, item) {
        return LdListItem(
          title: Text(item.value!.task),
          subtitle: Text("Due: \${item.value!.due}"),
          leading: LdAvatar(
            child: Icon(
              item.value!.done ? LucideIcons.squareCheck : LucideIcons.square,
            ),
          ),
        );
      },
    );
  }
}''',
        ),
        LdText.hs("6. Detail Page Configuration"),
        LdText.p(
            "The detail page displays details for selected items. Use LdMonkeyDetailPage to integrate with the monkey pattern."),
        CodeBlock(
          language: "dart",
          code: '''class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<Task, int>.scrollable(
      primaryAppBar: LdMonkeyAppBar<Task, int>(
        location: LdMonkeyActionLocation.detailAppBar,
        title: Text("Task"),
      ),
      buildDetail: (context, item) {
        return TaskDetail(task: item);
      },
    );
  }
}''',
        ),
        LdText.hs("7. Integration with GoRouter"),
        LdText.p("Integrate your monkey pattern with GoRouter by calling buildMonkeyRoutes."),
        CodeBlock(
          language: "dart",
          code: '''final router = GoRouter(
  routes: [
    // Your other routes...
    
    // Add monkey pattern routes using buildMonkeyRoutes
    ...buildMonkeyRoutes<Task, int>(
      masterPath: "/task-demo",
      routeConfig: LdMonkeyRouteConfig.identifiableInt<Task>(itemName: "task"),
      masterPage: TaskMasterPage(),
      detailPage: TaskDetailPage(),
      repositoryBuilder: (context) => taskRepository(context),
      filters: taskFilters,
      sortOptions: taskSortOptions,
      actions: taskActions,
    ),
  ],
);''',
        ),
        LdText.hs("8. Complete Example"),
        LdText.p("Here's a complete example of a task management monkey pattern:"),
        CodeBlock(
          language: "dart",
          code: '''// Master page
class TaskMasterPage extends StatelessWidget {
  const TaskMasterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyMasterPage<Task, int>(
      appBar: LdMonkeyAppBar<Task, int>(
        location: LdMonkeyActionLocation.masterAppBar,
        title: Text("Tasks"),
      ),
      buildItem: (context, item) => LdListItem(
        title: Text(item.value!.task),
        subtitle: Text("Due: \${item.value!.due}"),
      ),
    );
  }
}

// Detail page
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LdMonkeyDetailPage<Task, int>.scrollable(
      primaryAppBar: LdMonkeyAppBar<Task, int>(
        location: LdMonkeyActionLocation.detailAppBar,
        title: Text("Task"),
      ),
      buildDetail: (context, item) => TaskDetail(task: item),
    );
  }
}

// Shell wrapper (optional, for custom actions)
class TaskShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;
  
  const TaskShell({
    super.key,
    required this.child,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return LdMonkeyShell<Task, int>(
      layoutMode: LdMonkeyLayoutMode.auto,
      masterPage: TaskMasterPage(),
      actions: [
        // Your actions here - see Actions documentation for examples
      ],
      child: child,
    );
  }
}

// Router configuration
final router = GoRouter(
  routes: [
    ...buildMonkeyRoutes<Task, int>(
      masterPath: "/task-demo",
      routeConfig: LdMonkeyRouteConfig.identifiableInt<Task>(itemName: "task"),
      masterPage: TaskMasterPage(),
      detailPage: TaskDetailPage(),
      repositoryBuilder: (context) => taskRepository(context),
      filters: taskFilters,
      sortOptions: taskSortOptions,
      actions: taskActions,
      shellBuilder: (context, state, child) => TaskShell(
        state: state,
        child: child,
      ),
    ),
  ],
);''',
        ),
        LdText.hs("9. Related Documentation"),
        LdText.p("For more detailed information on specific aspects of the monkey pattern:"),
        LdAutoSpace(children: [
          LdCard(
            header: Text("Repository"),
            child: LdText.p("Learn how to set up the data repository with sorting and filtering"),
          ),
          LdCard(
            header: Text("Actions"),
            child: LdText.p("Detailed guide to creating and configuring actions"),
          ),
          LdCard(
            header: Text("Sorting & Filtering"),
            child: LdText.p("Advanced sorting and filtering configuration"),
          ),
        ]),
      ]),
    );
  }
}
