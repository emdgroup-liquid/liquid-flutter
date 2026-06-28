import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/loading_animation.dart';
import 'package:provider/provider.dart';

class LdListItemLoading extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final bool hasSubContent;
  final bool hasSubtitle;

  const LdListItemLoading({
    super.key,
    this.hasLeading = false,
    this.hasTrailing = false,
    this.hasSubContent = false,
    this.hasSubtitle = true,
  });

  /// A fractional-width loading bar with a [height]-bounded box.
  ///
  /// The explicit [SizedBox] height is important: a bare [FractionallySizedBox]
  /// in an unbounded column grows ~1px taller than its child, which would make
  /// the loader taller than the real item it stands in for.
  Widget _bar({required double height, required double widthFactor}) {
    return SizedBox(
      height: height,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: LdAnimatedLoadingGradient(height: height),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    // Mirror [LdListItemWidget]'s geometry so a loader occupies the exact same
    // vertical space as the real item it replaces (prevents scroll jumps).
    final config = Provider.of<LdListItemConfig?>(context, listen: true);
    final padding = config?.padding ?? theme.balPad(LdSize.s);
    // The real item reserves space for its border on every edge.
    final borderWidth = theme.borderWidth;
    // [LdAvatar] is the canonical leading; it is sized to paddingSize(m) * 3.
    final leadingSize = theme.paddingSize(size: LdSize.m) * 3;
    final labelSize = theme.labelSize(LdSize.m);
    final paragraphSize = theme.paragraphSize(LdSize.s);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.transparent,
          width: borderWidth,
        ),
      ),
      child: Row(children: [
        if (hasLeading) LdLoader(neutral: true, size: leadingSize),
        if (hasLeading) ldSpacerM,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(height: labelSize, widthFactor: 0.3),
              // Reserve the remaining subtitle line height (1.5x) above its bar.
              if (hasSubtitle) SizedBox(height: paragraphSize * 1.5 - paragraphSize),
              if (hasSubtitle) _bar(height: paragraphSize, widthFactor: 0.4),
              if (hasSubContent) ldSpacerS,
              if (hasSubContent) _bar(height: 8, widthFactor: 0.3),
            ],
          ),
        ),
        if (hasTrailing) ldSpacerM,
        if (hasTrailing)
          LdAnimatedLoadingGradient(
            height: labelSize * 2,
            width: labelSize * 4,
          ),
      ]),
    );
  }
}
