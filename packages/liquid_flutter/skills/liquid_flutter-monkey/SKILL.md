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

### Data Layer: `LdModel` and `LdCallbackModel`

The monkey data layer is built around `LdModel<T, IdType, TCreate, TUpdate>` (abstract base) and `LdCallbackModel<T, IdType>` (the callback-based implementation). These replace the old `LdRepository`. The in-tree controller is `LdListController<T, IdType>`.

Pass an `LdModel` via the `modelBuilder` parameter on `buildMonkeyRoutes` / `MonkeyRouteNode`. The monkey framework creates and attaches `LdListController` automatically.

#### `LdCallbackModel` (standard usage)

```dart
LdCallbackModel<Task, int>(
  // Required:
  fetchListWithParameters: (params) async {
    final page = await api.getTasks(offset: params.offset, limit: params.pageSize);
    return LdListPage(newItems: page.items, hasMore: page.hasMore, total: page.total);
  },
  getById: (context, id) async => await api.getTask(id),
  // Optional CRUD:
  createItem: (context, item) async => await api.createTask(item!),
  updateItem: (context, id, item) async => await api.updateTask(id, item),
  deleteItem: (context, id) async => await api.deleteTask(id),
  deleteBatchFn: (context, ids) async => await api.deleteTasks(ids),
  updateBatchFn: (context, items) async => await api.updateTasks(items),
)
```

#### `LdCallbackModel.fromList` (in-memory / local data)

```dart
LdCallbackModel.fromList<Task, int>(
  list: [Task(1, 'Write tests', false), Task(2, 'Ship it', true)],
)
```

Creates a greedy in-memory model. Optionally pass `filterFunction` and `sortFunction` for client-side filter/sort.

#### `LdCallbackModel.greedy`

For small or complete datasets that should fully load regardless of scroll:

```dart
LdCallbackModel.greedy<Task, int>(
  pageSize: 50,
  getById: (context, id) async => await api.getTask(id),
  fetchListWithParameters: (params) async {
    // Return pages; called repeatedly until hasMore == false on init.
    ...
  },
)
```

#### Subclassing `LdModel` (advanced)

Override `LdModel` when you need custom caching strategy, batching, or lifecycle hooks:

```dart
class TaskModel extends LdModel<Task, int, TaskCreate, TaskUpdate> {
  @override
  Future<LdListPage<Task>> fetchListWithParameters(FetchPageParameters<Task, int> params) async { ... }

  @override
  Future<Task> getById(BuildContext context, int id) async { ... }

  @override
  Future<Task> persistCreate(BuildContext context, TaskCreate payload) async { ... }

  @override
  Future<Task?> persistUpdate(BuildContext context, int id, TaskUpdate payload) async { ... }

  @override
  Future<void> persistDelete(BuildContext context, int id) async { ... }

  @override
  Future<void> persistDeleteBatch(BuildContext context, Set<int> ids) async { ... }

  @override
  Future<void> persistUpdateBatch(BuildContext context, Set<TaskUpdate> items) async { ... }
}
```

Call mutations via the model's public methods (which delegate to the mounted `LdListController`):

```dart
await model.create(context, payload);
await model.update(context, id, payload);
await model.delete(context: context, id: id);
```

#### `LdFetchReason`, `cacheKey`, and `LdListCache`

`fetchListWithParameters` receives a `reason`, per-model `cache`, and a deterministic `cacheKey` (active filters + sorts, excluding offset/pageSize/reason).

By default, `LdCallbackModel` auto-caches pages under `params.cacheKey` and auto-invalidates on `refresh` / `invalidate`. Opt out with `autoCache: false` or `autoInvalidateCache: false`.

| `LdFetchReason` | Typical use |
|-----------------|-------------|
| `initial` | First load |
| `pagination` | Scroll / load more |
| `filter` / `sort` | Filter or sort changed (paginator resets view) |
| `refresh` | User pull-to-refresh (clears cache when auto-invalidate is on) |
| `invalidate` | CRUD / external cache bust |

### Route Config: `LdMonkeyRouteConfig`

Defines URL parameter names and ID serialization. Use the factory constructors for common types:

