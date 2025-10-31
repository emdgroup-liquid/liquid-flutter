part of 'checkbox.dart';

class LdCheckbox extends StatelessWidget {
  const LdCheckbox({
    this.label,
    required this.checked,
    this.onChanged,
    this.color,
    this.size = LdSize.s,
    this.disabled = false,
    super.key,
  });

  final String? label;

  final bool checked;

  final bool disabled;

  final LdSize size;

  final dynamic Function(bool)? onChanged;

  final LdColor? color;

  static Widget success({
    String? label,
    required bool checked,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    LdSize size = LdSize.s,
    bool disabled = false,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdCheckbox(
        label: label,
        checked: checked,
        onChanged: onChanged,
        color: LdTheme.of(context).success,
        size: size,
        disabled: disabled,
        key: key,
      ),
    );
  }

  static Widget warning({
    String? label,
    required bool checked,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    LdSize size = LdSize.s,
    bool disabled = false,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdCheckbox(
        label: label,
        checked: checked,
        onChanged: onChanged,
        color: LdTheme.of(context).warning,
        size: size,
        disabled: disabled,
        key: key,
      ),
    );
  }

  static Widget error({
    String? label,
    required bool checked,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    LdSize size = LdSize.s,
    bool disabled = false,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdCheckbox(
        label: label,
        checked: checked,
        onChanged: onChanged,
        color: LdTheme.of(context).error,
        size: size,
        disabled: disabled,
        key: key,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdCheckboxWidget(
      label: label,
      checked: checked,
      onChanged: onChanged,
      color: color,
      size: size,
      disabled: disabled,
      key: key,
    );
  }
}
