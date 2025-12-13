import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
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
  LdAppBarScrollBehavior _secondaryScrollBehavior = LdAppBarScrollBehavior.static;

  LdAppBarPositionMode _primaryAppBarPositionMode = LdAppBarPositionMode.top;
  LdAppBarPositionMode _secondaryAppBarPositionMode = LdAppBarPositionMode.bottom;

  LdAppBarShadowMode _shadowMode = LdAppBarShadowMode.whenScrolled;
  LdAppBarBorderMode _borderMode = LdAppBarBorderMode.whenScrolled;
  LdAppBarBackgroundMode _backgroundMode = LdAppBarBackgroundMode.whenScrolled;

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
          return LdText.p(suggestion.toString());
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
          return LdText.p(suggestion.toString());
        },
      );
    } else {
      _secondarySearchConfig = null;
    }
  }

  List<Widget> get _actions => [
        LdButton(
          leading: const Icon(LucideIcons.search),
          onPressed: () {
            setState(() {
              _hasPrimarySearchConfig = !_hasPrimarySearchConfig;
              _updatePrimarySearchConfig();
            });
          },
          child: const Text('Search'),
        ),
        LdButton(
          leading: const Icon(LucideIcons.settings),
          onPressed: () {
            // Show settings dialog
          },
          child: const Text('Settings'),
        ),
        LdContextMenu(
            builder: (context, isShuttle, open, isOpen, child) => LdButton(
                  leading: const Icon(LucideIcons.ellipsisVertical),
                  onPressed: () {
                    open();
                  },
                  child: const Text('More'),
                ),
            menuBuilder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LdButton.ghost(
                      width: 200,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Action 1
                      },
                      child: LdText.p('Action 1'),
                    ),
                    LdButton.ghost(
                      width: 200,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Action 2
                      },
                      child: LdText.p('Action 2'),
                    ),
                    LdButton.ghost(
                      width: 200,
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Action 3
                      },
                      child: LdText.p('Action 3'),
                    ),
                  ],
                )),
        LdButton(
          leading: const Icon(LucideIcons.bell),
          onPressed: () {
            // This will show notification
            Future.delayed(const Duration(seconds: 1));
          },
          child: const Text('Notification'),
        ),
        LdButton(
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
      appBars: [
        if (_hasPrimary)
          LdAppBar(
            positionMode: _primaryAppBarPositionMode,
            scrollBehavior: _primaryScrollBehavior,
            title: LdText.l('Primary AppBar'),
            actions: _actions,
            searchConfig: _primarySearchConfig,
            shadowMode: _shadowMode,
            borderMode: _borderMode,
            backgroundMode: _backgroundMode,
          ),
        if (_hasSecondary)
          LdAppBar(
            positionMode: _secondaryAppBarPositionMode,
            scrollBehavior: _secondaryScrollBehavior,
            title: LdText.l('Secondary AppBar'),
            actions: _actions.take(3).toList(), // Fewer actions for secondary
            searchConfig: _secondarySearchConfig,
            shadowMode: _shadowMode,
            borderMode: _borderMode,
            backgroundMode: _backgroundMode,
          ),
      ],
      primaryScrollController: _scrollController,
      body: LdScaffoldBody(
        children: [
          LdCard(
            child: LdAutoSpace(
              children: [
                LdText.l('LdAppBar Demo Controls'),
                LdText.p('Use the controls below to explore LdAppBar features:'),

                // Primary AppBar Controls
                LdText.l('Primary AppBar'),
                Row(
                  children: [
                    LdToggle(
                      checked: _hasPrimary,
                      onChanged: (value) => setState(() => _hasPrimary = value),
                    ),
                    ldHSpacerS,
                    LdText.p('Show Primary AppBar'),
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
                    LdText.p('Enable Search'),
                  ],
                ),
                LdText.p('Position:'),
                LdSwitch<LdAppBarPositionMode>(
                  value: _primaryAppBarPositionMode,
                  onChanged: (value) => setState(() => _primaryAppBarPositionMode = value),
                  children: {
                    LdAppBarPositionMode.top: LdText.p('Top'),
                    LdAppBarPositionMode.bottom: LdText.p('Bottom'),
                    LdAppBarPositionMode.adaptive: LdText.p('Adaptive'),
                  },
                ),
                LdText.p('Scroll Behavior:'),
                LdSwitch<LdAppBarScrollBehavior>(
                  value: _primaryScrollBehavior,
                  onChanged: (value) => setState(() => _primaryScrollBehavior = value),
                  children: {
                    LdAppBarScrollBehavior.static: LdText.p('Static'),
                    LdAppBarScrollBehavior.mobileOnly: LdText.p('Mobile Only'),
                    LdAppBarScrollBehavior.always: LdText.p('Always'),
                  },
                ),

                // Secondary AppBar Controls
                LdText.l('Secondary AppBar'),
                Row(
                  children: [
                    LdToggle(
                      checked: _hasSecondary,
                      onChanged: (value) => setState(() => _hasSecondary = value),
                    ),
                    ldHSpacerS,
                    LdText.p('Show Secondary AppBar'),
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
                    LdText.p('Enable Search'),
                  ],
                ),
                LdText.p('Position:'),
                LdSwitch<LdAppBarPositionMode>(
                  value: _secondaryAppBarPositionMode,
                  onChanged: (value) => setState(() => _secondaryAppBarPositionMode = value),
                  children: {
                    LdAppBarPositionMode.top: LdText.p('Top'),
                    LdAppBarPositionMode.bottom: LdText.p('Bottom'),
                    LdAppBarPositionMode.adaptive: LdText.p('Adaptive'),
                  },
                ),
                LdText.p('Scroll Behavior:'),
                LdSwitch<LdAppBarScrollBehavior>(
                  value: _secondaryScrollBehavior,
                  onChanged: (value) => setState(() => _secondaryScrollBehavior = value),
                  children: {
                    LdAppBarScrollBehavior.static: LdText.p('Static'),
                    LdAppBarScrollBehavior.mobileOnly: LdText.p('Mobile Only'),
                    LdAppBarScrollBehavior.always: LdText.p('Always'),
                  },
                ),

                // Shared Visual Controls
                LdText.l('Visual Appearance (Applied to Both AppBars)'),
                LdText.p('Shadow Mode:'),
                LdSwitch<LdAppBarShadowMode>(
                  value: _shadowMode,
                  onChanged: (value) => setState(() => _shadowMode = value),
                  children: {
                    LdAppBarShadowMode.visible: LdText.p('Visible'),
                    LdAppBarShadowMode.whenScrolled: LdText.p('When Scrolled'),
                    LdAppBarShadowMode.hidden: LdText.p('Hidden'),
                  },
                ),
                LdText.p('Border Mode:'),
                LdSwitch<LdAppBarBorderMode>(
                  value: _borderMode,
                  onChanged: (value) => setState(() => _borderMode = value),
                  children: {
                    LdAppBarBorderMode.visible: LdText.p('Visible'),
                    LdAppBarBorderMode.whenScrolled: LdText.p('When Scrolled'),
                    LdAppBarBorderMode.hidden: LdText.p('Hidden'),
                  },
                ),
                LdText.p('Background Mode:'),
                LdSwitch<LdAppBarBackgroundMode>(
                  value: _backgroundMode,
                  onChanged: (value) => setState(() => _backgroundMode = value),
                  children: {
                    LdAppBarBackgroundMode.visible: LdText.p('Visible'),
                    LdAppBarBackgroundMode.whenScrolled: LdText.p('When Scrolled'),
                    LdAppBarBackgroundMode.hidden: LdText.p('Hidden'),
                  },
                ),
              ],
            ),
          ),

          // Scrollable content to demonstrate scroll behaviors
          LdCard(
            child: LdAutoSpace(
              children: [
                LdText.l('Scrollable Content'),
                LdText.p('Scroll down to see the app bar scroll behaviors in action:'),
                ...List.generate(50, (index) => LdText.p('Content item ${index + 1}')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
