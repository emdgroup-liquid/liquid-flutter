import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/color/color.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/preview_wrapper.dart';
import 'package:liquid_flutter/src/touchable/outline_color.dart';
import 'package:liquid_flutter/src/touchable/solid_color.dart';
import 'package:liquid_flutter/src/touchable/touchable.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'tokens.dart';

import 'theme/theme.dart';
import 'annotations.dart';

part 'checkbox.variants.g.dart';

@LiquidMultiPreview(
  name: 'LdCheckbox checked',
)
Widget ldCheckboxPreview() {
  return const LdCheckbox(
    checked: true,
    label: 'Checkbox',
  );
}

@LiquidMultiPreview(
  name: 'LdCheckbox unchecked',
)
Widget ldCheckboxPreviewUnchecked() {
  return const LdCheckbox(
    checked: false,
    label: 'Checkbox',
  );
}

/// A checkbox control.
@Variants([
  Variant('success', defaults: {'color': 'LdTheme.of(context).success'}),
  Variant('warning', defaults: {'color': 'LdTheme.of(context).warning'}),
  Variant('error', defaults: {'color': 'LdTheme.of(context).error'}),
])
class _LdCheckboxWidget extends StatefulWidget {
  final String? label;
  final bool checked;
  final bool disabled;
  final FocusNode? focusNode;

  final LdSize size;
  final Function(bool)? onChanged;
  final LdColor? color;
  const _LdCheckboxWidget(
      {this.label,
      @ContextConfigurable() this.checked = false,
      @ContextConfigurable() this.onChanged,
      @ContextConfigurable() this.color,
      @ContextConfigurable() this.focusNode,
      @ContextConfigurable() this.size = LdSize.s,
      @ContextConfigurable() this.disabled = false});

  @override
  State<_LdCheckboxWidget> createState() => _LdCheckboxState();
}

class _LdCheckboxState extends State<_LdCheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final color = widget.color ?? theme.palette.primary;

    final size = widget.size.clamp(LdSize.s, LdSize.l);

    final checkboxSize = theme.paddingSize(size: size) * 2;

    final label = LdFormLabel(
      label: widget.label,
      size: widget.size,
      direction: Axis.horizontal,
    );

    return LdTouchableSurface(
      key: const Key('ldCheckbox_touchable'),
      hitTestBehavior: HitTestBehavior.opaque,
      disabled: widget.disabled,
      focusNode: widget.focusNode,
      onPressed: () {
        if (widget.onChanged != null) {
          widget.onChanged!(!widget.checked);
        }
        LdHaptics.vibrate(HapticsType.selection);
      },
      builder: (context, status, _) => Builder(builder: (context) {
        final colors = switch (widget.checked) {
          true => solidColor(color, theme, status),
          false => outlineColor(color, theme, status),
        };
        return Semantics(
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
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(
                    color: colors.border,
                    width: 2,
                  ),
                  borderRadius: LdTheme.of(context).radius(size.adjust(-2)),
                ),
                child: Opacity(
                  opacity: widget.checked ? 1 : 0,
                  child: Icon(
                    key: const ValueKey("checkmark"),
                    LucideIcons.check,
                    color: colors.text,
                    size: theme.labelSize(widget.size),
                  ),
                ),
              ),
              Flexible(child: label),
            ],
          ),
        );
      }),
    );
  }
}
