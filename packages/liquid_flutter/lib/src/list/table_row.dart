import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/touchable/neutral_ghost_color.dart';

class LdTableRow extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets? padding;
  final Widget? title;
  final bool active;
  final Widget? subtitle;
  final VoidCallback? onPressed;
  final double? width;
  final bool selectDisabled;
  final OnSelectionChanged? onSelectionChanged;
  final LdSelectionControl selectionControl;
  final BorderRadius? borderRadius;
  final Widget? subContent;
  final bool isSelected;
  final FocusNode? focusNode;
  final bool disabled;
  final LdColor? color;
  final bool isOdd;

  const LdTableRow({
    super.key,
    this.active = false,
    this.borderRadius,
    this.disabled = false,
    this.isSelected = false,
    this.leading,
    this.onSelectionChanged,
    this.onPressed,
    this.padding,
    this.selectDisabled = false,
    this.subContent,
    this.subtitle,
    this.title,
    this.focusNode,
    this.trailing,
    this.color,
    this.width,
    this.selectionControl = LdSelectionControl.none,
    this.isOdd = false,
  });

  @override
  Widget build(BuildContext context) {
    bool disabledState;

    if (selectionControl != LdSelectionControl.none) {
      if (selectDisabled) {
        disabledState = false;
      } else {
        disabledState = disabled;
      }
    } else {
      disabledState = disabled;
    }

    final theme = LdTheme.of(context, listen: true);
    final effectiveWidth = width ?? double.infinity;

    Widget buildSelectionControls() {
      if (selectionControl == LdSelectionControl.none) return const SizedBox.shrink();
      return Row(
        children: [
          switch (selectionControl) {
            LdSelectionControl.radio => LdRadio(
                checked: isSelected,
                color: color,
                disabled: disabledState,
                onChanged: (value) {
                  onSelectionChanged?.call(value);
                },
              ),
            LdSelectionControl.checkbox => LdCheckbox(
                checked: isSelected,
                color: color,
                disabled: disabledState,
                onChanged: (value) {
                  onSelectionChanged?.call(value);
                },
              ),
            LdSelectionControl.none => const SizedBox.shrink(),
          },
          ldSpacerM,
        ],
      );
    }

    return LdTouchableSurface(
      focusNode: focusNode,
      isOdd: isOdd,
      onPressed: () {
        if (selectionControl != LdSelectionControl.none) {
          onSelectionChanged?.call(!isSelected);
        } else {
          onPressed?.call();
        }
      },
      active: active || (selectionControl != LdSelectionControl.none && isSelected),
      disabled: disabledState || (selectionControl == LdSelectionControl.none && onPressed == null),
      builder: (contxt, status, _) {
        final colors = neutralGhostColor(theme, status);
        return IconTheme(
          data: IconThemeData(
            color: colors.text,
            size: theme.labelSize(LdSize.l) * 1.2,
          ),
          child: Container(
            width: effectiveWidth,
            padding: padding ?? theme.balPad(LdSize.m),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border.all(
                color: colors.border,
                width: theme.borderWidth,
              ),
              borderRadius: borderRadius,
            ),
            child: Row(
              mainAxisSize: effectiveWidth != double.infinity ? MainAxisSize.min : MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selectionControl != LdSelectionControl.none) buildSelectionControls(),
                if (leading != null) leading!,
                if (title != null) Expanded(flex: 2, child: title!),
                if (subtitle != null) Expanded(flex: 2, child: subtitle!),
                if (subContent != null) Expanded(flex: 2, child: subContent!),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        );
      },
    );
  }
}
