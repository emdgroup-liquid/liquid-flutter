---
name: liquid_flutter-tab-navigation
description: Use when implementing primary tab navigation with go_router and Liquid Flutter — covers StatefulShellRoute, IndexedStack vs PageView branch containers, LdTabNavigation with PageController, LdNavigationRail, independent per-tab navigators, and route/URL sync.
---

# Tab Navigation with go_router

Use this skill when an app needs **persistent navigation state per tab** (bottom tabs, swipeable pages, or a side rail) while keeping **deep links and URLs** working.

## When to use what

| Need | Use |
|------|-----|
| Single shared navigator, no tab stacks | `ShellRoute` (current example app pattern) |
| Tab stacks, instant switch, no swipe | `StatefulShellRoute.indexedStack` |
| Tab stacks + swipe + animated tab indicator | `StatefulShellRoute` + custom `navigatorContainerBuilder` + `PageView` |
| Desktop primary nav | Same branches; swap `LdTabNavigation` for `LdNavigationRail` |

**Do not** put all screens as sibling `GoRoute`s under one `ShellRoute` when each tab must keep its own back stack.

## Core model

```
StatefulShellRoute
├── StatefulShellBranch  → Navigator (tab 0 stack)
├── StatefulShellBranch  → Navigator (tab 1 stack)
└── StatefulShellBranch  → Navigator (tab 2 stack)
```

- Each branch gets its own `Navigator` and preserves stack state when inactive.
- `StatefulNavigationShell.currentIndex` is the active branch.
- Switch branches with `navigationShell.goBranch(index)` (not `context.go` to another tab root unless you also want to reset that branch — see `initialLocation` below).
- Nested routes inside a branch push on **that branch's** navigator only.

Share one `List<LdNavigationTab>` between `LdTabNavigation` (mobile) and `LdNavigationRail` (desktop). The app chooses chrome; go_router owns branch state.

## Route setup

### 1. Define tabs once

```dart
final primaryTabs = [
  LdNavigationTab(
    label: 'Home',
    icon: Icon(LucideIcons.house),
    route: '/home*', // prefix match for nested routes
  ),
  LdNavigationTab(
    label: 'Search',
    icon: Icon(LucideIcons.search),
    route: '/search*',
  ),
];
```

Use `*` suffix on `route` so `LdNavigationTab.matches()` highlights the tab for nested paths (e.g. `/home/details/1`).

### 2. Map tabs to branches

Branch order must match tab order. One root `GoRoute` per branch:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return AppShell(
      navigationShell: navigationShell,
      tabs: primaryTabs,
    );
  },
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'details/:id',
              builder: (_, state) => HomeDetailScreen(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/search',
          builder: (_, __) => const SearchScreen(),
        ),
      ],
    ),
  ],
)
```

Optional: `preload: false` on a branch to defer building that navigator until first visit.

## Pattern A — IndexedStack (no swipe)

Simplest. go_router renders branch navigators in an `IndexedStack` internally.

```dart
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    required this.tabs,
  });

  final StatefulNavigationShell navigationShell;
  final List<LdNavigationTab> tabs;

  @override
  Widget build(BuildContext context) {
    final activeRoute = GoRouterState.of(context).uri.path;

    return LdScaffold(
      body: LdTabNavigation(
        activeRoute: activeRoute,
        tabs: tabs,
        onTabPressed: (route) => context.go(route),
        child: navigationShell,
      ),
    );
  }
}
```

For desktop, replace `LdTabNavigation` with `LdNavigationRail` in the drawer and call `navigationShell.goBranch(index)` on selection.

### Tap active tab → pop to root

```dart
void onTabSelected(int index) {
  navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}
