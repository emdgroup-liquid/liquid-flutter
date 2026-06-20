import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DemoShell extends StatelessWidget {
  final StatefulNavigationShell child;
  const DemoShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final activeRoute = GoRouterState.of(context).uri.path;
    final isTaskDemoRoot = activeRoute == ("/task-demo");
    final isMovieDemoRoot = activeRoute == ("/movie-demo");
    final isProjectsDemoRoot = activeRoute == ("/projects");
    final isRoot = isTaskDemoRoot || isMovieDemoRoot || isProjectsDemoRoot;
    final theme = LdTheme.of(context);
    // Build the tab navigation (shown conditionally based on platform/route)

    return LdScaffold(
      debugName: "Demo Shell Scaffold",
      body: LdTabNavigation(
        position: LdAppBarPositionMode.adaptive,
        attachedMode: LdAppBarAttachedMode.attached,
        activeRoute: GoRouterState.of(context).uri.path,
        scrollBehavior: isRoot || theme.platform.isDesktop
            ? LdAppBarScrollBehavior.static
            : LdAppBarScrollBehavior.hidden,
        tabs: [
          LdNavigationTab(label: "Tasks", icon: const Icon(LucideIcons.check), route: "/task-demo*"),
          LdNavigationTab(label: "Movies", icon: const Icon(LucideIcons.film), route: "/movie-demo*"),
          LdNavigationTab(label: "Projects", icon: Icon(LucideIcons.folder), route: "/projects*"),
          LdNavigationTab(label: "Exit", icon: const Icon(LucideIcons.x), route: "/"),
        ],
        onTabPressed: (route) {
          if (route == "/") {
            context.go("/");
          } else {
            final branchIndex = switch (route) {
              "/task-demo*" => 1,
              "/projects*" => 2,
              "/movie-demo*" => 0,
              _ => throw Exception("Invalid route: $route"),
            };
            child.goBranch(branchIndex);
          }
        },

        child: LdWrapConditional(
          condition: theme.platform.isDesktop,
          child: child,
          builder: (context, child) => LdAppBar(
            shadowMode: LdAppBarShadowMode.hidden,
            borderMode: LdAppBarBorderMode.visible,
            backgroundMode: LdAppBarBackgroundMode.visible,
            title: const Text("LdMonkey Demos"),
            child: child,
          ),
        ),
      ),
    );
  }
}
