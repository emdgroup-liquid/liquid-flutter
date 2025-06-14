import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final Widget? trailing;
  final bool? centerTitle;
  final bool? primary;
  final Color? backgroundColor;
  final bool? implyLeading;
  final bool addContainer;
  final bool elevateOnScroll;

  const LdAppBar({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.centerTitle,
    this.primary,
    this.backgroundColor,
    this.addContainer = true,
    this.implyLeading,
    this.elevateOnScroll = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  State<LdAppBar> createState() => _LdAppBarState();
}

class _LdAppBarState extends State<LdAppBar> {
  bool _scrolledUnder = false;

  bool get _isDesktop {
    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.macOS ||
        platform == TargetPlatform.linux ||
        platform == TargetPlatform.windows;
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
        child: const Icon(LucideIcons.arrowLeft),
        onPressed: () => Navigator.of(context).maybePop(),
      );
    }

    final scaffold = Scaffold.of(context);
    if (scaffold.hasDrawer) {
      return LdButtonGhost(
        child: const Icon(LucideIcons.menu),
        onPressed: () => scaffold.openDrawer(),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final backgroundColor = widget.backgroundColor ?? theme.surface;
    final showShadow = _scrolledUnder && widget.elevateOnScroll != false;

    final leading = _buildLeading(context);

    final hasLeadingOrTrailing = leading != null || widget.trailing != null;

    final isCenterTitle =
        widget.centerTitle ?? (!_isDesktop && !hasLeadingOrTrailing);

    final appBar = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: theme.neutralShade(1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        top: widget.primary ?? true,
        bottom: false,
        minimum: EdgeInsets.zero,
        child: SizedBox(
          height: switch (theme.themeSize) {
            LdThemeSize.s => 46,
            LdThemeSize.m => 56,
            LdThemeSize.l => 64,
          },
          child: LdContainer(
            padding: LdTheme.of(context)
                .pad(size: LdSize.l)
                .copyWith(top: 0, bottom: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) ...[
                  leading,
                ],
                Expanded(
                  child: Align(
                    alignment:
                        isCenterTitle ? Alignment.center : Alignment.centerLeft,
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
                  widget.trailing!,
                ],
              ],
            ).spaceM(),
          ),
        ),
      ),
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _handleScrollNotification(notification);
        return false;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          appBar,
          const LdDivider(height: 1),
        ],
      ),
    );
  }
}
