part of 'hint.dart';

class LdHint extends StatelessWidget {
  const LdHint({
    this.child,
    required this.type,
    this.size = LdSize.m,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  factory LdHint.info({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  }) {
    return LdHint(
      child: child,
      type: LdHintType.info,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
    );
  }

  factory LdHint.warning({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  }) {
    return LdHint(
      child: child,
      type: LdHintType.warning,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
    );
  }

  factory LdHint.success({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  }) {
    return LdHint(
      child: child,
      type: LdHintType.success,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
    );
  }

  factory LdHint.error({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  }) {
    return LdHint(
      child: child,
      type: LdHintType.error,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
    );
  }

  factory LdHint.canceled({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  }) {
    return LdHint(
      child: child,
      type: LdHintType.canceled,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
    );
  }

  factory LdHint.loading({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  }) {
    return LdHint(
      child: child,
      type: LdHintType.loading,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
    );
  }

  factory LdHint.pending({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  }) {
    return LdHint(
      child: child,
      type: LdHintType.pending,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
    );
  }

  factory LdHint.ongoing({
    Widget? child,
    required LdHintType type,
    LdSize size = LdSize.m,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    super.key,
  }) {
    return LdHint(
      child: child,
      type: LdHintType.ongoing,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
      key: key,
    );
  }

  final Widget? child;

  final LdHintType type;

  final LdSize size;

  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return _LdHintWidget(
      child: child,
      type: type,
      size: size,
      crossAxisAlignment: crossAxisAlignment,
    );
  }
}
