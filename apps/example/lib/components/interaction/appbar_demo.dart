import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// iPhone-style safe area used when mock system UI is enabled.
const _kMockViewPadding = EdgeInsets.only(top: 44, bottom: 34);

/// Typical on-screen keyboard height used when mock keyboard is enabled.
const _kMockKeyboardInset = 300.0;

/// Interactive demo for [LdAppBarWidget]: add, remove, and configure app bars.
class AppBarDemo extends StatefulWidget {
  const AppBarDemo({super.key});

  @override
  State<AppBarDemo> createState() => _AppBarDemoState();
}

class _AppBarDemoConfig {
  const _AppBarDemoConfig({
    required this.id,
    this.title = 'App Bar',
    this.debugName = 'App Bar',
    this.positionMode = LdAppBarPositionMode.top,
    this.scrollBehavior = LdAppBarScrollBehavior.mobileOnly,
    this.shadowMode = LdAppBarShadowMode.adaptive,
    this.borderMode = LdAppBarBorderMode.adaptive,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
    this.attachedMode = LdAppBarAttachedMode.adaptive,
    this.addContainer = false,
    this.implyFeatures = const {
      LdAppBarImpliedFeature.back,
      LdAppBarImpliedFeature.close,
      LdAppBarImpliedFeature.windowControls,
      LdAppBarImpliedFeature.drawerToggle,
    },
    this.autoAttachToKeyboard = true,
    this.avoidViewInsets = false,
    this.enableSearch = false,
    this.actionCount = 3,
  });

  final int id;
  final String title;
  final String debugName;
  final LdAppBarPositionMode positionMode;
  final LdAppBarScrollBehavior scrollBehavior;
  final LdAppBarShadowMode shadowMode;
  final LdAppBarBorderMode borderMode;
  final LdAppBarBackgroundMode backgroundMode;
  final LdAppBarAttachedMode attachedMode;
  final bool addContainer;
  final Set<LdAppBarImpliedFeature> implyFeatures;

  final bool autoAttachToKeyboard;
  final bool avoidViewInsets;
  final bool enableSearch;
  final int actionCount;

  String get summary {
    final parts = <String>[
      '.${positionMode.name}',
      '.${scrollBehavior.name}',
      '.${attachedMode.name}',
      '$actionCount actions',
      if (enableSearch) 'search',
    ];
    return parts.join(' · ');
  }

  _AppBarDemoConfig copyWith({
    String? title,
    String? debugName,
    LdAppBarPositionMode? positionMode,
    LdAppBarScrollBehavior? scrollBehavior,
    LdAppBarShadowMode? shadowMode,
    LdAppBarBorderMode? borderMode,
    LdAppBarBackgroundMode? backgroundMode,
    LdAppBarAttachedMode? attachedMode,
    bool? addContainer,
    Set<LdAppBarImpliedFeature>? implyFeatures,

    bool? autoAttachToKeyboard,
    bool? avoidViewInsets,
    bool? enableSearch,
    int? actionCount,
  }) {
    return _AppBarDemoConfig(
      id: id,
      title: title ?? this.title,
      debugName: debugName ?? this.debugName,
      positionMode: positionMode ?? this.positionMode,
      scrollBehavior: scrollBehavior ?? this.scrollBehavior,
      shadowMode: shadowMode ?? this.shadowMode,
      borderMode: borderMode ?? this.borderMode,
      backgroundMode: backgroundMode ?? this.backgroundMode,
      attachedMode: attachedMode ?? this.attachedMode,
      addContainer: addContainer ?? this.addContainer,
      implyFeatures: implyFeatures ?? this.implyFeatures,

      autoAttachToKeyboard: autoAttachToKeyboard ?? this.autoAttachToKeyboard,
      avoidViewInsets: avoidViewInsets ?? this.avoidViewInsets,
      enableSearch: enableSearch ?? this.enableSearch,
      actionCount: actionCount ?? this.actionCount,
    );
  }

