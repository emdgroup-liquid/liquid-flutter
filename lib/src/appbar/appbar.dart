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
    this.showWindowControls = true,
    this.attachedMode = LdAppBarAttachedMode.adaptive,
    this.autoAttachToKeyboard = true,
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
  }) : positionMode = LdAppBarPositionMode.bottom;

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

  LdDrawerSlot? get _drawerSlot {
    return context.watch<LdDrawerSlot?>();
  }

  bool get _isDrawer {
    return _drawerSlot == LdDrawerSlot.drawer;
  }

  AppBarPosition get _effectivePosition {
    return switch (widget.positionMode) {
      LdAppBarPositionMode.top => AppBarPosition.top,
      LdAppBarPositionMode.bottom => AppBarPosition.bottom,
      LdAppBarPositionMode.adaptive => switch (LdTheme.of(context).platform.isMobile) {
          true => AppBarPosition.bottom,
          _ => AppBarPosition.top,
        },
    };
  }

  bool _effectivelyAttached(BuildContext context) {
    final position = _effectivePosition;
    final key = context.appBarRegistryKey();
    final level = AppBarRegistry.maybeStateOf(context)?.getLevel(key, position) ?? 0;
    final attached = switch (widget.attachedMode) {
      LdAppBarAttachedMode.attached => true,

      /// Adaptive mode means the app bar is floating when in the bottom slot on mobile.
      LdAppBarAttachedMode.adaptive => switch (position) {
          AppBarPosition.bottom => LdTheme.of(context).platform.isDesktop,
          _ => true,
        },
      LdAppBarAttachedMode.floating => false,
    };

    if (attached) return true;

    // Now check if we should auto attach.

    if (widget.autoAttachToKeyboard && LdTheme.of(context).platform.isMobile) {
      return _focusScopeNode.hasFocus &&
          MediaQuery.of(context).viewInsets.bottom > 0 &&
          position == AppBarPosition.bottom &&
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
    return _effectivePosition == AppBarPosition.top;
  }

  bool get _isInBottomSlot {
    return _effectivePosition == AppBarPosition.bottom;
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
  BoxDecoration _buildOutsideDecoration({
    required BuildContext context,
    required bool isScrolledUnder,
    required bool isAttached,
    required AppBarPosition position,
  }) {
    return BoxDecoration(
      // We fill the outside container when attached.
      color: isAttached ? _fillColor(isScrolledUnder) : null,
      // Gradient behind the floating app bar.
      gradient: !isAttached
          ? LinearGradient(
              begin: switch (position) {
                AppBarPosition.bottom => Alignment.topCenter,
                AppBarPosition.top => Alignment.bottomCenter,
              },
              end: switch (position) {
                AppBarPosition.bottom => Alignment.bottomCenter,
                AppBarPosition.top => Alignment.topCenter,
              },
              stops: const [0, 0.3],
              colors: [
                LdTheme.of(context).absolute.withAlpha(0),
                LdTheme.of(context).absolute.withAlpha(200),
              ],
            )
          : null,
      // Shadow behind the the bar only visible when attached.
      boxShadow: [
        if (isAttached)
          ldShadowSticky.copyWith(
            color: _shouldShowShadow(isScrolledUnder)
                ? ldShadowSticky.color.withAlpha(isScrolledUnder ? 50 : 0)
                : Colors.transparent,
          ),
      ],
      // Add a border to the app bar when attached. either top or bottom.
      // to separate the app bar from the content.
      border: isAttached
          ? Border(
              bottom: switch (position) {
                AppBarPosition.top => BorderSide(
                    color: _shouldShowBorder(isScrolledUnder) ? LdTheme.of(context).border : Colors.transparent,
                    width: LdTheme.of(context).borderWidth,
                  ),
                AppBarPosition.bottom => BorderSide.none,
              },
              top: switch (position) {
                AppBarPosition.bottom => BorderSide(
                    color: _shouldShowBorder(isScrolledUnder) ? LdTheme.of(context).border : Colors.transparent,
                    width: LdTheme.of(context).borderWidth,
                  ),
                AppBarPosition.top => BorderSide.none,
              },
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

  BoxDecoration _buildInsideDecoration({
    required BuildContext context,
    required bool isScrolledUnder,
    required bool isAttached,
    required AppBarPosition position,
  }) {
    if (isAttached) {
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
          MediaQuery.viewInsetsOf(context);
          final leading = _buildLeading(context);
          final appBarKey = context.appBarRegistryKey();
          final isAttached = _effectivelyAttached(context);
          final position = _effectivePosition;
          final level = AppBarRegistry.maybeStateOf(context)?.getLevel(appBarKey, position) ?? 0;
          final enableWindowDrag = position == AppBarPosition.top && level == 0 && !_isModal;
          return LdAppBarScrollWrapper(
            position: position,
            scrollBehavior: widget.scrollBehavior,
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
                      return AppBarFrame(
                        debugName: widget.debugName,
                        position: position,
                        insetBorderRadius: !_isModal,
                        attached: isAttached,
                        insideDecoration: _buildInsideDecoration(
                          context: context,
                          isScrolledUnder: isScrolledUnder,
                          isAttached: isAttached,
                          position: position,
                        ),
                        outsideDecoration: _buildOutsideDecoration(
                          context: context,
                          isScrolledUnder: isScrolledUnder,
                          isAttached: isAttached,
                          position: position,
                        ),
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
                                  if (hasSearch)
                                    LdFlexibleChild(
                                      child: LdSearchInput(
                                        searchConfig: widget.searchConfig!,
                                        isBottomNavigationBar: _isInBottomSlot,
                                        fullWidth: false,
                                      ),
                                    ),
                                  ...widget.actions
                                ];

                                return Row(
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
                                    if (_closeModalButton != null) ...[_closeModalButton!],
                                    if (widget.showWindowControls && !_isModal)
                                      LdReveal(
                                        revealed: _showWindowsWindowControls,
                                        child: const WindowsWindowControls(),
                                      ),
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
