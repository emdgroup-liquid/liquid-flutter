import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Whether the keyboard (or another UI) is obscuring part of the viewport.
bool _hasKeyboardViewInsets(MediaQueryData mediaQuery) {
  return mediaQuery.viewInsets.bottom > 0 || mediaQuery.viewInsets.top > 0;
}

/// Shrinks the scroll viewport above the keyboard without changing [MediaQuery]
/// above this subtree (so [LdAppBar] metrics stay stable).
///
/// Matches Material [Scaffold.resizeToAvoidBottomInset] but scoped to the body
/// scroll area only.
Widget _scrollViewportForKeyboard(
  BuildContext context,
  Widget scrollChild, {
  bool enabled = true,
}) {
  if (!enabled) {
    return _mediaQueryForScrollChild(context, scrollChild);
  }

  final mediaQuery = MediaQuery.of(context);
  final bottomInset = mediaQuery.viewInsets.bottom;

  // Stable structure when the keyboard opens — do not toggle wrappers.
  return MediaQuery(
    data: mediaQuery.removeViewInsets(removeBottom: true),
    child: Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: _mediaQueryForScrollChild(context, scrollChild),
    ),
  );
}
/// Strips vertical [MediaQueryData.padding] for scroll content without touching
/// [MediaQueryData.viewPadding] (unlike [MediaQuery.removePadding]).
///
/// When the keyboard is open we keep vertical padding on the scroll subtree so
/// [Scrollable] / [Scrollable.ensureVisible] respect [LdAppBar] insets.
Widget _mediaQueryForScrollChild(BuildContext context, Widget child) {
  final mediaQuery = MediaQuery.of(context);
  // Always wrap in [MediaQuery] so the scroll subtree keeps a stable widget
  // structure when the keyboard opens. Toggling between a wrapper and a bare
  // [child] remounts scroll content and drops body input focus.
  final verticalPadding =
      _hasKeyboardViewInsets(mediaQuery) ? mediaQuery.padding : mediaQuery.padding.copyWith(top: 0, bottom: 0);
  return MediaQuery(
    data: mediaQuery.copyWith(padding: verticalPadding),
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
        child: _scrollViewportForKeyboard(
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
  final bool shrinkWrap;

  /// When true, fades the top and bottom edges when more content is scrollable.
  final bool scrollEdgeFade;

  /// Height of each scroll-edge fade band. Uses theme sizing when null.
  final double? scrollEdgeFadeExtent;

  /// When true, the scroll viewport shrinks above the keyboard.
  final bool resizeToAvoidBottomInset;

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
    this.shrinkWrap = false,
    this.scrollEdgeFadeExtent,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding.atLeast(mediaQuery.viewPadding);

    final theme = LdTheme.of(context, listen: true);

    final themePadding = minimumPadding ?? theme.pad();
    final verticalSliverPadding = EdgeInsets.only(
      top: themePadding.top + padding.top,
      bottom: themePadding.bottom + padding.bottom,
    );

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
        shrinkWrap: shrinkWrap,
        slivers: [
          if (effectiveChildren.isNotEmpty)
            SliverPadding(
              padding: horizontalPadding.copyWith(
                top: verticalSliverPadding.top,
                bottom: verticalSliverPadding.bottom,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: effectiveChildren,
                ),
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
                  top: isFirst ? verticalSliverPadding.top : 0,
                  bottom: isLast ? verticalSliverPadding.bottom : 0,
                ),
                sliver: sliver,
              );
            }),
        ],
      );

      final effectiveColor = backgroundColor ?? (context.isSurface ? theme.surface : theme.background);

      final scrollContent = scrollEdgeFade
          ? LdScrollEdgeFade(
              fadeColor: effectiveColor,
              fadeExtent: scrollEdgeFadeExtent,
              child: scrollView,
            )
          : scrollView;

      return ColoredBox(
        color: effectiveColor,
        child: _scrollViewportForKeyboard(
          context,
          scrollContent,
          enabled: resizeToAvoidBottomInset,
        ),
      );
    });
  }
}
