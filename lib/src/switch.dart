import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';

class LdSwitch<T> extends StatelessWidget {
  final Function(T)? onChanged;
  final LdSize size;
  final Map<T, Widget> children;
  final String? label;
  final LdColor? color;
  final bool disabled;
  final T value;

  const LdSwitch({
    Key? key,
    required this.children,
    required this.value,
    this.disabled = false,
    this.label,
    this.size = LdSize.m,
    this.color,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LdFormLabel(label: label, size: size),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: theme.radius(LdSize.s),
          ),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: children.entries
                  .map((e) => _buildItem(theme, e.key, e.value))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(LdTheme theme, T key, Widget child) {
    var isSelected = key == value;

    var index = children.keys.toList().indexOf(key);

    var borderRadius = BorderRadius.zero;

    if (index == 0) {
      borderRadius = BorderRadius.only(
        topLeft: theme.radius(LdSize.s).topLeft,
        bottomLeft: theme.radius(LdSize.s).bottomLeft,
      );
    } else if (index == children.length - 1) {
      borderRadius = BorderRadius.only(
        topRight: theme.radius(LdSize.s).topRight,
        bottomRight: theme.radius(LdSize.s).bottomRight,
      );
    }

    return Flexible(
      child: LdButton(
        circular: false,
        child: child,
        color: color,
        size: size,
        disabled: disabled,
        onPressed: () {
          _onTap(key);
        },
        borderRadius: borderRadius,
        mode: isSelected ? LdButtonMode.filled : LdButtonMode.vague,
      ),
    );
  }

  void _onTap(T key) {
    if (onChanged != null) {
      onChanged!(key);
    }
  }
}
