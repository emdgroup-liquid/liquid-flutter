import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdAppBar extends AppBar {
  LdAppBar({
    super.key,
    required BuildContext context,
    Widget? title,
    super.actions,
    super.leading,
    super.elevation,
    super.iconTheme,
    super.primary,
    super.centerTitle,
    super.titleSpacing,
    super.toolbarOpacity,
    super.bottomOpacity,
    double? toolbarHeight,
    super.titleTextStyle,
    super.backgroundColor,
    super.actionsIconTheme,
    super.flexibleSpace,
    super.foregroundColor,
    super.automaticallyImplyLeading,
    super.clipBehavior,
    super.shape,
    super.toolbarTextStyle,
    super.leadingWidth,
    super.notificationPredicate,
    super.forceMaterialTransparency,
    super.scrolledUnderElevation,
    super.surfaceTintColor,
    super.excludeHeaderSemantics,
  }) : super(
          shadowColor: LdTheme.of(context, listen: true).neutralShade(1),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: LdTheme.of(context).surface,
            systemNavigationBarColor: LdTheme.of(context).surface,
            systemNavigationBarIconBrightness:
                LdTheme.of(context).isDark ? Brightness.light : Brightness.dark,
            statusBarIconBrightness:
                LdTheme.of(context).isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                LdTheme.of(context).isDark ? Brightness.dark : Brightness.light,
          ),
          title: DefaultTextStyle(
            style: ldBuildTextStyle(
              LdTheme.of(context),
              LdTextType.headline,
              LdSize.s,
            ),
            child: title ?? const SizedBox(),
          ),
          toolbarHeight: toolbarHeight ??
              (LdTheme.of(context).themeSize == LdThemeSize.s
                  ? 48
                  : kToolbarHeight),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: LdDivider(
              height: 1,
            ),
          ),
        );
}
