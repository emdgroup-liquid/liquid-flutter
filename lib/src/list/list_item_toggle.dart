import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdListItemToggle extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final bool disabled;
  final LdSize size;
  final LdColor? color;
  final EdgeInsets? padding;

  const LdListItemToggle({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    required this.checked,
    this.onChanged,
    this.disabled = false,
    this.size = LdSize.m,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LdListItem(
      leading: leading,
      title: title,
      subtitle: subtitle,
      disabled: disabled,
      padding: padding,
      onTap: onChanged != null ? () => onChanged!(!checked) : null,
      trailing: LdToggle(
        checked: checked,
        onChanged: onChanged,
        disabled: disabled,
        size: size,
        color: color,
      ),
    );
  }
}
