part of 'button.dart';

class LdButton extends StatelessWidget {
  const LdButton({
    required this.child,
    required this.onPressed,
    this.autoLoading = true,
    this.borderRadius,
    this.color,
    this.active,
    this.width,
    this.disabled = false,
    this.focusNode,
    this.autoFocus = false,
    this.alignment,
    this.leading,
    this.circular,
    this.loading = false,
    this.loadingText,
    this.errorText,
    this.mode = LdButtonMode.filled,
    this.progress,
    this.size = LdSize.m,
    this.trailing,
    super.key,
  });

  factory LdButton.ghost({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) {
    return LdButton(
      child: child,
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
      key: key,
    );
  }

  factory LdButton.vague({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) {
    return LdButton(
      child: child,
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
      key: key,
    );
  }

  factory LdButton.outline({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) {
    return LdButton(
      child: child,
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
      key: key,
    );
  }

  factory LdButton.filled({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) {
    return LdButton(
      child: child,
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
      key: key,
    );
  }

  final Widget child;

  final Function onPressed;

  final bool disabled;

  final FocusNode? focusNode;

  final Widget? trailing;

  final Widget? leading;

  final bool loading;

  final LdColor? color;

  final double? width;

  final bool autoLoading;

  final double? progress;

  final bool autoFocus;

  final LdButtonMode mode;

  final MainAxisAlignment? alignment;

  final LdSize size;

  final bool? active;

  final bool? circular;

  final BorderRadius? borderRadius;

  final String? loadingText;

  final String? errorText;

  static Widget warning({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdButton(
        child: child,
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
        key: key,
      ),
    );
  }

  static Widget error({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdButton(
        child: child,
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
        key: key,
      ),
    );
  }

  static Widget success({
    required Widget child,
    required Function onPressed,
    bool autoLoading = true,
    BorderRadius? borderRadius,
    LdColor? color,
    bool? active,
    double? width,
    bool disabled = false,
    FocusNode? focusNode,
    bool autoFocus = false,
    MainAxisAlignment? alignment,
    Widget? leading,
    bool? circular,
    bool loading = false,
    String? loadingText,
    String? errorText,
    LdButtonMode mode = LdButtonMode.filled,
    double? progress,
    LdSize size = LdSize.m,
    Widget? trailing,
    Key? key,
  }) {
    return Builder(
      builder: (BuildContext context) => LdButton(
        child: child,
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
        key: key,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdButtonWidget(
      child: child,
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
      mode: mode,
      progress: progress,
      size: size,
      trailing: trailing,
      key: key,
    );
  }
}
