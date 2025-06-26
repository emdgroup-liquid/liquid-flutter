import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/conditional_parent.dart';
import 'package:liquid_flutter/src/notifications/implicit_blur.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:overflow_view/overflow_view.dart';

class LdAppBar extends StatefulWidget {
  final Widget? title;
  final Widget? leading;
  final Widget? trailing;
  final bool? centerTitle;
  final bool? primary;
  final Color? backgroundColor;
  final bool? implyLeading;
  final bool addContainer;
  final bool elevateOnScroll;
  final bool blurOnScroll;
  final Widget? bottom;

  final double? height;

  const LdAppBar({
    super.key,
    this.title,
    this.height,
    this.leading,
    this.trailing,
    this.centerTitle,
    this.primary,
    this.backgroundColor,
    this.blurOnScroll = false,
    this.addContainer = false,
    this.implyLeading,
    this.bottom,
    this.elevateOnScroll = true,
  });

  @override
  State<LdAppBar> createState() => _LdAppBarState();
}

class _LdAppBarState extends State<LdAppBar> {
  bool _scrolledUnder = false;

  ScrollNotificationObserverState? _scrollNotificationObserver;

  bool get _isDesktop {
    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.macOS || platform == TargetPlatform.linux || platform == TargetPlatform.windows;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollNotificationObserver = ScrollNotificationObserver.maybeOf(context);
      _scrollNotificationObserver?.addListener(_handleScrollNotification);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollNotificationObserver?.removeListener(_handleScrollNotification);
    _scrollNotificationObserver = null;
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      final bool scrolled = notification.metrics.extentBefore > 0;
      if (scrolled != _scrolledUnder) {
        setState(() {
          _scrolledUnder = scrolled;
        });
      }
    }
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.leading != null) return widget.leading;
    final imply = widget.implyLeading ?? true;
    if (!imply) return null;

    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);

    final bool canPop = parentRoute?.canPop ?? false;

    if (canPop) {
      return LdButtonGhost(
        child: const Icon(LucideIcons.chevronLeft),
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    final scaffold = Scaffold.maybeOf(context);
    if (scaffold?.hasDrawer ?? false) {
      return LdButtonGhost(
        child: const Icon(LucideIcons.menu),
        onPressed: () => scaffold?.openDrawer(),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final backgroundColor = widget.backgroundColor ?? theme.surface;

    final leading = _buildLeading(context);

    final hasLeadingOrTrailing = leading != null || widget.trailing != null;

    final isCenterTitle = widget.centerTitle ?? (!_isDesktop && !hasLeadingOrTrailing);

    final appBar = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(boxShadow: [
        if (!widget.blurOnScroll)
          BoxShadow(
            color: theme.palette.neutral.shades.last.withAlpha(_scrolledUnder ? 10 : 0),
            blurRadius: 10,
            spreadRadius: 10,
          ),
      ]),
      child: LdWrapConditional(
        condition: widget.blurOnScroll,
        builder: (context, child) => ClipRect(
          child: ImplicitBlur(
            sigma: _scrolledUnder ? 10 : 0,
            child: child,
            duration: const Duration(milliseconds: 300),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: backgroundColor.withAlpha(
              widget.blurOnScroll ? 100 : 255,
            ),
          ),
          child: SafeArea(
            top: widget.primary ?? true,
            bottom: false,
            minimum: LdTheme.of(context).pad(size: LdSize.m),
            child: LdWrapConditional(
              condition: widget.addContainer,
              builder: (context, child) => LdContainer(
                padding: EdgeInsets.zero,
                child: child,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (leading != null) ...[
                        Flexible(child: leading),
                      ],
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: isCenterTitle ? Alignment.center : Alignment.centerLeft,
                                child: DefaultTextStyle(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ldBuildTextStyle(
                                    theme,
                                    LdTextType.headline,
                                    LdSize.s,
                                    lineHeight: 1,
                                  ),
                                  child: widget.title ?? const SizedBox(),
                                ),
                              ),
                            ),
                            if (widget.trailing != null) ...[
                              Flexible(child: widget.trailing!),
                            ],
                          ],
                        ).spaceM(),
                      ),
                    ],
                  ).spaceM(),
                  if (widget.bottom != null) ...[
                    widget.bottom!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        appBar,
        const LdDivider(height: 1),
      ],
    );
  }
}

mixin LdLabeledAction {
  String label(BuildContext context);
  Widget? icon(BuildContext context);
  String? loadingText(BuildContext context);

  bool isVisible(BuildContext context) {
    return true;
  }

  FutureOr<void> onPressed(BuildContext context);

  LdColor? color(BuildContext context) {
    return null;
  }

  LdLabeledActionSubmitType get submitType => LdLabeledActionSubmitType.notification;
}

enum LdLabeledActionSubmitType { none, notification, dialog }

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
                  data: IconThemeData(color: action.color(context)?.center(LdTheme.of(context).isDark)),
                  child: icon,
                )
              : null,
          title: Text(label),
        ),
      );
    } else {
      return LdReveal.quick(
        revealed: action.isVisible(context),
        child: Tooltip(
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
        ),
      );
    }
  }
}

class LdAppBarActions extends StatelessWidget {
  final List<LdLabeledAction> actions;

  const LdAppBarActions({super.key, required this.actions});

  Widget _buildAction(BuildContext context, LdLabeledAction action, bool bigToolbar, bool inMenu) {
    if (inMenu) {
      print("inMenu");
      print(action.label(context));
    }
    switch (action.submitType) {
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bigToolbar = constraints.maxWidth > 200 || actions.length < 2;

      return OverflowView.flexible(
        children: [
          ...actions.map(
            (e) => _buildAction(context, e, bigToolbar, false),
          ),
        ],
        builder: (context, remaining) => LdContextMenu(
          scaleFromTrigger: true,
          builder: (context, isOpen, open, child) => LdButtonGhost(
            onPressed: open,
            child: const Icon(LucideIcons.ellipsisVertical),
          ),
          menuBuilder: (context, close) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: ListView(
              shrinkWrap: true,
              children: [
                ...actions.sublist(actions.length - remaining).map(
                      (e) => _buildAction(
                        context,
                        e,
                        bigToolbar,
                        true,
                      ),
                    ),
              ],
            ),
          ),
        ),
      );
    });
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
