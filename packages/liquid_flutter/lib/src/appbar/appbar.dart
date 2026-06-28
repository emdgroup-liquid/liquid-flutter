import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_decoration.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:liquid_flutter/src/appbar/macos_window_controls.dart';
import 'package:liquid_flutter/src/appbar/windows_window_controls.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

part 'appbar.variants.g.dart';

class LdAppBarParentShowsImpliedLeading {
  const LdAppBarParentShowsImpliedLeading(this.value);

  final bool value;
}

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

enum LdAppBarPositionMode {
  top,
  bottom,

  /// Will move to the bottom slot on mobile.
  adaptive,
}

enum LdAppBarAttachedMode {
  attached,

  /// The app bar is floating when in the bottom slot on mobile.
  adaptive,
  floating,
}

/// When the app bar is narrower than this, search moves to a row below the title
/// (same as mobile) instead of sharing the title row.
const kLdAppBarInlineSearchMinWidth = 560.0;

/// A flexible app bar widget that wraps its [child] content.
///
/// ## Usage
///
/// Wrap the scaffold body (or any subtree) with [LdAppBar] to add an app bar:
///
/// ```dart
/// LdScaffold(
///   body: LdAppBar.top(
///     title: Text('My App'),
///     child: LdScaffoldBody(children: [...]),
///   ),
/// )
/// ```
///
/// Nest bars for multiple edges:
///
/// ```dart
/// LdAppBar.top(
///   title: Text('Title'),
///   child: LdTabNavigation.bottom(
///     tabs: [...],
///     child: LdScaffoldBody(children: [...]),
///   ),
/// )
/// ```
///
/// ## Positioning
///
/// - [LdAppBar.top] — places the bar at the top
/// - [LdAppBar.bottom] — places the bar at the bottom
/// - [LdAppBar] default — uses [positionMode] (defaults to top)
///
/// ## MediaQuery Padding
///
/// The bar automatically patches [MediaQuery.padding] inside [child] so that
/// descendants can read the correct insets without any additional wiring.
///
/// See also:
/// - [LdTabNavigation] for tab-based navigation bars
/// - [LdScaffold] for the scaffold that hosts bars
@Variants([
  Variant('top', defaults: {'positionMode': 'LdAppBarPositionMode.top'}),
  Variant('bottom', defaults: {'positionMode': 'LdAppBarPositionMode.bottom'}),
])
class LdAppBarWidget extends StatefulWidget {
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

  final LdAppBarAttachedMode attachedMode;

  final bool showWindowControls;

  final bool implyCloseModalButton;

  final bool avoidViewInsets;

  final bool autoAttachToKeyboard;

  final List<Widget> actions;

  static LdWindowCallbacks? callbacks;

  final List<SingleChildWidget> Function(BuildContext context)? overflowMenuProviders;

  final LdSearchConfig? searchConfig;

  final String? debugName;

  final LdAppBarPositionMode positionMode;

  final LdAppBarScrollBehavior scrollBehavior;

  /// The subtree that this bar wraps.
  ///
  /// When provided, the bar uses the new wrapper-based composition model:
  /// the bar surface is pinned at the edge of a [Stack] and [child] fills
  /// the background. [MediaQuery.padding] inside [child] is patched with the
  /// bar's consumed insets.
  ///
  /// When null the bar renders the bar surface only (no subtree wrapping).
  final Widget child;

  final EdgeInsets? padding;

  final bool? insetScreenRadius;

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

  @ContextConfigurable()
  const LdAppBarWidget({
    super.key,
    required this.child,
    this.actions = const [],
    this.addContainer = false,
    this.attachedMode = LdAppBarAttachedMode.adaptive,
    this.autoAttachToKeyboard = true,
    this.backgroundColor,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
    this.borderMode = LdAppBarBorderMode.adaptive,
    this.bottom,
    this.debugName,
    this.insetScreenRadius = true,
    this.implyCloseModalButton = true,
    this.implyLeading,
    this.avoidViewInsets = false,
    this.leading,
    this.overflowMenuProviders,
    this.positionMode = LdAppBarPositionMode.top,
    this.scrollBehavior = LdAppBarScrollBehavior.mobileOnly,
    this.searchConfig,
    this.shadowMode = LdAppBarShadowMode.hidden,
    this.showWindowControls = true,
    this.title,
    this.trailing,
    this.padding,
  });