```dart
// For items with String IDs:
LdMonkeyRouteConfig.identifiableString<Task>(itemName: 'task')

// For items with int IDs:
LdMonkeyRouteConfig.identifiableInt<Task>(itemName: 'task')
```

The `itemName` must be unique across a monkey tree. It is used for:
- Path params: `viewing_<itemName>`
- Query keys: `selection_<itemName>`, `select_<itemName>`
- Route names: `<itemName>-master`, `<itemName>-detail`, `<itemName>-create`

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
  modelBuilder: (context, state) => LdCallbackModel<Task, int>(...),
  filtersBuilder: (_) async => [],
  sortOptionsBuilder: (_) async => [],
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

### 3. The route tree is created by the framework

Navigating to `/tasks` shows the master list. Navigating to `/tasks/:viewing_task` opens the detail. On wide screens (`>600px`) the layout becomes side-by-side automatically.

## Route Building API

### `buildMonkeyRoutes`

Creates a single-level master-detail route pair wrapped in `ShellRoute`:

```dart
buildMonkeyRoutes<T, IdType>({
  required LdMonkeyRouteConfig<T, IdType> routeConfig,
  required String masterPath,
  required Widget detailPage,            // LdMonkeyDetailPage or custom
  required Widget masterPage,            // LdMonkeyMasterPage or custom
  required LdModel<T, IdType, Object?, Object?> Function(BuildContext, GoRouterState) modelBuilder,
  required LdMonkeyFiltersBuilder<T, IdType> filtersBuilder,    // async filter builder
  required LdMonkeySortOptionsBuilder<T, IdType> sortOptionsBuilder,  // async sort builder
  LdMonkeyRouteDefinitionsLoadingTextBuilder? routeDefinitionsLoadingText,
  required List<LdMonkeyAction<T, IdType>> actions,
  Widget Function(BuildContext, GoRouterState, Widget)? shellBuilder,
  List<RouteBase>? additionalDetailRoutes,
  List<RouteBase>? additionalMasterRoutes,
  bool detailInDialog = false,
  Widget? createPage,                    // optional create route (served at masterPath/new)
  LdMonkeyLayoutMode layoutMode = LdMonkeyLayoutMode.auto,
  double? reflowBreakpoint,
  double? detailPanelFlex,
  bool? allowMultipleSelection,
  bool? immediateViewSelection,
  LdMonkeyReorderHandler<T, IdType>? reorderHandler,  // drag-to-reorder handler
})
```

`filtersBuilder` and `sortOptionsBuilder` are async because filter/sort definitions may be fetched from the server. For static options, return a completed future:

```dart
filtersBuilder: (_) async => [LdFilterSearch(...)],
sortOptionsBuilder: (_) async => [LdSortOption(...)],
```

### `buildMonkeyRouteTree` and `MonkeyRouteNode`

For nested/stacked master-detail trees (where the parent's detail page contains the child level's master list), use `buildMonkeyRouteTree`:

```dart
final routes = buildMonkeyRouteTree<Task, int>(
  masterPath: '/projects',
  root: MonkeyRouteNode<Project, int>(
    routeConfig: parentRouteConfig,
    masterPage: LdMonkeyMasterPage<Project, int>(...),
    detailPage: LdMonkeyMasterPage<Task, int>(...),  // child master
    modelBuilder: (context, state) => parentModel,
    filtersBuilder: (_) async => [],
    sortOptionsBuilder: (_) async => [],
    actions: const [],
    child: MonkeyRouteNode<Task, int>(
      detailPathPrefix: 'tasks',
      routeConfig: childRouteConfig,
      masterPage: const SizedBox(),
      detailPage: const Text('TaskDetail'),
      modelBuilder: (context, state) => childModel,
      filtersBuilder: (_) async => [],
      sortOptionsBuilder: (_) async => [],
      actions: const [],
    ),
  ),
);
```

See the **Nested Master-Detail** section below for more detail.

## LdMonkeyMasterPage

Renders the master (list) side of the monkey. Expects an `LdListController<T, IdType>` and `LdMonkeyActions<T, IdType>` in the context (provided by the `ShellRoute` scope).

