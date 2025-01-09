import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/color/color.dart';

import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/touchable/touchable.dart';

import 'theme/theme.dart';
import 'tokens.dart';

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

    final checkboxSize = theme.paddingSize(size: size) * 2;

    final label = LdFormLabel(
      label: this.label,
      size: size,
      direction: Axis.horizontal,
    );

    return LdTouchableSurface(
        onTap: _onTap,
        mode: !checked
            ? LdTouchableSurfaceMode.outline
            : LdTouchableSurfaceMode.solid,
        disabled: disabled,
        color: color ?? theme.palette.primary,
        builder: (contxt, colorBundle, status) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: checkboxSize,
                width: checkboxSize,
                child: Center(
                    child: Container(
                  height: theme.paragraphSize(size),
                  width: theme.paragraphSize(size),
                  decoration: BoxDecoration(
                      color: checked ? colorBundle.text : null,
                      borderRadius: BorderRadius.circular(15)),
                )),
                key: const ValueKey("frame"),
                decoration: BoxDecoration(
                  color: colorBundle.surface,
                  border: Border.all(
                      color: colorBundle.border,
                      width: checked ? theme.paddingSize(size: size) / 2 : 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              if (this.label != null) Flexible(child: label)
            ],
          );
        });
  }
}
