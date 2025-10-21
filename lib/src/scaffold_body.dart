import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdScaffoldBody extends StatelessWidget {
  final List<Widget> children;
  final List<Widget> slivers;
  final LdSize minimumPadding;
  const LdScaffoldBody({
    super.key,
    this.children = const [],
    this.minimumPadding = LdSize.m,
    this.slivers = const [],
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final themePadding = LdTheme.of(context).pad(size: minimumPadding);

    return CustomScrollView(
      slivers: [
        if (children.isNotEmpty)
          SliverPadding(
            padding: padding + themePadding,
            sliver: SliverList.builder(
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
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
    );
  }
}
