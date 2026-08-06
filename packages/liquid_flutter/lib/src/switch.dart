import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:liquid_flutter/src/haptics.dart';

class LdSwitch<T> extends StatelessWidget {
  final Function(T)? onChanged;
  final LdSize size;
  final Map<T, Widget> children;
  final String? label;
  final LdColor? color;
  final bool disabled;
  final T value;
  final bool expand;

  const LdSwitch({
    super.key,
    required this.children,
    required this.value,
    this.disabled = false,
    this.label,
    this.size = LdSize.m,
    this.color,
    this.onChanged,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          LdText.l(
            label!,
            size: size,
          ),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: theme.radius(LdSize.s),
            border: Border.all(
              color: theme.border,
              width: theme.borderWidth,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (var entry in children.entries) ..._buildItem(theme, entry.key, entry.value)],
            ),
          ),
        ),
      ],
    ).spaceS();
  }

  int get activeIndex => children.keys.toList().indexOf(value);

  List<Widget> _buildItem(LdTheme theme, T key, Widget child) {
    var isSelected = key == value;

    var index = children.keys.toList().indexOf(key);

    return [
      Flexible(
        fit: expand ? FlexFit.tight : FlexFit.loose,
        child: LdTouchableSurface(
          active: isSelected,
          onPressed: () {
            LdHaptics.vibrate(HapticsType.selection);
            _onTap(key);
          },
          child: child,
          builder: (context, state, child) {
            final bundle = outlineColor(theme.palette.primary, theme, state);

            return IntrinsicWidth(
              child: Container(
                padding: theme.controlContentPadding(size) - EdgeInsets.all(theme.borderWidth),
                decoration: BoxDecoration(
                  color: bundle.surface,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: DefaultTextStyle(
                      style: ldBuildTextStyle(theme, LdTextType.label, size).copyWith(color: bundle.text),
                      child: child!),
                ),
              ),
            );
          },
        ),
      ),
      if (index < children.length - 1) VerticalDivider(color: theme.border, width: theme.borderWidth),
    ];
  }

  void _onTap(T key) {
    if (onChanged != null) {
      onChanged!(key);
    }
  }
}
