import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/macos_window_controls.dart';
import 'package:liquid_flutter/src/appbar/windows_window_controls.dart';
import 'package:liquid_flutter/src/notifications/implicit_blur.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

enum LdAppBarShadowMode {
  visible,
  whenScrolled,
  hidden,
}

enum LdAppBarBorderMode {
  visible,
  whenScrolled,
  hidden,
}

class LdAppBar extends StatefulWidget {
  final Widget? title;
  final Widget? leading;
  final Widget? trailing;

  final bool? primary;
  final bool disableSafeArea;
  final Color? backgroundColor;
  final bool? implyLeading;
  final bool addContainer;
  final bool elevateOnScroll;
  final bool blurOnScroll;
  final Widget? bottom;
  final LdAppBarShadowMode shadowMode;
  final LdAppBarBorderMode borderMode;

  final List<LdLabeledAction> actions;

  final double? height;

  static LdWindowCallbacks? callbacks;

  final List<SingleChildWidget> Function(BuildContext context)? overflowMenuProviders;

  final LdSearchConfig? searchConfig;

  final String? debugName;

  const LdAppBar({
    super.key,
    this.title,
    this.height,
    this.actions = const [],
    this.leading,
    this.trailing,
    this.primary,
    this.backgroundColor,
    this.blurOnScroll = false,
    this.searchConfig,
    this.addContainer = false,
    this.implyLeading,
    this.bottom,
    this.disableSafeArea = false,
    this.elevateOnScroll = true,
    this.shadowMode = LdAppBarShadowMode.whenScrolled,
    this.borderMode = LdAppBarBorderMode.whenScrolled,
    this.overflowMenuProviders,
    this.debugName,
  });

  @override
  State<LdAppBar> createState() => _LdAppBarState();
}

