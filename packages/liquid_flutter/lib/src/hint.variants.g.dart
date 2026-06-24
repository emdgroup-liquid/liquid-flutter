part of 'hint.dart';

class LdHint extends StatelessWidget {
  const LdHint({
    this.child,
    required this.type,
    this.size = LdSize.m,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  });

  factory LdHint.info({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.info,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.warning({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.warning,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.success({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.success,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.error({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.error,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.canceled({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.canceled,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.loading({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.loading,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.pending({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.pending,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
      child: child,
    );
  }

  factory LdHint.ongoing({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    Key? key,
  }) {
    return LdHint(
      type: LdHintType.ongoing,
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

  @override
  Widget build(BuildContext context) {
    return _LdHintWidget(
      type: type,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      child: child,
    );
  }
}