```

## Pattern B — PageView + LdTabNavigation (swipe)

Use when tabs should swipe and the indicator should track the finger. go_router passes branch navigators as `children` via `navigatorContainerBuilder`.

```dart
StatefulShellRoute(
  builder: (context, state, navigationShell) => navigationShell,
  navigatorContainerBuilder: (context, navigationShell, children) {
    return TabShellPageView(
      navigationShell: navigationShell,
      tabs: primaryTabs,
      children: children,
    );
  },
  branches: [/* same as above */],
)
```

### TabShellPageView — bidirectional sync

**Critical:** sync PageView ↔ `goBranch` ↔ URL in both directions.

```dart
class TabShellPageView extends StatefulWidget {
  const TabShellPageView({
    required this.navigationShell,
    required this.tabs,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<LdNavigationTab> tabs;
  final List<Widget> children;

  @override
  State<TabShellPageView> createState() => _TabShellPageViewState();
}

class _TabShellPageViewState extends State<TabShellPageView> {
  late final PageController _pageController = PageController(
    initialPage: widget.navigationShell.currentIndex,
  );

  @override
  void didUpdateWidget(TabShellPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // External navigation (deep link, context.go) → sync PageView
    if (_pageController.hasClients &&
        _pageController.page?.round() != widget.navigationShell.currentIndex) {
      _pageController.jumpToPage(widget.navigationShell.currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _indexForRoute(String route) {
    return widget.tabs.indexWhere((tab) {
      if (tab.route.endsWith('*')) {
        return route.startsWith(tab.route.substring(0, tab.route.length - 1));
      }
      return route == tab.route;
    });
  }

  void _onTabPressed(String route) {
    final index = _indexForRoute(route);
    if (index >= 0) {
      widget.navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LdTabNavigation(
      pageController: _pageController,
      tabs: widget.tabs,
      onTabPressed: _onTabPressed,
      child: PageView(
        controller: _pageController,
        onPageChanged: widget.navigationShell.goBranch,
        children: widget.children,
      ),
    );
  }
}
```

`LdTabNavigation` already animates the tab indicator from `PageController.page` when `pageController` is set. See `apps/example/lib/components/interaction/tab_pageview.dart`.

Pass the **same** `PageController` to both `LdTabNavigation` and `PageView`. Do not set manual icon/text sizes on tab button children — use `LdButton.size` / component defaults per design rules.

## Mobile vs desktop shell

```dart
// Mobile: bottom tabs + optional PageView
LdTabNavigation(..., child: navigationShellOrPageView)

// Desktop: rail in drawer
LdScaffold(
  drawerWidth: LdNavigationRail.defaultWidth,
  drawerMinWidth: LdNavigationRail.defaultMinWidth,
  drawer: LdNavigationRail(
    destinations: primaryTabs,
    activeRoute: GoRouterState.of(context).uri.path,
    onDestinationSelected: (route) {
      final index = primaryTabs.indexWhere((t) => t.route == route);
      if (index >= 0) navigationShell.goBranch(index);
    },
  ),
  body: navigationShell,
)
```

Use `StatefulShellRoute.indexedStack` on desktop (no PageView). Use PageView on mobile when swipe is required.

## Nesting stateful shells

A branch can contain another `StatefulShellRoute` (e.g. bottom tabs at app root, top tabs inside one tab). See go_router's [custom stateful shell example](https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/others/custom_stateful_shell_route.dart) (`TabbedRootScreen`, `PagedRootScreen`).

## Checklist

When implementing or reviewing tab navigation:

- [ ] Each tab is a `StatefulShellBranch`, not a flat sibling `GoRoute`
- [ ] Tab order matches branch order
- [ ] `LdNavigationTab.route` uses `*` suffix when branches have nested routes
- [ ] Tab tap calls `navigationShell.goBranch(index)` (PageView pattern) or `context.go(tabRoot)` (IndexedStack pattern)
- [ ] PageView: `onPageChanged` → `goBranch`; `didUpdateWidget` → `jumpToPage(currentIndex)`
- [ ] Modals / full-screen flows that cover tabs use `parentNavigatorKey` on the root navigator when needed
- [ ] `GoRouter.optionURLReflectsImperativeAPIs = true` in `main()` (project convention)

## Trade-offs

- **Memory:** IndexedStack and PageView keep inactive branch navigators in the tree. Use `preload: false` to avoid building unseen branches early.
- **Animations:** go_router animates pushes **within** a branch. **Between** branches, the container (`IndexedStack`, `PageView`, or custom) owns transitions.
- **Back button:** Each branch navigator pops independently. Shell-level back logic in `LdAppBar` already prefers the deepest poppable shell navigator.

## References in this repo

- `LdTabNavigation` + `PageController`: `packages/liquid_flutter/lib/src/appbar/tab_navigation.dart`
- Demo (UI only, no go_router): `apps/example/lib/components/interaction/tab_pageview.dart`
- `LdNavigationTab`: `packages/liquid_flutter/lib/src/navigation/navigation_tab.dart`
- Flat shell (not tab stacks): `apps/example/lib/router.dart` — `ShellRoute` + `AppScaffold`
- go_router examples: `stateful_shell_route.dart`, `others/custom_stateful_shell_route.dart` in the go_router package

## Related skills

- `liquid_flutter-app-root` — `GoRouter` setup in `main()` and root widget tree
- `liquid_flutter-monkey` — master-detail **inside** a branch (monkey routes + `ShellRoute` per monkey level)
- Design system nav components — `.cursor/rules/design.mdc` (`LdTabNavigation`, `LdNavigationRail`, `LdNavigationTab`)