  LdSearchConfig? buildSearchConfig() {
    if (!enableSearch) return null;
    return LdSearchConfig(
      onSearch: (_) {},
      getSuggestions: (query) async {
        return [
          '$title suggestion 1',
          '$title suggestion 2',
          '$title suggestion 3',
        ].where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
      },
      buildSuggestion: (context, suggestion) {
        return LdListItem(title: Text(suggestion.toString()));
      },
    );
  }

  Widget wrap(Widget child, List<Widget> demoActions) {
    return LdAppBar(
      positionMode: positionMode,
      scrollBehavior: scrollBehavior,
      title: Text(title),
      actions: demoActions.take(actionCount).toList(),
      searchConfig: buildSearchConfig(),
      debugName: debugName,
      shadowMode: shadowMode,
      borderMode: borderMode,
      backgroundMode: backgroundMode,
      attachedMode: attachedMode,

      addContainer: addContainer,
      implyFeatures: implyFeatures,
      autoAttachToKeyboard: autoAttachToKeyboard,
      avoidViewInsets: avoidViewInsets,
      child: child,
    );
  }
}

class _AppBarConfigModal extends StatefulWidget {
  const _AppBarConfigModal({
    required this.config,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  final _AppBarDemoConfig config;
  final int index;
  final ValueChanged<_AppBarDemoConfig> onChanged;
  final VoidCallback onDelete;

  @override
  State<_AppBarConfigModal> createState() => _AppBarConfigModalState();
}

class _AppBarConfigModalState extends State<_AppBarConfigModal> {
  late _AppBarDemoConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  void _update(_AppBarDemoConfig Function(_AppBarDemoConfig) fn) {
    setState(() {
      _config = fn(_config);
    });
    widget.onChanged(_config);
  }

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      body: LdAppBar.top(
        title: Text('App Bar ${widget.index + 1}'),
        child: LdScaffoldBody(
          children: [
            LdInput(
              key: ValueKey('title-${_config.id}'),
              label: 'Title',
              hint: _config.title,
              onChanged: (value) => _update((c) => c.copyWith(title: value)),
            ),
            LdInput(
              key: ValueKey('debug-${_config.id}'),
              label: 'Debug name',
              hint: _config.debugName,
              onChanged: (value) => _update((c) => c.copyWith(debugName: value)),
            ),
            LdSwitch<LdAppBarPositionMode>(
              label: 'Position',
              value: _config.positionMode,
              onChanged: (value) => _update((c) => c.copyWith(positionMode: value)),
              children: {
                LdAppBarPositionMode.top: const Text('.top'),
                LdAppBarPositionMode.bottom: const Text('.bottom'),
                LdAppBarPositionMode.adaptive: const Text('.adaptive'),
              },
            ),
            LdSwitch<LdAppBarScrollBehavior>(
              label: 'Scroll behavior',
              value: _config.scrollBehavior,
              onChanged: (value) => _update((c) => c.copyWith(scrollBehavior: value)),
              children: {
                LdAppBarScrollBehavior.static: const Text('.static'),
                LdAppBarScrollBehavior.mobileOnly: const Text('.mobileOnly'),
                LdAppBarScrollBehavior.always: const Text('.always'),
                LdAppBarScrollBehavior.hidden: const Text('.hidden'),
              },
            ),
            LdSwitch<LdAppBarAttachedMode>(
              label: 'Attached mode',
              value: _config.attachedMode,
              onChanged: (value) => _update((c) => c.copyWith(attachedMode: value)),
              children: {
                LdAppBarAttachedMode.attached: const Text('.attached'),
                LdAppBarAttachedMode.adaptive: const Text('.adaptive'),
                LdAppBarAttachedMode.floating: const Text('.floating'),
              },
            ),
            LdSwitch<LdAppBarShadowMode>(
              label: 'Shadow mode',
              value: _config.shadowMode,
              onChanged: (value) => _update((c) => c.copyWith(shadowMode: value)),
              children: {
                LdAppBarShadowMode.visible: const Text('.visible'),
                LdAppBarShadowMode.whenScrolled: const Text('.whenScrolled'),
                LdAppBarShadowMode.hidden: const Text('.hidden'),
                LdAppBarShadowMode.adaptive: const Text('.adaptive'),
              },
            ),
            LdSwitch<LdAppBarBorderMode>(
              label: 'Border mode',
              value: _config.borderMode,
              onChanged: (value) => _update((c) => c.copyWith(borderMode: value)),
              children: {
                LdAppBarBorderMode.visible: const Text('.visible'),
                LdAppBarBorderMode.whenScrolled: const Text('.whenScrolled'),
                LdAppBarBorderMode.hidden: const Text('.hidden'),
                LdAppBarBorderMode.adaptive: const Text('.adaptive'),
              },
            ),
            LdSwitch<LdAppBarBackgroundMode>(
              label: 'Background mode',
              value: _config.backgroundMode,
              onChanged: (value) => _update((c) => c.copyWith(backgroundMode: value)),
              children: {
                LdAppBarBackgroundMode.visible: const Text('.visible'),
                LdAppBarBackgroundMode.whenScrolled: const Text('.whenScrolled'),
                LdAppBarBackgroundMode.hidden: const Text('.hidden'),
                LdAppBarBackgroundMode.adaptive: const Text('.adaptive'),
              },
            ),
            LdSwitch<int>(
              label: 'Action count',
              value: _config.actionCount,
              onChanged: (value) => _update((c) => c.copyWith(actionCount: value)),
              children: {
                0: const Text('0'),
                1: const Text('1'),
                2: const Text('2'),
                3: const Text('3'),
                4: const Text('4'),
              },
            ),
            LdToggle(
              label: 'Enable search',
              checked: _config.enableSearch,
              onChanged: (value) => _update((c) => c.copyWith(enableSearch: value)),
            ),
            LdToggle(
              label: 'Add container padding',
              checked: _config.addContainer,
              onChanged: (value) => _update((c) => c.copyWith(addContainer: value)),
            ),
            LdChoose.fromSelectItems(
              multiple: true,
              label: 'Implied features',
              items: LdAppBarImpliedFeature.values.map((e) => LdSelectItem(value: e, child: Text(e.name))).toList(),
              onChanged: (value) => _update((c) => c.copyWith(implyFeatures: value)),
              value: _config.implyFeatures,
            ),
            LdToggle(
              label: 'Auto attach to keyboard',
              checked: _config.autoAttachToKeyboard,
              onChanged: (value) => _update((c) => c.copyWith(autoAttachToKeyboard: value)),
            ),
            LdToggle(
              label: 'Avoid view insets',
              checked: _config.avoidViewInsets,
              onChanged: (value) => _update((c) => c.copyWith(avoidViewInsets: value)),
            ),
            LdButton.error(child: const Text('Remove app bar'), onPressed: widget.onDelete),
          ],
        ),
      ),
    );
  }
}