```dart
LdMonkeyMasterPage<T, IdType>({
  Widget Function(BuildContext, LdListController<T, IdType>)? buildList,
  Widget Function(BuildContext, LdPaginatorItem<T>)? buildItem,
  List<LdFilterChipConfig<T, IdType>>? filterBarConfig,   // renders LdFilterChipsBar
  LdAppBarConfig? primaryAppBarConfig,
  LdAppBarConfig? secondaryAppBarConfig,
  List<Widget> primaryAppBarAdditionalActions = const [],
  bool allowMultipleSelection = true,
})
```

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

`buildList` receives a `LdListController<T, IdType>` (not `LdRepository`). Bypasses default selection, reorder, and context-menu wiring.

```dart
LdMonkeyMasterPage<Task, int>(
  buildList: (context, controller) => LdSelectableList<Task, int>(
    paginator: controller,
    multiSelect: true,
    itemBuilder: (context, item, index) => MyCustomListItem(item: item),
  ),
)
```

### With app bar config

Title, leading, and bar customization go through `LdAppBarConfig`:

```dart
LdMonkeyMasterPage<Task, int>(
  primaryAppBarConfig: LdAppBarConfig(title: Text('Tasks')),
  primaryAppBarAdditionalActions: [MyCustomButton()],
  filterBarConfig: [LdFilterChipConfig(...)],  // renders chip bar below primary bar
  buildItem: (context, item) => LdListItem(title: Text(item.value?.title ?? '')),
)
```

### `filterBarConfig`

Pass a list of `LdFilterChipConfig<T, IdType>` to render an `LdFilterChipsBar` automatically between the primary and secondary app bars. This is the preferred way to show active filter chips.

### `allowMultipleSelection`

Controls whether the default list allows multi-select (default `true`). Set it here — the route-level `allowMultipleSelection` on `buildMonkeyRoutes` / `MonkeyRouteNode` controls URL-sync, not the list widget.

### Key behavior

- Shortcut bindings and context menus are automatically wired when using the default `buildItem` path.
- When `canReorder` is true (exactly one active sort option with `supportsReorder: true`), the list renders inside `LdListReorderScope` with `LdListReorderHandler`.

## LdMonkeyDetailPage

```dart
LdMonkeyDetailPage<T, IdType>({
  required Widget body,
  LdAppBarConfig? primaryAppBarConfig,
  LdAppBarConfig? secondaryAppBarConfig,
})
```

### Scrollable (renders all viewing items as a scrollable list)

```dart
LdMonkeyDetailPage.scrollable(
  primaryAppBarConfig: LdAppBarConfig(title: Text('Task')),
  buildDetail: (context, item) => TaskDetailCard(item: item),
)
```

### Stacked (renders viewing items as a stack with animated transforms)

```dart
LdMonkeyDetailPage.stacked(
  buildDetail: (context, item) => TaskDetailCard(item: item),
)
```

### `LdMonkeyStreamSelection`

Streams live updates for all currently-viewed items and rebuilds when they change:

```dart
LdMonkeyStreamSelection<Task, int>(
  showLoaderWhileEmpty: false,
  buildItem: (context, item) => TaskCard(item: item),
  builder: (context, itemWidgets) => Column(children: itemWidgets),
)
```

## LdMonkeyAppBar

`LdMonkeyAppBar` automatically injects monkey actions at the given location. Set title and bar properties via `LdAppBarConfig` on `LdMonkeyMasterPage` or `LdMonkeyDetailPage` — `LdMonkeyAppBar` itself has no `title` parameter.

```dart
const LdMonkeyAppBar({
  required LdMonkeyActionLocation location,
  List<Widget> additionalActions = const [],
  String? debugName,
  bool? implyLeading,   // overrides LdAppBarConfig.implyLeading
  Widget? child,        // subtree the bar wraps; null renders the bar surface only
})
```

