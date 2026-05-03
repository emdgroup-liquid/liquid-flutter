import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_decoration.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_behavior.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:liquid_flutter/src/appbar/macos_window_controls.dart';
import 'package:liquid_flutter/src/appbar/windows_window_controls.dart';
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

/// A flexible app bar widget that can be positioned at the top or bottom of a scaffold.
///
/// ## Adding App Bars to Scaffolds
///
/// App bars are added to a scaffold by passing them in the `appBars` parameter of [LdScaffold]:
///
/// ```dart
/// LdScaffold(
///   appBars: [
///     LdAppBar.top(title: Text('My App')),
///     LdAppBar.bottom(actions: [/* ... */]),
///   ],
///   body: MyContent(),
/// )
/// ```
///
/// Multiple app bars can be added to a single scaffold, and they will be stacked
/// vertically based on their position and order.
///
/// ## Utility Constructors and Positioning
///
/// Use the utility constructors to specify the app bar's position:
///
/// - [LdAppBar.top] - Places the app bar at the top of the scaffold
/// - [LdAppBar.bottom] - Places the app bar at the bottom of the scaffold
/// - [LdAppBar] (default) - Uses [positionMode] to determine position (defaults to top)
///
/// The [order] parameter controls the stacking order when multiple app bars are at the same
/// position. Lower order values appear closer to the content (higher in the visual stack).
/// For example, an app bar with `order: 0` will be positioned above an app bar with `order: 1`
/// when both are at the top position.
///
/// ## MediaQuery Padding
///
/// The app bar's size is automatically applied to the scaffold body's [MediaQuery] padding.
/// This ensures that content in the body is not obscured by the app bar. The padding is
/// calculated based on the app bar's effective height (including margins) and is updated
/// dynamically as app bars are added, removed, or resized.
///
/// The padding is applied separately for top and bottom app bars:
/// - Top app bars add padding to `MediaQuery.padding.top`
/// - Bottom app bars add padding to `MediaQuery.padding.bottom`
///
/// ## Actions and Overflow Menu
///
/// Actions provided in the [actions] list are displayed in the app bar. When there isn't
/// enough space to display all actions, they automatically overflow into a menu accessible
/// via an ellipsis button. The overflow menu is implemented using [LdAppbarActionOverflowMenu].
///
/// ## Action Behavior in Different Contexts
///
/// [LdAppBarAction] widgets behave differently depending on their context:
///
/// - **In the app bar**: Actions are rendered as [LdButton] widgets with optional leading/trailing
///   icons. On mobile, if [preferLeadingOnMobile] is true, the leading icon replaces the child
///   text to save space.
///
/// - **In the overflow menu**: Actions are rendered as [LdListItem] widgets with a more compact
///   list item appearance. The action automatically detects when it's inside a context menu
///   (overflow menu) and switches to this presentation.
///
/// This dual behavior allows actions to have an appropriate appearance whether they're visible
/// in the main app bar or hidden in the overflow menu.
///
/// See also:
/// - [LdAppBarAction] for creating action buttons
/// - [LdScaffold] for the scaffold that hosts app bars
/// - [AppBarRegistry] for the internal registry that manages app bar positioning
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
    this.order = 0,
    this.overflowMenuProviders,
    this.positionMode = LdAppBarPositionMode.top,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.searchConfig,
    this.shadowMode = LdAppBarShadowMode.adaptive,
    this.showWindowControls = true,
    this.title,
    this.trailing,
  });

  const LdAppBar.top({
    super.key,
    this.title,
    this.actions = const [],
    this.leading,
    this.autoAttachToKeyboard = true,
    this.trailing,
    this.avoidViewInsets = false,
    this.showWindowControls = true,
    this.backgroundColor,
    this.searchConfig,
    this.addContainer = false,
    this.implyCloseModalButton = true,
    this.implyLeading,
    this.bottom,
    this.attachedMode = LdAppBarAttachedMode.adaptive,
    this.shadowMode = LdAppBarShadowMode.adaptive,
    this.borderMode = LdAppBarBorderMode.adaptive,
    this.backgroundMode = LdAppBarBackgroundMode.adaptive,
    this.overflowMenuProviders,
    this.debugName,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.order = 0,
  }) : positionMode = LdAppBarPositionMode.top;

  const LdAppBar.bottom({
    super.key,
    this.title,
    this.actions = const [],
    this.leading,
    this.trailing,
    this.addContainer = false,
    this.showWindowControls = true,
    this.avoidViewInsets = false,
    this.attachedMode = LdAppBarAttachedMode.adaptive,
    this.autoAttachToKeyboard = true,
    this.backgroundColor,
    this.searchConfig,
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
  }) : positionMode = LdAppBarPositionMode.bottom;

  // Note: adaptive constructor cannot be a factory that returns LdAppBar directly
  // as it needs BuildContext. Use LdAppBar.adaptiveWidget() instead or
  // determine position manually using LdTheme

  @override
  State<LdAppBar> createState() => _LdAppBarState();
}

