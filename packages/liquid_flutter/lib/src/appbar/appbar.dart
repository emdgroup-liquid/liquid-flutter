import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_decoration.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:liquid_flutter/src/appbar/macos_window_controls.dart';
import 'package:liquid_flutter/src/appbar/windows_window_controls.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

part 'appbar.variants.g.dart';

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
  final Widget? child;

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
    this.child,
    this.actions = const [],
    this.addContainer = false,
    this.attachedMode = LdAppBarAttachedMode.adaptive,
    this.autoAttachToKeyboard = true,
    this.backgroundColor,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
    this.borderMode = LdAppBarBorderMode.adaptive,
    this.bottom,
    this.debugName,
    this.implyCloseModalButton = true,
    this.implyLeading,
    this.avoidViewInsets = false,
    this.leading,
    this.overflowMenuProviders,
    this.positionMode = LdAppBarPositionMode.top,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.searchConfig,
    this.shadowMode = LdAppBarShadowMode.adaptive,
    this.showWindowControls = true,
    this.title,
    this.trailing,
  });

  @override
  State<LdAppBarWidget> createState() => _LdAppBarWidgetState();
}

class _LdAppBarWidgetState extends State<LdAppBarWidget> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusScopeNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    // Use addPostFrameCallback instead of Future.delayed(Duration.zero) to
    // avoid leaving a pending timer that fails widget tests.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

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

  bool get _canPopParentRoute {
    final parentRoute = ModalRoute.of(context);
    return parentRoute?.canPop ?? false;
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
      final parentMetrics = context.read<LdAppBarMetrics?>();
      final isLevel0 = parentMetrics == null || parentMetrics.position != position;
      return isLevel0 &&
          _focusScopeNode.hasFocus &&
          MediaQuery.of(context).viewInsets.bottom > 0 &&
          position == LdAppBarPosition.bottom;
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

  Widget? _buildLeading(BuildContext context) {
    if (widget.leading != null) return widget.leading;
    final imply = widget.implyLeading ?? true;
    if (!imply) return null;

    if (_canPopParentRoute && !_isDrawer && !_isModal && !_isInBottomSlot) {
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
    return _effectivePosition == LdAppBarPosition.top;
  }

  bool get _isInBottomSlot {
    return _effectivePosition == LdAppBarPosition.bottom;
  }

  bool get _hasTopContent {
    return widget.title != null || widget.actions.isNotEmpty || widget.searchConfig != null;
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
    final position = _effectivePosition;
    final isAttached = _effectivelyAttached();

    // Level-0 top bar not in a modal enables window-drag + scroll-to-top.
    // We compute isLevel0 from the *parent* metrics (bar that wraps this one).
    // In both legacy and stack-mode this is the metrics provided by an ancestor
    // AppBarFrame (if any).
    final parentMetrics = context.read<LdAppBarMetrics?>();
    final isLevel0 = parentMetrics == null || parentMetrics.position != LdAppBarPosition.top;
    final enableWindowDrag = position == LdAppBarPosition.top && isLevel0 && !_isModal;

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

        final leading = _buildLeading(context);

        List<Widget> bottomContent = [
          if (widget.bottom != null) widget.bottom!,
        ];

        if (hasSearch && mobile) {
          bottomContent.add(LdSearchInput(
            searchConfig: widget.searchConfig!,
            isBottomNavigationBar: _isInBottomSlot,
            fullWidth: true,
          ));
        }

        final isSurface = widget.backgroundColor == null && (context.read<LdSurfaceInfo?>()?.isSurface ?? false);

        return Provider.value(
          value: LdSurfaceInfo(isSurface: isSurface),
          child: LdButtonConfigProvider(
            config: const LdButtonConfig(
              mode: LdButtonMode.ghost,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(builder: (context, constraints) {
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
                    if (hasSearch && !mobile)
                      LdFlexibleChild(
                        child: LdSearchInput(
                          searchConfig: widget.searchConfig!,
                          isBottomNavigationBar: _isInBottomSlot,
                          fullWidth: false,
                        ),
                      ),
                    ...widget.actions
                  ];

                  return Provider<LdAppBarActionRequestedLeading>.value(
                    value: hasSearch,
                    child: Row(
                      children: [
                        if (widget.showWindowControls && !_isModal) const MacOSWindowControls(),
                        OpenDrawerButton(drawerParent: _findDrawerParent(context)),
                        if (leading != null) ...[leading, ldSpacerM],
                        if (overflowItems.isNotEmpty)
                          Expanded(
                            child: LdOverflowView(
                              spacing: LdTheme.of(context).paddingSize(size: LdSize.xs),
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment:
                                  widget.title == null ? MainAxisAlignment.start : MainAxisAlignment.center,
                              builder: (context, remainingItemCount) {
                                final remainder = overflowItems.sublist(
                                  overflowItems.length - remainingItemCount,
                                );
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
                  );
                }),
                if (bottomContent.isNotEmpty) ...[
                  LdWrapConditional(
                    condition: _hasTopContent,
                    builder: (context, child) => Padding(
                      padding: EdgeInsets.only(
                        top: LdTheme.of(context).pad(size: LdSize.s).top,
                      ),
                      child: child,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: bottomContent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (enableWindowDrag) {
      barSurface = GestureDetector(
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
      child: FocusScope(
        node: _focusScopeNode,
        child: barSurface,
      ),
    );

    final frame = AppBarFrame(
      avoidViewInsets: widget.avoidViewInsets,
      addContainer: widget.addContainer,
      debugName: widget.debugName,
      position: position,
      insetBorderRadius: !_isModal,
      attached: isAttached,
      scrollBehavior: widget.scrollBehavior,
      wrappedChild: widget.child, // null = legacy scaffold-injection mode
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
      child: barSurface,
    );

    return frame;
  }
}
