import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/window/drawer.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Used to theme the scaffold and make it work with the drawer
class AppScaffold extends StatefulWidget {
  final Widget child;
  final GoRouterState state;
  final Text title;

  const AppScaffold({super.key, required this.child, required this.title, required this.state});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, size) {
        return LdPortal(
          child: LdScaffold(
            drawer: MainNavigationDrawer(),
            autoLayoutBody: false,
            appBar: LdAppBar(
              blurOnScroll: true,
              leading: Container(
                height: 24,
                decoration: BoxDecoration(borderRadius: LdTheme.of(context).radius(LdSize.m)),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  "liquid_flutter_icon.jpg",
                ),
              ),
              title: widget.title,
            ),
            body: LdNotificationPortal(
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
