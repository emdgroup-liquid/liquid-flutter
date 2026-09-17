import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// The shared frame shell for input-like selection triggers
/// ([LdDatePicker], [LdTimePicker], [LdDurationPicker],
/// [LdRecurrencePicker], [LdSelect], [LdChooseInputTrigger]).
///
/// Every trigger renders its contents identically so they all paint at exactly
/// [LdTheme.controlHeight]: a flat, clipped, border-compensated container
/// padded with [LdTheme.controlContentPadding] and a content area constrained
/// to at least one label line box.
///
/// When placed inside an [LdInputGroup] the frame reads the
/// [LdControlGroupScope] of the group and joins its neighbours: seam edges
/// halve the border width, the radius only rounds outer corners, and [size]
/// falls back to the group's size. Standalone it renders exactly as before.
class LdFieldFrame extends StatelessWidget {
  /// The colour bundle triaging this trigger's surface/border/text from
  /// [inputColor] (or a custom bundle). Keeps per-control focus, hover and
  /// validation states intact inside groups.
  final LdColorBundle colors;

  /// The trigger's content, aligned with [alignment] inside the frame.
  final Widget child;

  /// The control size. When the frame is inside an [LdInputGroup] the group's
  /// [LdControlGroupScope.size] takes precedence so all members match.
  final LdSize size;

  /// Where [child] sits inside the content box. Defaults to [Alignment.centerLeft].
  final Alignment alignment;

  /// Explicit width. Defaults to full width (`double.infinity`).
  final double? width;

  /// Overrides the derived radius. Inside a group it is honoured for the outer
  /// corners only (seam corners stay flat).
  final BorderRadius? borderRadius;

  const LdFieldFrame({
    super.key,
    required this.colors,
    required this.child,
    this.size = LdSize.m,
    this.alignment = Alignment.centerLeft,
    this.width = double.infinity,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final scope = LdControlGroupScope.of(context);
    final effectiveSize = scope?.size ?? size;
    final textDirection = Directionality.of(context);

    final lineBoxHeight =
        theme.labelSize(effectiveSize) * ldLineHeight(LdTextType.label, size: effectiveSize);

    final border = scope != null
        ? scope.borderFor(theme, colors.border, textDirection)
        : Border.all(color: colors.border, width: theme.borderWidth);

    final controlPadding = theme.controlContentPadding(effectiveSize);
    final padding = EdgeInsets.fromLTRB(
      controlPadding.left - border.left.width,
      controlPadding.top - border.top.width,
      controlPadding.right - border.right.width,
      controlPadding.bottom - border.bottom.width,
    );

    final radius = scope != null
        ? scope.radiusFor(theme, textDirection, explicit: borderRadius)
        : borderRadius ?? theme.radius(LdSize.s);

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: padding,
      width: width,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: radius,
        border: border,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: lineBoxHeight),
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}