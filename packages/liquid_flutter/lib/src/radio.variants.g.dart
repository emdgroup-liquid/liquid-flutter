part of 'radio.dart';

class LdRadio extends StatelessWidget {
  const LdRadio({
    this.label,
    required this.checked,
    this.size = LdSize.m,
    this.onChanged,
    this.color,
    this.focusNode,
    this.disabled = false,
    super.key,
  });

  final String? label;

  final bool checked;

  final bool disabled;

  final LdSize size;

  final FocusNode? focusNode;

  final LdColor? color;

  final dynamic Function(bool)? onChanged;

  static Widget success({
    String? label,
    required bool checked,
    LdSize size = LdSize.m,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    FocusNode? focusNode,
    bool disabled = false,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdRadio(
        label: label,
        checked: checked,
        size: size,
        onChanged: onChanged,
        color: LdTheme.of(context).success,
        focusNode: focusNode,
        disabled: disabled,
        key: key,
      ),
    );
  }

  static Widget warning({
    String? label,
    required bool checked,
    LdSize size = LdSize.m,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    FocusNode? focusNode,
    bool disabled = false,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdRadio(
        label: label,
        checked: checked,
        size: size,
        onChanged: onChanged,
        color: LdTheme.of(context).warning,
        focusNode: focusNode,
        disabled: disabled,
        key: key,
      ),
    );
  }

  static Widget error({
    String? label,
    required bool checked,
    LdSize size = LdSize.m,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    FocusNode? focusNode,
    bool disabled = false,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdRadio(
        label: label,
        checked: checked,
        size: size,
        onChanged: onChanged,
        color: LdTheme.of(context).error,
        focusNode: focusNode,
        disabled: disabled,
        key: key,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LdRadioWidget(
      label: label,
      checked: checked,
      size: size,
      onChanged: onChanged,
      color: color,
      focusNode: focusNode,
      disabled: disabled,
    );
  }
}