class _TabNavConfigModal extends StatefulWidget {
  const _TabNavConfigModal({
    required this.showTabNavigation,
    required this.attachedMode,
    required this.backgroundMode,
    required this.position,
    required this.scrollBehavior,
    required this.onChanged,
  });

  final bool showTabNavigation;
  final LdAppBarAttachedMode attachedMode;
  final LdAppBarBackgroundMode backgroundMode;
  final LdAppBarPositionMode position;
  final LdAppBarScrollBehavior scrollBehavior;
  final void Function({
    required bool showTabNavigation,
    required LdAppBarAttachedMode attachedMode,
    required LdAppBarBackgroundMode backgroundMode,
    required LdAppBarPositionMode position,
    required LdAppBarScrollBehavior scrollBehavior,
  })
  onChanged;

  @override
  State<_TabNavConfigModal> createState() => _TabNavConfigModalState();
}

class _TabNavConfigModalState extends State<_TabNavConfigModal> {
  late bool _showTabNavigation;
  late LdAppBarAttachedMode _attachedMode;
  late LdAppBarBackgroundMode _backgroundMode;
  late LdAppBarPositionMode _position;
  late LdAppBarScrollBehavior _scrollBehavior;

  @override
  void initState() {
    super.initState();
    _showTabNavigation = widget.showTabNavigation;
    _attachedMode = widget.attachedMode;
    _backgroundMode = widget.backgroundMode;
    _position = widget.position;
    _scrollBehavior = widget.scrollBehavior;
  }

