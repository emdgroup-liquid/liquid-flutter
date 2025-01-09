import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/loading_animation.dart';

class LdListItemLoading extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final bool hasSubContent;
  final bool hasSubtitle;

  const LdListItemLoading({
    super.key,
    this.hasLeading = false,
    this.hasTrailing = false,
    this.hasSubContent = true,
    this.hasSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Container(
      padding: theme.balPad(LdSize.m),
      decoration: const BoxDecoration(),
      child: Row(children: [
        if (hasLeading) const LdLoader(neutral: true),
        if (hasLeading) ldSpacerM,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(
                widthFactor: 0.3,
                child: LdAnimatedLoadingGradient(
                  height: theme.labelSize(LdSize.m),
                ),
              ),
              if (hasSubtitle) ldSpacerS,
              if (hasSubtitle)
                const FractionallySizedBox(
                  widthFactor: 0.4,
                  child: LdAnimatedLoadingGradient(height: 8),
                ),
              if (hasSubContent) ldSpacerS,
              if (hasSubContent)
                const FractionallySizedBox(
                    widthFactor: 0.3,
                    child: LdAnimatedLoadingGradient(height: 8)),
            ],
          ),
        ),
        if (hasTrailing) ldSpacerM,
        if (hasTrailing)
          LdAnimatedLoadingGradient(
            height: theme.labelSize(LdSize.m) * 2,
            width: theme.labelSize(LdSize.m) * 4,
          ),
      ]),
    );
  }
}
