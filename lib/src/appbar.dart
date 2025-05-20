import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final double? elevation;
  final IconThemeData? iconTheme;
  final bool? primary;
  final bool? centerTitle;
  final double? titleSpacing;
  final double? toolbarOpacity;
  final double? bottomOpacity;
  final double? toolbarHeight;
  final TextStyle? titleTextStyle;
  final Color? backgroundColor;
  final IconThemeData? actionsIconTheme;
  final Widget? flexibleSpace;
  final Color? foregroundColor;
  final bool? automaticallyImplyLeading;
  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final TextStyle? toolbarTextStyle;
  final double? leadingWidth;
  final ScrollNotificationPredicate? notificationPredicate;
  final bool? forceMaterialTransparency;
  final double? scrolledUnderElevation;
  final Color? surfaceTintColor;
  final bool? excludeHeaderSemantics;
  final BuildContext? context;
  final bool loading;
  final bool actionsDisabled;

  const LdAppBar({
    super.key,
    @Deprecated(
      "Context is no longer needed you can simply remove this parameter",
    )
    this.context,
    this.title,
    this.actions,
    this.leading,
    this.elevation,
    this.iconTheme,
    this.primary,
    this.centerTitle,
    this.titleSpacing,
    this.toolbarOpacity,
    this.bottomOpacity,
    this.toolbarHeight,
    this.titleTextStyle,
    this.backgroundColor,
    this.actionsIconTheme,
    this.flexibleSpace,
    this.foregroundColor,
    this.automaticallyImplyLeading,
    this.clipBehavior,
    this.shape,
    this.toolbarTextStyle,
    this.leadingWidth,
    this.notificationPredicate,
    this.forceMaterialTransparency,
    this.scrolledUnderElevation,
    this.surfaceTintColor,
    this.excludeHeaderSemantics,
    this.loading = false,
    this.actionsDisabled = false,
  });

  @override
  Size get preferredSize {
    if (toolbarHeight != null) {
      return Size.fromHeight(toolbarHeight! + 1);
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const Size.fromHeight(kToolbarHeight + 1);
      default:
        return const Size.fromHeight(kToolbarHeight + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          key: key,
          leading: leading,
          elevation: elevation,
          iconTheme: iconTheme,
          primary: primary ?? true,
          centerTitle: centerTitle,
          titleSpacing: titleSpacing,
          toolbarOpacity: toolbarOpacity ?? 1.0,
          bottomOpacity: bottomOpacity ?? 1.0,
          toolbarHeight: toolbarHeight ?? (theme.themeSize == LdThemeSize.s ? 48 : kToolbarHeight),
          titleTextStyle: titleTextStyle,
          backgroundColor: backgroundColor,
          actionsIconTheme: actionsIconTheme,
          flexibleSpace: flexibleSpace,
          foregroundColor: foregroundColor,
          automaticallyImplyLeading: automaticallyImplyLeading ?? true,
          clipBehavior: clipBehavior ?? Clip.none,
          shape: shape,
          toolbarTextStyle: toolbarTextStyle,
          leadingWidth: leadingWidth,
          notificationPredicate: notificationPredicate ?? (notification) => notification.depth == 0,
          forceMaterialTransparency: forceMaterialTransparency ?? false,
          scrolledUnderElevation: scrolledUnderElevation,
          surfaceTintColor: surfaceTintColor,
          excludeHeaderSemantics: excludeHeaderSemantics ?? false,
          shadowColor: theme.neutralShade(1),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: theme.surface,
            systemNavigationBarColor: theme.surface,
            systemNavigationBarIconBrightness: theme.isDark ? Brightness.light : Brightness.dark,
            statusBarIconBrightness: theme.isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: theme.isDark ? Brightness.dark : Brightness.light,
          ),
          title: DefaultTextStyle(
            style: ldBuildTextStyle(
              theme,
              LdTextType.headline,
              LdSize.s,
            ),
            child: title ?? const SizedBox(),
          ),
          actions: actions?.map((action) {
            if (actionsDisabled) {
              // Wrap each action in an AbsorbPointer to block interactions
              return AbsorbPointer(
                child: Opacity(
                  // Optionally reduce opacity to indicate disabled state
                  opacity: 0.5,
                  child: action,
                ),
              );
            }
            return action;
          }).toList(),
        ),
        if (loading)
          LinearProgressIndicator(
            minHeight: 1,
            backgroundColor: LdTheme.of(context).surface,
            valueColor: AlwaysStoppedAnimation<Color>(
              LdTheme.of(context).primaryColor,
            ),
            value: null,
          )
        else
          const LdDivider(height: 1),
      ],
    );
  }
}
