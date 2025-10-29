import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppBarDemo extends StatefulWidget {
  const AppBarDemo({super.key});

  @override
  State<AppBarDemo> createState() => _AppBarDemoState();
}

class _AppBarDemoState extends State<AppBarDemo> {
  bool _hasPrimary = true;
  bool _hasSecondary = false;
  bool _hasPrimarySearchConfig = false;
  bool _hasSecondarySearchConfig = false;

  LdAppBarScrollBehavior _primaryScrollBehavior = LdAppBarScrollBehavior.static;
  LdAppBarScrollBehavior _secondaryScrollBehavior =
      LdAppBarScrollBehavior.static;

  LdScaffoldAppBarPlacement _primaryAppBarPlacement =
      LdScaffoldAppBarPlacement.top;
  LdScaffoldAppBarPlacement _secondaryAppBarPlacement =
      LdScaffoldAppBarPlacement.mobileBottomDesktopTop;

  LdAppBarShadowMode _shadowMode = LdAppBarShadowMode.whenScrolled;
  LdAppBarBorderMode _borderMode = LdAppBarBorderMode.whenScrolled;
  LdAppBarBackgroundMode _backgroundMode = LdAppBarBackgroundMode.whenScrolled;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _primarySearchController =
      TextEditingController();
  final TextEditingController _secondarySearchController =
      TextEditingController();
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
    _primarySearchController.dispose();
    _secondarySearchController.dispose();
    _primarySearchConfig?.dispose();
    _secondarySearchConfig?.dispose();
    super.dispose();
  }

  void _updatePrimarySearchConfig() {
    _primarySearchConfig?.dispose();
    _primarySearchConfig = null;
    if (_hasPrimarySearchConfig) {
      _primarySearchConfig = LdSearchConfig(
        inputController: _primarySearchController,
        onSearch: (query) {
          // Handle primary search
          print('Primary search query: $query');
        },
        getSuggestions: (query) async {
          // Mock suggestions for primary
          return [
            'Primary Suggestion 1',
            'Primary Suggestion 2',
            'Primary Suggestion 3'
          ]
              .where((s) => s.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        buildSuggestion: (context, suggestion) {
          return LdTextP(suggestion.toString());
        },
      );
    } else {
      _primarySearchConfig = null;
    }
  }

  void _updateSecondarySearchConfig() {
    _secondarySearchConfig?.dispose();
    _secondarySearchConfig = null;
    if (_hasSecondarySearchConfig) {
      _secondarySearchConfig = LdSearchConfig(
        inputController: _secondarySearchController,
        onSearch: (query) {
          // Handle secondary search
          print('Secondary search query: $query');
        },
        getSuggestions: (query) async {
          // Mock suggestions for secondary
          return [
            'Secondary Suggestion 1',
            'Secondary Suggestion 2',
            'Secondary Suggestion 3'
          ]
              .where((s) => s.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        buildSuggestion: (context, suggestion) {
          return LdTextP(suggestion.toString());
        },
      );
    } else {
      _secondarySearchConfig = null;
    }
  }

  List<LdLabeledAction> get _actions => [
        LdLabeledActionBuilder(
          buildLabel: (context) => 'Search',
          buildIcon: (context) => const Icon(LucideIcons.search),
          action: (context) async {
            // Toggle primary search
            setState(() {
              _hasPrimarySearchConfig = !_hasPrimarySearchConfig;
              _updatePrimarySearchConfig();
            });
          },
          submitType: LdLabeledActionType.none,
        ),
        LdLabeledActionBuilder(
          buildLabel: (context) => 'Settings',
          buildIcon: (context) => const Icon(LucideIcons.settings),
          action: (context) async {
            // Show settings dialog
            await LdModal(
              title: const LdTextL('Settings'),
              modalContent: (context) =>
                  const LdTextP('Settings dialog content'),
            ).show(context);
          },
          submitType: LdLabeledActionType.none,
        ),
        LdLabeledActionBuilder(
          buildLabel: (context) => 'More',
          buildIcon: (context) => const Icon(LucideIcons.ellipsisVertical),
          action: (context) async {
            // This will show context menu
          },
          submitType: LdLabeledActionType.contextMenu,
          buildContextMenu: (context, close) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LdButtonGhost(
                width: 200,
                onPressed: () {
                  close();
                  // Action 1
                },
                child: const LdTextP('Action 1'),
              ),
              LdButtonGhost(
                width: 200,
                onPressed: () {
                  close();
                  // Action 2
                },
                child: const LdTextP('Action 2'),
              ),
              LdButtonGhost(
                width: 200,
                onPressed: () {
                  close();
                  // Action 3
                },
                child: const LdTextP('Action 3'),
              ),
            ],
          ),
        ),
        LdLabeledActionBuilder(
          buildLabel: (context) => 'Notification',
          buildIcon: (context) => const Icon(LucideIcons.bell),
          action: (context) async {
            // This will show notification
            await Future.delayed(const Duration(seconds: 1));
          },
          submitType: LdLabeledActionType.notification,
        ),
        LdLabeledActionBuilder(
          buildLabel: (context) => 'Delete',
          buildIcon: (context) => const Icon(LucideIcons.trash2),
          action: (context) async {
            // This will show notification
            await Future.delayed(const Duration(seconds: 1));
          },
          submitType: LdLabeledActionType.notification,
          color: LdTheme.of(context).error,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      appBar: _hasPrimary
          ? LdAppBar(
              title: const LdTextL('Primary AppBar'),
              actions: _actions,
              searchConfig: _primarySearchConfig,
              shadowMode: _shadowMode,
              borderMode: _borderMode,
              backgroundMode: _backgroundMode,
            )
          : null,
      secondaryAppBar: _hasSecondary
          ? LdAppBar(
              title: const LdTextL('Secondary AppBar'),
              actions: _actions.take(3).toList(), // Fewer actions for secondary
              searchConfig: _secondarySearchConfig,
              shadowMode: _shadowMode,
              borderMode: _borderMode,
              backgroundMode: _backgroundMode,
            )
          : null,
      appBarPlacement: _primaryAppBarPlacement,
      secondaryAppBarPlacement: _secondaryAppBarPlacement,
      appBarScrollBehavior: _primaryScrollBehavior,
      secondaryAppBarScrollBehavior: _secondaryScrollBehavior,
      primaryScrollController: _scrollController,
      body: LdScaffoldBody(
        children: [
          LdCard(
            child: LdAutoSpace(
              children: [
                const LdTextL('LdAppBar Demo Controls'),
                LdTextP('Use the controls below to explore LdAppBar features:'),

                // Primary AppBar Controls
                LdTextL('Primary AppBar'),
                Row(
                  children: [
                    LdToggle(
                      checked: _hasPrimary,
                      onChanged: (value) => setState(() => _hasPrimary = value),
                    ),
                    ldHSpacerS,
                    const LdTextP('Show Primary AppBar'),
                  ],
                ),
                Row(
                  children: [
                    LdToggle(
                      checked: _hasPrimarySearchConfig,
                      onChanged: (value) {
                        setState(() {
                          _hasPrimarySearchConfig = value;
                          _updatePrimarySearchConfig();
                        });
                      },
                    ),
                    ldHSpacerS,
                    const LdTextP('Enable Search'),
                  ],
                ),
                LdTextP('Position:'),
                LdSwitch<LdScaffoldAppBarPlacement>(
                  value: _primaryAppBarPlacement,
                  onChanged: (value) =>
                      setState(() => _primaryAppBarPlacement = value),
                  children: {
                    LdScaffoldAppBarPlacement.top: const LdTextP('Top'),
                    LdScaffoldAppBarPlacement.bottom: const LdTextP('Bottom'),
                    LdScaffoldAppBarPlacement.mobileTopDesktopBottom:
                        const LdTextP('Mobile Top, Desktop Bottom'),
                    LdScaffoldAppBarPlacement.mobileBottomDesktopTop:
                        const LdTextP('Mobile Bottom, Desktop Top'),
                  },
                ),
                LdTextP('Scroll Behavior:'),
                LdSwitch<LdAppBarScrollBehavior>(
                  value: _primaryScrollBehavior,
                  onChanged: (value) =>
                      setState(() => _primaryScrollBehavior = value),
                  children: {
                    LdAppBarScrollBehavior.static: const LdTextP('Static'),
                    LdAppBarScrollBehavior.mobileOnly:
                        const LdTextP('Mobile Only'),
                    LdAppBarScrollBehavior.always: const LdTextP('Always'),
                  },
                ),

                // Secondary AppBar Controls
                LdTextL('Secondary AppBar'),
                Row(
                  children: [
                    LdToggle(
                      checked: _hasSecondary,
                      onChanged: (value) =>
                          setState(() => _hasSecondary = value),
                    ),
                    ldHSpacerS,
                    const LdTextP('Show Secondary AppBar'),
                  ],
                ),
                Row(
                  children: [
                    LdToggle(
                      checked: _hasSecondarySearchConfig,
                      onChanged: (value) {
                        setState(() {
                          _hasSecondarySearchConfig = value;
                          _updateSecondarySearchConfig();
                        });
                      },
                    ),
                    ldHSpacerS,
                    const LdTextP('Enable Search'),
                  ],
                ),
                LdTextP('Position:'),
                LdSwitch<LdScaffoldAppBarPlacement>(
                  value: _secondaryAppBarPlacement,
                  onChanged: (value) =>
                      setState(() => _secondaryAppBarPlacement = value),
                  children: {
                    LdScaffoldAppBarPlacement.top: const LdTextP('Top'),
                    LdScaffoldAppBarPlacement.bottom: const LdTextP('Bottom'),
                    LdScaffoldAppBarPlacement.mobileTopDesktopBottom:
                        const LdTextP('Mobile Top, Desktop Bottom'),
                    LdScaffoldAppBarPlacement.mobileBottomDesktopTop:
                        const LdTextP('Mobile Bottom, Desktop Top'),
                  },
                ),
                LdTextP('Scroll Behavior:'),
                LdSwitch<LdAppBarScrollBehavior>(
                  value: _secondaryScrollBehavior,
                  onChanged: (value) =>
                      setState(() => _secondaryScrollBehavior = value),
                  children: {
                    LdAppBarScrollBehavior.static: const LdTextP('Static'),
                    LdAppBarScrollBehavior.mobileOnly:
                        const LdTextP('Mobile Only'),
                    LdAppBarScrollBehavior.always: const LdTextP('Always'),
                  },
                ),

                // Shared Visual Controls
                LdTextL('Visual Appearance (Applied to Both AppBars)'),
                LdTextP('Shadow Mode:'),
                LdSwitch<LdAppBarShadowMode>(
                  value: _shadowMode,
                  onChanged: (value) => setState(() => _shadowMode = value),
                  children: {
                    LdAppBarShadowMode.visible: const LdTextP('Visible'),
                    LdAppBarShadowMode.whenScrolled:
                        const LdTextP('When Scrolled'),
                    LdAppBarShadowMode.hidden: const LdTextP('Hidden'),
                  },
                ),
                LdTextP('Border Mode:'),
                LdSwitch<LdAppBarBorderMode>(
                  value: _borderMode,
                  onChanged: (value) => setState(() => _borderMode = value),
                  children: {
                    LdAppBarBorderMode.visible: const LdTextP('Visible'),
                    LdAppBarBorderMode.whenScrolled:
                        const LdTextP('When Scrolled'),
                    LdAppBarBorderMode.hidden: const LdTextP('Hidden'),
                  },
                ),
                LdTextP('Background Mode:'),
                LdSwitch<LdAppBarBackgroundMode>(
                  value: _backgroundMode,
                  onChanged: (value) => setState(() => _backgroundMode = value),
                  children: {
                    LdAppBarBackgroundMode.visible: const LdTextP('Visible'),
                    LdAppBarBackgroundMode.whenScrolled:
                        const LdTextP('When Scrolled'),
                    LdAppBarBackgroundMode.hidden: const LdTextP('Hidden'),
                  },
                ),
              ],
            ),
          ),

          // Scrollable content to demonstrate scroll behaviors
          LdCard(
            child: LdAutoSpace(
              children: [
                const LdTextL('Scrollable Content'),
                LdTextP(
                    'Scroll down to see the app bar scroll behaviors in action:'),
                ...List.generate(
                    50, (index) => LdTextP('Content item ${index + 1}')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
