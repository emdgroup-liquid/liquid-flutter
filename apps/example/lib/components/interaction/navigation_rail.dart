import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NavigationRailDemo extends StatefulWidget {
  const NavigationRailDemo({super.key});

  @override
  State<NavigationRailDemo> createState() => _NavigationRailDemoState();
}

class _NavigationRailDemoState extends State<NavigationRailDemo> {
  String _activeRoute = '/home';

  final List<LdNavigationTab> _tabs = [
    LdNavigationTab(label: 'Home', route: '/home', icon: Icon(LucideIcons.house)),
    LdNavigationTab(label: 'Search', route: '/search', icon: Icon(LucideIcons.search)),
    LdNavigationTab(label: 'Bookmarks', route: '/bookmarks', icon: Icon(LucideIcons.bookmark)),
    LdNavigationTab(label: 'Profile', route: '/profile', icon: Icon(LucideIcons.user)),
  ];

  void _onSelect(String route) {
    setState(() => _activeRoute = route);
  }

  Widget _pageContent() {
    final label = _tabs.firstWhere((t) => t.route == _activeRoute).label;
    return Center(child: LdText.p('Selected: $label'));
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: 'lib/components/interaction/navigation_rail.dart',
      title: 'LdNavigationRail',
      apiComponents: ['LdNavigationRail', 'LdNavigationTab', 'LdTabNavigation'],
      demo: LdAutoSpace(
        children: [
          LdText.p(
            'Pass the same List<LdNavigationTab> to LdNavigationRail (drawer) '
            'or LdTabNavigation (bottom bar). Resize the drawer to reflow '
            'between compact square tiles and extended icon+label rows.',
          ),
          LdText.hxs('Rail in drawer (resize to reflow)'),
          ComponentWell(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 420,
              child: LdScaffold(
                drawerWidth: LdNavigationRail.defaultWidth,
                drawerMinWidth: LdNavigationRail.defaultMinWidth,
                drawer: LdNavigationRail(
                  destinations: _tabs,
                  activeRoute: _activeRoute,
                  onDestinationSelected: _onSelect,
                  leading: LdText.caption('App'),
                  trailing: LdButton.ghost(onPressed: () {}, child: const Icon(LucideIcons.settings)),
                ),
                body: LdAppBar.top(
                  title: LdText.l('Rail demo'),
                  child: LdScaffoldBody(
                    addContainer: true,
                    children: [
                      _pageContent(),
                      LdText.p(
                        'Drag the panel divider to shrink into square '
                        'icon-over-label tiles or expand into a row layout.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          LdText.hxs('Same tabs as LdTabNavigation'),
          ComponentWell(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 220,
              child: LdTabNavigation(
                tabs: _tabs,
                activeRoute: _activeRoute,
                position: LdAppBarPositionMode.bottom,
                attachedMode: LdAppBarAttachedMode.attached,
                onTabPressed: _onSelect,
                child: _pageContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
