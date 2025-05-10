import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid/window/drawer.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Used to theme the scaffold and make it work with the drawer
class AppScaffold extends StatefulWidget {
  final Widget child;
  final Text title;

  const AppScaffold({super.key, required this.child, required this.title});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  @override
  Widget build(BuildContext context) {
    var themeService = LdTheme.of(context, listen: true);

    final drawerSize = switch (themeService.themeSize) {
      LdThemeSize.s => 300.0,
      LdThemeSize.m => 350.0,
      LdThemeSize.l => 400.0,
    };

    return ResponsiveBuilder(
      builder: (context, size) {
        final split = size.screenSize.width > 900;
        return LdWindowFrame(
          title: const Text("Liquid Flutter"),
          frameBuilder: (context, child) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              appWindow.startDragging();
            },
            onDoubleTap: () => appWindow.maximizeOrRestore(),
            child: child,
          ),
          child: LdPortal(
            child: Scaffold(
              drawer: !split ? const MainNavigationDrawer() : null,
              backgroundColor: themeService.background,
              appBar: size.isMobile
                  ? LdAppBar(context: context, title: widget.title)
                  : null,
              body: LdNotificationPortal(
                child: (split)
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(left: drawerSize, child: widget.child)
                              .animate(delay: 200.ms)
                              .fadeIn()
                              .moveX(
                                  begin: 100,
                                  curve: Curves.easeOutCubic,
                                  duration: 500.ms),
                          Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: drawerSize,
                              child: const MainNavigationDrawer(
                                persistent: true,
                              ),
                            ).animate().fadeIn().moveX(
                                  begin: -100,
                                  curve: Curves.easeOutCubic,
                                  duration: 500.ms,
                                ),
                          ),
                        ],
                      )
                    : widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
