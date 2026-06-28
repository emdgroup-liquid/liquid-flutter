import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/touchable/solid_color.dart';

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
    this.size = LdSize.s,
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

    final size = this.size.clamp(LdSize.s, LdSize.l);

    final radioSize = theme.paddingSize(size: size) * 2;

    final label = LdFormLabel(
      label: this.label,
      size: size,
      direction: Axis.horizontal,
    );

    return LdTouchableSurface(
      onPressed: _onTap,
      hitTestBehavior: HitTestBehavior.opaque,
      focusNode: focusNode,
      active: checked,
      disabled: disabled,
      builder: (contxt, status, _) => Builder(
        builder: (context) {
          final colorBundle = solidColor(color ?? theme.palette.primary, theme, status);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LdSpring(
                springConstant: 20,
                position: (checked ? radioSize / 4 : radioSize / 8),
                builder: (context, state, child) {
                  final borderWidth = state.position;
                  return Container(
                    height: radioSize,
                    width: radioSize,
                    key: const ValueKey("frame"),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.primaryColor,
                        width: borderWidth,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              if (this.label != null) Flexible(child: label)
            ],
          );
        },
      ),
    );
  }
}
