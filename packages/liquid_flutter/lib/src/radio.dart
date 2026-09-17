import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:liquid_flutter/src/haptics.dart';

part 'radio.variants.g.dart';

enum LdRadioMode { primary, warning, error }

/// a radio box
@Variants([
  Variant('success', defaults: {'color': 'LdTheme.of(context).success'}),
  Variant('warning', defaults: {'color': 'LdTheme.of(context).warning'}),
  Variant('error', defaults: {'color': 'LdTheme.of(context).error'}),
])
class _LdRadioWidget extends StatelessWidget {
  final String? label;
  final bool checked;
  final bool disabled;
  final LdSize size;
  final FocusNode? focusNode;

  final LdColor? color;
  final Function(bool)? onChanged;

  const _LdRadioWidget({
    this.label,
    required this.checked,
    this.size = LdSize.m,
    this.onChanged,
    this.color,
    this.focusNode,
    this.disabled = false,
  });

  void _onTap() {
    if (onChanged != null) {
      LdHaptics.vibrate(HapticsType.selection);
      onChanged!(!checked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final scope = LdControlGroupScope.of(context);

    final color = (this.color ?? theme.palette.primary).center(theme.isDark);

    final size = (scope?.size ?? this.size).clamp(LdSize.s, LdSize.l);

    final labelSize = theme.labelSize(size);

    final radioSize = labelSize * 1.2;

    final label = LdText.l(
      this.label ?? '',
      size: this.size,
    );

    return LdTouchableSurface(
      onPressed: _onTap,
      hitTestBehavior: HitTestBehavior.opaque,
      focusNode: focusNode,
      active: checked,
      disabled: disabled,
      builder: (contxt, status, _) => Builder(
        builder: (context) {
          final dot = LdSpring(
            springConstant: 20,
            position: (checked ? radioSize * 0.5 : 0),
            builder: (context, state, child) {
              final fillWidth = state.position.clamp(0.0, radioSize);
              return Container(
                  height: radioSize,
                  width: radioSize,
                  key: const ValueKey("frame"),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: color,
                      width: theme.borderWidth,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      height: fillWidth,
                      width: fillWidth,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ));
            },
          );

          if (scope != null) {
            // Joining an [LdInputGroup]: frame the (label-free) radio dot in a
            // control-height slot that carries the group's seam border and
            // position radius, matching the height of neighbouring inputs. The
            // label surfaces as a tooltip.
            return ldGroupLabelTooltip(
              context: context,
              label: this.label,
              child: Container(
                key: const ValueKey("groupedFrame"),
                width: theme.controlHeight(size),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: scope.radiusFor(theme, Directionality.of(context)),
                  border: scope.borderFor(theme, theme.border, Directionality.of(context)),
                ),
                child: dot,
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [dot, if (this.label != null) Flexible(child: label)],
          ).spaceXS();
        },
      ),
    );
  }
}
