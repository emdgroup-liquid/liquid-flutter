---
name: liquid_flutter-monkey
description: Use when implementing master-detail interfaces with Liquid Flutter — covers monkey route setup, LdMonkeyShell, LdMonkeyMasterPage, LdMonkeyDetailPage, LdMonkeyAppBar, actions, filters, sort options, selection state, and nested/stacked master-detail trees.
---

# LdMonkey — Master-Detail Interfaces

The monkey system provides a complete master-detail interface framework with URL-driven state, responsive layouts (side-by-side or stacked), selection controls, filtering, sorting, and action injection.

## Core Concepts

### Data Model: `Identifiable` mixin

All items in a monkey interface must use the `Identifiable<IdType>` mixin which requires an `id` getter:

```dart
class Task with Identifiable<int> {
  @override
  final int id;
  final String title;
  final bool completed;

  Task(this.id, this.title, this.completed);
}
```

### Repository: `LdRepository`

The repository extends `LdPaginator` and manages fetching, creating, updating, and deleting items. It's provided to the widget tree via `LdRepositoryProvider`.

**Required parameters:** `fetchListWithParameters` and `getById`. Everything else (`createItem`, `updateItem`, `deleteItem`, `deleteBatch`, `updateBatch`) is optional.

```dart
LdRepository<Task, int>(
  // Required:
  fetchListWithParameters: (params) async {
    final page = await api.getTasks(offset: params.offset, limit: params.pageSize);
    return LdListPage(newItems: page.items, hasMore: page.hasMore, total: page.total);
  },
  getById: (id) async => await api.getTask(id),
  // Optional:
  createItem: (item) async => await api.createTask(item!),
  updateItem: (id, item) async => await api.updateTask(id, item),
  deleteItem: (id) async => await api.deleteTask(id),
)
```

### `LdRepository.fromList` (in-memory / local data)

For demos, tests, or simple use cases where all data is available locally:

```dart
LdRepository.fromList<Task, int>(
  list: [Task(1, 'Write tests', false), Task(2, 'Ship it', true)],
)
```

This creates a paginating repository backed by the in-memory list with no additional setup needed.

### Route Config: `LdMonkeyRouteConfig`

Defines URL parameter names and ID serialization. Use the factory constructors for common types:

```dart
// For items with String IDs:
LdMonkeyRouteConfig.identifiableString<Task>(itemName: 'task')

// For items with int IDs:
LdMonkeyRouteConfig.identifiableInt<Task>(itemName: 'task')
```

The `itemName` must be unique across a monkey tree and is used for path params (`viewing_<itemName>`), query keys (`selection_<itemName>`, `select_<itemName>`), and `GoRoute.name`s (`<itemName>-master`, `<itemName>-detail`).

## Getting Started: A Basic Monkey Route

### 1. Build the routes

```dart
final routeConfig = LdMonkeyRouteConfig.identifiableInt<Task>(itemName: 'task');

final routes = buildMonkeyRoutes<Task, int>(
  masterPath: '/tasks',
  routeConfig: routeConfig,
  masterPage: LdMonkeyMasterPage<Task, int>(
    buildItem: (context, item) => LdListItem(
      title: Text(item.value?.title ?? ''),
    ),
  ),
  detailPage: LdMonkeyDetailPage(
    body: TaskDetail(),
  ),
  repositoryBuilder: (context, state) => LdRepository<Task, int>(...),
  filters: const [],
  sortOptions: const [],
  actions: const [],
);
```

Minimal example — no filters, sort, or actions. `buildMonkeyRoutes` returns a `List<RouteBase>` — spread it into your `GoRouter` routes.

### 2. Add the routes to GoRouter

```dart
final router = GoRouter(
  routes: [
    ...buildMonkeyRoutes<Task, int>(...),  // spread the list
    // other routes...
  ],
  initialLocation: '/tasks',
);
```

