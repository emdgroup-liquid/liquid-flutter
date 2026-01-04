import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A comprehensive demo showcasing [LdAppBar] features and capabilities.
///
/// This demo allows you to interactively explore:
///
/// - **Multiple app bars**: Toggle primary and secondary app bars independently
/// - **Positioning**: Switch between top, bottom, and adaptive positioning modes
/// - **Scroll behaviors**: Test static, mobile-only, and always scroll behaviors
/// - **Visual appearance**: Control shadow, border, and background modes
/// - **Search functionality**: Enable/disable search with suggestions
/// - **Action overflow**: Observe how actions automatically overflow into a menu when
///   there isn't enough space (try resizing the window or adding more actions)
///
/// The demo includes multiple actions in the primary app bar to demonstrate the overflow
/// menu behavior. When the app bar doesn't have enough space to display all actions,
/// they automatically move to an overflow menu accessible via an ellipsis button.
///
/// See also:
/// - [LdAppBar] for the app bar widget being demonstrated
/// - [LdAppBarAction] for action buttons that adapt to overflow menus
class AppBarDemo extends StatefulWidget {
  const AppBarDemo({super.key});

  @override
  State<AppBarDemo> createState() => _AppBarDemoState();
}

class _AppBarDemoState extends State<AppBarDemo> {
  bool _hasPrimarySearchConfig = false;
  bool _hasSecondarySearchConfig = false;

  LdAppBarScrollBehavior _primaryScrollBehavior = LdAppBarScrollBehavior.mobileOnly;
  LdAppBarScrollBehavior _secondaryScrollBehavior = LdAppBarScrollBehavior.mobileOnly;

  LdAppBarPositionMode _primaryAppBarPositionMode = LdAppBarPositionMode.top;
  LdAppBarPositionMode _secondaryAppBarPositionMode = LdAppBarPositionMode.top;

  LdAppBarShadowMode _shadowMode = LdAppBarShadowMode.adaptive;
  LdAppBarBorderMode _borderMode = LdAppBarBorderMode.adaptive;
  LdAppBarBackgroundMode _backgroundMode = LdAppBarBackgroundMode.adaptive;
  LdAppBarAttachedMode _attachedMode = LdAppBarAttachedMode.adaptive;

  // Tab Navigation state
  String _activeTabRoute = '/home';
  bool _showTabNavigation = true;
  LdAppBarAttachedMode _tabAttachedMode = LdAppBarAttachedMode.adaptive;
  LdAppBarBackgroundMode _tabBackgroundMode = LdAppBarBackgroundMode.adaptive;
  LdAppBarPositionMode _tabPosition = LdAppBarPositionMode.adaptive;
  LdAppBarScrollBehavior _tabScrollBehavior = LdAppBarScrollBehavior.static;

  final ScrollController _scrollController = ScrollController();

  LdSearchConfig? _primarySearchConfig;
  LdSearchConfig? _secondarySearchConfig;

