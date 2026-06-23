import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TabsDemo extends StatefulWidget {
  const TabsDemo({super.key});

  @override
  State<TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<TabsDemo> with SingleTickerProviderStateMixin {
  String _activeRoute = "/";
  LdAppBarAttachedMode _attachedMode = LdAppBarAttachedMode.floating;
  final LdAppBarBackgroundMode _backgroundMode = LdAppBarBackgroundMode.adaptive;

  final LdAppBarScrollBehavior _scrollBehavior = LdAppBarScrollBehavior.static;

  bool _enableGradient = true;

  final List<LdNavigationTab> _tabs = [
    LdNavigationTab(label: "Home", route: "/", icon: Icon(LucideIcons.house)),
    LdNavigationTab(label: "Settings", route: "/settings", icon: Icon(LucideIcons.settings)),
    LdNavigationTab(label: "Profile", route: "/profile", icon: Icon(LucideIcons.user)),
    LdNavigationTab(label: "Messages", route: "/messages", icon: Icon(LucideIcons.messageSquare)),
    LdNavigationTab(label: "Notifications", route: "/notifications", icon: Icon(LucideIcons.bell)),
    LdNavigationTab(label: "Search", route: "/search", icon: Icon(LucideIcons.search)),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/tab.dart",
      title: "LdTabs",
      apiComponents: [
        "LdTabNavigation",
        "LdAppBarAttachedMode",
        "LdAppBarBackgroundMode",
        "LdAppBarPositionMode",
        "LdAppBarScrollBehavior",
        "LdNavigationTab",
      ],
      demo: LdAutoSpace(
        children: [
          ComponentWell(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: Placeholder()),
                  LdTabNavigation(
                    activeRoute: _activeRoute,
                    tabs: _tabs,
                    attachedMode: _attachedMode,
                    backgroundMode: _backgroundMode,
                    position: LdAppBarPositionMode.bottom,
                    scrollBehavior: _scrollBehavior,
                    enableGradient: _enableGradient,
                    onTabPressed: (route) => setState(() => _activeRoute = route),
                    child: Placeholder(),
                  ),
                ],
              ),
            ),
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdText.caption('Configuration'),
                LdText.p(
                  "Enable a gradient effect visible when not attached to make the tab bar more visually seperated from the background",
                ),
                LdToggle(
                  label: 'Enable Gradient',
                  disabled: _attachedMode != LdAppBarAttachedMode.floating,
                  checked: _enableGradient && _attachedMode == LdAppBarAttachedMode.floating,
                  onChanged: (value) => setState(() => _enableGradient = value),
                ),
                LdText.p(
                  "The attached mode determines how the tab bar is attached to the screen."
                  "Adaptive will be detached when placed at the bottom",
                ),
                LdSwitch<LdAppBarAttachedMode>(
                  value: _attachedMode,
                  label: 'Attached Mode',
                  onChanged: (value) => setState(() => _attachedMode = value),
                  children: {
                    LdAppBarAttachedMode.attached: const Text('.attached'),
                    LdAppBarAttachedMode.adaptive: const Text('.adaptive'),
                    LdAppBarAttachedMode.floating: const Text('.floating'),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
