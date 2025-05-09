import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:liquid_flutter/src/form_label.dart';

enum LdRadioMode { primary, warning, error }

/// a radio box
class LdRadio extends StatelessWidget {
  final String? label;
  final bool checked;
  final bool disabled;
  final LdSize size;

  final LdColor? color;
  final Function(bool)? onChanged;

  const LdRadio(
      {this.label,
      required this.checked,
      this.size = LdSize.s,
      this.onChanged,
      this.color,
      this.disabled = false,
      Key? key})
      : super(key: key);

  void _onTap() {
    if (onChanged != null) {
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
        onTap: _onTap,
        mode: LdTouchableSurfaceMode.outline,
        active: checked,
        disabled: disabled,
        color: color ?? theme.palette.primary,
        builder: (contxt, colorBundle, status) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LdSpring(
                  springConstant: 20,
                  position: (checked ? 4 : 2),
                  builder: (context, state) {
                    return Container(
                      height: radioSize,
                      width: radioSize,
                      key: const ValueKey("frame"),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colorBundle.border,
                          width: state.position,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
              if (this.label != null) Flexible(child: label)
            ],
          );
        });
  }
}