  @override
  void initState() {
    super.initState();
    _updatePrimarySearchConfig();
    _updateSecondarySearchConfig();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _updatePrimarySearchConfig() {
    _primarySearchConfig = null;
    if (_hasPrimarySearchConfig) {
      _primarySearchConfig = LdSearchConfig(
        onSearch: (query) {
          // Handle primary search
        },
        getSuggestions: (query) async {
          // Mock suggestions for primary
          return ['Primary Suggestion 1', 'Primary Suggestion 2', 'Primary Suggestion 3']
              .where((s) => s.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        buildSuggestion: (context, suggestion) {
          return LdListItem(
            title: Text(suggestion.toString()),
          );
        },
      );
    } else {
      _primarySearchConfig = null;
    }
  }

  void _updateSecondarySearchConfig() {
    _secondarySearchConfig = null;
    if (_hasSecondarySearchConfig) {
      _secondarySearchConfig = LdSearchConfig(
        onSearch: (query) {},
        getSuggestions: (query) async {
          // Mock suggestions for secondary
          return ['Secondary Suggestion 1', 'Secondary Suggestion 2', 'Secondary Suggestion 3']
              .where((s) => s.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        buildSuggestion: (context, suggestion) {
          return LdListItem(
            title: Text(suggestion.toString()),
          );
        },
      );
    } else {
      _secondarySearchConfig = null;
    }
  }

  /// Actions list for the app bars.
  ///
  /// This list contains multiple actions to demonstrate overflow behavior.
  /// When there isn't enough space in the app bar, actions automatically
  /// overflow into a menu. The primary app bar uses all actions, while
  /// the secondary app bar uses only the first 3 to show a less crowded example.
  List<Widget> get _actions => [
        LdAppBarAction(
          leading: const Icon(LucideIcons.settings),
          onPressed: () {
            // Show settings dialog
          },
          child: const Text('Settings'),
        ),
        LdContextMenu(
            builder: (context, isShuttle, open, isOpen, child) => LdAppBarAction(
                  leading: const Icon(LucideIcons.expand),
                  onPressed: () {
                    open();
                  },
                  child: const Text('Options'),
                ),
            menuBuilder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LdListItem(
                      width: 200,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Action 1
                      },
                      title: LdText.p('Action 1'),
                    ),
                    LdListItem(
                      width: 200,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Action 2
                      },
                      title: LdText.p('Action 2'),
                    ),
                    LdListItem(
                      width: 200,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Action 3
                      },
                      title: LdText.p('Action 3'),
                    ),
                  ],
                )),
        LdAppBarAction(
          leading: const Icon(LucideIcons.bell),
          onPressed: () {
            // This will show notification
            Future.delayed(const Duration(seconds: 1));
          },
          child: const Text('Notification'),
        ),
        LdAppBarAction(
          leading: const Icon(LucideIcons.trash2),
          onPressed: () {
            // This will show notification
            Future.delayed(const Duration(seconds: 1));
          },
          child: const Text('Delete'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      // Multiple app bars can be added to a single scaffold.
      // They are positioned based on their positionMode and order.
      drawer: LdScaffold(
        appBars: [
          LdAppBar(
            title: LdText.l('Drawer'),
          )
        ],
        body: LdText.p('Drawer'),
      ),
      appBars: [
        LdAppBar(
          positionMode: _primaryAppBarPositionMode,
          scrollBehavior: _primaryScrollBehavior,
          title: LdText.l('Primary AppBar'),
          // All actions are included to demonstrate overflow behavior
          actions: _actions,
          order: 0,
          searchConfig: _primarySearchConfig,
          shadowMode: _shadowMode,
          borderMode: _borderMode,
          backgroundMode: _backgroundMode,
          attachedMode: _attachedMode,
        ),
        LdAppBar(
          positionMode: _secondaryAppBarPositionMode,
          scrollBehavior: _secondaryScrollBehavior,
          title: LdText.l('Secondary AppBar'),
          // Fewer actions for secondary to show a less crowded example
          actions: _actions.take(3).toList(),
          searchConfig: _secondarySearchConfig,
          shadowMode: _shadowMode,
          order: 1,
          borderMode: _borderMode,
          backgroundMode: _backgroundMode,
          attachedMode: _attachedMode,
        ),
        if (_showTabNavigation)
          TabNavigation(
            activeRoute: _activeTabRoute,
            onTabPressed: (route) => setState(() => _activeTabRoute = route),
            tabs: const [
              LdNavigationTab(
                label: 'Home',
                icon: Icon(LucideIcons.house),
                route: '/home',
              ),
              LdNavigationTab(
                label: 'Search',
                icon: Icon(LucideIcons.search),
                route: '/search',
              ),
              LdNavigationTab(
                label: 'Settings',
                icon: Icon(LucideIcons.settings),
                route: '/settings',
              ),
              LdNavigationTab(
                label: 'Profile',
                icon: Icon(LucideIcons.user),
                route: '/profile',
              ),
            ],
            attachedMode: _tabAttachedMode,
            backgroundMode: _tabBackgroundMode,
            position: _tabPosition,
            scrollBehavior: _tabScrollBehavior,
            order: 2,
          ),
      ],
      primaryScrollController: _scrollController,
      body: LdScaffoldBody(
        children: [
          LdText.h('LdAppBar Demo'),
          LdButton.vague(
              child: Text("Leave demo"),
              onPressed: () {
                context.go('/');
              }),
          LdAutoSpace(
            children: [
              LdText.p(
                'This demo shows how to add one or more LdAppBars to an LdScaffold using the appBars parameter.',
              ),
              LdText.p(
                'Use LdAppBar.top or LdAppBar.bottom to pin an app bar to the top or bottom. When multiple app bars share the same position, the order property controls their stacking.',
              ),
              LdText.p(
                'The combined height of all app bars is applied to MediaQuery padding so the body content is never hidden behind them.',
              ),
              LdText.p(
                'Actions that do not fit on the bar automatically overflow into a context menu. In the bar, actions are rendered as buttons; in the overflow menu they are rendered as list items (via LdAppBarAction).',
              ),
            ],
          ),
          LdDivider(),

          LdAutoSpace(
            children: [
              // Primary AppBar Controls
              // These controls allow you to toggle the primary app bar and configure
              // its position, scroll behavior, and search functionality.
              Row(
                children: [
                  Expanded(
                    child: LdAutoSpace(
                      children: [
                        LdText.caption('Primary AppBar'),
                        LdCard(
                          child: LdAutoSpace(
                            children: [
                              LdToggle(
                                label: 'Enable Search',
                                checked: _hasPrimarySearchConfig,
                                onChanged: (value) {
                                  setState(() {
                                    _hasPrimarySearchConfig = value;
                                    _updatePrimarySearchConfig();
                                  });
                                },
                              ),
                              LdSwitch<LdAppBarPositionMode>(
                                // Position of the primary app bar in the scaffold.
                                label: 'Position (LdAppBarPositionMode)',
                                value: _primaryAppBarPositionMode,
                                onChanged: (value) => setState(() => _primaryAppBarPositionMode = value),
                                children: {
                                  LdAppBarPositionMode.top: const Text('.top'),
                                  LdAppBarPositionMode.bottom: const Text('.bottom'),
                                  LdAppBarPositionMode.adaptive: const Text('.adaptive'),
                                },
                              ),
                              LdSwitch<LdAppBarScrollBehavior>(
                                // How the primary app bar responds to scroll.
                                label: 'Scroll Behavior (LdAppBarScrollBehavior)',
                                value: _primaryScrollBehavior,
                                onChanged: (value) => setState(() => _primaryScrollBehavior = value),
                                children: {
                                  LdAppBarScrollBehavior.static: const Text('.static'),
                                  LdAppBarScrollBehavior.mobileOnly: const Text('.mobileOnly'),
                                  LdAppBarScrollBehavior.always: const Text('.always'),
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LdAutoSpace(
                      children: [
                        LdText.caption('Secondary AppBar'),
                        LdCard(
                          child: LdAutoSpace(
                            children: [
                              LdToggle(
                                label: 'Enable Search',
                                checked: _hasSecondarySearchConfig,
                                onChanged: (value) {
                                  setState(() {
                                    _hasSecondarySearchConfig = value;
                                    _updateSecondarySearchConfig();
                                  });
                                },
                              ),
                              LdSwitch<LdAppBarPositionMode>(
                                // Position of the secondary app bar.
                                label: 'Position (LdAppBarPositionMode)',
                                value: _secondaryAppBarPositionMode,
                                onChanged: (value) => setState(() => _secondaryAppBarPositionMode = value),
                                children: {
                                  LdAppBarPositionMode.top: const Text('.top'),
                                  LdAppBarPositionMode.bottom: const Text('.bottom'),
                                  LdAppBarPositionMode.adaptive: const Text('.adaptive'),
                                },
                              ),
                              LdSwitch<LdAppBarScrollBehavior>(
                                // How the secondary app bar responds to scroll.
                                label: 'Scroll Behavior (LdAppBarScrollBehavior)',
                                value: _secondaryScrollBehavior,
                                onChanged: (value) => setState(() => _secondaryScrollBehavior = value),
                                children: {
                                  LdAppBarScrollBehavior.static: const Text('.static'),
                                  LdAppBarScrollBehavior.mobileOnly: const Text('.mobileOnly'),
                                  LdAppBarScrollBehavior.always: const Text('.always'),
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ).spaceM(),

              LdText.caption('Visual Appearance (Applied to Both AppBars)'),
              LdText.p(
                'Tune how both app bars look: shadow controls elevation, border controls separators, background controls how much of the surface color is visible, and attached mode controls whether the app bar is attached to the scaffold or floating.',
              ),

              LdCard(
                child: LdAutoSpace(
                  children: [
                    LdSwitch<LdAppBarAttachedMode>(
                      value: _attachedMode,
                      label: 'Attached Mode (LdAppBarAttachedMode)',
                      onChanged: (value) => setState(() => _attachedMode = value),
                      children: {
                        LdAppBarAttachedMode.attached: const Text('.attached'),
                        LdAppBarAttachedMode.adaptive: const Text('.adaptive'),
                        LdAppBarAttachedMode.floating: const Text('.floating'),
                      },
                    ),
                    LdSwitch<LdAppBarShadowMode>(
                      label: 'Shadow Mode (LdAppBarShadowMode)',
                      value: _shadowMode,
                      onChanged: (value) => setState(() => _shadowMode = value),
                      children: {
                        LdAppBarShadowMode.visible: const Text('.visible'),
                        LdAppBarShadowMode.whenScrolled: const Text('.whenScrolled'),
                        LdAppBarShadowMode.hidden: const Text('.hidden'),
                        LdAppBarShadowMode.adaptive: const Text('.adaptive'),
                      },
                    ),
                    LdSwitch<LdAppBarBorderMode>(
                      value: _borderMode,
                      label: 'Border Mode (LdAppBarBorderMode)',
                      onChanged: (value) => setState(() => _borderMode = value),
                      children: {
                        LdAppBarBorderMode.visible: const Text('.visible'),
                        LdAppBarBorderMode.whenScrolled: const Text('.whenScrolled'),
                        LdAppBarBorderMode.hidden: const Text('.hidden'),
                        LdAppBarBorderMode.adaptive: const Text('.adaptive'),
                      },
                    ),
                    LdSwitch<LdAppBarBackgroundMode>(
                      value: _backgroundMode,
                      label: 'Background Mode (LdAppBarBackgroundMode)',
                      onChanged: (value) => setState(() => _backgroundMode = value),
                      children: {
                        LdAppBarBackgroundMode.visible: const Text('.visible'),
                        LdAppBarBackgroundMode.whenScrolled: const Text('.whenScrolled'),
                        LdAppBarBackgroundMode.hidden: const Text('.hidden'),
                        LdAppBarBackgroundMode.adaptive: const Text('.adaptive'),
                      },
                    ),
                  ],
                ),
              ),

              LdDivider(),

              LdText.caption('Tab Navigation'),
              LdText.p(
                'Tab navigation provides a bottom navigation bar that can be positioned at the top or bottom of the scaffold. It integrates with the app bar registry system and supports various attached modes and scroll behaviors.',
              ),

              LdCard(
                child: LdAutoSpace(
                  children: [
                    LdToggle(
                      label: 'Show Tab Navigation',
                      checked: _showTabNavigation,
                      onChanged: (value) => setState(() => _showTabNavigation = value),
                    ),
                    LdSwitch<LdAppBarAttachedMode>(
                      value: _tabAttachedMode,
                      label: 'Attached Mode (LdAppBarAttachedMode)',
                      onChanged: (value) => setState(() => _tabAttachedMode = value),
                      children: {
                        LdAppBarAttachedMode.attached: const Text('.attached'),
                        LdAppBarAttachedMode.adaptive: const Text('.adaptive'),
                        LdAppBarAttachedMode.floating: const Text('.floating'),
                      },
                    ),
                    LdSwitch<LdAppBarBackgroundMode>(
                      value: _tabBackgroundMode,
                      label: 'Background Mode (LdAppBarBackgroundMode)',
                      onChanged: (value) => setState(() => _tabBackgroundMode = value),
                      children: {
                        LdAppBarBackgroundMode.visible: const Text('.visible'),
                        LdAppBarBackgroundMode.whenScrolled: const Text('.whenScrolled'),
                        LdAppBarBackgroundMode.hidden: const Text('.hidden'),
                        LdAppBarBackgroundMode.adaptive: const Text('.adaptive'),
                      },
                    ),
                    LdSwitch<LdAppBarPositionMode>(
                      value: _tabPosition,
                      label: 'Position (LdAppBarPositionMode)',
                      onChanged: (value) => setState(() => _tabPosition = value),
                      children: {
                        LdAppBarPositionMode.top: const Text('.top'),
                        LdAppBarPositionMode.bottom: const Text('.bottom'),
                        LdAppBarPositionMode.adaptive: const Text('.adaptive'),
                      },
                    ),
                    LdSwitch<LdAppBarScrollBehavior>(
                      value: _tabScrollBehavior,
                      label: 'Scroll Behavior (LdAppBarScrollBehavior)',
                      onChanged: (value) => setState(() => _tabScrollBehavior = value),
                      children: {
                        LdAppBarScrollBehavior.static: const Text('.static'),
                        LdAppBarScrollBehavior.mobileOnly: const Text('.mobileOnly'),
                        LdAppBarScrollBehavior.always: const Text('.always'),
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Scrollable content to demonstrate scroll behaviors
          // Scroll this content to see how different scroll behaviors affect the app bar's
          // appearance (e.g., shadow and border appearing when scrolled).
          SizedBox(height: 1000, child: LdText.p('Scrollable Content')),
        ],
      ),
    );
  }
}
