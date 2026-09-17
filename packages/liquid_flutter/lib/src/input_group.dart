import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/preview_wrapper.dart';
import 'package:provider/provider.dart';

/// Describes the position of a single control inside an [LdInputGroup].
///
/// [LdInputGroup] provides a scope of this type to every member so that
/// controls which know how to join (inputs, selects, buttons, checkboxes,
/// radios, switches, [LdInputGroupText]) can derive joined decorations — flat
/// seam corners and half-width inner borders — from their position instead of
/// rendering standalone. Anything that does not read the scope is simply
/// placed as-is on the row.
///
/// Read the scope with [LdControlGroupScope.of].
class LdControlGroupScope {
  /// Position of this member inside the group (0-based).
  final int index;

  /// Total number of members in the group.
  final int count;

  /// The size applied to every member of the group. Members read this so a
  /// group renders uniformly even if individual controls were constructed with
  /// a different size.
  final LdSize size;

  const LdControlGroupScope({
    required this.index,
    required this.count,
    required this.size,
  });

  /// The nearest ancestor group scope, or `null` when the control is not part
  /// of an [LdInputGroup].
  static LdControlGroupScope? of(BuildContext context) => Provider.of<LdControlGroupScope?>(context);

  bool get isFirst => index == 0;

  bool get isLast => index == count - 1;

  bool get isSingle => count == 1;

  /// Corner radius for this member.
  ///
  /// In a group the two outer corners of the first and last member stay rounded
  /// while every seam corner is flattened, and a lone member keeps its full
  /// radius. [explicit] (e.g. a caller-provided `borderRadius`) always wins.
  /// The result mirrors with [textDirection] so RTL groups look correct.
  BorderRadius radiusFor(
    LdTheme theme,
    TextDirection textDirection, {
    BorderRadius? explicit,
  }) {
    if (explicit != null) {
      return explicit;
    }
    final r = theme.radiusSize(LdSize.s);
    if (isSingle) {
      return BorderRadius.circular(r);
    }
    final outer = Radius.circular(r);
    if (isFirst) {
      return textDirection == TextDirection.ltr
          ? BorderRadius.horizontal(left: outer)
          : BorderRadius.horizontal(right: outer);
    }
    if (isLast) {
      return textDirection == TextDirection.ltr
          ? BorderRadius.horizontal(right: outer)
          : BorderRadius.horizontal(left: outer);
    }
    return BorderRadius.zero;
  }

  /// Border for this member.
  ///
  /// Outer edges carry the full [LdTheme.borderWidth] while inner (seam) edges
  /// carry half the width, so two adjacent members always sum to a crisp 1px
  /// line — no colour lifting required and focus states stay per-control.
  /// Mirrors with [textDirection] like [radiusFor].
  Border borderFor(
    LdTheme theme,
    Color color,
    TextDirection textDirection,
  ) {
    final w = theme.borderWidth;
    if (isSingle) {
      return Border.all(color: color, width: w);
    }
    final start = isFirst ? w : w / 2;
    final end = isLast ? w : w / 2;
    final side = BorderSide(color: color, width: w);
    final startSide = BorderSide(color: color, width: start);
    final endSide = BorderSide(color: color, width: end);
    return textDirection == TextDirection.ltr
        ? Border(top: side, bottom: side, left: startSide, right: endSide)
        : Border(top: side, bottom: side, left: endSide, right: startSide);
  }
}

@LiquidMultiPreview(name: 'LdInputGroup – input + button')
Widget ldInputGroupBasicPreview() => LdInputGroup(
      children: [
        LdInput(hint: 'Email'),
        LdButton(
          onPressed: () {},
          child: const Text('Subscribe'),
        ),
      ],
    );

@LiquidMultiPreview(name: 'LdInputGroup – with add-ons')
Widget ldInputGroupAddonsPreview() => LdInputGroup(
      children: [
        LdInputGroupText(const Text('@')),
        LdInput(hint: 'Username'),
        LdInputGroupText(const Text('@sample.com')),
      ],
    );

/// Joins form controls into a single visually-grouped row.
///
/// Bootstrap-style input groups: controls flow horizontally, share the same
/// height, touch at seams (inner borders render at half width so neighbouring
/// members sum to a clean 1px line), and only the outer corners are rounded.
///
/// ```dart
/// LdInputGroup(
///   children: [
///     LdInput(hint: 'Email'),
///     LdInputGroupText(Icon(LucideIcons.atSign)),
///     LdButton(onPressed: subscribe, child: const Text('Subscribe')),
///   ],
/// )
/// ```
///
/// Member handling:
/// - [LdInput], [LdSelect], [LdChoose], [LdDatePicker], [LdTimePicker],
///   [LdDurationPicker] and [LdRecurrencePicker] are given flexible width and
///   grow to fill the row (like Bootstrap `.form-control`).
/// - [LdButton], [LdCheckbox], [LdRadio], [LdSwitch] and [LdInputGroupText]
///   keep their intrinsic width.
/// - Any other widget is placed as-is and told its position, so custom
///   controls can opt in to joined decorations by reading
///   [LdControlGroupScope.of] in their own build.
///
/// Controls with a `label` drop it inside a group — put labels above the
/// group instead. All members render at [size].
///
/// ## Interactive playground
///
/// <!-- demo:LdInputGroup -->
///
/// ## Context configuration
///
/// The group only injects *position* information. No decoration is lifted:
/// each member keeps its own fill, border colour, focus and validation state.
class LdInputGroup extends StatelessWidget {
  /// The members to join. Must contain at least one widget.
  final List<Widget> children;

