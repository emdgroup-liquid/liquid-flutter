import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DemoShell extends StatelessWidget {
  final StatefulNavigationShell child;
  const DemoShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      debugName: "Demo Shell Scaffold",
      resizeToAvoidBottomInset: false,
      appBarScrollBehavior: LdAppBarScrollBehavior.mobileOnly,
      appBarPlacement: LdScaffoldAppBarPlacement.bottom,
      appBar: TabNavigation(
        activeRoute: GoRouterState.of(context).uri.path,
        tabs: [
          LdNavigationTab(
            label: "Tasks",
            icon: const Icon(LucideIcons.check),
            route: "/task-demo",
            isActive: (context) =>
                GoRouterState.of(context).uri.path.startsWith("/task-demo"),
          ),
          LdNavigationTab(
            label: "Movies",
            icon: const Icon(LucideIcons.film),
            route: "/movie-demo",
            isActive: (context) =>
                GoRouterState.of(context).uri.path.startsWith("/movie-demo"),
          ),
          LdNavigationTab(
            label: "Exit",
            icon: const Icon(LucideIcons.x),
            route: "/",
          ),
        ],
        onTabPressed: (route) {
          if (route == "/") {
            context.go("/");
          } else {
            child.goBranch(switch (route) {
              "/task-demo" => 0,
              "/movie-demo" => 1,
              _ => throw Exception("Invalid route: $route"),
            });
          }
        },
      ),
      body: child,
    );
  }
}