**Note:** When an `LdMonkeyAppBar` has no actions and no `additionalActions`, it renders as `child ?? SizedBox.shrink()` — the bar surface is invisible. This is by design (avoids an empty bar), but can be surprising if you expect an app bar to always be visible.

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
  isVisible: (ctx) => true,  // Custom predicate (receives LdMonkeyActionContext)
)
```

### `LdMonkeyActionContext`

Shared snapshot for action logic in both bare-child and submit actions. Built by the framework at build/trigger time.

| Need | Use |
|------|-----|
| `selectedIds`, `selection`, `repository`, `contextItem` | `ctx.selectedIds`, `ctx.selection`, … |
| App/feature `Provider`s, modals, navigation | `ctx.appContext` |
| `updateViewing`, `updateSelection`, … | helpers on `ctx` |
| After any `await` | `ctx.appContext.mounted` |

Context menu actions receive item-scoped `selectedIds` because `LdMonkeyContextMenu` overrides the selection provider for the overlay.

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
  shortcutActivators: { SingleActivator(LogicalKeyboardKey.keyN, meta: true) },
  builder: (ctx, trigger) => LdAppBarAction(
    leading: const Icon(LucideIcons.plus),
    onPressed: trigger,
    child: const Text('New'),
  ),
  onTrigger: (ctx) async {
    // Use ctx.selectedIds, ctx.appContext for providers, navigation, etc.
  },
)
```

Wire `onPressed: trigger` so press-time snapshots stay fresh. `onTrigger` is also used for keyboard shortcuts.

### `LdMonkeySubmitAction`

For async operations with loading state, error handling, and notifications. Requires a unique `id`. One offstage `LdSubmit` host is mounted per route; app bar and context menu share loading state.

For standard delete, use `deleteAction<Task, int>()` instead (see Built-in Action Factories below).

```dart
LdMonkeySubmitAction<Task, int, void>(
  id: 'archive',
  tooltip: (context) => 'Archive selected tasks',
  visibility: {
    LdMonkeyActionVisibility(
      location: LdMonkeyActionLocation.masterAppBar,
      minSelectionCount: 1,
    ),
  },
  submitConfig: (appContext) => const LdMonkeySubmitConfig(
    loadingText: 'Archiving...',
  ),
  onSubmit: (ctx) async {
    await archiveSelected(ctx.selectedIds);
  },
  child: const Text('Archive'),
  icon: const Icon(LucideIcons.archive),
  // Optional:
  childBuilder: (triggerContext) => Text('Archive (${count})'),  // reactive child
  appBarOverflowMode: LdAppBarActionOverflowMode.overflowable,
  multiSelect: true,
)
```

### Built-in Action Factories

| Factory Function | Location | Behavior |
|---|---|---|
| `toggleSelectionControls<T, IdType>()` | `masterAppBar` | Toggles selection mode (checkbox UI) |
| `showSelection<T, IdType>()` | `masterSecondary` | Shows "Show Selection" button when selection differs from viewing |
| `showFilterContextMenu<T, IdType>()` | `masterAppBar` | Dropdown filter menu |
| `showFilterModal<T, IdType>()` | `masterAppBar` | Modal filter dialog |
| `refreshAction<T, IdType>()` | `masterAppBar` | Desktop-only refresh button |
| `deleteAction<T, IdType>()` | `detailAppBar`, `context`, `masterSecondary` | Deletes selected items via the model |
| `reactiveCreateAction<T, IdType>(routeConfig:)` | `masterAppBar` | Pushes the named create route (`<itemName>-create`) |

```dart
actions: [
  toggleSelectionControls<Task, int>(),
  showSelection<Task, int>(),
  showFilterContextMenu<Task, int>(),
  refreshAction<Task, int>(),
  deleteAction<Task, int>(),
  reactiveCreateAction<Task, int>(routeConfig: routeConfig),
  // Custom actions...
]
```

### Context Menu Actions

Actions with `LdMonkeyActionVisibility(location: LdMonkeyActionLocation.context, ...)` automatically appear in the right-click or long-press context menu on list items.

### Keyboard Shortcuts

Set `shortcutActivators` on any action and the monkey system will automatically wire `CallbackShortcuts`:

```dart
LdMonkeyBareChildAction<Task, int>(
  shortcutActivators: { SingleActivator(LogicalKeyboardKey.keyN, meta: true) },
  ...
)
```

Built-in shortcuts:
- `Cmd+F` — Search intent (when `LdFilterSearch` is configured)
- `Cmd+R` — Refresh intent
- `Cmd+A` — Select all intent

### `appBarOverflowMode` and `multiSelect`

All action types expose two additional base parameters:

```dart
LdAppBarActionOverflowMode appBarOverflowMode = LdAppBarActionOverflowMode.overflowable,
bool multiSelect = true,
```

## Filtering

### Filter Types

- **`LdFilterSearch<T, IdType, Suggestion>`** — Search/text filter, automatically adds a search bar to the master app bar
- **`LdFilterBool<T, IdType>`** — Boolean toggle filter
- **`LdFilterOneOf<T, IdType, V>`** — Select one from a set of options
- **`LdFilterAnyOf<T, IdType, V>`** — Select any number from a set of options (checkboxes)
- **`LdFilterRange<T, IdType>`** — Range filter (min/max)

### Adding Filters

Filters are provided via the async `filtersBuilder` on `buildMonkeyRoutes` / `MonkeyRouteNode`. Dynamic option catalogs can be loaded inside the builder:

```dart
buildMonkeyRoutes<Task, int>(
  filtersBuilder: (context) async {
    final categories = await api.fetchCategories();
    return [
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
      LdFilterOneOf<Task, int, String>(
        name: 'category',
        label: (context) => 'Category',
        icon: (context) => const Icon(LucideIcons.tag),
        allValues: {
          for (final cat in categories) cat: (context) => Text(cat),
        },
      ),
    ];
  },
  sortOptionsBuilder: (_) async => taskSortOptions,
  ...
);
```

The monkey will automatically:
- Resolve definitions via `LdMonkeyRouteDefinitionsResolver` (with loading state)
- Sync filter state with URL query parameters
- Show a search bar in the master app bar when an `LdFilterSearch` is configured
- Show filter indicator badges on filter buttons

Re-fetch definitions from the server: `LdMonkeySortAndFilterState.refreshFilterDefinitions(context)`.

For filter chips on the master bar, pass `filterBarConfig` to `LdMonkeyMasterPage`. Chips are rendered in `LdFilterChipsBar` which handles horizontal scrolling on mobile and wrapping on desktop.

### Accessing Active Filters

```dart
final filterState = LdMonkeySortAndFilterState.of<Task, int>(context);  // listen: true by default
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
    name: 'order',
    label: (context) => 'Custom order',
    icon: (context) => const Icon(LucideIcons.gripVertical),
    supportsReorder: true,  // enables drag-to-reorder when this sort is active
  ),
];
```

Sort options are synced with URL query parameters. Access active sort options:

```dart
final sortAndFilter = LdMonkeySortAndFilterState.of<Task, int>(context);
final activeSorts = sortAndFilter.activeSortOptions;
final canReorder = sortAndFilter.canReorder; // true when exactly one active sort has supportsReorder: true
```

**Note:** Filters and sort options are not stored in the list controller — they live in `LdMonkeySortAndFilterState` in the widget tree. `LdMonkeyListFilterAdapter` (included automatically in the monkey scope) reacts to filter/sort changes and refreshes the list controller.

## Drag-to-Reorder

Provide a `reorderHandler` on `buildMonkeyRoutes` / `MonkeyRouteNode` and set `supportsReorder: true` on the relevant sort option. The list automatically renders with drag handles when `canReorder` is true:

```dart
buildMonkeyRoutes<Task, int>(
  reorderHandler: (context, item, fromIndex, toIndex) async {
    return await api.reorderTask(item.id, toIndex);
  },
  sortOptionsBuilder: (_) async => [
    LdSortOption<Task, int>(
      name: 'order',
      label: (context) => 'Custom order',
      icon: (context) => const Icon(LucideIcons.gripVertical),
      supportsReorder: true,
    ),
  ],
  ...
)
```

## Selection State

The `LdMonkeySelection<T, IdType>` class tracks three things:
- **`selection`** — Items the user has checked/selected (checkbox mode)
- **`viewing`** — Items currently shown in the detail view
- **`showSelectionControls`** — Whether selection checkboxes are visible

### Reading Selection

```dart
// listen: false by default — pass true to rebuild when selection changes
final selection = LdMonkeySelection.of<Task, int>(context, listen: true);
final selectedIds = selection.selection;
final viewingIds = selection.viewing;
```

### Updating Selection