  void _notify() {
    widget.onChanged(
      showTabNavigation: _showTabNavigation,
      attachedMode: _attachedMode,
      backgroundMode: _backgroundMode,
      position: _position,
      scrollBehavior: _scrollBehavior,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      body: LdAppBar.top(
        title: const Text('Tab navigation'),
        child: LdScaffoldBody(
          children: [
            LdAutoSpace(
              children: [
                LdToggle(
                  label: 'Show tab navigation',
                  checked: _showTabNavigation,
                  onChanged: (value) {
                    setState(() => _showTabNavigation = value);
                    _notify();
                  },
                ),
                LdSwitch<LdAppBarAttachedMode>(
                  value: _attachedMode,
                  label: 'Attached mode',
                  onChanged: (value) {
                    setState(() => _attachedMode = value);
                    _notify();
                  },
                  children: {
                    LdAppBarAttachedMode.attached: const Text('.attached'),
                    LdAppBarAttachedMode.adaptive: const Text('.adaptive'),
                    LdAppBarAttachedMode.floating: const Text('.floating'),
                  },
                ),
                LdSwitch<LdAppBarBackgroundMode>(
                  value: _backgroundMode,
                  label: 'Background mode',
                  onChanged: (value) {
                    setState(() => _backgroundMode = value);
                    _notify();
                  },
                  children: {
                    LdAppBarBackgroundMode.visible: const Text('.visible'),
                    LdAppBarBackgroundMode.whenScrolled: const Text('.whenScrolled'),
                    LdAppBarBackgroundMode.hidden: const Text('.hidden'),
                    LdAppBarBackgroundMode.adaptive: const Text('.adaptive'),
                  },
                ),
                LdSwitch<LdAppBarPositionMode>(
                  value: _position,
                  label: 'Position',
                  onChanged: (value) {
                    setState(() => _position = value);
                    _notify();
                  },
                  children: {
                    LdAppBarPositionMode.top: const Text('.top'),
                    LdAppBarPositionMode.bottom: const Text('.bottom'),
                    LdAppBarPositionMode.adaptive: const Text('.adaptive'),
                  },
                ),
                LdSwitch<LdAppBarScrollBehavior>(
                  value: _scrollBehavior,
                  label: 'Scroll behavior',
                  onChanged: (value) {
                    setState(() => _scrollBehavior = value);
                    _notify();
                  },
                  children: {
                    LdAppBarScrollBehavior.static: const Text('.static'),
                    LdAppBarScrollBehavior.mobileOnly: const Text('.mobileOnly'),
                    LdAppBarScrollBehavior.always: const Text('.always'),
                    LdAppBarScrollBehavior.hidden: const Text('.hidden'),
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarDemoState extends State<AppBarDemo> {
  int _nextAppBarId = 3;

  List<_AppBarDemoConfig> _appBars = const [
    _AppBarDemoConfig(id: 1, title: 'Primary AppBar', debugName: 'Primary AppBar', actionCount: 4),
    _AppBarDemoConfig(id: 2, title: 'Secondary AppBar', debugName: 'Secondary AppBar', actionCount: 3),
  ];

  String _activeTabRoute = '/home';
  bool _showTabNavigation = false;
  bool _showRawAppBar = true;
  LdRawAppBarLayout _rawAppBarLayout = LdRawAppBarLayout.expand;
  bool _rawAppBarDecorate = true;
  bool _mockSafeArea = false;
  bool _mockKeyboard = false;
  LdAppBarAttachedMode _tabAttachedMode = LdAppBarAttachedMode.adaptive;
  LdAppBarBackgroundMode _tabBackgroundMode = LdAppBarBackgroundMode.adaptive;
  LdAppBarPositionMode _tabPosition = LdAppBarPositionMode.adaptive;
  LdAppBarScrollBehavior _tabScrollBehavior = LdAppBarScrollBehavior.static;

  final ScrollController _scrollController = ScrollController();

  String get _tabNavSummary {
    if (!_showTabNavigation) return 'Disabled';
    return '.${_tabPosition.name} · .${_tabScrollBehavior.name} · .${_tabAttachedMode.name}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateAppBar(int id, _AppBarDemoConfig updated) {
    setState(() {
      final index = _appBars.indexWhere((bar) => bar.id == id);
      if (index == -1) return;
      _appBars = [..._appBars.sublist(0, index), updated, ..._appBars.sublist(index + 1)];
    });
  }

  void _addAppBar() {
    setState(() {
      final id = _nextAppBarId++;
      _appBars = [..._appBars, _AppBarDemoConfig(id: id, title: 'App Bar $id', debugName: 'App Bar $id')];
    });
  }

  void _removeAppBar(int id) {
    setState(() {
      _appBars = _appBars.where((bar) => bar.id != id).toList();
    });
  }

  Future<void> _openAppBarConfig(_AppBarDemoConfig config, int index) async {
    await Navigator.of(context, rootNavigator: true).push(
      LdModalRoute(
        context: context,
        pageBuilder: (modalContext) => _AppBarConfigModal(
          config: config,
          index: index,
          onChanged: (updated) => _updateAppBar(config.id, updated),
          onDelete: () {
            _removeAppBar(config.id);
            Navigator.of(modalContext).pop();
          },
        ),
      ),
    );
  }

  Future<void> _openTabNavConfig() async {
    await Navigator.of(context, rootNavigator: true).push(
      LdModalRoute(
        context: context,
        pageBuilder: (modalContext) => _TabNavConfigModal(
          showTabNavigation: _showTabNavigation,
          attachedMode: _tabAttachedMode,
          backgroundMode: _tabBackgroundMode,
          position: _tabPosition,
          scrollBehavior: _tabScrollBehavior,
          onChanged:
              ({
                required showTabNavigation,
                required attachedMode,
                required backgroundMode,
                required position,
                required scrollBehavior,
              }) {
                setState(() {
                  _showTabNavigation = showTabNavigation;
                  _tabAttachedMode = attachedMode;
                  _tabBackgroundMode = backgroundMode;
                  _tabPosition = position;
                  _tabScrollBehavior = scrollBehavior;
                });
              },
        ),
      ),
    );
  }

  List<Widget> get _demoActions => [
    LdAppBarAction(leading: const Icon(LucideIcons.settings), onPressed: () {}, child: const Text('Settings')),
    LdContextMenu(
      builder: (context, isShuttle, open, isOpen, child) =>
          LdAppBarAction(leading: const Icon(LucideIcons.expand), onPressed: open, child: const Text('Options')),
      menuBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LdListItem(width: 200, onPressed: () => Navigator.of(context).pop(), title: LdText.p('Action 1')),
          LdListItem(width: 200, onPressed: () => Navigator.of(context).pop(), title: LdText.p('Action 2')),
          LdListItem(width: 200, onPressed: () => Navigator.of(context).pop(), title: LdText.p('Action 3')),
        ],
      ),
    ),
    LdAppBarAction(leading: const Icon(LucideIcons.bell), onPressed: () {}, child: const Text('Notification')),
    LdAppBarAction(leading: const Icon(LucideIcons.trash2), onPressed: () {}, child: const Text('Delete')),
  ];

  Widget _wrapWithAppBars(Widget body) {
    var wrapped = body;
    for (final config in _appBars.reversed) {
      wrapped = config.wrap(wrapped, _demoActions);
    }
    return wrapped;
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldContent = LdScaffoldBody(
      addContainer: true,
      children: [
        LdText.h('LdAppBar Demo'),
        LdButton.outline(
          alignment: MainAxisAlignment.spaceBetween,
          trailing: const Icon(LucideIcons.x),
          size: LdSize.l,
          width: double.infinity,
          child: const Text('Leave demo'),
          onPressed: () => context.go('/'),
        ),
        LdAutoSpace(
          children: [
            LdText.p(
              'Tap an app bar below to configure it. App bars nest in list order — the first entry wraps all others.',
            ),
            LdText.p(
              'Changes apply live while the config modal is open. Actions that do not fit overflow into a context menu.',
            ),
          ],
        ),
        LdDivider(),
        Row(
          children: [
            Expanded(child: LdText.caption('App bars (${_appBars.length})')),
            LdButton.filled(
              leading: const Icon(LucideIcons.plus),
              onPressed: _addAppBar,
              child: const Text('Add app bar'),
            ),
          ],
        ),
        if (_appBars.isEmpty)
          LdText.p('No app bars configured. Add one to get started.')
        else
          LdCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ...List.generate(_appBars.length, (index) {
                  final config = _appBars[index];
                  return LdListItem.trailingForward(
                    title: Text(config.title),
                    subtitle: LdText.l(config.summary),
                    onPressed: () => _openAppBarConfig(config, index),
                  );
                }),
              ],
            ),
          ),
        LdText.caption('Tab navigation'),
        LdCard(
          padding: EdgeInsets.zero,
          child: LdListItem.trailingForward(
            title: const Text('Tab navigation'),
            subtitle: LdText.l(_tabNavSummary),
            onPressed: _openTabNavConfig,
          ),
        ),
        LdText.caption('Raw app bar'),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdToggle(
                label: 'Show LdRawAppBar.bottom (chips + leading/trailing)',
                checked: _showRawAppBar,
                onChanged: (value) => setState(() => _showRawAppBar = value),
              ),
              if (_showRawAppBar)
                LdSwitch<LdRawAppBarLayout>(
                  label: 'Layout',
                  value: _rawAppBarLayout,
                  onChanged: (value) => setState(() => _rawAppBarLayout = value),
                  children: const {
                    LdRawAppBarLayout.expand: Text('.expand'),
                    LdRawAppBarLayout.center: Text('.center'),
                  },
                ),
              if (_showRawAppBar)
                LdToggle(
                  label: 'Inside / outside decoration',
                  checked: _rawAppBarDecorate,
                  onChanged: (value) => setState(() => _rawAppBarDecorate = value),
                ),
            ],
          ),
        ),
        LdText.caption('System simulation'),
        LdCard(
          child: LdAutoSpace(
            children: [
              LdText.p(
                'Override [MediaQuery] to simulate device safe areas and an on-screen keyboard. '
                'Colored overlays mark the mocked regions.',
              ),
              LdToggle(
                label: 'Mock safe area (viewPadding top 44, bottom 34)',
                checked: _mockSafeArea,
                onChanged: (value) => setState(() => _mockSafeArea = value),
              ),
              LdToggle(
                label: 'Mock keyboard (viewInsets bottom 300)',
                checked: _mockKeyboard,
                onChanged: (value) => setState(() => _mockKeyboard = value),
              ),
              LdInput(label: 'Focus to test keyboard attachment', hint: 'Tap to focus'),
            ],
          ),
        ),
        SizedBox(height: 1000, child: LdText.p('Scrollable content')),
        LdText.p('End'),
      ],
    );

    Widget body = scaffoldContent;

    if (_showRawAppBar) {
      final content = switch (_rawAppBarLayout) {
        LdRawAppBarLayout.expand => LdHorizontalScroll(
          layout: LdHorizontalScrollLayout.scroll,
          children: const [
            LdTag(child: Text('Inbox')),
            LdTag(child: Text('Starred')),
            LdTag(child: Text('Sent')),
            LdTag(child: Text('Drafts')),
            LdTag(child: Text('Archive')),
            LdTag(child: Text('Spam')),
          ],
        ),
        LdRawAppBarLayout.center => Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            LdTag(child: Text('Inbox')),
            LdTag(child: Text('Starred')),
          ],
        ).spaceS(),
      };

      final theme = LdTheme.of(context);
      body = LdRawAppBar.bottom(
        layout: _rawAppBarLayout,
        leading: LdButton.outline(onPressed: () {}, child: const Icon(LucideIcons.plus)),
        trailing: LdButton.filled(onPressed: () {}, child: const Icon(LucideIcons.arrowUp)),
        content: Container(
          padding: theme.pad(size: LdSize.m),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: theme.radius(LdSize.l),
            border: Border.all(color: theme.floatingBorder, width: theme.borderWidth),
          ),
          child: content,
        ),

        floating: false,
        outsideDecoration: _rawAppBarDecorate
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.surface.withAlpha(0), theme.surface.withAlpha(255)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              )
            : null,

        child: body,
      );
    }

    if (_showTabNavigation) {
      body = LdTabNavigation(
        activeRoute: _activeTabRoute,
        onTabPressed: (route) => setState(() => _activeTabRoute = route),
        tabs: const [
          LdNavigationTab(label: 'Home', icon: Icon(LucideIcons.house), route: '/home'),
          LdNavigationTab(label: 'Search', icon: Icon(LucideIcons.search), route: '/search'),
          LdNavigationTab(label: 'Settings', icon: Icon(LucideIcons.settings), route: '/settings'),
          LdNavigationTab(label: 'Profile', icon: Icon(LucideIcons.user), route: '/profile'),
          LdNavigationTab(label: 'Notifications', icon: Icon(LucideIcons.bell), route: '/notifications'),
        ],
        attachedMode: _tabAttachedMode,
        backgroundMode: _tabBackgroundMode,
        position: _tabPosition,
        scrollBehavior: _tabScrollBehavior,
        child: body,
      );
    }

    body = _wrapWithAppBars(body);

    return _MockSystemUiScope(
      mockSafeArea: _mockSafeArea,
      mockKeyboard: _mockKeyboard,
      child: LdScaffold(
        drawer: LdScaffold(
          body: LdAppBar(
            title: const Text('Drawer'),
            child: const LdScaffoldBodyCentered(child: Text('Drawer')),
          ),
        ),
        primaryScrollController: _scrollController,
        body: body,
      ),
    );
  }
}

