import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdScaffoldBody extends StatelessWidget {
  final List<Widget> children;
  final List<Widget> slivers;
  final LdSize minimumPadding;
  final Color? backgroundColor;
  final ScrollController? scrollController;
  final bool autoSpaceChildren;
  const LdScaffoldBody({
    super.key,
    this.children = const [],
    this.minimumPadding = LdSize.m,
    this.slivers = const [],
    this.scrollController,
    this.backgroundColor,
    this.autoSpaceChildren = true,
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final themePadding = LdTheme.of(context).pad(size: minimumPadding);

    final effectiveChildren = autoSpaceChildren ? children.autoSpace(context) : children;

    // Get the scroll controller from the scaffold if none provided
    final effectiveController =
        scrollController ?? (context.findAncestorStateOfType<LdScaffoldState>()?.effectiveScrollController);

    return ColoredBox(
      color: backgroundColor ?? LdTheme.of(context).background,
      child: CustomScrollView(
        controller: effectiveController,
        slivers: [
          if (effectiveChildren.isNotEmpty)
            SliverPadding(
              padding: padding + themePadding,
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
                padding: EdgeInsets.only(
                  left: padding.left + themePadding.left,
                  right: padding.right + themePadding.right,
                  top: isFirst ? padding.top + themePadding.top : 0,
                  bottom: isLast ? padding.bottom + themePadding.bottom : 0,
                ),
                sliver: sliver,
              );
            }),
        ],
      ),
    );
  }
}
