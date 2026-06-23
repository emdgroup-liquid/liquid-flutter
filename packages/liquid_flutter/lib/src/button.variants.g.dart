part of 'button.dart';

class LdButtonConfig {
  const LdButtonConfig({
    this.autoLoading,
    this.borderRadius,
    this.color,
    this.active,
    this.width,
    this.disabled,
    this.focusNode,
    this.alignment,
    this.circular,
    this.mode,
    this.size,
    this.disableSqueeze,
  });

  final bool? autoLoading;

  final BorderRadius? borderRadius;

  final LdColor? color;

  final bool? active;

  final double? width;

  final bool? disabled;

  final FocusNode? focusNode;

  final MainAxisAlignment? alignment;

  final bool? circular;

  final LdButtonMode? mode;

  final LdSize? size;

  final bool? disableSqueeze;
}

class LdButtonConfigProvider extends StatelessWidget {
  const LdButtonConfigProvider({
    required this.config,
    required this.child,
    this.ignoreParent = false,
    super.key,
  });

  final LdButtonConfig config;

  final Widget child;

  final bool ignoreParent;

  @override
  Widget build(BuildContext context) {
    if (ignoreParent) {
      return Provider<LdButtonConfig>.value(
        value: config,
        child: child,
      );
    }
    final parentConfig = Provider.of<LdButtonConfig?>(context, listen: true);
    final mergedConfig = parentConfig != null
        ? LdButtonConfig(
            autoLoading: config.autoLoading ?? parentConfig.autoLoading,
            borderRadius: config.borderRadius ?? parentConfig.borderRadius,
            color: config.color ?? parentConfig.color,
            active: config.active ?? parentConfig.active,
            width: config.width ?? parentConfig.width,
            disabled: config.disabled ?? parentConfig.disabled,
            focusNode: config.focusNode ?? parentConfig.focusNode,
            alignment: config.alignment ?? parentConfig.alignment,
            circular: config.circular ?? parentConfig.circular,
            mode: config.mode ?? parentConfig.mode,
            size: config.size ?? parentConfig.size,
            disableSqueeze:
                config.disableSqueeze ?? parentConfig.disableSqueeze)
        : config;
    return Provider<LdButtonConfig>.value(
      value: mergedConfig,
      child: child,
    );
  }
}

class LdButton extends StatelessWidget {
  const LdButton({
    required this.child,
    required this.onPressed,
    this.autoLoading,
    this.borderRadius,
    this.color,
    this.active,
    this.width,
    this.disabled,
    this.focusNode,
    this.autoFocus = false,
    this.alignment,
    this.leading,
    this.circular,
    this.loading = false,
    this.loadingText,
    this.errorText,
    this.mode,
    this.progress,
    this.size,
    this.trailing,
    this.disableSqueeze,
    super.key,
  });

  factory LdButton.ghost({
    required Widget child,
    required FutureOr<void> Function() onPressed,
    bool? autoLoading,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool? disabled,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode? mode,
    double? progress,
    LdSize? size,
    Widget? trailing,
    bool? disableSqueeze,
    Key? key,
  }) {
    return LdButton(
      onPressed: onPressed,
      autoLoading: autoLoading,
      borderRadius: borderRadius,
      color: color,
      active: active,
      width: width,
      disabled: disabled,
      focusNode: focusNode,
      autoFocus: autoFocus,
      alignment: alignment,
      leading: leading,
      circular: circular,
      loading: loading,
      loadingText: loadingText,
      errorText: errorText,
      mode: LdButtonMode.ghost,
      progress: progress,
      size: size,
      trailing: trailing,
      disableSqueeze: disableSqueeze,
      child: child,
    );
  }

  factory LdButton.vague({
    required Widget child,
    required FutureOr<void> Function() onPressed,
    bool? autoLoading,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool? disabled,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode? mode,
    double? progress,
    LdSize? size,
    Widget? trailing,
    bool? disableSqueeze,
    Key? key,
  }) {
    return LdButton(
      onPressed: onPressed,
      autoLoading: autoLoading,
      borderRadius: borderRadius,
      color: color,
      active: active,
      width: width,
      disabled: disabled,
      focusNode: focusNode,
      autoFocus: autoFocus,
      alignment: alignment,
      leading: leading,
      circular: circular,
      loading: loading,
      loadingText: loadingText,
      errorText: errorText,
      mode: LdButtonMode.vague,
      progress: progress,
      size: size,
      trailing: trailing,
      disableSqueeze: disableSqueeze,
      child: child,
    );
  }

  factory LdButton.outline({
    required Widget child,
    required FutureOr<void> Function() onPressed,
    bool? autoLoading,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool? disabled,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode? mode,
    double? progress,
    LdSize? size,
    Widget? trailing,
    bool? disableSqueeze,
    Key? key,
  }) {
    return LdButton(
      onPressed: onPressed,
      autoLoading: autoLoading,
      borderRadius: borderRadius,
      color: color,
      active: active,
      width: width,
      disabled: disabled,
      focusNode: focusNode,
      autoFocus: autoFocus,
      alignment: alignment,
      leading: leading,
      circular: circular,
      loading: loading,
      loadingText: loadingText,
      errorText: errorText,
      mode: LdButtonMode.outline,
      progress: progress,
      size: size,
      trailing: trailing,
      disableSqueeze: disableSqueeze,
      child: child,
    );
  }