class _LdAppBarState extends State<LdAppBar> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  LdScaffoldLayoutState? get _layoutState {
    return context.watch<LdScaffoldLayoutState?>();
  }

  bool get _canPopParentRoute {
    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);

    final bool canPop = parentRoute?.canPop ?? false;

    return canPop;
  }

  bool get _hasDrawer {
    return _scaffold?.hasDrawer ?? false;
  }

  bool get _isDrawerOpen {
    return _layoutState?.isDrawerOpen ?? false;
  }

  bool get _isDrawer {
    return _layoutState?.parentLayoutState?.slot == LdScaffoldSlot.drawer;
  }

  bool get _isDrawerAppBar {
    return _layoutState?.slot == LdScaffoldSlot.appBar && _isDrawer;
  }

  bool get _isAppBar {
    return _layoutState?.slot == LdScaffoldSlot.appBar;
  }

  bool get _isBottomNavigationBar {
    return _layoutState?.slot == LdScaffoldSlot.secondaryNavigationBarBottom;
  }

  bool get _isSideBySide {
    return _layoutState?.parentLayoutState?.isSideBySide ?? false;
  }

  bool get _showOpenDrawerButton {
    return _hasDrawer && !_isDrawerOpen && (_isAppBar);
  }

  bool get _showCloseDrawerButton {
    return _isDrawerAppBar && (_layoutState?.parentLayoutState?.isDrawerOpen ?? false) && _isSideBySide;
  }

  LdScaffoldSlot? get _slot {
    return _layoutState?.slot ?? LdScaffoldSlot.appBar;
  }

  bool get _showWindowsWindowControls {
    return LdTheme.of(context).platform == LdPlatform.windows && _slot == LdScaffoldSlot.appBar;
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.leading != null) return widget.leading;
    final imply = widget.implyLeading ?? true;
    if (!imply) return null;

    if (_canPopParentRoute && !_isDrawer) {
      return LdButtonGhost(
        child: const Icon(LucideIcons.chevronLeft),
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    return null;
  }

  LdScaffoldState? get _scaffold {
    return context.findAncestorStateOfType<LdScaffoldState>();
  }

  EdgeInsets _padding(BuildContext context) {
    final theme = LdTheme.of(context);
    final basePadding = theme.paddingSize(size: LdSize.s);
    return EdgeInsets.all(basePadding);
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

  EdgeInsets get _outsideContainerPadding {
    final EdgeInsets verticalSpace = EdgeInsets.only(
      bottom: LdTheme.of(context).paddingSize(size: LdSize.s),
    );
    final radiusPadding = EdgeInsets.all(LdTheme.of(context).screenRadius / 4);
    if (_isBottomNavigationBar) {
      final mediaPadding = MediaQuery.of(context).padding;
      final viewInsets = MediaQuery.of(context).viewInsets;
      final pad = LdTheme.of(context).pad(size: LdSize.s);

      final result = (mediaPadding + verticalSpace)
          .atLeast(viewInsets + verticalSpace)
          .atLeast(pad + verticalSpace)
          .atLeast(radiusPadding + verticalSpace)
          .remove(top: true);

      return result;
    }

    return MediaQuery.of(context).padding.atLeast(radiusPadding).remove(
          bottom: true,
        );
  }

  bool get _attached {
    return switch (_slot) {
      LdScaffoldSlot.appBar => true,
      LdScaffoldSlot.secondaryNavigationBarTop => true,
      _ => false,
    };
  }

  bool _shouldShowShadow(bool isScrolledUnder) {
    return switch (widget.shadowMode) {
      LdAppBarShadowMode.visible => true,
      LdAppBarShadowMode.whenScrolled => isScrolledUnder,
      LdAppBarShadowMode.hidden => false,
    };
  }

  bool _shouldShowBorder(bool isScrolledUnder) {
    return switch (widget.borderMode) {
      LdAppBarBorderMode.visible => true,
      LdAppBarBorderMode.whenScrolled => isScrolledUnder,
      LdAppBarBorderMode.hidden => false,
    };
  }

  /// Wraps the app bar in a container that applies the correct padding to make sure
  /// the app bar is not covered by the system UI or parent app bars.
  Widget _buildOutsideContainer(BuildContext context, bool isScrolledUnder, Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: _outsideContainerPadding,
      decoration: BoxDecoration(
        color: _attached ? _fillColor(isScrolledUnder).withAlpha(_fillOpacity(isScrolledUnder)) : null,
        boxShadow: [
          if (_attached)
            ldShadowSticky.copyWith(
              color: _shouldShowShadow(isScrolledUnder)
                  ? ldShadowSticky.color.withAlpha(isScrolledUnder ? 50 : 0)
                  : Colors.transparent,
            ),
        ],
        border: _attached
            ? Border(
                bottom: BorderSide(
                  color: _shouldShowBorder(isScrolledUnder)
                      ? LdTheme.of(context).border.withAlpha(_fillOpacity(isScrolledUnder))
                      : Colors.transparent,
                  width: LdTheme.of(context).borderWidth,
                ),
              )
            : null,
      ),
      child: child,
    );
  }

  int _fillOpacity(bool isScrolledUnder) {
    int opacity = 0;
    if (LdTheme.of(context).platform.isDesktop) {
      opacity = 255;
    }

    if (isScrolledUnder || _isBottomNavigationBar) {
      opacity = 255;
    }

    return opacity;
  }

  Color _fillColor(bool isScrolledUnder) {
    return Color.alphaBlend(
        (widget.backgroundColor ?? LdTheme.of(context).surface).withAlpha(_fillOpacity(isScrolledUnder)),
        LdTheme.of(context).background);
  }

  double _borderRadius(BuildContext context) {
    final theme = LdTheme.of(context);

    if (_slot == LdScaffoldSlot.secondaryNavigationBarTop) {
      return 0;
    }

    final radius = theme.screenRadius - _outsideContainerPadding.bottom;
    return radius < 1 ? theme.radiusSize(LdSize.m) : radius;
  }

  bool get _hasTopContent {
    return widget.title != null || widget.actions.isNotEmpty || widget.searchConfig != null;
  }

  Widget _buildInsideContainer(BuildContext context, bool isScrolledUnder, Widget child) {
    late BoxDecoration decoration;

    if (!_attached) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius(context)),
        color: _fillColor(isScrolledUnder),
        boxShadow: [
          ldShadowSticky.copyWith(
            color: _shouldShowShadow(isScrolledUnder) ? ldShadowSticky.color : Colors.transparent,
          ),
        ],
        border: Border.all(
          color: _shouldShowBorder(isScrolledUnder) ? LdTheme.of(context).floatingBorder : Colors.transparent,
          width: LdTheme.of(context).borderWidth,
        ),
      );
    } else {
      decoration = const BoxDecoration(
          //color: _fillColor(isScrolledUnder),

          );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: _padding(context),
      decoration: decoration,
      child: child,
    );
  }

  SystemUiOverlayStyle get _systemUiOverlayStyle {
    final theme = LdTheme.of(context, listen: true);
    if (theme.isDark) {
      return SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: theme.background.withAlpha(150),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      );
    }
    return SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
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
    final theme = LdTheme.of(context, listen: true);

    final layoutState = context.watch<LdScaffoldLayoutState>();

    final scrollListenable = switch (layoutState.slot) {
      LdScaffoldSlot.appBar => _layoutState?.bodyScrollOffset,
      LdScaffoldSlot.body => _layoutState?.bodyScrollOffset,
      LdScaffoldSlot.secondaryNavigationBarBottom => _layoutState?.bodyScrollOffset,
      LdScaffoldSlot.secondaryNavigationBarTop => _layoutState?.bodyScrollOffset,
      LdScaffoldSlot.drawer => _layoutState?.drawerScrollOffset,
    };

    final leading = _buildLeading(context);

    return ValueListenableBuilder(
        valueListenable: scrollListenable ?? ValueNotifier<double>(0),
        builder: (context, value, child) {
          final scrolledUnder = value > 10 || _isBottomNavigationBar;

          final visibleActions = widget.actions.where((e) => e.isVisible(context)).toList();

          final appBar = AnnotatedRegion<SystemUiOverlayStyle>(
            value: _systemUiOverlayStyle,
            child: _buildOutsideContainer(
              context,
              scrolledUnder,
              LdWrapConditional(
                condition: widget.blurOnScroll,
                builder: (context, child) => ClipRect(
                  child: ImplicitBlur(
                    sigma: scrolledUnder ? 5 : 0,
                    child: child,
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
                child: _buildInsideContainer(
                  context,
                  scrolledUnder,
                  LdWrapConditional(
                    condition: widget.addContainer,
                    builder: (context, child) => LdContainer(
                      padding: EdgeInsets.zero,
                      child: child,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LayoutBuilder(builder: (context, constraints) {
                          final hasSearch = widget.searchConfig != null;

                          return Row(
                            children: [
                              const MacOSWindowControls(),
                              if (_hasDrawer) ...[
                                LdReveal(
                                  revealed: _showOpenDrawerButton,
                                  child: const OpenDrawerButton(),
                                ),
                                ldSpacerS,
                              ],
                              if (leading != null) ...[leading, ldSpacerS],
                              if (widget.title != null || visibleActions.isNotEmpty || hasSearch)
                                Expanded(
                                    child: LdOverflowView(
                                  spacing: LdTheme.of(context).paddingSize(size: LdSize.xs),
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      widget.title == null ? MainAxisAlignment.start : MainAxisAlignment.center,
                                  builder: (context, remainingItemCount) {
                                    if (remainingItemCount > visibleActions.length) {
                                      return const SizedBox();
                                    }
                                    return LdAppbarActionOverflowMenu(
                                      layoutState: layoutState,
                                      actions: [...visibleActions.sublist(visibleActions.length - remainingItemCount)],
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
                                          isBottomNavigationBar: _isBottomNavigationBar,
                                          fullWidth: false,
                                        ),
                                      ),
                                    ...visibleActions.map(
                                      (e) => LdAppBarActionWidget(
                                        action: e,
                                        layoutState: layoutState,
                                        inMenu: false,
                                        menuProviders: widget.overflowMenuProviders,
                                      ),
                                    ),
                                  ],
                                ))
                              else
                                const SizedBox.shrink(),
                              LdReveal(revealed: _showCloseDrawerButton, child: const CloseDrawerButton()),
                              if (widget.trailing != null) widget.trailing!,
                              LdReveal(revealed: _showWindowsWindowControls, child: const WindowsWindowControls()),
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
                ),
              ),
            ),
          );

          return LdWrapConditional(
            condition: _isAppBar || _isDrawerAppBar,
            builder: (context, child) => GestureDetector(
              onPanStart: (details) {
                LdAppBar.callbacks?.onMove?.call();
              },
              onDoubleTap: () {
                LdScaffoldState.of(context).scrollToTop();
              },
              child: child,
            ),
            child: KeyedSubtree(
              key: _key,
              child: appBar,
            ),
          );
        });
  }
}

extension _WithoutPadding on EdgeInsets {
  EdgeInsets remove({bool bottom = false, bool top = false, bool left = false, bool right = false}) {
    return copyWith(
      bottom: bottom ? 0 : this.bottom,
      top: top ? 0 : this.top,
      left: left ? 0 : this.left,
      right: right ? 0 : this.right,
    );
  }
}

extension AtLeastBorderRadius on BorderRadius {
  BorderRadius atLeast(BorderRadius other) {
    return BorderRadius.only(
      topLeft: Radius.circular(max(topLeft.x, other.topLeft.x)),
      topRight: Radius.circular(max(topRight.x, other.topRight.x)),
      bottomLeft: Radius.circular(max(bottomLeft.x, other.bottomLeft.x)),
      bottomRight: Radius.circular(max(bottomRight.x, other.bottomRight.x)),
    );
  }
}
