part of 'indicators.dart';

class LdIndicator extends StatelessWidget {
  const LdIndicator({
    super.key,
    required this.type,
    this.size = LdSize.m,
    this.customSize,
  });

  factory LdIndicator.info({
    Key? key,
    required LdIndicatorType type,
    LdSize size = LdSize.m,
    double? customSize,
  }) {
    return LdIndicator(
      key: key,
      type: LdIndicatorType.info,
      size: size,
      customSize: customSize,
    );
  }

  factory LdIndicator.warning({
    Key? key,
    required LdIndicatorType type,
    LdSize size = LdSize.m,
    double? customSize,
  }) {
    return LdIndicator(
      key: key,
      type: LdIndicatorType.warning,
      size: size,
      customSize: customSize,
    );
  }

  factory LdIndicator.canceled({
    Key? key,
    required LdIndicatorType type,
    LdSize size = LdSize.m,
    double? customSize,
  }) {
    return LdIndicator(
      key: key,
      type: LdIndicatorType.canceled,
      size: size,
      customSize: customSize,
    );
  }

  factory LdIndicator.error({
    Key? key,
    required LdIndicatorType type,
    LdSize size = LdSize.m,
    double? customSize,
  }) {
    return LdIndicator(
      key: key,
      type: LdIndicatorType.error,
      size: size,
      customSize: customSize,
    );
  }

  factory LdIndicator.success({
    Key? key,
    required LdIndicatorType type,
    LdSize size = LdSize.m,
    double? customSize,
  }) {
    return LdIndicator(
      key: key,
      type: LdIndicatorType.success,
      size: size,
      customSize: customSize,
    );
  }

  factory LdIndicator.loading({
    Key? key,
    required LdIndicatorType type,
    LdSize size = LdSize.m,
    double? customSize,
  }) {
    return LdIndicator(
      key: key,
      type: LdIndicatorType.loading,
      size: size,
      customSize: customSize,
    );
  }

  factory LdIndicator.pending({
    Key? key,
    required LdIndicatorType type,
    LdSize size = LdSize.m,
    double? customSize,
  }) {
    return LdIndicator(
      key: key,
      type: LdIndicatorType.pending,
      size: size,
      customSize: customSize,
    );
  }

  factory LdIndicator.ongoing({
    Key? key,
    required LdIndicatorType type,
    LdSize size = LdSize.m,
    double? customSize,
  }) {
    return LdIndicator(
      key: key,
      type: LdIndicatorType.ongoing,
      size: size,
      customSize: customSize,
    );
  }

  final LdIndicatorType type;

  final LdSize size;

  final double? customSize;

  @override
  Widget build(BuildContext context) {
    return LdIndicatorWidget(
      type: type,
      size: size,
      customSize: customSize,
    );
  }
}
