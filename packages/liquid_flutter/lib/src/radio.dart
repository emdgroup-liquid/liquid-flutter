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

    final size = this.size.clamp(LdSize.s, LdSize.l);

    final labelSize = theme.labelSize(size);

    final radioSize = labelSize * 1.5;

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
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, 1),
                child: LdSpring(
                  springConstant: 20,
                  position: (checked ? radioSize * 0.3 : radioSize * 0.15),
                  builder: (context, state, child) {
                    final borderWidth = state.position;
                    return Container(
                      height: radioSize,
                      width: radioSize,
                      key: const ValueKey("frame"),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: (color ?? theme.palette.primary).center(theme.isDark),
                          width: borderWidth,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ),
              if (this.label != null) Flexible(child: label)
            ],
          ).spaceXS();
        },
      ),
    );
  }
}