Or assign to a variable first and pass it directly when it is the only routes list:

```dart
final routes = buildMonkeyRoutes<Task, int>(...);
final router = GoRouter(routes: routes, initialLocation: '/tasks');
```

### 3. The route tree is created by the framework

Navigating to `/tasks` shows the master list. Navigating to `/tasks/1` opens the detail for item with id 1. On wide screens (`>600px`) the layout becomes side-by-side automatically.

## Route Building API

### `buildMonkeyRoutes`

Creates a single-level master-detail route pair wrapped in `ShellRoute`:

```dart
buildMonkeyRoutes<T, IdType>({
  required LdMonkeyRouteConfig<T, IdType> routeConfig,
  required String masterPath,
  required Widget detailPage,            // LdMonkeyDetailPage or custom
  required Widget masterPage,            // LdMonkeyMasterPage or custom
  required LdRepository<T, IdType> Function(BuildContext, GoRouterState) repositoryBuilder,
  required List<LdFilterOption<T, IdType>> filters,
  required List<LdSortOption<T, IdType>> sortOptions,
  required List<LdMonkeyAction<T, IdType>> actions,
  Widget Function(BuildContext, GoRouterState, Widget)? shellBuilder,
  List<RouteBase>? additionalDetailRoutes,
  List<RouteBase>? additionalMasterRoutes,
  bool detailInDialog = false,
  LdMonkeyLayoutMode layoutMode = LdMonkeyLayoutMode.auto,
  double? reflowBreakpoint,
  double? detailPanelFlex,
  bool? allowMultipleSelection,
  bool? immediateViewSelection,
})
```

### `buildMonkeyRouteTree` and `MonkeyRouteNode`

For nested/stacked master-detail trees (where the parent's detail page contains the child level's master list), use `buildMonkeyRouteTree`:

```dart
final routes = buildMonkeyRouteTree<Task, int>(
  masterPath: '/projects',
  root: MonkeyRouteNode<Task, int>(
    routeConfig: parentRouteConfig,
    masterPage: LdMonkeyMasterPage<Task, int>(...),
    detailPage: LdMonkeyMasterPage<File, String>(...),  // child master
    repositoryBuilder: (context, state) => parentRepo,
    filters: const [],
    sortOptions: const [],
    actions: const [],
    child: MonkeyRouteNode<File, String>(
      detailPathPrefix: 'files',
      routeConfig: childRouteConfig,
      masterPage: const SizedBox(),
      detailPage: const Text('FileDetail'),
      repositoryBuilder: (context, state) => childRepo,
      ...
    ),
  ),
);
```

See the **Nested Master-Detail** section below for more detail.

## LdMonkeyMasterPage

Renders the master (list) side of the monkey. It expects an `LdRepository<T, IdType>` and `LdMonkeyActions<T, IdType>` in the context (provided by the `ShellRoute` scope). `LdMonkeyActions` is a typedef alias for `List<LdMonkeyAction<T, IdType>>`.

### With `buildItem` (default list)

```dart
LdMonkeyMasterPage<Task, int>(
  buildItem: (context, item) => LdListItem(
    leading: LdAvatar(title: item.value?.title ?? ''),
    title: Text(item.value?.title ?? ''),
    subtitle: Text(item.value?.completed == true ? 'Done' : 'Pending'),
  ),
)
```

### With `buildList` (custom list widget)

```dart
LdMonkeyMasterPage<Task, int>(
  buildList: (context, repository) => LdSelectableList<Task, int>(
    paginator: repository,
    multiSelect: true,
    itemBuilder: (context, item, index) => MyCustomListItem(item: item),
  ),
)
```

### With custom app bars

```dart
LdMonkeyMasterPage<Task, int>(
  appBar: LdMonkeyAppBar<Task, int>(
    location: LdMonkeyActionLocation.masterAppBar,
    title: Text('Tasks'),
    additionalActions: [MyCustomAction()],
  ),
  secondaryAppBar: LdMonkeyAppBar<Task, int>(
    location: LdMonkeyActionLocation.masterSecondary,
  ),
)
```