  /// Size applied to every member of the group.
  final LdSize size;

  const LdInputGroup({
    super.key,
    required this.children,
    this.size = LdSize.m,
  });

  @override
  Widget build(BuildContext context) {
    final count = children.length;
    return LdButtonConfigProvider(
      config: LdButtonConfig(
        circular: false,
        mode: LdButtonMode.outline,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < count; i++)
              Provider<LdControlGroupScope>.value(
                value: LdControlGroupScope(index: i, count: count, size: size),
                child: _member(children[i]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _member(Widget child) {
    final unwrapped = _unwrap(child);
    // Text entry and dialog-trigger fields grow to fill the row like
    // Bootstrap `.form-control`; buttons, framed controls and add-ons keep
    // their intrinsic width.
    if (unwrapped is LdInput ||
        unwrapped is LdSelect ||
        unwrapped is LdChoose ||
        unwrapped is LdDatePicker ||
        unwrapped is LdTimePicker ||
        unwrapped is LdDurationPicker ||
        unwrapped is LdRecurrencePicker) {
      return Expanded(child: child);
    }
    return child;
  }
}

Widget _unwrap(Widget child) {
  var current = child;
  while (true) {
    if (current is LdReveal) {
      current = current.child;
    } else if (current is LdCollapse) {
      current = current.child;
    } else if (current is LdMute) {
      current = current.child;
    } else {
      return current;
    }
  }
}

/// Carries a suppressed field label across to a [Tooltip] when [child] lives
/// inside an [LdInputGroup].
///
/// Groups drop the visual label to keep members compact and uniform; this
/// helper restores the label as a hover / long-press tooltip (and semantics
/// label) so it stays discoverable. Standalone controls render [child]
/// unchanged — callers keep showing the visual label themselves.
Widget ldGroupLabelTooltip({
  required BuildContext context,
  required String? label,
  required Widget child,
}) {
  if (label == null || label.isEmpty || LdControlGroupScope.of(context) == null) {
    return child;
  }
  return Tooltip(message: label, child: child);
}

/// A static text or icon add-on for an [LdInputGroup] (Bootstrap's
/// `.input-group-text`).
///
/// It renders a neutral, surface-toned frame with the same seam-aware border
/// and radius as its neighbours and styles its [child] with the muted label
/// look, so a plain `Text` or `Icon` inherits the correct colour and size.
class LdInputGroupText extends StatelessWidget {
  /// The contents of the add-on. Plain [Text] and [Icon] are styled
  /// automatically.
  final Widget child;

  /// Size used when the add-on is not part of an [LdInputGroup].
  final LdSize size;

  const LdInputGroupText(this.child, {super.key, this.size = LdSize.m});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final scope = LdControlGroupScope.of(context);
    final effectiveSize = scope?.size ?? size;
    final textDirection = Directionality.of(context);

    final border = scope != null
        ? scope.borderFor(theme, theme.border, textDirection)
        : Border.all(color: theme.border, width: theme.borderWidth);
    final inset = theme.controlContentPadding(effectiveSize);
    final padding = scope != null
        ? EdgeInsets.fromLTRB(
            inset.left - border.left.width,
            inset.top - border.top.width,
            inset.right - border.right.width,
            inset.bottom - border.bottom.width,
          )
        : inset - EdgeInsets.all(theme.borderWidth);

    final background = theme.neutralShade(theme.isDark ? 2 : 1);

    return Container(
      key: const Key('ldInputGroupText_surface'),
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: scope?.radiusFor(theme, textDirection) ?? theme.radius(LdSize.s),
        border: border,
      ),
      alignment: Alignment.center,
      child: DefaultTextStyle(
        style: ldBuildTextStyle(
          theme,
          LdTextType.label,
          effectiveSize,
          color: theme.textMuted,
        ).copyWith(leadingDistribution: TextLeadingDistribution.even),
        child: IconTheme(
          data: IconThemeData(
            color: theme.textMuted,
            size: theme.labelSize(effectiveSize),
          ),
          child: child,
        ),
      ),
    );
  }
}
