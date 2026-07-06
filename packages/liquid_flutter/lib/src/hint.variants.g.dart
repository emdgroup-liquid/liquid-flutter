part of 'hint.dart';

class LdHint extends StatelessWidget {
  const LdHint({
    this.child,
    required this.type,
    this.withBackground = false,
    this.size = LdSize.m,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  });

  factory LdHint.info({
    Widget? child,
    bool withBackground = false,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.info,
      withBackground: withBackground,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.warning({
    Widget? child,
    bool withBackground = false,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.warning,
      withBackground: withBackground,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.success({
    Widget? child,
    bool withBackground = false,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.success,
      withBackground: withBackground,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.error({
    Widget? child,
    bool withBackground = false,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.error,
      withBackground: withBackground,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.canceled({
    Widget? child,
    bool withBackground = false,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.canceled,
      withBackground: withBackground,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.loading({
    Widget? child,
    bool withBackground = false,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.loading,
      withBackground: withBackground,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.pending({
    Widget? child,
    bool withBackground = false,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.pending,
      withBackground: withBackground,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.ongoing({
    Widget? child,
    bool withBackground = false,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.ongoing,
      withBackground: withBackground,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  final Widget? child;

  final LdHintType type;

  final LdSize size;

  final CrossAxisAlignment crossAxisAlignment;

  final bool withBackground;

  @override
  Widget build(BuildContext context) {
    return _LdHintWidget(
      type: type,
      withBackground: withBackground,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      child: child,
    );
  }
}
