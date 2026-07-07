import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TabPageViewDemo extends StatefulWidget {
  const TabPageViewDemo({super.key});

  @override
  State<TabPageViewDemo> createState() => _TabPageViewDemoState();
}

class _TabPageViewDemoState extends State<TabPageViewDemo> {
  late final PageController _pageController;

  final List<LdNavigationTab> _tabs = [
    LdNavigationTab(label: 'Home', route: '/home', icon: Icon(LucideIcons.house)),
    LdNavigationTab(label: 'Search', route: '/search', icon: Icon(LucideIcons.search)),
    LdNavigationTab(label: 'Bookmarks', route: '/bookmarks', icon: Icon(LucideIcons.bookmark)),
    LdNavigationTab(label: 'Profile', route: '/profile', icon: Icon(LucideIcons.user)),
  ];

  final List<({IconData icon, String title, String description})> _pages = [
    (
      icon: LucideIcons.house,
      title: 'Home',
      description: 'Swipe left or tap a tab to navigate between pages. '
          'The indicator tracks your finger in real-time.',
    ),
    (
      icon: LucideIcons.search,
      title: 'Search',
      description: 'The tab indicator follows the PageView scroll position '
          'continuously — no lag during the swipe gesture.',
    ),
    (
      icon: LucideIcons.bookmark,
      title: 'Bookmarks',
      description: 'On release the spring animation kicks in and settles '
          'the indicator on the final tab with a satisfying bounce.',
    ),
    (
      icon: LucideIcons.user,
      title: 'Profile',
      description: 'You can also drag the tab indicator itself to scroll '
          'the PageView — the sync is fully bidirectional.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/interaction/tab_pageview.dart",
      title: "LdTabs + PageView",
      apiComponents: [
        "LdTabNavigation",
        "LdNavigationTab",
      ],
      demo: LdAutoSpace(
        children: [
          LdText.p(
            'Pass a PageController to LdTabNavigation to keep the tab '
            'indicator in continuous sync with a PageView. The indicator '
            'tracks the finger during swipes (spring bypassed) and '
            'spring-animates on release.',
          ),
          ComponentWell(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 320,
              child: LdTabNavigation(
                pageController: _pageController,
                tabs: _tabs,
                position: LdAppBarPositionMode.bottom,
                attachedMode: LdAppBarAttachedMode.attached,
                onTabPressed: (route) {
                  // onTabPressed is still called on tap / indicator drag.
                  // The PageView is scrolled automatically via the
                  // PageController; no manual setState needed here.
                },
                child: PageView(
                  controller: _pageController,
                  children: _pages.map((page) => _PageContent(page: page)).toList(),
                ),
              ),
            ),
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdText.caption('How it works'),
                LdListItem(
                  leading: Icon(LucideIcons.arrowLeftRight),
                  title: LdText.p('Bidirectional sync'),
                  subtitle: LdText.ps(
                    'Swiping the PageView moves the tab indicator, and '
                    'tapping a tab (or dragging the indicator) scrolls '
                    'the PageView.',
                  ),
                ),
                LdListItem(
                  leading: Icon(LucideIcons.zap),
                  title: LdText.p('Frame-perfect tracking'),
                  subtitle: LdText.ps(
                    'The indicator follows PageController.page on every '
                    'frame during a swipe — spring is bypassed so there '
                    'is zero lag.',
                  ),
                ),
                LdListItem(
                  leading: Icon(LucideIcons.activity),
                  title: LdText.p('Spring on release'),
                  subtitle: LdText.ps(
                    'Once the page settles the spring re-engages, giving '
                    'the indicator its characteristic elastic finish.',
                  ),
                ),
              ],
            ),
          ),
          LdCard(
            child: LdAutoSpace(
              children: [
                LdText.caption('Minimal usage'),
                LdText.ps(
                  'Pass the same PageController to both LdTabNavigation '
                  'and PageView. No extra setState or listeners needed in '
                  'your widget.',
                ),
                LdText.ps(
                  'final controller = PageController();\n\n'
                  'LdTabNavigation(\n'
                  '  pageController: controller,\n'
                  '  tabs: myTabs,\n'
                  '  onTabPressed: (_) {},\n'
                  '  child: PageView(\n'
                  '    controller: controller,\n'
                  '    children: [...],\n'
                  '  ),\n'
                  ')',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final ({IconData icon, String title, String description}) page;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    return Center(
      child: Padding(
        padding: theme.pad(size: LdSize.l),
        child: LdAutoSpace(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(page.icon, size: 48, color: theme.primaryColor),
            LdText.hs(page.title),
            LdText.p(page.description, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