### `allowMultipleSelection`

`LdMonkeyMasterPage` has its own `allowMultipleSelection` parameter (default `true`) that controls whether the default list allows multi-select. **Known bug (#112):** setting `allowMultipleSelection: false` at the route level (`buildMonkeyRoutes` / `MonkeyRouteNode`) currently has no effect on `LdMonkeyMasterPage` — the two parameters are independent. Until the bug is fixed, set it on `LdMonkeyMasterPage` directly:

```dart
LdMonkeyMasterPage<Task, int>(
  allowMultipleSelection: false,  // set here, not only on buildMonkeyRoutes
  buildItem: (context, item) => LdListItem(title: Text(item.value?.title ?? '')),
)
```

### Key behavior

- `LdMonkeyAppBar` with `location: LdMonkeyActionLocation.masterAppBar` is the primary app bar (top).
- `LdMonkeyAppBar` with `location: LdMonkeyActionLocation.masterSecondary` is the secondary bar (bottom).
- Shortcut bindings (`LdMonkeyMultiShortcuts` / `LdMonkeySingleShortcuts`) and context menus (`LdMonkeyContextMenu`) are automatically wired when using the default `buildItem` path.

## LdMonkeyDetailPage

### Default

```dart
LdMonkeyDetailPage(
  body: MyDetailWidget(),
)
```

### Scrollable (renders all viewing items as a scrollable list)

```dart
LdMonkeyDetailPage.scrollable(
  buildDetail: (context, item) => TaskDetailCard(item: item),
)
```

### Stacked (renders viewing items as a stack with animated transforms)

```dart
LdMonkeyDetailPage.stacked(
  buildDetail: (context, item) => TaskDetailCard(item: item),
)
```

## LdMonkeyAppBar

The LdMonkeyAppBar automatically injects actions based on the `LdMonkeyActionLocation`. It wraps content using the new wrapper-based composition model (child parameter).

```dart
LdMonkeyAppBar<Task, int>(
  location: LdMonkeyActionLocation.masterAppBar,
  title: Text('Tasks'),
  child: /* body wrapped by this app bar */,
)
```

**Note:** When an `LdMonkeyAppBar` has no title, no actions, and no `additionalActions`, it renders as `child ?? SizedBox.shrink()` — the bar surface is invisible. This is by design (avoids an empty bar), but can be surprising if you expect an app bar to always be visible.

### Action locations

- `LdMonkeyActionLocation.masterAppBar` — Primary bar on the master page
- `LdMonkeyActionLocation.masterSecondary` — Secondary bar on the master page
- `LdMonkeyActionLocation.detailAppBar` — Primary bar on the detail page
- `LdMonkeyActionLocation.detailSecondary` — Secondary bar on the detail page
- `LdMonkeyActionLocation.context` — Context menu (right-click / long-press)

## Actions

Actions are the primary way to add buttons, menus, and submit operations to the monkey interface. All actions are subclasses of `LdMonkeyAction<T, IdType>`.

### Action Visibility: `LdMonkeyActionVisibility`

Controls where and when an action appears:

```dart
LdMonkeyActionVisibility(
  location: LdMonkeyActionLocation.masterAppBar,  // Where to show
  minSelectionCount: 1,     // Need at least 1 item selected
  maxSelectionCount: null,  // No upper limit
  layoutModes: {            // Which layout modes (default: all 3)
    LdMonkeyEffectiveLayoutMode.master,
    LdMonkeyEffectiveLayoutMode.detail,
    LdMonkeyEffectiveLayoutMode.sideBySide,
  },
  visibleWhenShowingSelectionControls: true,  // null = always, true/false = specific
  isVisible: (context) => true,  // Custom predicate
)
```

### `LdMonkeyBareChildAction`

For custom actions that render any widget:

```dart
LdMonkeyBareChildAction<Task, int>(
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.masterAppBar,
      minSelectionCount: 0,
    ),
  },
  onShortcutTrigger: (context) { /* handle keyboard shortcut */ },
  shortcutActivators: { SingleActivator(LogicalKeyboardKey.keyN, meta: true) },
  builder: (context) => LdAppBarAction(
    leading: const Icon(LucideIcons.plus),
    onPressed: () { /* create new task */ },
    child: const Text('New'),
  ),
)
```

### `LdMonkeySubmitAction`

For async operations with loading state, error handling, and notifications:

```dart
LdMonkeySubmitAction<Task, int, void>(
  tooltip: (context) => 'Delete selected tasks',
  color: LdColor.error,
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.masterAppBar,
      minSelectionCount: 1,
    ),
  },
  config: (context) => LdSubmitConfig(
    loadingText: 'Deleting...',
    action: (_) async {
      final selection = LdMonkeySelection.of<Task, int>(context);
      final repository = LdRepository.of<Task, int>(context);
      await repository.deleteBatch(selection.selection);
    },
  ),
  child: const Text('Delete'),
  icon: const Icon(LucideIcons.trash),
)
```

### Built-in Action Factories

The monkey system provides several pre-built actions:

| Factory Function | Location | Behavior |
|---|---|---|
| `toggleSelectionControls<T, IdType>()` | `masterAppBar` | Toggles selection mode (checkbox UI) |
| `showSelection<T, IdType>()` | `masterSecondary` | Shows "Show Selection" button when selection differs from viewing |
| `showFilterContextMenu<T, IdType>()` | `masterAppBar` | Dropdown filter menu |
| `showFilterModal<T, IdType>()` | `masterAppBar` | Modal filter dialog |
| `refreshAction<T, IdType>()` | `masterAppBar` | Desktop-only refresh button |

Include them in the `actions` list:

```dart
actions: [
  toggleSelectionControls<Task, int>(),
  showSelection<Task, int>(),
  showFilterContextMenu<Task, int>(),
  refreshAction<Task, int>(),
  // Custom actions...
]
```

### Context Menu Actions

Actions with `LdMonkeyActionVisibility(location: LdMonkeyActionLocation.context, ...)` automatically appear in the right-click or long-press context menu on list items.

### Keyboard Shortcuts

Set `shortcutActivators` on any action and the monkey system will automatically wire `CallbackShortcuts` (via `LdMonkeyMultiShortcuts`/`LdMonkeySingleShortcuts`):

```dart
LdMonkeyBareChildAction<Task, int>(
  shortcutActivators: { SingleActivator(LogicalKeyboardKey.keyN, meta: true) },
  ...
)
```

The `monkeyShortcuts` constant provides built-in keyboard shortcuts:
- `Cmd+F` — Search intent (when `LdFilterSearch` is configured)
- `Cmd+R` — Refresh intent
- `Cmd+A` — Select all intent

## Filtering

### Filter Types

- **`LdFilterSearch<T, IdType, Suggestion>`** — Search/text filter, automatically adds a search bar to the master app bar
- **`LdFilterBool<T, IdType>`** — Boolean toggle filter
- **`LdFilterOneOf<T, IdType>`** — Select one from a set of options
- **`LdFilterAnyOf<T, IdType>`** — Select any number from a set of options (checkboxes)
- **`LdFilterRange<T, IdType>`** — Range filter (min/max)

### Adding Filters

```dart
final filters = <LdFilterOption<Task, int>>[
  LdFilterSearch<Task, int, String>(
    name: 'search',
    label: (context) => 'Search tasks',
    icon: (context) => const Icon(LucideIcons.search),
  ),
  LdFilterBool<Task, int>(
    name: 'completed',
    label: (context) => 'Completed only',
    icon: (context) => const Icon(LucideIcons.checkCircle),
  ),
  LdFilterOneOf<Task, int>(
    name: 'priority',
    label: (context) => 'Priority',
    icon: (context) => const Icon(LucideIcons.flag),
    options: ['Low', 'Medium', 'High'],
    buildOption: (option) => Text(option),
  ),
];
```

Pass filters to `buildMonkeyRoutes` or `MonkeyRouteNode`. The monkey will automatically:
- Sync filter state with URL query parameters
- Show a search bar in the master app bar when an `LdFilterSearch` is configured
- Show filter indicator badges on filter buttons

### Accessing Active Filters

```dart
final filterState = LdMonkeySortAndFilterState.of<Task, int>(context);
final activeFilters = filterState.activeFilters;
final searchFilter = filterState.filters.whereType<LdFilterSearch>().firstOrNull;
```

## Sorting

```dart
final sortOptions = <LdSortOption<Task, int>>[
  LdSortOption<Task, int>(
    name: 'name',
    label: (context) => 'Name',
    icon: (context) => const Icon(LucideIcons.arrowUpAZ),
  ),
  LdSortOption<Task, int>(
    name: 'priority',
    label: (context) => 'Priority',
    icon: (context) => const Icon(LucideIcons.arrowUpAZ),
  ),
];
```

Sort options are synced with URL query parameters. Access active sort options via:

```dart
final sortAndFilter = LdMonkeySortAndFilterState.of<Task, int>(context);
final activeSorts = sortAndFilter.activeSortOptions;
```

**Note:** Filters and sort options are not stored in the repository — they live in `LdMonkeySortAndFilterState` in the widget tree. Use `LdMonkeyRepositoryFilterAdapter` (automatically included in the monkey scope) to react to filter/sort changes and refresh the repository.

## Selection State

The `LdMonkeySelection<T, IdType>` class tracks three things:
- **`selection`** — Items the user has checked/selected (checkbox mode)
- **`viewing`** — Items currently shown in the detail view
- **`showSelectionControls`** — Whether selection checkboxes are visible

### Reading Selection

```dart
final selection = LdMonkeySelection.of<Task, int>(context, listen: true);
final selectedIds = selection.selection;
final viewingIds = selection.viewing;
```

### Updating Selection

```dart
LdMonkeySelection.updateSelection<Task, int>(context, {1, 2, 3});
LdMonkeySelection.updateViewing<Task, int>(context, {1});
LdMonkeySelection.updateShowSelectionControls<Task, int>(context, true);
```

### Adaptive Selection

The `adaptive` method returns the relevant set based on action location:
- `masterAppBar` / `masterSecondary` / `context` → `selection`
- `detailAppBar` / `detailSecondary` → `viewing`

### `immediateViewSelection`

Controls whether selecting an item immediately opens it in the detail view:
- `true` (default in side-by-side mode) — Clicking an item updates viewing and URL immediately
- `false` (default with selection controls) — Selection and viewing are decoupled; use "Show Selection" to view selected items

## Layout Modes

```dart
LdMonkeyLayoutMode.auto  // Side-by-side when width > breakpoint, stacked otherwise (default)
LdMonkeyLayoutMode.sideBySide  // Always side-by-side
LdMonkeyLayoutMode.neverSideBySide  // Always stacked
```

Control the breakpoint and panel flex:

```dart
buildMonkeyRoutes<Task, int>(
  layoutMode: LdMonkeyLayoutMode.auto,
  reflowBreakpoint: 800,  // Default: 600
  detailPanelFlex: 3,     // Default: 2 (detail is 2/3 of space)
  ...
)
```

## Nested (Stacked) Master-Detail

Use `MonkeyRouteNode` and `buildMonkeyRouteTree` for multi-level master-detail interfaces. The parent's detail page renders the child level's master list.

```dart
final routes = buildMonkeyRouteTree<Project, int>(
  masterPath: '/projects',
  root: MonkeyRouteNode<Project, int>(
    routeConfig: LdMonkeyRouteConfig.identifiableInt<Project>(itemName: 'project'),
    masterPage: LdMonkeyMasterPage<Project, int>(...),
    // Parent detail IS the child's master page:
    detailPage: LdMonkeyMasterPage<Task, int>(...),
    repositoryBuilder: (context, state) => projectRepo,
    filters: [...],
    sortOptions: [...],
    actions: [...],
    child: MonkeyRouteNode<Task, int>(
      detailPathPrefix: 'tasks',  // URL: /projects/:viewing_project/tasks/:viewing_task
      routeConfig: LdMonkeyRouteConfig.identifiableInt<Task>(itemName: 'task'),
      masterPage: const SizedBox(),
      detailPage: const Text('Task Detail'),
      repositoryBuilder: (context, state) => taskRepo,
      filters: [...],
      sortOptions: [...],
      actions: [...],
    ),
  ),
);
```

**Important:** Each `routeConfig.itemName` must be unique across the entire tree to avoid path param and query key collisions.

## Detail Modal

Show detail in a modal/dialog when not in side-by-side mode. Pass `detailInDialog: true` to `buildMonkeyRoutes` — the router will automatically open the detail page as an `LdModalRoute` when a narrow-screen user navigates to the detail route:

```dart
buildMonkeyRoutes<Task, int>(
  detailInDialog: true,
  ...
)
```

## Deleted Items Guard

`LdMonkeyDeletedItemsGuard` automatically removes deleted items from selection and viewing state. It is included automatically — it is nested inside `LdMonkeyRouterAdapter`, which is part of every monkey scope.

## LdMonkeyRouteScope

For custom GoRouter shapes, use `LdMonkeyRouteScope` directly to provide the monkey provider stack:

```dart
LdMonkeyRouteScope<Task, int>(
  routeState: routeState,
  routeConfig: routeConfig,
  actions: actions,
  filters: filters,
  sortOptions: sortOptions,
  repositoryBuilder: (context, state) => repository,
  masterPage: masterPage,
  child: child,
)
```

The provider stack is:
`LdMonkeyRouteConfig` → `LdMonkeyActions` → `LdRepositoryProvider` → `LdMonkeyRouterAdapter` (provides `LdMonkeySelection`, `LdMonkeySortAndFilterState`, `LdMonkeyRouterController`, `LdMonkeyRepositoryFilterAdapter`, `LdMonkeyDeletedItemsGuard`) → `LdMonkeyShell`.

## Best Practices

1. **Use `buildMonkeyRoutes` for single-level master-detail** — it handles all the ShellRoute/GoRoute wiring.
2. **Use `buildMonkeyRouteTree` and `MonkeyRouteNode` for nested master-detail** — the child's scope is automatically available at the parent's detail position.
3. **Always use `LdMonkeyRouteConfig.identifiableString` or `.identifiableInt`** — custom serialization only when IDs contain underscores or special characters.
4. **Keep `itemName` unique across the entire monkey tree** to avoid URL parameter collisions.
5. **Use the built-in action factories** (`toggleSelectionControls`, `showSelection`, `showFilterContextMenu`, `refreshAction`) before writing custom ones.
6. **Prefer `LdMonkeyBareChildAction` for simple buttons** and `LdMonkeySubmitAction` for async operations.
7. **Use `LdMonkeyActionVisibility` to control action placement** — set the `location`, `minSelectionCount`, and `layoutModes` to match your UX requirements.
8. **Add `LdFilterSearch` to enable search** — it automatically adds a search bar to the master app bar and syncs with URL query params.
9. **Use `LdMonkeyDetailPage.scrollable` for multiple viewing items** and `.stacked` for animated transitions.
10. **Set `detailPanelFlex` to control side-by-side proportions** — higher values give more space to the detail panel.