```dart
LdMonkeySelection.updateSelection<Task, int>(context, {1, 2, 3});
LdMonkeySelection.updateViewing<Task, int>(context, {1});
LdMonkeySelection.updateShowSelectionControls<Task, int>(context, true);
LdMonkeySelection.maybeClearSelection<Task, int>(context);  // shows confirmation modal
```

### Getting Item Objects

```dart
final selectedItems = await LdMonkeySelection.getSelectedItems<Task, int>(context);
final viewingItems = await LdMonkeySelection.getViewingItems<Task, int>(context);
```

### Adaptive Selection

`LdMonkeySelection.adaptive` returns the relevant set based on action location:
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
    modelBuilder: (context, state) => projectModel,
    filtersBuilder: (_) async => [...],
    sortOptionsBuilder: (_) async => [...],
    actions: [...],
    child: MonkeyRouteNode<Task, int>(
      detailPathPrefix: 'tasks',  // URL: /projects/:viewing_project/tasks/:viewing_task
      routeConfig: LdMonkeyRouteConfig.identifiableInt<Task>(itemName: 'task'),
      masterPage: const SizedBox(),
      detailPage: const Text('Task Detail'),
      modelBuilder: (context, state) => taskModel,
      filtersBuilder: (_) async => [...],
      sortOptionsBuilder: (_) async => [...],
      actions: [...],
    ),
  ),
);
```

**Important:** Each `routeConfig.itemName` must be unique across the entire tree to avoid path param and query key collisions.

### `scopeStorageKey`

Override the default scope key generation (which uses ancestor `viewing_*` path params) via the `scopeStorageKey` parameter on `MonkeyRouteNode`:

```dart
MonkeyRouteNode<Task, int>(
  scopeStorageKey: (root, state) => 'my-custom-scope-key',
  ...
)
```

## Create Route

A separate create route (`masterPath/new`) can be provided via `createPage` on `buildMonkeyRoutes` / `MonkeyRouteNode`. Use `reactiveCreateAction` to push to it:

```dart
buildMonkeyRoutes<Task, int>(
  createPage: LdMonkeyDetailPage(body: TaskCreateForm()),
  actions: [
    reactiveCreateAction<Task, int>(routeConfig: routeConfig),
  ],
  ...
)
```

The named route is `<itemName>-create`; use `GoRouter.of(context).pushNamed('task-create')` to navigate programmatically.

## Detail Modal

Show detail in a modal/dialog when not in side-by-side mode:

```dart
buildMonkeyRoutes<Task, int>(
  detailInDialog: true,
  ...
)
```

The router automatically opens the detail page as an `LdModalRoute` when a narrow-screen user navigates to the detail route.

## Detail Editing Guards

Editable monkey detail pages use `LdLocationLockRegistry` with `GoRouter.redirect` to intercept all navigation away from a dirty detail path.

### Setup

Mount `LdThemeProvider` (includes `LdLocationLockRegistry`) and wire the router:

```dart
GoRouter(
  redirect: ldLocationLockRedirect,
  routes: [...],
)
```

Combine with app-specific redirects using `ldComposeGoRouterRedirects`.

### Self-managed locks

Each editor owns its lock:

```dart
LdLocationLockRegistry.of(context).register(
  LdLocationLock(
    id: 'my-form-${item.id}',
    pathPrefix: GoRouter.of(context).state.uri.path,
    onLeave: (context) async {
      if (isSaving()) return false; // block silently mid-save
      return ldMonkeyConfirmDiscardEdits(context);
    },
  ),
);
```

Return `true` from `onLeave` to allow leaving; `false` to stay. Unregister the lock when the editor becomes pristine and in `dispose`.

`LdMonkeyReactiveDetailForm` does all of this automatically — non-reactive editors use this generic API directly.

## Reactive Detail Forms (`liquid_flutter_reactive_forms` package)

`LdMonkeyReactiveDetailForm` connects a `reactive_forms` `FormGroup` to `LdModel.update` / `LdModel.create`. It manages save mode, field conflict resolution, navigation guards, and streams live updates.

```dart
// Edit mode — 5 type params: T, IdType, TDetail, TCreate, TUpdate
LdMonkeyReactiveDetailForm<Task, int, Task, Task, Task>.edit(
  item: paginatorItem,                     // LdPaginatorItem<T>? from the list
  saveMode: LdMonkeyDetailSaveMode.adaptive,
  detailToFormValues: (task) => {
    'title': task.title,
    'completed': task.completed,
  },
  formToUpdatePayload: (form, task) => task.copyWith(
    title: form.control('title').value as String,
    completed: form.control('completed').value as bool,
  ),
  itemsBuilder: (context, hooks) => [
    LdReactiveFormItem.input<String>(
      key: 'title',
      inputFieldHint: 'Task title',
      onBlurred: hooks.onBlurred('title'),
    ),
    LdReactiveFormItem.checkbox(
      key: 'completed',
      label: 'Completed',
    ),
  ],
)
```

When `TDetail` differs from `T` (e.g. a richer detail DTO loaded separately):

```dart
LdMonkeyReactiveDetailForm<Task, int, TaskDetail, TaskCreate, TaskUpdate>.edit(
  item: paginatorItem,
  loadDetail: (context, id) async => await api.getTaskDetail(id),  // async detail loader
  detailFromEntity: (task) => TaskDetail.fromTask(task),           // extract from stream updates
  detailToFormValues: (detail) => {'title': detail.title},
  formToUpdatePayload: (form, detail) => TaskUpdate(title: form.control('title').value as String),
  ...
)
```

```dart
// Create mode
LdMonkeyReactiveDetailForm<Task, int, Task, TaskCreate, TaskUpdate>.create(
  initialDetail: null,
  detailToFormValues: (_) => {'title': ''},
  formToCreatePayload: (form, _) => TaskCreate(title: form.control('title').value as String),
  onCreated: (context, task) => GoRouter.of(context).go('/tasks/${task.id}'),
  itemsBuilder: (context, hooks) => [
    LdReactiveFormItem.input<String>(key: 'title', inputFieldHint: 'Task title'),
  ],
)
```

### Save modes

```dart
enum LdMonkeyDetailSaveMode {
  onBlur,        // save on blur/field commit; no submit button
  manualSubmit,  // explicit save button when form is dirty and valid
  adaptive,      // onBlur on mobile, manualSubmit on desktop
}
```

### Conflict resolution

When the server returns an updated item while the user is editing:

```dart
enum LdMonkeyFieldConflictPolicy {
  keepLocal,    // always keep user's local value (default)
  preferServer, // always overwrite with server value
  prompt,       // show per-field UI prompt (use LdMonkeyFieldConflictHint)
}
```

With `LdMonkeyDetailPreSaveCheck.repositoryGetById`, a fresh entity is fetched before saving and any conflicts are merged. Throws `LdMonkeyVersionConflictException` if unresolvable.

### Accessing form state from child widgets

`LdMonkeyDetailFormScope` is an `InheritedWidget` that exposes form state for use in custom layouts (e.g., a Save button in an app bar):

```dart
final formScope = LdMonkeyDetailFormScope.of<TaskDetail>(context);
// formScope.isDirty, formScope.isSaving, formScope.detail, formScope.save(), formScope.reset()
```

### `LdReactiveFormItem` factory constructors

```dart
LdReactiveFormItem.input<String>(key: 'title', inputFieldHint: 'Title', onBlurred: hooks.onBlurred('title'))
LdReactiveFormItem.input<int>(key: 'count', inputFieldHint: 'Count')       // uses IntValueAccessor
LdReactiveFormItem.input<double>(key: 'price', inputFieldHint: 'Price')    // uses DoubleValueAccessor
LdReactiveFormItem.input<DateTime>(key: 'due', inputFieldHint: 'Due date') // uses DateTimeValueAccessor
LdReactiveFormItem.select<Priority>(key: 'priority', items: [...])
LdReactiveFormItem.chooseFromItems<String>(key: 'tags', items: [...], multiple: true)
LdReactiveFormItem.chooseFromList<Tag, int>(key: 'tags', items: allTags, selectedItemBuilder: ..., multiple: true)
LdReactiveFormItem.chooseRepository<Tag, int>(key: 'tags', repository: tagController, itemBuilder: ..., selectedItemBuilder: ...)
LdReactiveFormItem.checkbox(key: 'done', label: 'Done')
LdReactiveFormItem.datePicker(key: 'due', label: 'Due date', onCommitted: hooks.onCommitted('due'))
LdReactiveFormItem.slider(key: 'progress', label: 'Progress', min: 0, max: 100)
```

## Picker Scope

`LdMonkeyPickerScope` renders the monkey master list as an entity picker, without a router. The Navigator pops with the confirmed `Set<IdType>`:

```dart
LdMonkeyPickerScope<Tag, int>(
  repository: tagController,           // pre-constructed LdListController
  initialSelection: {1, 3},
  label: 'Select tags',
  multiple: true,
  allowEmpty: false,
  itemBuilder: (context, item, index) => LdListItem(title: Text(item.value?.name ?? '')),
  filtersBuilder: (_) async => [],
  sortOptionsBuilder: (_) async => [],
)
```

## Ephemeral Monkey Controller

`LdEphemeralMonkeyController` provides in-memory monkey navigation state for picker / test scopes (no GoRouter):

```dart
LdEphemeralMonkeyController<Task, int>(
  filters: filterSet,
  sortOptions: sortList,
  initialSelection: {1},
  showSelectionControls: true,
)
```

The `controllerDelegate` getter returns an `LdMonkeyRouterController` interface for use with `Provider`.

## Deleted Items Guard

`LdMonkeyDeletedItemsGuard` automatically removes deleted items from selection and viewing state. It is included automatically inside `LdMonkeyRouterAdapter`, which is part of every monkey scope.

## LdMonkeyRouteScope

For custom GoRouter shapes, use `LdMonkeyRouteScope` directly to provide the monkey provider stack:

```dart
LdMonkeyRouteScope<Task, int>(
  routeState: routeState,
  routeConfig: routeConfig,
  actions: actions,
  filtersBuilder: (_) async => filters,
  sortOptionsBuilder: (_) async => sortOptions,
  modelBuilder: (context, state) => model,
  masterPage: masterPage,
  child: child,
)
```

The provider stack is:
`LdMonkeyRouteConfig` → `LdMonkeyActions` → `LdMonkeyDataProvider` → `LdMonkeyRouteDefinitionsResolver` → `LdMonkeyRouterAdapter` (provides `LdMonkeySelection`, `LdMonkeySortAndFilterState`, `LdMonkeyRouterController`, `LdMonkeyListFilterAdapter`, `LdMonkeyDeletedItemsGuard`) → `LdMonkeyShell`.

## Best Practices

1. **Use `buildMonkeyRoutes` for single-level master-detail** — it handles all the ShellRoute/GoRoute wiring.
2. **Use `buildMonkeyRouteTree` and `MonkeyRouteNode` for nested master-detail** — the child's scope is automatically available at the parent's detail position.
3. **Always use `LdMonkeyRouteConfig.identifiableString` or `.identifiableInt`** — custom serialization only when IDs contain underscores or special characters.
4. **Keep `itemName` unique across the entire monkey tree** to avoid URL parameter collisions.
5. **Use the built-in action factories** (`toggleSelectionControls`, `showSelection`, `showFilterContextMenu`, `refreshAction`, `deleteAction`, `reactiveCreateAction`) before writing custom ones.
6. **Prefer `LdMonkeyBareChildAction` for simple buttons** and `LdMonkeySubmitAction` for async operations.
7. **Use `LdMonkeyActionVisibility` to control action placement** — set the `location`, `minSelectionCount`, and `layoutModes` to match your UX requirements.
8. **Add `LdFilterSearch` to enable search** — it automatically adds a search bar to the master app bar and syncs with URL query params.
9. **Use `LdMonkeyDetailPage.scrollable` for multiple viewing items** and `.stacked` for animated transitions.
10. **Set `detailPanelFlex` to control side-by-side proportions** — higher values give more space to the detail panel.
11. **Use `LdCallbackModel.fromList` for demos/tests** — it handles in-memory pagination, filtering, and sorting automatically.
12. **Use `LdMonkeyReactiveDetailForm` from `liquid_flutter_reactive_forms`** for editing detail pages — it handles save mode, conflict resolution, navigation guards, and live updates automatically.
13. **Set `supportsReorder: true` on a sort option and pass `reorderHandler`** to enable drag-to-reorder when that sort is active.
