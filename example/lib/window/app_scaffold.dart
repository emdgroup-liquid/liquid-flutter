import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/window/drawer.dart';
import 'package:liquid/window/font_selector.dart';
import 'package:liquid/window/headline_font_selector.dart';
import 'package:liquid/window/radius_selector.dart';
import 'package:liquid/window/size_selector.dart';
import 'package:liquid/window/theme_selector.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';

// Used to theme the scaffold and make it work with the drawer
class AppScaffold extends StatefulWidget {
  final Widget child;
  final GoRouterState state;
  final Text title;

  const AppScaffold({
    super.key,
    required this.child,
    required this.title,
    required this.state,
  });

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
            appBar: LdAppBar(
              leading: Container(
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: LdTheme.of(context).radius(LdSize.m),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  "liquid_flutter_icon.jpg",
                ),
              ),
              title: widget.title,
              trailing: LdContextMenu(
                scaleFromTrigger: true,
                positionMode: LdContextPositionMode.relativeTrigger,
                builder: (context, shuttle, trigger, child) => LdButtonVague(
                  trailing: const Icon(LucideIcons.squareMousePointer),
                  onPressed: () {
                    trigger();
                  },
                  child: const Text("Theme"),
                ),
                menuBuilder: (context, openMenu) => ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 300,
                  ),
                  child: SingleChildScrollView(
                    child: LdAutoSpace(
                      children: [
                        const ThemeSelector(),
                        ldSpacerM,
                        const SizeSelector(),
                        ldSpacerM,
                        const RadiusSelector(),
                        ldSpacerM,
                        const FontSelector(),
                        ldSpacerM,
                        const HeadlineFontSelector(),
                      ],
                    ).padL(),
                  ),
                ),
              ),
              actions: [
                LdAppBarAction(
                  icon: const Icon(LucideIcons.github),
                  label: "GitHub",
                  submitType: LdLabeledActionSubmitType.none,
                  onPressed: (context) {
                    launchUrl(
                      Uri.parse(
                        "https://github.com/emdgroup-liquid/liquid-flutter",
                      ),
                    );
                  },
                ),
              ],
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
