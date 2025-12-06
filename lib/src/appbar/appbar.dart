import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:liquid_flutter/src/appbar/macos_window_controls.dart';
import 'package:liquid_flutter/src/appbar/windows_window_controls.dart';
import 'package:liquid_flutter/src/drawer_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

enum LdAppBarShadowMode {
  visible,
  whenScrolled,
  hidden,
  adaptive,
}

enum LdAppBarBorderMode {
  visible,
  whenScrolled,
  hidden,
  adaptive,
}

enum LdAppBarBackgroundMode {
  visible,
  whenScrolled,
  hidden,
  adaptive,
}

class LdAppBar extends StatefulWidget {
  final Widget? title;
  final Widget? leading;
  final Widget? trailing;

  final Color? backgroundColor;
  final bool? implyLeading;
  final bool addContainer;
  final Widget? bottom;
  final LdAppBarShadowMode shadowMode;
  final LdAppBarBorderMode borderMode;
  final LdAppBarBackgroundMode backgroundMode;
  final bool showWindowControls;
  final bool implyCloseModalButton;

  final List<Widget> actions;

  static LdWindowCallbacks? callbacks;

  final List<SingleChildWidget> Function(BuildContext context)? overflowMenuProviders;

  final LdSearchConfig? searchConfig;

  final String? debugName;

  final AppBarPosition position;
  final LdAppBarScrollBehavior scrollBehavior;
  final int order;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('debugName', debugName));
    properties.add(EnumProperty<LdAppBarShadowMode>('shadowMode', shadowMode));
    properties.add(EnumProperty<LdAppBarBorderMode>('borderMode', borderMode));
    properties.add(FlagProperty('addContainer', value: addContainer, ifTrue: 'enabled'));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(IntProperty('actionsCount', actions.length));
    properties.add(DiagnosticsProperty<bool?>('implyLeading', implyLeading));
    properties.add(DiagnosticsProperty<Widget?>('title', title));
    properties.add(DiagnosticsProperty<Widget?>('leading', leading));
    properties.add(DiagnosticsProperty<Widget?>('trailing', trailing));
    properties.add(DiagnosticsProperty<Widget?>('bottom', bottom));
    properties.add(DiagnosticsProperty<LdSearchConfig?>('searchConfig', searchConfig));
  }

  const LdAppBar({
    super.key,
    this.title,
    this.actions = const [],
    this.leading,
    this.trailing,
    this.showWindowControls = true,
    this.backgroundColor,
    this.searchConfig,
    this.addContainer = false,
    this.implyCloseModalButton = true,
    this.implyLeading,
    this.bottom,
    this.shadowMode = LdAppBarShadowMode.adaptive,
    this.borderMode = LdAppBarBorderMode.adaptive,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
    this.overflowMenuProviders,
    this.debugName,
    this.position = AppBarPosition.top,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.order = 0,
  });

  const LdAppBar.top({
    super.key,
    this.title,
    this.actions = const [],
    this.leading,
    this.trailing,
    this.showWindowControls = true,
    this.backgroundColor,
    this.searchConfig,
    this.addContainer = false,
    this.implyCloseModalButton = true,
    this.implyLeading,
    this.bottom,
    this.shadowMode = LdAppBarShadowMode.adaptive,
    this.borderMode = LdAppBarBorderMode.adaptive,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
    this.overflowMenuProviders,
    this.debugName,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.order = 0,
  }) : position = AppBarPosition.top;

  const LdAppBar.bottom({
    super.key,
    this.title,
    this.actions = const [],
    this.leading,
    this.trailing,
    this.showWindowControls = true,
    this.backgroundColor,
    this.searchConfig,
    this.addContainer = false,
    this.implyCloseModalButton = true,
    this.implyLeading,
    this.bottom,
    this.shadowMode = LdAppBarShadowMode.adaptive,
    this.borderMode = LdAppBarBorderMode.adaptive,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
    this.overflowMenuProviders,
    this.debugName,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.order = 0,
  }) : position = AppBarPosition.bottom;

  // Note: adaptive constructor cannot be a factory that returns LdAppBar directly
  // as it needs BuildContext. Use LdAppBar.adaptiveWidget() instead or
  // determine position manually using LdTheme

  @override
  State<LdAppBar> createState() => _LdAppBarState();
}

