import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/conditional_parent.dart';
import 'package:liquid_flutter/src/notifications/implicit_blur.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:overflow_view/overflow_view.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class LdWindowCallbacks {
  void Function()? onClose;
  void Function()? onMinimize;
  void Function()? onMaximize;
  void Function()? onMove;

  LdWindowCallbacks({this.onClose, this.onMinimize, this.onMaximize, this.onMove});
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
    return _layoutState?.slot == LdScaffoldSlot.bottomNavigationBar;
  }

  bool get _isSideBySide {
    return _layoutState?.isSideBySide ?? false;
  }

  bool get _showOpenDrawerButton {
    return _hasDrawer && !_isDrawerOpen && (_isAppBar);
  }

  bool get _showCloseDrawerButton {
    return _hasDrawer && _isDrawerOpen && (_isDrawer && _isSideBySide);
  }

  bool get _showWindowControls {
    if (kIsWeb) {
      return false;
    }

    if (_layoutState?.level != 1) {
      return false;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        if (LdAppBar.callbacks == null) {
          debugPrint(
            "Warning: You have not set the window callbacks. \n"
            "Please configure LdAppBar.callbacks in your main function.",
          );
        }
        return _isDrawerOpen && _layoutState?.slot == LdScaffoldSlot.drawer ||
            !_isDrawerOpen && _layoutState?.slot == LdScaffoldSlot.appBar;
      default:
        return false;
    }
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

  IconData get _openDrawerIcon {
    final layoutState = _layoutState;
    if (layoutState?.isSideBySide ?? false) {
      return LucideIcons.panelLeftOpen;
    }
    return LucideIcons.menu;
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
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(boxShadow: [
              if (!widget.blurOnScroll)
                BoxShadow(
                  color: theme.palette.neutral.shades.last.withAlpha(scrolledUnder ? 10 : 0),
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
                  condition: !widget.disableSafeArea,
                  builder: (context, child) => SafeArea(
                    bottom: _isBottomNavigationBar,
                    top: _isAppBar,
                    child: child,
                  ),
                  child: Padding(
                    padding: switch (theme.themeSize) {
                      (LdThemeSize.s) => LdTheme.of(context).pad(size: LdSize.xs),
                      (LdThemeSize.m || LdThemeSize.l) => LdTheme.of(context).pad(size: LdSize.xs),
                    },
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
                          child: child,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Main row of the app bar

                            OverflowView(
                              spacing: LdTheme.of(context).paddingSize(),
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
                                Row(
                                  children: [
                                    LdReveal(
                                      initialRevealed: _showWindowControls,
                                      revealed: _showWindowControls,
                                      child: Row(
                                        children: [
                                          LdButtonGhost(
                                            size: LdSize.xs,
                                            color: LdTheme.of(context).error,
                                            child: const Icon(Icons.circle),
                                            onPressed: () {
                                              LdAppBar.callbacks?.onClose?.call();
                                            },
                                          ),
                                          LdButtonGhost(
                                            size: LdSize.xs,
                                            color: LdTheme.of(context).warning,
                                            child: const Icon(Icons.circle),
                                            onPressed: () {
                                              LdAppBar.callbacks?.onMinimize?.call();
                                            },
                                          ),
                                          LdButtonGhost(
                                            size: LdSize.xs,
                                            color: LdTheme.of(context).success,
                                            child: const Icon(Icons.circle),
                                            onPressed: () {
                                              LdAppBar.callbacks?.onMaximize?.call();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_showOpenDrawerButton) ...[
                                      const _OpenDrawerButton(),
                                    ],
                                    if (leading != null) ...[
                                      leading,
                                      ldSpacerM,
                                    ],
                                    if (widget.title != null)
                                      DefaultTextStyle(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: headerStyle,
                                        child: widget.title ?? const SizedBox(),
                                      ),
                                    if (widget.trailing != null) ...[
                                      widget.trailing!,
                                    ],
                                    if (_showCloseDrawerButton) ...[
                                      const _CloseDrawerButton(),
                                    ],
                                  ],
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
                            ).padHorizontal(),
                            if (widget.bottom != null) ...[
                              widget.bottom!.padM(),
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
        GestureDetector(
          onPanStart: (details) {
            LdAppBar.callbacks?.onMove?.call();
          },
          child: appBar,
        ),
        if (!_isBottomNavigationBar) const LdDivider(height: 1),
      ],
    );
  }
}

mixin LdLabeledAction {
  String label(BuildContext context);
  Widget? icon(BuildContext context);
  String? loadingText(BuildContext context);

  Widget? contextMenu(BuildContext context);

  bool isVisible(BuildContext context) {
    return true;
  }

  FutureOr<void> onPressed(BuildContext context);

  LdColor? color(BuildContext context) {
    return null;
  }

  LdLabeledActionSubmitType get submitType => LdLabeledActionSubmitType.notification;
}

enum LdLabeledActionSubmitType { none, notification, dialog, contextMenu }

class _ActionTriggerButton extends StatelessWidget {
  final LdLabeledAction action;
  final bool bigToolbar;
  final bool inMenu;
  final VoidCallback onPressed;
  final bool loading;
  final String? loadingText;
  final bool disabled;

  const _ActionTriggerButton({
    required this.action,
    required this.bigToolbar,
    required this.inMenu,
    required this.onPressed,
    this.loading = false,
    this.loadingText,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = action.icon(context);
    final label = action.label(context);
    if (inMenu) {
      return LdReveal.quick(
        revealed: action.isVisible(context),
        child: LdListItem(
          onTap: () {
            LdContextMenuDissmissNotification().dispatch(context);
            onPressed();
          },
          disabled: disabled,
          leading: icon != null
              ? IconTheme(
                  data: IconThemeData(
                    size: LdTheme.of(context).labelSize(null),
                    color:
                        action.color(context)?.center(LdTheme.of(context).isDark) ?? LdTheme.of(context).primaryColor,
                  ),
                  child: icon,
                )
              : null,
          title: Text(label),
        ),
      );
    } else {
      return Tooltip(
        message: action.label(context),
        child: LdButtonGhost(
          color: action.color(context),
          leading: bigToolbar ? icon : null,
          onPressed: onPressed,
          loadingText: loadingText,
          loading: loading,
          disabled: disabled,
          child: bigToolbar || icon == null ? Text(label) : icon,
        ),
      );
    }
  }
}

class LdAppBarAction extends StatelessWidget {
  final LdLabeledAction action;
  final bool bigToolbar;
  final List<SingleChildWidget> Function(BuildContext context)? menuProviders;
  final bool inMenu;

  const LdAppBarAction(
      {super.key, required this.action, required this.bigToolbar, required this.inMenu, this.menuProviders});

  @override
  Widget build(BuildContext context) {
    switch (action.submitType) {
      case LdLabeledActionSubmitType.contextMenu:
        return LdContextMenu(
          menuProviders: menuProviders,
          blurMode: LdContextMenuBlurMode.never,
          zoomMode: LdContextZoomMode.never,
          builder: (context, isOpen, open, child) => _ActionTriggerButton(
            action: action,
            bigToolbar: bigToolbar,
            loadingText: action.loadingText(context),
            inMenu: inMenu,
            onPressed: () => open(),
            disabled: false,
          ),
          menuBuilder: (context, close) => action.contextMenu.call(context) ?? const SizedBox(),
        );
      case LdLabeledActionSubmitType.none:
        return _ActionTriggerButton(
          action: action,
          bigToolbar: bigToolbar,
          loadingText: action.loadingText(context),
          inMenu: inMenu,
          onPressed: () => action.onPressed(context),
          disabled: false,
        );
      case LdLabeledActionSubmitType.notification:
      case LdLabeledActionSubmitType.dialog:
        final builder = action.submitType == LdLabeledActionSubmitType.notification
            ? LdSubmitNotificationBuilder<void, BuildContext>.new
            : LdSubmitDialogBuilder<void, BuildContext>.new;

        return LdSubmit<void, BuildContext>(
          arg: context,
          config: LdSubmitConfig(
            loadingText: action.loadingText(context),
            action: (context) async => action.onPressed(context!),
          ),
          builder: builder(
            submitButtonBuilder: (submitButtonBuilder, controller) {
              return _ActionTriggerButton(
                action: action,
                bigToolbar: bigToolbar,
                inMenu: inMenu,
                onPressed: controller.trigger,
                loading: controller.state.type == LdSubmitStateType.loading,
                loadingText: action.loadingText(context),
                disabled: !controller.canTrigger,
              );
            },
          ),
        );
    }
  }
}

class LdAppbarActionOverflowMenu extends StatelessWidget {
  final List<LdLabeledAction> actions;
  final bool bigToolbar;
  final List<SingleChildWidget> Function(BuildContext context)? menuProviders;

  final bool inMenu;

  const LdAppbarActionOverflowMenu({
    super.key,
    required this.actions,
    required this.bigToolbar,
    required this.inMenu,
    this.menuProviders,
  });

  @override
  Widget build(BuildContext context) {
    return LdContextMenu(
      menuProviders: menuProviders,
      scaleFromTrigger: true,
      builder: (context, isOpen, open, child) => LdButtonGhost(
        onPressed: open,
        child: const Icon(LucideIcons.ellipsisVertical),
      ),
      menuBuilder: (context, close) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            ...actions.map(
              (e) => LdAppBarAction(
                action: e,
                bigToolbar: bigToolbar,
                inMenu: inMenu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LdBottomBar extends StatelessWidget {
  final Widget child;

  const LdBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LdTheme.of(context).surface,
        border: Border(
          top: BorderSide(
            color: LdTheme.of(context).border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: LdTheme.of(context).pad(size: LdSize.s),
        child: child,
      ),
    );
  }
}

class _OpenDrawerButton extends StatelessWidget {
  const _OpenDrawerButton();

  @override
  Widget build(BuildContext context) {
    final layoutState = context.watch<LdScaffoldLayoutState?>();

    final icon = layoutState?.isSideBySide ?? false ? LucideIcons.panelLeftOpen : LucideIcons.menu;
    final scaffold = context.findAncestorStateOfType<LdScaffoldState>();
    return LdButtonGhost(
      size: LdSize.s,
      child: Icon(icon),
      onPressed: () => scaffold?.openDrawer(),
    );
  }
}

class _CloseDrawerButton extends StatelessWidget {
  const _CloseDrawerButton();

  @override
  Widget build(BuildContext context) {
    final layoutState = context.watch<LdScaffoldLayoutState?>();

    final icon = layoutState?.isSideBySide ?? false ? LucideIcons.panelLeftClose : LucideIcons.chevronRight;
    return LdButtonGhost(
      size: LdSize.s,
      child: Icon(icon),
      onPressed: () {
        Navigator.of(context).maybePop();
      },
    );
  }
}
