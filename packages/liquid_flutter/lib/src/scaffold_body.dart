import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

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
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: Center(child: child),
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
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context).atLeast(MediaQuery.viewPaddingOf(context));

    final theme = LdTheme.of(context, listen: true);

    final themePadding = minimumPadding ?? theme.pad();

    final effectiveChildren = autoSpaceChildren ? children.autoSpace(context) : children;

    // Get the scroll controller from the scaffold if none provided
    final effectiveController =
        scrollController ?? (context.findAncestorStateOfType<LdScaffoldState>()?.effectiveScrollController);

    return LayoutBuilder(builder: (context, constraints) {
      final basePadding = themePadding + padding;
      EdgeInsets horizontalPadding = basePadding;

      if (addContainer) {
        final maxWidthPadding = EdgeInsets.only(
            left: (constraints.maxWidth - theme.sizingConfig.containerMaxWidth) / 2,
            right: (constraints.maxWidth - theme.sizingConfig.containerMaxWidth) / 2);
        horizontalPadding = horizontalPadding.atLeast(maxWidthPadding);
      }

      return LdListItemConfigProvider(
        config: LdListItemConfig(
          borderRadius: LdTheme.of(context).radius(LdSize.m),
        ),
        child: ColoredBox(
          color: backgroundColor ?? Colors.transparent,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: CustomScrollView(
              controller: effectiveController,
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
            ),
          ),
        ),
      );
    });
  }
}
