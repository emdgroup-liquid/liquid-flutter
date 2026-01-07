part of 'checkbox.dart';

class LdCheckboxConfig {
  const LdCheckboxConfig({
    this.checked,
    this.onChanged,
    this.color,
    this.focusNode,
    this.size,
    this.disabled,
  });

  final bool? checked;

  final dynamic Function(bool)? onChanged;

  final LdColor? color;

  final FocusNode? focusNode;

  final LdSize? size;

  final bool? disabled;
}

class LdCheckboxConfigProvider extends StatelessWidget {
  const LdCheckboxConfigProvider({
    required this.config,
    required this.child,
    super.key,
  });

  final LdCheckboxConfig config;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parentConfig = Provider.of<LdCheckboxConfig?>(context, listen: true);
    final mergedConfig = parentConfig != null
        ? LdCheckboxConfig(
            checked: config.checked ?? parentConfig.checked,
            onChanged: config.onChanged ?? parentConfig.onChanged,
            color: config.color ?? parentConfig.color,
            focusNode: config.focusNode ?? parentConfig.focusNode,
            size: config.size ?? parentConfig.size,
            disabled: config.disabled ?? parentConfig.disabled)
        : config;
    return Provider<LdCheckboxConfig>.value(
      value: mergedConfig,
      child: child,
    );
  }
}

class LdCheckbox extends StatelessWidget {
  const LdCheckbox({
    this.label,
    this.checked,
    this.onChanged,
    this.color,
    this.focusNode,
    this.size,
    this.disabled,
  });

  final String? label;

  final bool? checked;

  final bool? disabled;

  final FocusNode? focusNode;

  final LdSize? size;

  final dynamic Function(bool)? onChanged;

  final LdColor? color;

  static Widget success({
    String? label,
    bool? checked,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    FocusNode? focusNode,
    LdSize? size,
    bool? disabled,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdCheckbox(
        label: label,
        checked: checked,
        onChanged: onChanged,
        color: LdTheme.of(context).success,
        focusNode: focusNode,
        size: size,
        disabled: disabled,
        key: key,
      ),
    );
  }

  static Widget warning({
    String? label,
    bool? checked,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    FocusNode? focusNode,
    LdSize? size,
    bool? disabled,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdCheckbox(
        label: label,
        checked: checked,
        onChanged: onChanged,
        color: LdTheme.of(context).warning,
        focusNode: focusNode,
        size: size,
        disabled: disabled,
        key: key,
      ),
    );
  }

  static Widget error({
    String? label,
    bool? checked,
    dynamic Function(bool)? onChanged,
    LdColor? color,
    FocusNode? focusNode,
    LdSize? size,
    bool? disabled,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdCheckbox(
        label: label,
        checked: checked,
        onChanged: onChanged,
        color: LdTheme.of(context).error,
        focusNode: focusNode,
        size: size,
        disabled: disabled,
        key: key,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<LdCheckboxConfig?>(context, listen: true);
    return _LdCheckboxWidget(
      label: label,
      checked: checked ?? config?.checked ?? false,
      onChanged: onChanged ?? config?.onChanged,
      color: color ?? config?.color,
      focusNode: focusNode ?? config?.focusNode,
      size: size ?? config?.size ?? LdSize.s,
      disabled: disabled ?? config?.disabled ?? false,
    );
  }
}