  factory LdButton.filled({
    required Widget child,
    required FutureOr<void> Function() onPressed,
    bool? autoLoading,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool? disabled,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode? mode,
    double? progress,
    LdSize? size,
    Widget? trailing,
    bool? disableSqueeze,
    Key? key,
  }) {
    return LdButton(
      onPressed: onPressed,
      autoLoading: autoLoading,
      borderRadius: borderRadius,
      color: color,
      active: active,
      width: width,
      disabled: disabled,
      focusNode: focusNode,
      autoFocus: autoFocus,
      alignment: alignment,
      leading: leading,
      circular: circular,
      loading: loading,
      loadingText: loadingText,
      errorText: errorText,
      mode: LdButtonMode.filled,
      progress: progress,
      size: size,
      trailing: trailing,
      disableSqueeze: disableSqueeze,
      child: child,
    );
  }

  final Widget child;

  final FutureOr<void> Function() onPressed;

  final bool? disabled;

  final FocusNode? focusNode;

  final Widget? trailing;

  final Widget? leading;

  final bool loading;

  final LdColor? color;

  final double? width;

  final bool? autoLoading;

  final double? progress;

  final bool autoFocus;

  final bool? disableSqueeze;

  final LdButtonMode? mode;

  final MainAxisAlignment? alignment;

  final LdSize? size;

  final bool? active;

  final bool? circular;

  final BorderRadius? borderRadius;

  final String? loadingText;

  final String? errorText;

  static Widget warning({
    required Widget child,
    required FutureOr<void> Function() onPressed,
    bool? autoLoading,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool? disabled,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode? mode,
    double? progress,
    LdSize? size,
    Widget? trailing,
    bool? disableSqueeze,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdButton(
        onPressed: onPressed,
        autoLoading: autoLoading,
        borderRadius: borderRadius,
        color: LdTheme.of(context).warning,
        active: active,
        width: width,
        disabled: disabled,
        focusNode: focusNode,
        autoFocus: autoFocus,
        alignment: alignment,
        leading: leading,
        circular: circular,
        loading: loading,
        loadingText: loadingText,
        errorText: errorText,
        mode: mode,
        progress: progress,
        size: size,
        trailing: trailing,
        disableSqueeze: disableSqueeze,
        child: child,
      ),
    );
  }

  static Widget error({
    required Widget child,
    required FutureOr<void> Function() onPressed,
    bool? autoLoading,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool? disabled,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode? mode,
    double? progress,
    LdSize? size,
    Widget? trailing,
    bool? disableSqueeze,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdButton(
        onPressed: onPressed,
        autoLoading: autoLoading,
        borderRadius: borderRadius,
        color: LdTheme.of(context).error,
        active: active,
        width: width,
        disabled: disabled,
        focusNode: focusNode,
        autoFocus: autoFocus,
        alignment: alignment,
        leading: leading,
        circular: circular,
        loading: loading,
        loadingText: loadingText,
        errorText: errorText,
        mode: mode,
        progress: progress,
        size: size,
        trailing: trailing,
        disableSqueeze: disableSqueeze,
        child: child,
      ),
    );
  }

  static Widget success({
    required Widget child,
    required FutureOr<void> Function() onPressed,
    bool? autoLoading,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool? disabled,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode? mode,
    double? progress,
    LdSize? size,
    Widget? trailing,
    bool? disableSqueeze,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdButton(
        onPressed: onPressed,
        autoLoading: autoLoading,
        borderRadius: borderRadius,
        color: LdTheme.of(context).success,
        active: active,
        width: width,
        disabled: disabled,
        focusNode: focusNode,
        autoFocus: autoFocus,
        alignment: alignment,
        leading: leading,
        circular: circular,
        loading: loading,
        loadingText: loadingText,
        errorText: errorText,
        mode: mode,
        progress: progress,
        size: size,
        trailing: trailing,
        disableSqueeze: disableSqueeze,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<LdButtonConfig?>(context, listen: true);
    return _LdButtonWidget(
      onPressed: onPressed,
      autoLoading: autoLoading ?? config?.autoLoading ?? true,
      borderRadius: borderRadius ?? config?.borderRadius,
      color: color ?? config?.color,
      active: active ?? config?.active,
      width: width ?? config?.width,
      disabled: disabled ?? config?.disabled ?? false,
      focusNode: focusNode ?? config?.focusNode,
      autoFocus: autoFocus,
      alignment: alignment ?? config?.alignment,
      leading: leading,
      circular: circular ?? config?.circular,
      loading: loading,
      loadingText: loadingText,
      errorText: errorText,
      mode: mode ?? config?.mode ?? LdButtonMode.filled,
      progress: progress,
      size: size ?? config?.size ?? LdSize.m,
      trailing: trailing,
      disableSqueeze: disableSqueeze ?? config?.disableSqueeze ?? false,
      child: child,
    );
  }
}
