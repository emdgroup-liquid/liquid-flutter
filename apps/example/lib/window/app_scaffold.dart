import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid/window/drawer.dart';
import 'package:liquid/window/font_selector.dart';
import 'package:liquid/window/headline_font_selector.dart';
import 'package:liquid/window/platform_selector.dart';
import 'package:liquid/window/radius_selector.dart';
import 'package:liquid/window/size_selector.dart';
import 'package:liquid/window/theme_selector.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

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
  ValueNotifier<bool> mockSystemUi = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: mockSystemUi,
      builder: (context, value, child) {
        final mockPadding = EdgeInsets.only(top: 50, bottom: 50);
        var mediaQuery = MediaQuery.of(context);
        if (mockSystemUi.value) {
          mediaQuery = mediaQuery.copyWith(padding: mockPadding, viewPadding: mockPadding);
        }
        return MediaQuery(
          data: mediaQuery,
          child: Stack(
            children: [
              Positioned.fill(
                child: LdScaffold(
                  drawer: MainNavigationDrawer(),
                  body: LdAppBar(
                    debugName: "Master App Bar",

                    leading: Container(
                      height: 24,
                      decoration: BoxDecoration(borderRadius: LdTheme.of(context).radius(LdSize.m)),
                      clipBehavior: Clip.hardEdge,
                      child: Image.asset("liquid_flutter_icon.jpg"),
                    ),
                    title: widget.title,
                    actions: [
                      LdAppBarAction(
                        tooltip: "GitHub",
                        leading: Icon(LucideIcons.gitFork),
                        onPressed: () {
                          launchUrl(Uri.parse("https://github.com/emdgroup-liquid/liquid-flutter"));
                        },
                        child: const Text("GitHub"),
                      ),
                      LdContextMenu(
                        builder: (context, isShuttle, open, isOpen, child) => LdAppBarAction(
                          tooltip: "Theme",
                          leading: const Icon(LucideIcons.paintBucket),
                          onPressed: open,
                          active: isOpen,
                          child: const Text("Theme"),
                        ),
                        menuBuilder: (context) => ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: SingleChildScrollView(
                            child: LdAutoSpace(
                              children: [
                                const PlatformSelector(),

                                const ThemeSelector(),

                                const SizeSelector(),

                                const RadiusSelector(),

                                const FontSelector(),

                                const HeadlineFontSelector(),

                                MockSystemUiToggle(mockSystemUi: mockSystemUi),
                              ],
                            ).padL(),
                          ),
                        ),
                      ),
                    ],
                    child: widget.child,
                  ),
                ),
              ),
              if (mockSystemUi.value)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: mockPadding.top,
                  child: ColoredBox(color: LdTheme.of(context).primaryColor.withValues(alpha: 0.18)),
                ),
              if (mockSystemUi.value)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: mockPadding.bottom,
                  child: ColoredBox(color: LdTheme.of(context).primaryColor.withValues(alpha: 0.18)),
                ),
            ],
          ),
        );
      },
    );
  }
}

class MockSystemUiToggle extends StatelessWidget {
  const MockSystemUiToggle({super.key, required this.mockSystemUi});

  final ValueNotifier<bool> mockSystemUi;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: mockSystemUi,
      builder: (context, value, child) {
        return LdToggle(
          label: "Mock System UI",
          checked: value,
          onChanged: (value) {
            mockSystemUi.value = value;
          },
        );
      },
    );
  }
}