class _LdAppBarState extends State<LdAppBar> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  bool get _isModal {
    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);
    return parentRoute is LdModalRoute;
  }

  Widget? get _closeModalButton {
    if (!widget.implyCloseModalButton) return null;
    if (!_isModal) return null;
    if (!_canDismissModal) return null;
    if (!_isInTopSlot) return null;

    return LdButton.ghost(
      child: const Icon(LucideIcons.x),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }

  bool get _canDismissModal {
    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);
    return parentRoute is LdModalRoute && parentRoute.barrierDismissible;
  }

  bool get _canPopParentRoute {
    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    return canPop;
  }

  LdDrawerState? get _drawerState {
    return context.watch<LdDrawerState?>();
  }

  LdDrawerSlot? get _drawerSlot {
    return context.watch<LdDrawerSlot?>();
  }

  bool get _isDrawer {
    return _drawerSlot == LdDrawerSlot.drawer;
  }

  bool get _isDrawerAppBar {
    return _isInTopSlot && _isDrawer;
  }

  bool get _isSideBySide {
    return _drawerState?.isSideBySide ?? false;
  }

  LdScaffoldState? _findDrawerParent(BuildContext context) {
    BuildContext? currentContext = context;
    while (currentContext != null) {
      final scaffoldState = currentContext.findAncestorStateOfType<LdScaffoldState>();
      if (scaffoldState == null) {
        return null;
      }
      if (scaffoldState.hasDrawer && !scaffoldState.isDrawerOpen) {
        return scaffoldState;
      }
      currentContext = scaffoldState.context;
    }
    return null;
  }

  bool get _showOpenDrawerButton {
    if (!_isInTopSlot) return false;
    if (_drawerSlot == LdDrawerSlot.drawer) return false;

    final drawerParent = _findDrawerParent(context);
    if (drawerParent == null) return false;
    // Check if this app bar is in the parent's app bars list
    // For now, we'll assume it's the primary app bar if it's top
    if (drawerParent.widget.appBars != null && drawerParent.widget.appBars!.isNotEmpty) {
      // This is a simplified check - in practice we'd need to compare widget identity
    }

    return !drawerParent.isDrawerOpen;
  }

  bool get _showWindowsWindowControls {
    // Calculate level by walking up scaffolds
    int level = 0;
    BuildContext? currentContext = context;
    while (currentContext != null) {
      final scaffoldState = currentContext.findAncestorStateOfType<LdScaffoldState>();
      if (scaffoldState == null) break;
      currentContext = scaffoldState.context;
      if (currentContext == context) break;
      level++;
    }

    return LdTheme.of(context).platform == LdPlatform.windows && _isInTopSlot && level == 0 && !_isDrawer;
  }

  bool get _showCloseDrawerButton {
    return _isDrawerAppBar && _isSideBySide;
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.leading != null) return widget.leading;
    final imply = widget.implyLeading ?? true;
    if (!imply) return null;

    if (_canPopParentRoute && !_isDrawer && !_isModal) {
      return LdButton.ghost(
        child: const Icon(LucideIcons.chevronLeft),
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    return null;
  }

  TextStyle get _headerStyle {
    final theme = LdTheme.of(context, listen: true);
    return switch (theme.themeSize) {
      (LdThemeSize.s) => ldBuildTextStyle(
          theme,
          LdTextType.label,
          LdSize.m,
          lineHeight: 1,
        ),
      (LdThemeSize.m || LdThemeSize.l) => ldBuildTextStyle(
          theme,
          LdTextType.headline,
          LdSize.s,
          lineHeight: 1,
        ),
    };
  }

  bool get _isInTopSlot {
    return widget.position == AppBarPosition.top;
  }

  bool get _isInBottomSlot {
    return widget.position == AppBarPosition.bottom;
  }

  bool _shouldShowShadow(bool isScrolledUnder) {
    final theme = LdTheme.of(context);
    return switch (widget.shadowMode) {
      LdAppBarShadowMode.visible => true,
      LdAppBarShadowMode.whenScrolled => isScrolledUnder,
      LdAppBarShadowMode.hidden => false,
      LdAppBarShadowMode.adaptive => switch (theme.platform.isDesktop) {
          false => isScrolledUnder,
          true => true,
        },
    };
  }

  bool _shouldShowBorder(bool isScrolledUnder) {
    final theme = LdTheme.of(context);
    return switch (widget.borderMode) {
      LdAppBarBorderMode.visible => true,
      LdAppBarBorderMode.whenScrolled => isScrolledUnder,
      LdAppBarBorderMode.hidden => false,
      LdAppBarBorderMode.adaptive => switch (theme.platform.isDesktop) {
          false => isScrolledUnder,
          true => true,
        },
    };
  }

  /// Wraps the app bar in a container that applies the correct padding to make sure
  /// the app bar is not covered by the system UI or parent app bars.
  BoxDecoration _buildOutsideDecoration(BuildContext context, bool isScrolledUnder) {
    return BoxDecoration(
      color: _isInTopSlot ? _fillColor(isScrolledUnder) : null,
      gradient: !_isInTopSlot
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.3],
              colors: [
                LdTheme.of(context).absolute.withAlpha(0),
                LdTheme.of(context).absolute.withAlpha(200),
              ],
            )
          : null,
      boxShadow: [
        if (_isInTopSlot)
          ldShadowSticky.copyWith(
            color: _shouldShowShadow(isScrolledUnder)
                ? ldShadowSticky.color.withAlpha(isScrolledUnder ? 50 : 0)
                : Colors.transparent,
          ),
      ],
      border: _isInTopSlot
          ? Border(
              bottom: BorderSide(
                color: _shouldShowBorder(isScrolledUnder) ? LdTheme.of(context).border : Colors.transparent,
                width: LdTheme.of(context).borderWidth,
              ),
            )
          : null,
    );
  }

  int _fillOpacity(bool isScrolledUnder) {
    int opacity = 0;

    if (isScrolledUnder || _isInBottomSlot) {
      opacity = 255;
    }

    return opacity;
  }

  Color _fillColor(bool isScrolledUnder) {
    final theme = LdTheme.of(context);
    final color = widget.backgroundColor ?? LdTheme.of(context).surface;

    return switch (widget.backgroundMode) {
      LdAppBarBackgroundMode.hidden => Colors.transparent,
      LdAppBarBackgroundMode.visible => color,
      LdAppBarBackgroundMode.whenScrolled => Color.alphaBlend(
          color.withAlpha(_fillOpacity(isScrolledUnder)),
          LdTheme.of(context).background,
        ),
      LdAppBarBackgroundMode.adaptive => switch (theme.platform.isDesktop) {
          false => Color.alphaBlend(
              color.withAlpha(_fillOpacity(isScrolledUnder)),
              LdTheme.of(context).background,
            ),
          true => color,
        },
    };
  }

  double _borderRadius(BuildContext context) {
    final theme = LdTheme.of(context);
    // Secondary app bars (bottom navigation) typically don't have radius when at top
    // This logic might need adjustment based on actual usage
    final radius = theme.radiusSize(LdSize.m);
    return radius;
  }

  bool get _hasTopContent {
    return widget.title != null || widget.actions.isNotEmpty || widget.searchConfig != null;
  }

  BoxDecoration _buildInsideDecoration(BuildContext context, bool isScrolledUnder) {
    if (_isInTopSlot) {
      return const BoxDecoration();
    }

    return BoxDecoration(
      borderRadius: BorderRadius.circular(_borderRadius(context)),
      color: _fillColor(isScrolledUnder),
      boxShadow: [
        ldShadowSticky.copyWith(
          color: _shouldShowShadow(isScrolledUnder) ? ldShadowSticky.color : Colors.transparent,
        ),
      ],
      border: Border.all(
        color: LdTheme.of(context).floatingBorder,
        width: LdTheme.of(context).borderWidth,
      ),
    );
  }

  SystemUiOverlayStyle get _systemUiOverlayStyle {
    final theme = LdTheme.of(context, listen: true);
    if (theme.isDark) {
      return SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: theme.background.withAlpha(150),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      );
    }
    return SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: theme.background.withAlpha(150),
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdAppBarRegistryEntry(
      debugName: widget.debugName,
      order: widget.order,
      child: Builder(
        builder: (context) {
          final leading = _buildLeading(context);
          final appBarKey = context.appBarRegistryKey();

          return LdAppBarScrollWrapper(
            position: widget.position,
            scrollBehavior: widget.scrollBehavior,
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: _systemUiOverlayStyle,
              child: LdWrapConditional(
                condition: _isInTopSlot && !_isModal,
                builder: (context, child) => GestureDetector(
                  onPanStart: (details) {
                    LdAppBar.callbacks?.onMove?.call();
                  },
                  onDoubleTap: () {
                    LdScaffoldState.maybeOf(context)?.scrollToTop();
                  },
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey('appbar_${appBarKey.order}'),
                  child: ScrolledUnderBuilder(builder: (context, isScrolledUnder) {
                    return AppBarFrame(
                      debugName: widget.debugName,
                      position: widget.position,
                      insetBorderRadius: !_isModal,
                      attached: _isInTopSlot,
                      insideDecoration: _buildInsideDecoration(context, isScrolledUnder),
                      outsideDecoration: _buildOutsideDecoration(context, isScrolledUnder),
                      child: LdButtonConfigProvider(
                        const LdButtonConfig(
                          mode: LdButtonMode.ghost,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LayoutBuilder(builder: (context, constraints) {
                              final hasSearch = widget.searchConfig != null;

                              return Row(
                                children: [
                                  if (widget.showWindowControls && !_isModal) const MacOSWindowControls(),
                                  OpenDrawerButton(drawerParent: _findDrawerParent(context)),
                                  if (leading != null) ...[leading, ldSpacerM],
                                  if (widget.title != null || widget.actions.isNotEmpty || hasSearch)
                                    Expanded(
                                        child: LdOverflowView(
                                      spacing: LdTheme.of(context).paddingSize(size: LdSize.xs),
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          widget.title == null ? MainAxisAlignment.start : MainAxisAlignment.center,
                                      builder: (context, remainingItemCount) {
                                        if (remainingItemCount > widget.actions.length) {
                                          // Todo: not even the title fits.
                                          return const SizedBox();
                                        }
                                        return LdAppbarActionOverflowMenu(
                                          actions: widget.actions.sublist(widget.actions.length - remainingItemCount),
                                          menuProviders: widget.overflowMenuProviders,
                                          inMenu: true,
                                        );
                                      },
                                      children: [
                                        if (widget.title != null)
                                          LdFlexibleChild(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: DefaultTextStyle(
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: _headerStyle,
                                                child: widget.title ?? const SizedBox(),
                                              ),
                                            ),
                                          ),
                                        if (hasSearch)
                                          LdFlexibleChild(
                                            child: LdSearchInput(
                                              searchConfig: widget.searchConfig!,
                                              isBottomNavigationBar: _isInBottomSlot,
                                              fullWidth: false,
                                            ),
                                          ),
                                        ...widget.actions
                                      ],
                                    ))
                                  else
                                    const SizedBox.shrink(),
                                  const CloseDrawerButton(),
                                  if (widget.trailing != null) widget.trailing!,
                                  if (_closeModalButton != null) ...[_closeModalButton!],
                                  if (widget.showWindowControls && !_isModal)
                                    LdReveal(
                                        revealed: _showWindowsWindowControls, child: const WindowsWindowControls()),
                                ],
                              );
                            }),
                            if (widget.bottom != null) ...[
                              LdWrapConditional(
                                condition: _hasTopContent,
                                builder: (context, child) => Padding(
                                  padding: EdgeInsets.only(
                                    top: LdTheme.of(context).pad(size: LdSize.s).top,
                                  ),
                                  child: child,
                                ),
                                child: widget.bottom!,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

extension AtLeastBorderRadius on BorderRadius {
  BorderRadius atLeast(BorderRadius other) {
    return BorderRadius.only(
      topLeft: topLeft.atLeast(other.topLeft),
      topRight: topRight.atLeast(other.topRight),
      bottomLeft: bottomLeft.atLeast(other.bottomLeft),
      bottomRight: bottomRight.atLeast(other.bottomRight),
    );
  }
}

extension AtLeast on Radius {
  Radius atLeast(Radius other) {
    assert(x == y, "Radius must be circular");
    assert(other.x == other.y, "Other radius must be circular");
    return Radius.circular(max(x, other.x));
  }
}

extension TrimToAppBarPosition on EdgeInsets {
  EdgeInsets trimToAppBarPosition(AppBarPosition position) {
    return copyWith(
      top: position == AppBarPosition.top ? top : 0,
      bottom: position == AppBarPosition.bottom ? bottom : 0,
    );
  }
}

class ScrolledUnderBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isScrolledUnder) builder;

  const ScrolledUnderBuilder({super.key, required this.builder});

  @override
  State<ScrolledUnderBuilder> createState() => _ScrolledUnderBuilderState();
}

class _ScrolledUnderBuilderState extends State<ScrolledUnderBuilder> {
  bool _isScrolledUnder = false;

  AppBarRegistryState? _registry;
  late final appBarKey = context.maybeAppBarRegistryKey()!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRegistry = AppBarRegistry.maybeStateOf(context);
    if (_registry != newRegistry) {
      _registry?.removeListener(_onRegistryChange);
      _registry = newRegistry;
      _registry?.addListener(_onRegistryChange);
      _onRegistryChange();
    }
  }

  @override
  void dispose() {
    _registry?.removeListener(_onRegistryChange);
    super.dispose();
  }

  void _onRegistryChange() {
    if (!mounted) return;
    if (_registry == null) return;
    final currentInfo = _registry!.getAppBarInfo(appBarKey);
    if (currentInfo == null) return;
    final isScrolledUnder = currentInfo.scrollUnder;
    if (isScrolledUnder != _isScrolledUnder) {
      setState(() {
        _isScrolledUnder = isScrolledUnder;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isScrolledUnder);
  }
}
