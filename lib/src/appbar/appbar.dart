import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart'
    hide LdLabeledAction, LdLabeledActionSubmitType, LdAppBarAction, LdWindowCallbacks, LdAppbarActionOverflowMenu;
import 'package:liquid_flutter/src/conditional_parent.dart';
import 'package:liquid_flutter/src/notifications/implicit_blur.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:overflow_view/overflow_view.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'app_bar_action.dart';
import 'appbar_action_overflow_menu.dart';
import 'labeled_action.dart';
import 'window_callbacks.dart';

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

  final List<LdLabeledAction> actions;

  final double? height;

  static LdWindowCallbacks? callbacks;

  final List<SingleChildWidget> Function(BuildContext context)? overflowMenuProviders;

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
    this.addContainer = false,
    this.implyLeading,
    this.bottom,
    this.disableSafeArea = false,
    this.elevateOnScroll = true,
    this.overflowMenuProviders,
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
    return _layoutState?.slot == LdScaffoldSlot.drawer;
  }

  bool get _isAppBar {
    return _layoutState?.slot == LdScaffoldSlot.appBar;
  }

  bool get _isBottomNavigationBar {
    return _layoutState?.slot == LdScaffoldSlot.bottomNavigationBar ||
        _layoutState?.slot == LdScaffoldSlot.drawerBottomNavigationBar;
  }

  bool get _isSideBySide {
    return _layoutState?.isSideBySide ?? false;
  }

  bool get _showOpenDrawerButton {
    return _hasDrawer && !_isDrawerOpen && (_isAppBar);
  }

  bool get _showCloseDrawerButton {
    return _slot == LdScaffoldSlot.drawerAppBar && _isDrawerOpen && _isSideBySide;
  }

  LdScaffoldSlot? get _slot {
    return _layoutState?.slot ?? LdScaffoldSlot.appBar;
  }

  bool get _showWindowsWindowControls {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.windows && _slot == LdScaffoldSlot.appBar;
  }

  bool get _showMacOSWindowControls {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.macOS) {
      return false;
    }

    final slot = _slot;

    if (slot == null) {
      return false;
    }

    if (_slot == LdScaffoldSlot.drawerAppBar && _isDrawerOpen) {
      return true;
    }

    if (_slot == LdScaffoldSlot.appBar && !_isDrawerOpen && _layoutState?.level == 1) {
      return true;
    }

    return false;
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.leading != null) return widget.leading;
    final imply = widget.implyLeading ?? true;
    if (!imply) return null;

    if (_canPopParentRoute && !_isDrawerOpen) {
      return LdButtonGhost(
        size: LdSize.s,
        child: const Icon(LucideIcons.chevronLeft),
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    return null;
  }

  LdScaffoldState? get _scaffold {
    return context.findAncestorStateOfType<LdScaffoldState>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final layoutState = context.watch<LdScaffoldLayoutState>();

    Color backgroundColor;

    if (widget.backgroundColor == null) {
      backgroundColor = theme.surface;
    } else {
      backgroundColor = widget.backgroundColor!;
    }

    final scrollListenable = switch (layoutState.slot) {
      LdScaffoldSlot.appBar => _layoutState?.bodyScrollOffset,
      LdScaffoldSlot.body => _layoutState?.bodyScrollOffset,
      LdScaffoldSlot.bottomNavigationBar => _layoutState?.bodyScrollOffset,
      LdScaffoldSlot.drawer => _layoutState?.drawerScrollOffset,
      LdScaffoldSlot.drawerAppBar => _layoutState?.drawerScrollOffset,
      LdScaffoldSlot.drawerBottomNavigationBar => _layoutState?.drawerScrollOffset,
      LdScaffoldSlot.drawerBody => _layoutState?.drawerScrollOffset,
    };

    final leading = _buildLeading(context);

    final headerStyle = switch (theme.themeSize) {
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

    final appBar = ValueListenableBuilder(
        valueListenable: scrollListenable ?? ValueNotifier<double>(0),
        builder: (context, value, child) {
          final scrolledUnder = value > 10;

          return AnimatedContainer(
            width: double.infinity,
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(boxShadow: [
              if (!widget.blurOnScroll)
                BoxShadow(
                  color: theme.palette.neutral.shades.last.withAlpha(scrolledUnder || _isBottomNavigationBar ? 10 : 0),
                  blurRadius: 10,
                  spreadRadius: 10,
                ),
            ]),
            child: LdWrapConditional(
              condition: widget.blurOnScroll,
              builder: (context, child) => ClipRect(
                child: ImplicitBlur(
                  sigma: scrolledUnder ? 10 : 0,
                  child: child,
                  duration: const Duration(milliseconds: 300),
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                color: backgroundColor.withAlpha(widget.blurOnScroll && scrolledUnder ? 150 : 255),
                child: LdWrapConditional(
                  condition: widget.disableSafeArea,
                  builder: (context, child) => child.padS(),
                  child: LdWrapConditional(
                    condition: !widget.disableSafeArea,
                    builder: (context, child) => Padding(
                      padding: EdgeInsetsGeometry.only(
                        left: max(MediaQuery.paddingOf(context).left, LdTheme.of(context).pad(size: LdSize.s).left),
                        right: max(MediaQuery.paddingOf(context).right, LdTheme.of(context).pad(size: LdSize.s).right),
                        top: LdTheme.of(context).pad(size: LdSize.s).top +
                            (_isAppBar ? MediaQuery.paddingOf(context).top : 0),
                        bottom: max(LdTheme.of(context).pad(size: LdSize.s).bottom,
                            (_isBottomNavigationBar ? MediaQuery.paddingOf(context).bottom : 0)),
                      ),
                      child: child,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: switch (theme.themeSize) {
                          (LdThemeSize.s) => 34,
                          (LdThemeSize.m || LdThemeSize.l) => 34,
                        },
                      ),
                      child: LdWrapConditional(
                        condition: widget.addContainer,
                        builder: (context, child) => LdContainer(
                          padding: EdgeInsets.zero,
                          child: child,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                MacOSWindowControls(showWindowControls: _showMacOSWindowControls),
                                if (_showOpenDrawerButton) ...[
                                  const OpenDrawerButton(),
                                  ldSpacerS,
                                ],
                                if (leading != null) ...[
                                  leading,
                                  ldSpacerS,
                                ],
                                /*if (widget.title != null || widget.actions.isNotEmpty)
                                  Expanded(
                                    child: OverflowView(
                                      spacing: LdTheme.of(context).paddingSize(size: LdSize.xs),
                                      layoutBehavior: OverflowViewLayoutBehavior.expandFirstFlexible,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      builder: (context, remainingItemCount) {
                                        return LdAppbarActionOverflowMenu(
                                          actions: widget.actions.sublist(widget.actions.length - remainingItemCount),
                                          bigToolbar: true,
                                          menuProviders: widget.overflowMenuProviders,
                                          inMenu: true,
                                        );
                                      },
                                      children: [
                                        if (widget.title != null)
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: DefaultTextStyle(
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: headerStyle,
                                              child: widget.title ?? const SizedBox(),
                                            ),
                                          ),
                                        ...widget.actions.where((e) => e.isVisible(context)).map(
                                              (e) => LdAppBarAction(
                                                action: e,
                                                bigToolbar: true,
                                                inMenu: false,
                                                menuProviders: widget.overflowMenuProviders,
                                              ),
                                            ),
                                      ],
                                    ),
                                  )
                                else
                                  const Spacer(),*/
                                if (_showCloseDrawerButton) const CloseDrawerButton(),
                                if (_showWindowsWindowControls) const WindowsWindowControls(),
                                if (widget.trailing != null) widget.trailing!,
                              ],
                            ),
                            if (widget.bottom != null) ...[
                              Padding(
                                padding: EdgeInsets.only(
                                  top: LdTheme.of(context).pad(size: LdSize.s).top,
                                  left: LdTheme.of(context).pad(size: LdSize.s).left,
                                  right: LdTheme.of(context).pad(size: LdSize.s).right,
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
              ),
            ),
          );
        });

    return Column(
      mainAxisSize: MainAxisSize.min,
      key: _key,
      children: [
        if (_isBottomNavigationBar) const LdDivider(),
        appBar,
        if (!_isBottomNavigationBar) const LdDivider(height: 1),
      ],
    );
  }
}

class MacOSWindowControls extends StatelessWidget {
  const MacOSWindowControls({
    super.key,
    required bool showWindowControls,
  }) : _showWindowControls = showWindowControls;

  final bool _showWindowControls;

  @override
  Widget build(BuildContext context) {
    return LdReveal(
      initialRevealed: _showWindowControls,
      revealed: _showWindowControls,
      child: Row(
        children: [
          Tooltip(
            message: LiquidLocalizations.of(context).close,
            child: LdButtonGhost(
              size: LdSize.xs,
              color: LdTheme.of(context).error,
              child: const Icon(Icons.circle),
              onPressed: () {
                LdAppBar.callbacks?.onClose?.call();
              },
            ),
          ),
          Tooltip(
            message: LiquidLocalizations.of(context).minimize,
            child: LdButtonGhost(
              size: LdSize.xs,
              color: LdTheme.of(context).warning,
              child: const Icon(Icons.circle),
              onPressed: () {
                LdAppBar.callbacks?.onMinimize?.call();
              },
            ),
          ),
          Tooltip(
            message: LiquidLocalizations.of(context).maximize,
            child: LdButtonGhost(
              size: LdSize.xs,
              color: LdTheme.of(context).success,
              child: const Icon(Icons.circle),
              onPressed: () {
                LdAppBar.callbacks?.onMaximize?.call();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WindowsWindowControls extends StatelessWidget {
  const WindowsWindowControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LdButtonVague(
          size: LdSize.s,
          child: const Icon(LucideIcons.minus),
          onPressed: () {
            LdAppBar.callbacks?.onMinimize?.call();
          },
        ),
        LdButtonVague(
          size: LdSize.s,
          child: const Icon(LucideIcons.square),
          onPressed: () {
            LdAppBar.callbacks?.onMaximize?.call();
          },
        ),
        LdButtonVague(
          size: LdSize.s,
          child: const Icon(LucideIcons.x),
          onPressed: () {
            LdAppBar.callbacks?.onClose?.call();
          },
        ),
      ],
    );
  }
}