  @override
  State<LdAppBarWidget> createState() => _LdAppBarWidgetState();
}

class _LdAppBarWidgetState extends State<LdAppBarWidget> with WidgetsBindingObserver {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusScopeNode.removeListener(_handleFocusChange);
    FocusManager.instance.removeListener(_handleFocusChange);
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusScopeNode.addListener(_handleFocusChange);
    FocusManager.instance.addListener(_handleFocusChange);
  }

  @override
  void didChangeMetrics() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _barHasFocusedInput => ldAppBarFocusScopeHasInputFocus(_focusScopeNode);

  bool get _isModal {
    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);
    return parentRoute is LdModalRoute;
  }

  Widget? _closeModalButton(BuildContext context) {
    if (!widget.implyCloseModalButton) return null;
    if (!_isModal) return null;
    if (!_canDismissModal) return null;

    // Only show on a top-position bar at level 0.
    // In stack-mode, LdAppBarMetrics is injected by AppBarFrame into the bar
    // surface context. In legacy mode (no metrics available) we treat this bar
    // as level 0 and rely on position to decide.
    final metrics = context.read<LdAppBarMetrics?>();
    if (metrics != null) {
      // Stack-mode: check position and level from metrics.
      if (metrics.position != LdAppBarPosition.top) return null;
      if (metrics.level > 0) return null;
    } else {
      // Legacy mode: show only if this bar is at the top position.
      if (_effectivePosition != LdAppBarPosition.top) return null;
    }

    return LdButton.ghost(
      child: const Icon(LucideIcons.x),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }

  bool get _canDismissModal {
    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);
    return parentRoute is LdModalRoute && parentRoute.barrierDismissible;
  }

  bool get _drawerBlocksImplyLeading {
    final drawerState = context.watch<LdDrawerState?>();
    if (_drawerSlot != LdDrawerSlot.body) return false;
    if (drawerState == null || !drawerState.isOpen) return false;
    return !drawerState.isSideBySide;
  }

  bool get _canPopParentRoute {
    final route = ModalRoute.of(context);

    if (route != null && !route.isCurrent) {
      return false;
    }

    if (_drawerBlocksImplyLeading) {
      return false;
    }

    if (route?.impliesAppBarDismissal ?? false) {
      return true;
    }

    final router = GoRouter.maybeOf(context);
    if (router != null) {
      final rootCanPop = router.routerDelegate.navigatorKey.currentState?.canPop() ?? false;
      if (rootCanPop) {
        return false;
      }
      return _goRouterShellNavigatorCanPop(router);
    }

    return false;
  }

  void _popParentRoute() {
    final route = ModalRoute.of(context);
    if (route?.impliesAppBarDismissal ?? false) {
      route?.navigator?.maybePop();
      return;
    }

    final router = GoRouter.maybeOf(context);
    if (router != null) {
      Navigator.of(context).maybePop();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  LdDrawerSlot? get _drawerSlot {
    return context.watch<LdDrawerSlot?>();
  }

  bool get _isDrawer {
    return _drawerSlot == LdDrawerSlot.drawer;
  }

  LdAppBarPosition get _effectivePosition {
    return switch (widget.positionMode) {
      LdAppBarPositionMode.top => LdAppBarPosition.top,
      LdAppBarPositionMode.bottom => LdAppBarPosition.bottom,
      LdAppBarPositionMode.adaptive => switch (LdTheme.of(context).platform.isMobile) {
          true => LdAppBarPosition.bottom,
          _ => LdAppBarPosition.top,
        },
    };
  }

  bool _effectivelyAttached() {
    final position = _effectivePosition;
    final attached = switch (widget.attachedMode) {
      LdAppBarAttachedMode.attached => true,

      /// Adaptive mode means the app bar is floating when in the bottom slot on mobile.
      LdAppBarAttachedMode.adaptive => switch (position) {
          LdAppBarPosition.bottom => LdTheme.of(context).platform.isDesktop,
          _ => true,
        },
      LdAppBarAttachedMode.floating => false,
    };

    if (attached) return true;

    // Auto-attach to keyboard: the level check from the old code was used to
    // prevent inner bars from floating up. In Stack-mode the inner bar's level
    // is determined by AppBarFrame (it reads parent LdAppBarMetrics). Since
    // LdAppBar doesn't have direct access to its own level here, we use a
    // conservative heuristic: check for a parent LdAppBarMetrics at the same
    // position as a proxy for level > 0.
    if (widget.autoAttachToKeyboard && LdTheme.of(context).platform.isMobile) {
      return _barHasFocusedInput && MediaQuery.viewInsetsOf(context).bottom > 0 && position == LdAppBarPosition.bottom;
    }

    return false;
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

  Widget? _buildLeading(BuildContext context, LdAppBarMetrics? metrics) {
    if (widget.leading != null) return widget.leading;
    final imply = widget.implyLeading ?? true;
    if (!imply) return null;

    if (_shouldImplyRouteBack(metrics)) {
      return LdButton.ghost(
        onPressed: _popParentRoute,
        child: const Icon(LucideIcons.chevronLeft),
      );
    }

    return null;
  }

  bool _shouldImplyRouteBack(LdAppBarMetrics? metrics) {
    if (!_canPopParentRoute ||
        _isDrawer ||
        _isModal ||
        !_isInTopSlot ||
        widget.implyLeading == false ||
        widget.leading != null) {
      return false;
    }

    final parentShowsImpliedLeading = context.read<LdAppBarParentShowsImpliedLeading?>()?.value;

    if (parentShowsImpliedLeading ?? false) {
      return false;
    }

    return true;
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
    return _effectivePosition == LdAppBarPosition.top;
  }

  bool get _isInBottomSlot {
    return _effectivePosition == LdAppBarPosition.bottom;
  }

  SystemUiOverlayStyle get _systemUiOverlayStyle => appBarSystemUiOverlayStyle(LdTheme.of(context, listen: true));

  // Whether to show Windows window controls.
  // In stack-mode: level 0 = the bar's own metrics have level 0.
  // In legacy mode: the parent LdAppBarMetrics is the metrics from an
  // ancestor bar (if any).
  bool _showWindowsWindowControls(LdAppBarMetrics? metricsFromBarSurface) {
    if (!_isInTopSlot || _isModal || _isDrawer) return false;
    if (LdTheme.of(context).platform != LdPlatform.windows) return false;
    // In stack-mode the bar surface receives its own metrics (level >= 0).
    // Show window controls only when level == 0.
    if (metricsFromBarSurface != null) {
      return metricsFromBarSurface.level == 0;
    }
    // Legacy mode: check parent metrics (metrics from bars above this one).
    final parentMetrics = context.read<LdAppBarMetrics?>();
    return parentMetrics == null || parentMetrics.position != LdAppBarPosition.top;
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when the keyboard opens/closes (autoAttachToKeyboard).
    MediaQuery.viewInsetsOf(context);

    final position = _effectivePosition;
    final isAttached = _effectivelyAttached();
    // Keep drag tied to the visible top bar surface, not parent metrics,
    // because wrapper/stack composition can make parent-level checks stale.
    final enableWindowDrag = _isInTopSlot && !_isModal && !_isDrawer && widget.showWindowControls;

    final hasSearch = widget.searchConfig != null;
    final mobile = LdTheme.of(context).platform.isMobile;

    final decorationBuilder = LdAppBarDecorationBuilder(
      backgroundColor: widget.backgroundColor,
      shadowMode: widget.shadowMode,
      borderMode: widget.borderMode,
      backgroundMode: widget.backgroundMode,
    );

    // The bar surface is built as a widget that can read LdAppBarMetrics from
    // the context injected by AppBarFrame (which wraps the bar child with
    // Provider<LdAppBarMetrics>.value so the bar surface can react to scroll).
    Widget barSurface = Builder(
      builder: (context) {
        // Read metrics injected by AppBarFrame for the bar surface context.
        // isScrolledUnder is used via the decoration builders in AppBarFrame,
        // and metrics is used for level/position checks.
        final metrics = context.watch<LdAppBarMetrics?>();

        final leading = _buildLeading(context, metrics);

        return LdButtonConfigProvider(
          config: const LdButtonConfig(
            mode: LdButtonMode.ghost,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final isNarrowBar = barWidth.isFinite && barWidth < kLdAppBarInlineSearchMinWidth;
              final searchBelowBar = mobile || (hasSearch && isNarrowBar);

              final overflowItems = [
                if (widget.title != null)
                  LdFlexibleChild(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DefaultTextStyle(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: _headerStyle,
                        child: widget.title!,
                      ),
                    ),
                  ),
                if (hasSearch && !searchBelowBar)
                  LdFlexibleChild(
                    child: LdSearchInput(
                      searchConfig: widget.searchConfig!,
                      isBottomNavigationBar: _isInBottomSlot,
                      fullWidth: true,
                    ),
                  ),
                ...widget.actions,
              ];

              return LdAutoSpace(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (widget.showWindowControls && !_isModal) const MacOSWindowControls(),
                      OpenDrawerButton(drawerParent: _findDrawerParent(context)),
                      if (leading != null) ...[leading, ldSpacerM],
                      if (overflowItems.isNotEmpty)
                        Expanded(
                          child: LdOverflowView(
                            spacing: LdTheme.of(context).paddingSize(size: LdSize.xs),
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            builder: (context, overflowedChildIndices) {
                              final remainder = [
                                for (final index in overflowedChildIndices) overflowItems[index],
                              ];
                              return LdAppbarActionOverflowMenu(
                                actions: remainder,
                                menuProviders: widget.overflowMenuProviders,
                                inMenu: true,
                              );
                            },
                            children: overflowItems,
                          ),
                        ),
                      const CloseDrawerButton(),
                      if (widget.trailing != null) widget.trailing!,
                      if (_closeModalButton(context) != null) ...[_closeModalButton(context)!],
                      if (widget.showWindowControls && !_isModal)
                        LdReveal(
                          revealed: _showWindowsWindowControls(metrics),
                          child: const WindowsWindowControls(),
                        ),
                    ],
                  ),
                  if (hasSearch && searchBelowBar)
                    LdSearchInput(
                      searchConfig: widget.searchConfig!,
                      isBottomNavigationBar: _isInBottomSlot,
                      fullWidth: true,
                    ),
                  if (widget.bottom != null) widget.bottom!,
                ],
              );
            },
          ),
        );
      },
    );

    if (enableWindowDrag) {
      barSurface = GestureDetector(
        // Capture drags across transparent spacing between controls so the
        // title bar behaves like a native draggable region.
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          LdAppBarWidget.callbacks?.onMove?.call();
        },
        onDoubleTap: () {
          LdScaffoldState.maybeOf(context)?.scrollToTop();
        },
        child: barSurface,
      );
    }

    barSurface = AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemUiOverlayStyle,
      child: barSurface,
    );

    final parentMetrics = context.watch<LdAppBarMetrics?>();

    bool showingImpliedLeading = _shouldImplyRouteBack(parentMetrics);

    final frame = AppBarFrame(
      focusScopeNode: _focusScopeNode,
      avoidViewInsets: widget.avoidViewInsets,
      addContainer: widget.addContainer,
      debugName: widget.debugName,
      position: position,
      insetBorderRadius: widget.insetScreenRadius ?? !_isModal,
      attached: isAttached,
      outsideAdditionalPadding: isAttached ? EdgeInsets.zero : LdTheme.of(context).pad(size: LdSize.s),
      scrollBehavior: widget.scrollBehavior,
      wrappedChild: Provider<LdAppBarParentShowsImpliedLeading>.value(
        value: LdAppBarParentShowsImpliedLeading(showingImpliedLeading),
        child: widget.child,
      ),
      insidePadding: widget.padding,
      outsideDecorationBuilder: (isScrolledUnder) => decorationBuilder.buildOutsideDecoration(
        context: context,
        isScrolledUnder: isScrolledUnder,
        isAttached: isAttached,
        position: position,
      ),
      insideDecorationBuilder: (isScrolledUnder) => decorationBuilder.buildInsideDecoration(
        context: context,
        isScrolledUnder: isScrolledUnder,
        isAttached: isAttached,
        position: position,
      ),
      surfaceInfoBuilder: (isScrolledUnder) => LdSurfaceInfo(
        isSurface: decorationBuilder
            .resolveAppearance(
              context,
              isScrolledUnder: isScrolledUnder,
              position: position,
            )
            .childIsSurface,
      ),
      child: Builder(builder: (context) {
        return Padding(padding: MediaQuery.of(context).padding, child: barSurface);
      }),
    );

    return frame;
  }
}

bool _goRouterShellNavigatorCanPop(GoRouter router) {
  final matches = router.routerDelegate.currentConfiguration.matches;
  if (matches.isEmpty) {
    return false;
  }
  RouteMatchBase walker = matches.last;
  while (walker is ShellRouteMatch) {
    if (walker.navigatorKey.currentState?.canPop() ?? false) {
      return true;
    }
    walker = walker.matches.last;
  }
  return false;
}
