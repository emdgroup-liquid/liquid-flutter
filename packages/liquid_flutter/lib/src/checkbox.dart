import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:liquid_flutter/src/haptics.dart';
import 'package:liquid_flutter/src/preview_wrapper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

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

  @ContextConfigurable()
  const _LdCheckboxWidget({
    this.label,
    this.checked = false,
    this.onChanged,
    this.color,
    this.focusNode,
    this.size = LdSize.m,
    this.disabled = false,
  });

  @override
  State<_LdCheckboxWidget> createState() => _LdCheckboxState();
}

class _LdCheckboxState extends State<_LdCheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final color = widget.color ?? theme.palette.primary;

    final size = widget.size.clamp(LdSize.s, LdSize.l);

    final checkboxSize = theme.labelSize(size) * 1.5;

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
            textBaseline: TextBaseline.alphabetic,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, 1),
                child: Container(
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
              ),
              if (widget.label != null)
                LdText.l(
                  widget.label ?? '',
                  size: widget.size,
                )
            ],
          ).spaceXS(),
        );
      }),
    );
  }
}
