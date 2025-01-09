import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/color/color.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/touchable/touchable.dart';

import 'tokens.dart';

import 'theme/theme.dart';

/// A checkbox control.
class LdCheckbox extends StatefulWidget {
  final String? label;
  final bool checked;
  final bool disabled;

  final LdSize size;
  final Function(bool)? onChanged;
  final LdColor? color;
  const LdCheckbox(
      {this.label,
      required this.checked,
      this.onChanged,
      this.color,
      this.size = LdSize.s,
      this.disabled = false,
      Key? key})
      : super(key: key);

  @override
  State<LdCheckbox> createState() => _LdCheckboxState();
}

class _LdCheckboxState extends State<LdCheckbox> {
  bool hovering = false;
  bool tapping = false;

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final reactiveColors = widget.color ?? theme.palette.primary;

    final size = widget.size.clamp(LdSize.s, LdSize.l);

    final checkboxSize = theme.paddingSize(size: size) * 2;

    final label = LdFormLabel(
      label: widget.label,
      size: size,
      direction: Axis.horizontal,
    );

    return LdTouchableSurface(
      color: reactiveColors,
      mode: !widget.checked
          ? LdTouchableSurfaceMode.outline
          : LdTouchableSurfaceMode.solid,
      disabled: widget.disabled,
      onTap: () {
        if (widget.onChanged != null) {
          widget.onChanged!(!widget.checked);
        }
      },
      builder: (context, colors, status) => Semantics(
        checked: widget.checked,
        enabled: !widget.disabled,
        label: widget.label,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                key: const ValueKey("frame"),
                height: checkboxSize,
                width: checkboxSize,
                child: Opacity(
                  opacity: widget.checked ? 1 : 0,
                  child: Icon(
                    key: const ValueKey("checkmark"),
                    Icons.done,
                    color: colors.text,
                    size: theme.labelSize(widget.size),
                  ),
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(color: colors.border, width: 2),
                  borderRadius: theme.radius(LdSize.s),
                )),
            Flexible(child: label),
          ],
        ),
      ),
    );
  }
}
