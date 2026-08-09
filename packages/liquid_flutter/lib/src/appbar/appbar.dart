import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_decoration.dart';
import 'package:liquid_flutter/src/appbar/appbar_scrolled_under.dart';
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

  final Set<LdAppBarImpliedFeature> implyFeatures;

  final bool addContainer;

  final Widget? bottom;

  final LdAppBarShadowMode shadowMode;

  final LdAppBarBorderMode borderMode;

  final LdAppBarBackgroundMode backgroundMode;

  final LdAppBarAttachedMode attachedMode;

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

  final bool? useAdaptiveRadius;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('debugName', debugName));
    properties.add(EnumProperty<LdAppBarShadowMode>('shadowMode', shadowMode));
    properties.add(EnumProperty<LdAppBarBorderMode>('borderMode', borderMode));
    properties.add(FlagProperty('addContainer', value: addContainer, ifTrue: 'enabled'));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(IntProperty('actionsCount', actions.length));
    properties.add(DiagnosticsProperty<Set<LdAppBarImpliedFeature>>('implyFeatures', implyFeatures));
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
    this.backgroundMode = LdAppBarBackgroundMode.visible,
    this.borderMode = LdAppBarBorderMode.visible,
    this.bottom,
    this.debugName,
    this.useAdaptiveRadius = true,
    this.implyFeatures = const {
      LdAppBarImpliedFeature.back,
      LdAppBarImpliedFeature.close,
      LdAppBarImpliedFeature.windowControls,
      LdAppBarImpliedFeature.drawerToggle
    },
    this.avoidViewInsets = false,
    this.leading,
    this.overflowMenuProviders,
    this.positionMode = LdAppBarPositionMode.top,
    this.scrollBehavior = LdAppBarScrollBehavior.mobileOnly,
    this.searchConfig,
    this.shadowMode = LdAppBarShadowMode.hidden,
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
      LdAppBarAttachedMode.adaptive => !(context.isInSheet && _effectivePosition == LdAppBarPosition.bottom),
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

  @override
  Widget build(BuildContext context) {
    // Rebuild when the keyboard opens/closes (autoAttachToKeyboard).
    MediaQuery.viewInsetsOf(context);

    final position = _effectivePosition;
    final isAttached = _effectivelyAttached();
    // Keep drag tied to the visible top bar surface, not parent metrics,
    // because wrapper/stack composition can make parent-level checks stale.
    final enableWindowDrag = _isInTopSlot && widget.implyFeatures.contains(LdAppBarImpliedFeature.windowControls);

    final hasSearch = widget.searchConfig != null;
    final mobile = LdTheme.of(context).platform.isMobile;

    final decorationBuilder = LdAppBarDecorationBuilder(
      backgroundColor: widget.backgroundColor,
      shadowMode: widget.shadowMode,
      borderMode: widget.borderMode,
      backgroundMode: widget.backgroundMode,
      scrollBehavior: widget.scrollBehavior,
    );

    // The bar surface is built as a widget that can read LdAppBarMetrics from
    // the context injected by AppBarFrame (which wraps the bar child with
    // Provider<LdAppBarMetrics>.value so the bar surface can react to scroll).
    Widget barSurface = Builder(
      builder: (context) {
        // Watch metrics injected by AppBarFrame so this builder rebuilds
        // whenever metrics change (e.g. isScrolledUnder, level, position).
        context.watch<LdAppBarMetrics?>();

        final showWindowControls = MacOSWindowControls.canShow(context) &&
            widget.implyFeatures.contains(LdAppBarImpliedFeature.windowControls);
        final showDrawerOpenButton = LdDrawerButton.canShow(context, LdDrawerButtonType.open) &&
            widget.implyFeatures.contains(LdAppBarImpliedFeature.drawerToggle);
        final showDrawerCloseButton = LdDrawerButton.canShow(context, LdDrawerButtonType.close) &&
            widget.implyFeatures.contains(LdAppBarImpliedFeature.drawerToggle);
        final showCloseModalButton =
            LdAppBarCloseModalButton.canShow(context) && widget.implyFeatures.contains(LdAppBarImpliedFeature.close);
        final showBackButton =
            LdAppBarBackButton.canShow(context) && widget.implyFeatures.contains(LdAppBarImpliedFeature.back);
        final showWindowsWindowControls = WindowsWindowControls.canShow(context) &&
            widget.implyFeatures.contains(LdAppBarImpliedFeature.windowControls);

        return LdButtonConfigProvider(
          config: const LdButtonConfig(mode: LdButtonMode.ghost, size: LdSize.m),
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
                      if (showWindowControls) MacOSWindowControls(),
                      if (showDrawerOpenButton) LdDrawerButton(type: LdDrawerButtonType.open),
                      if (showBackButton) LdAppBarBackButton(),
                      if (widget.leading != null) widget.leading!,
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
                      if (showDrawerCloseButton) LdDrawerButton(type: LdDrawerButtonType.close),
                      if (widget.trailing != null) widget.trailing!,
                      if (showCloseModalButton) LdAppBarCloseModalButton(),
                      if (showWindowsWindowControls) WindowsWindowControls(),
                    ],
                  ).spaceS(),
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
        /* onDoubleTap: () {
          LdScaffoldState.maybeOf(context)?.scrollToTop();
        }, */
        child: barSurface,
      );
    }

    barSurface = AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemUiOverlayStyle,
      child: barSurface,
    );

    final frame = AppBarFrame(
      focusScopeNode: _focusScopeNode,
      avoidViewInsets: widget.avoidViewInsets,
      addContainer: widget.addContainer,
      debugName: widget.debugName,
      position: position,
      useAdaptiveRadius: widget.useAdaptiveRadius ?? false,
      attached: isAttached,
      outsideAdditionalPadding: isAttached ? EdgeInsets.zero : LdTheme.of(context).pad(size: LdSize.s),
      scrollBehavior: widget.scrollBehavior,
      wrappedChild: Builder(
        builder: (context) {
          return Provider<LdAppBarImpliedFeatures>.value(
            value: LdAppBarImpliedFeatures(features: {
              ...context.read<LdAppBarImpliedFeatures?>()?.features ?? {},
              if (LdAppBarBackButton.canShow(context)) LdAppBarImpliedFeature.back,
              if (MacOSWindowControls.canShow(context) || WindowsWindowControls.canShow(context))
                LdAppBarImpliedFeature.windowControls,
              if (LdDrawerButton.canShow(context, LdDrawerButtonType.open) ||
                  LdDrawerButton.canShow(context, LdDrawerButtonType.close))
                LdAppBarImpliedFeature.drawerToggle,
              if (LdAppBarCloseModalButton.canShow(context)) LdAppBarImpliedFeature.close,
            }),
            child: widget.child,
          );
        },
      ),
      insidePadding: widget.padding,
      outsideDecorationBuilder: (isScrolledUnder) => decorationBuilder.buildOutsideDecoration(
        context: context,
        isScrolledUnder: isScrolledUnder,
        isAttached: isAttached,
        position: position,
      ),
      scrimColor: (isScrolledUnder) => decorationBuilder.buildScrimColor(context, isScrolledUnder, position),
      insideDecorationBuilder: (isScrolledUnder) => decorationBuilder.buildInsideDecoration(
        context: context,
        isScrolledUnder: isScrolledUnder,
        isAttached: isAttached,
        position: position,
      ),
      child: Builder(
        builder: (context) {
          return Provider.value(
              value: LdSurfaceInfo(
                  isSurface: decorationBuilder
                      .resolveAppearance(
                        context,
                        isScrolledUnder: LdAppBarScrolledUnderScope.of(context),
                        position: position,
                      )
                      .showsFill),
              child: Padding(padding: MediaQuery.of(context).padding, child: barSurface));
        },
      ),
    );

    return frame;
  }
}