class _LdAppBarState extends State<LdAppBar> {
  @override
  Widget build(BuildContext context) {
    return LdAppBarRegistryEntry(
      debugName: widget.debugName,
      order: widget.order,
      child: _LdAppBarInner(appBar: widget),
    );
  }
}

class _LdAppBarInner extends StatefulWidget {
  final LdAppBar appBar;

  const _LdAppBarInner({required this.appBar});

  @override
  State<_LdAppBarInner> createState() => _LdAppBarInnerState();
}

class _LdAppBarInnerState extends State<_LdAppBarInner> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  LdAppBarDecorationBuilder get _decorationBuilder => LdAppBarDecorationBuilder(
        backgroundColor: widget.appBar.backgroundColor,
        shadowMode: widget.appBar.shadowMode,
        borderMode: widget.appBar.borderMode,
        backgroundMode: widget.appBar.backgroundMode,
      );

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusScopeNode.addListener(
      _handleFocusChange,
    );
    AppBarRegistry.maybeStateOf(context)?.addListener(
      _handleAppBarRegistryChange,
    );
  }

  void _handleFocusChange() async {
    await Future.delayed(Duration.zero);
    if (mounted) {
      setState(() {});
    }
  }

  void _handleAppBarRegistryChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  bool get _isModal {
    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);
    return parentRoute is LdModalRoute;
  }

  Widget? _closeModalButton(BuildContext context) {
    if (!widget.appBar.implyCloseModalButton) return null;
    if (!_isModal) return null;
    if (!_canDismissModal) return null;
    if (!_isInTopSlot) return null;
    if (_level() > 0) return null;

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
    return switch (widget.appBar.positionMode) {
      LdAppBarPositionMode.top => LdAppBarPosition.top,
      LdAppBarPositionMode.bottom => LdAppBarPosition.bottom,
      LdAppBarPositionMode.adaptive => switch (LdTheme.of(context).platform.isMobile) {
          true => LdAppBarPosition.bottom,
          _ => LdAppBarPosition.top,
        },
    };
  }

  int _level() {
    final position = _effectivePosition;
    final key = context.appBarRegistryKey();

    final modalRoute = ModalRoute.of(context);

    BuildContext? limitContext;

    if (modalRoute is LdModalRoute) {
      limitContext = modalRoute.subtreeContext;
    }

    final level = AppBarRegistry.maybeStateOf(context)?.getLevel(key, position, limitToChildrenOf: limitContext) ?? 0;
    return level;
  }

  bool _effectivelyAttached() {
    final level = _level();
    final position = _effectivePosition;
    final attached = switch (widget.appBar.attachedMode) {
      LdAppBarAttachedMode.attached => true,

      /// Adaptive mode means the app bar is floating when in the bottom slot on mobile.
      LdAppBarAttachedMode.adaptive => switch (position) {
          LdAppBarPosition.bottom => LdTheme.of(context).platform.isDesktop,
          _ => true,
        },
      LdAppBarAttachedMode.floating => false,
    };

    if (attached) return true;

    // Now check if we should auto attach.

    if (widget.appBar.autoAttachToKeyboard && LdTheme.of(context).platform.isMobile) {
      return _focusScopeNode.hasFocus &&
          MediaQuery.of(context).viewInsets.bottom > 0 &&
          position == LdAppBarPosition.bottom &&
          level == 0;
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

  bool get _showWindowsWindowControls {
    // Calculate level by walking up scaffolds
    final level = _level();
    return LdTheme.of(context).platform == LdPlatform.windows && _isInTopSlot && level == 0 && !_isDrawer;
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.appBar.leading != null) return widget.appBar.leading;
    final imply = widget.appBar.implyLeading ?? true;
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
    return widget.appBar.title != null || widget.appBar.actions.isNotEmpty || widget.appBar.searchConfig != null;
  }

  SystemUiOverlayStyle get _systemUiOverlayStyle => appBarSystemUiOverlayStyle(LdTheme.of(context, listen: true));

  @override
  Widget build(BuildContext context) {
    final appBarKey = context.appBarRegistryKey();
    final leading = _buildLeading(context);
    final level = _level();

    final isAttached = _effectivelyAttached();
    final position = _effectivePosition;
    final enableWindowDrag = position == LdAppBarPosition.top && level == 0 && !_isModal;

    final hasSearch = widget.appBar.searchConfig != null;
    final mobile = LdTheme.of(context).platform.isMobile;

    List<Widget> bottomContent = [
      if (widget.appBar.bottom != null) widget.appBar.bottom!,
    ];

    if (hasSearch && mobile) {
      bottomContent.add(LdSearchInput(
        searchConfig: widget.appBar.searchConfig!,
        isBottomNavigationBar: _isInBottomSlot,
        fullWidth: true,
      ));
    }

    return LdAppBarScrollWrapper(
      position: position,
      scrollBehavior: widget.appBar.scrollBehavior,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _systemUiOverlayStyle,
        child: LdWrapConditional(
          condition: enableWindowDrag,
          builder: (context, child) => GestureDetector(
            onPanStart: (details) {
              LdAppBar.callbacks?.onMove?.call();
            },
            onDoubleTap: () {
              LdScaffoldState.maybeOf(context)?.scrollToTop();
            },
            child: child,
          ),
          child: FocusScope(
            node: _focusScopeNode,
            child: KeyedSubtree(
              key: ValueKey('appbar_${appBarKey.order}'),
              child: ScrolledUnderBuilder(builder: (context, isScrolledUnder) {
                final isSurface =
                    widget.appBar.backgroundColor == null && (context.read<LdSurfaceInfo?>()?.isSurface ?? false);
                return Provider.value(
                  value: LdSurfaceInfo(isSurface: isSurface),
                  child: AppBarFrame(
                    avoidViewInsets: widget.appBar.avoidViewInsets,
                    addContainer: widget.appBar.addContainer,
                    debugName: widget.appBar.debugName,
                    position: position,
                    insetBorderRadius: !_isModal,
                    attached: isAttached,
                    insideDecoration: _decorationBuilder.buildInsideDecoration(
                      context: context,
                      isScrolledUnder: isScrolledUnder,
                      isAttached: isAttached,
                      position: position,
                    ),
                    outsideDecoration: _decorationBuilder.buildOutsideDecoration(
                      context: context,
                      isScrolledUnder: isScrolledUnder,
                      isAttached: isAttached,
                      position: position,
                    ),
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
                              if (widget.appBar.title != null)
                                LdFlexibleChild(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: DefaultTextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: _headerStyle,
                                      child: widget.appBar.title!,
                                    ),
                                  ),
                                ),
                              if (hasSearch && !mobile)
                                LdFlexibleChild(
                                  child: LdSearchInput(
                                    searchConfig: widget.appBar.searchConfig!,
                                    isBottomNavigationBar: _isInBottomSlot,
                                    fullWidth: false,
                                  ),
                                ),
                              ...widget.appBar.actions
                            ];

                            return Provider<LdAppBarActionRequestedLeading>.value(
                              value: hasSearch,
                              child: Row(
                                children: [
                                  if (widget.appBar.showWindowControls && !_isModal) const MacOSWindowControls(),
                                  OpenDrawerButton(drawerParent: _findDrawerParent(context)),
                                  if (leading != null) ...[leading, ldSpacerM],
                                  if (overflowItems.isNotEmpty)
                                    Expanded(
                                      child: LdOverflowView(
                                        spacing: LdTheme.of(context).paddingSize(size: LdSize.xs),
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: widget.appBar.title == null
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.center,
                                        builder: (context, remainingItemCount) {
                                          final remainder = overflowItems.sublist(
                                            overflowItems.length - remainingItemCount,
                                          );
                                          return LdAppbarActionOverflowMenu(
                                            actions: remainder,
                                            menuProviders: widget.appBar.overflowMenuProviders,
                                            inMenu: true,
                                          );
                                        },
                                        children: overflowItems,
                                      ),
                                    ),
                                  const CloseDrawerButton(),
                                  if (widget.appBar.trailing != null) widget.appBar.trailing!,
                                  if (_closeModalButton(context) != null) ...[_closeModalButton(context)!],
                                  if (widget.appBar.showWindowControls && !_isModal)
                                    LdReveal(
                                      revealed: _showWindowsWindowControls,
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
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