class _MockSystemUiScope extends StatelessWidget {
  const _MockSystemUiScope({required this.mockSafeArea, required this.mockKeyboard, required this.child});

  final bool mockSafeArea;
  final bool mockKeyboard;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!mockSafeArea && !mockKeyboard) {
      return child;
    }

    final theme = LdTheme.of(context);
    final base = MediaQuery.of(context);
    final viewPadding = mockSafeArea ? _kMockViewPadding : base.viewPadding;
    final viewInsets = mockKeyboard ? const EdgeInsets.only(bottom: _kMockKeyboardInset) : base.viewInsets;
    final padding = viewPadding.subtract(viewInsets).resolve(Directionality.of(context));

    return MediaQuery(
      data: base.copyWith(viewPadding: viewPadding, viewInsets: viewInsets, padding: padding),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (mockSafeArea && viewPadding.top > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: viewPadding.top,
              child: _MockSystemUiOverlay(
                label: 'viewPadding.top ${viewPadding.top.toStringAsFixed(0)}',
                color: theme.primaryColor.withValues(alpha: 0.18),
              ),
            ),
          if (mockSafeArea && viewPadding.bottom > 0)
            Positioned(
              bottom: viewInsets.bottom,
              left: 0,
              right: 0,
              height: viewPadding.bottom,
              child: _MockSystemUiOverlay(
                label: 'viewPadding.bottom ${viewPadding.bottom.toStringAsFixed(0)}',
                color: theme.primaryColor.withValues(alpha: 0.18),
              ),
            ),
          if (mockKeyboard && viewInsets.bottom > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: viewInsets.bottom,
              child: _MockSystemUiOverlay(
                label: 'viewInsets.bottom ${viewInsets.bottom.toStringAsFixed(0)}',
                color: theme.warningColor.withValues(alpha: 0.22),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _MockSystemUiOverlay extends StatelessWidget {
  const _MockSystemUiOverlay({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return IgnorePointer(
      child: ColoredBox(
        color: color,
        child: Center(child: LdText.caption(label, color: theme.textMuted)),
      ),
    );
  }
}
