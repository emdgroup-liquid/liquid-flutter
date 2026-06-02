import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Strips vertical [MediaQueryData.padding] for scroll content without touching
/// [MediaQueryData.viewPadding] (unlike [MediaQuery.removePadding]).
Widget _mediaQueryWithoutVerticalPadding(BuildContext context, Widget child) {
  final mediaQuery = MediaQuery.of(context);
  return MediaQuery(
    data: mediaQuery.copyWith(
      padding: mediaQuery.padding.copyWith(top: 0, bottom: 0),
    ),
    child: child,
  );
}

class LdScaffoldBodyCentered extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? minimumPadding;
  final bool addContainer;
  const LdScaffoldBodyCentered({
    super.key,
    required this.child,
    this.backgroundColor,
    this.minimumPadding,
    this.addContainer = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final themePadding = minimumPadding ?? theme.pad();
    var padding = MediaQuery.paddingOf(context).atLeast(MediaQuery.viewPaddingOf(context)).atLeast(themePadding);

    return LayoutBuilder(builder: (context, constraints) {
      if (addContainer) {
        final maxWidthPadding = EdgeInsets.only(
            left: (constraints.maxWidth - theme.sizingConfig.containerMaxWidth) / 2,
            right: (constraints.maxWidth - theme.sizingConfig.containerMaxWidth) / 2);
        padding = padding.atLeast(maxWidthPadding);
      }

      return Container(
        color: backgroundColor ?? Colors.transparent,
        padding: padding,
        child: _mediaQueryWithoutVerticalPadding(
          context,
          Center(child: child),
        ),
      );
    });
  }
}

class LdScaffoldBody extends StatelessWidget {
  final List<Widget> children;
  final List<Widget> slivers;
  final EdgeInsets? minimumPadding;
  final Color? backgroundColor;
  final ScrollController? scrollController;
  final bool autoSpaceChildren;
  final bool addContainer;

  /// When true, fades the top and bottom edges when more content is scrollable.
  final bool scrollEdgeFade;

  /// Height of each scroll-edge fade band. Uses theme sizing when null.
  final double? scrollEdgeFadeExtent;
  const LdScaffoldBody({
    super.key,
    this.children = const [],

    /// The minimum padding to apply to the scaffold body. Defaults to [LdSize.m].
    this.minimumPadding,
    this.slivers = const [],
    this.scrollController,
    this.backgroundColor,
    this.autoSpaceChildren = true,
    this.addContainer = false,
    this.scrollEdgeFade = true,
    this.scrollEdgeFadeExtent,
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context).atLeast(MediaQuery.viewPaddingOf(context));

    final theme = LdTheme.of(context, listen: true);

    final themePadding = minimumPadding ?? theme.pad();

    final effectiveChildren = autoSpaceChildren ? children.autoSpace(context) : children;

    // Only pass an explicit [scrollController] when the caller provides one.
    // [LdScaffold] already wraps the body in [PrimaryScrollController]; attaching
    // the same controller here too can leave two scroll views on it during rebuilds
    // (e.g. when [ThemeData.platform] changes).

    return LayoutBuilder(builder: (context, constraints) {
      final basePadding = themePadding + padding;
      EdgeInsets horizontalPadding = basePadding;

      if (addContainer) {
        final maxWidthPadding = EdgeInsets.only(
            left: (constraints.maxWidth - theme.sizingConfig.containerMaxWidth) / 2,
            right: (constraints.maxWidth - theme.sizingConfig.containerMaxWidth) / 2);
        horizontalPadding = horizontalPadding.atLeast(maxWidthPadding);
      }

      final scrollView = CustomScrollView(
        controller: scrollController,
        slivers: [
          if (effectiveChildren.isNotEmpty)
            SliverPadding(
              padding: horizontalPadding.copyWith(
                top: (themePadding.top + padding.top),
                bottom: (themePadding.bottom + padding.bottom),
              ),
              sliver: SliverList.builder(
                itemCount: effectiveChildren.length,
                itemBuilder: (context, index) => effectiveChildren[index],
              ),
            ),
          if (slivers.isNotEmpty)
            ...slivers.asMap().entries.map((entry) {
              final index = entry.key;
              final sliver = entry.value;
              final isFirst = index == 0;
              final isLast = index == slivers.length - 1;

              return SliverPadding(
                padding: horizontalPadding.copyWith(
                  top: isFirst ? padding.top + themePadding.top : 0,
                  bottom: isLast ? padding.bottom + themePadding.bottom : 0,
                ),
                sliver: sliver,
              );
            }),
        ],
      );

      final fadeColor = backgroundColor ?? theme.background;

      return ColoredBox(
        color: backgroundColor ?? theme.background,
        child: _mediaQueryWithoutVerticalPadding(
          context,
          scrollEdgeFade
              ? LdScrollEdgeFade(
                  fadeColor: fadeColor,
                  fadeExtent: scrollEdgeFadeExtent,
                  child: scrollView,
                )
              : scrollView,
        ),
      );
    });
  }
}
