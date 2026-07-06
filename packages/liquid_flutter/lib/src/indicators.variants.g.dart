part of 'indicators.dart';

class LdIndicator extends StatelessWidget {
  const LdIndicator({
    required this.type,
    this.size = LdSize.m,
    this.customSize,
    super.key,
  });

  factory LdIndicator.info({
    LdSize size = LdSize.m,
    double? customSize,
    Key? key,
  }) {
    return LdIndicator(
      type: LdIndicatorType.info,
      size: size,
      customSize: customSize,
      key: key,
    );
  }

  factory LdIndicator.warning({
    LdSize size = LdSize.m,
    double? customSize,
    Key? key,
  }) {
    return LdIndicator(
      type: LdIndicatorType.warning,
      size: size,
      customSize: customSize,
      key: key,
    );
  }

  factory LdIndicator.canceled({
    LdSize size = LdSize.m,
    double? customSize,
    Key? key,
  }) {
    return LdIndicator(
      type: LdIndicatorType.canceled,
      size: size,
      customSize: customSize,
      key: key,
    );
  }

  factory LdIndicator.error({
    LdSize size = LdSize.m,
    double? customSize,
    Key? key,
  }) {
    return LdIndicator(
      type: LdIndicatorType.error,
      size: size,
      customSize: customSize,
      key: key,
    );
  }

  factory LdIndicator.success({
    LdSize size = LdSize.m,
    double? customSize,
    Key? key,
  }) {
    return LdIndicator(
      type: LdIndicatorType.success,
      size: size,
      customSize: customSize,
      key: key,
    );
  }

  factory LdIndicator.loading({
    LdSize size = LdSize.m,
    double? customSize,
    Key? key,
  }) {
    return LdIndicator(
      type: LdIndicatorType.loading,
      size: size,
      customSize: customSize,
      key: key,
    );
  }

  factory LdIndicator.pending({
    LdSize size = LdSize.m,
    double? customSize,
    Key? key,
  }) {
    return LdIndicator(
      type: LdIndicatorType.pending,
      size: size,
      customSize: customSize,
      key: key,
    );
  }

  factory LdIndicator.ongoing({
    LdSize size = LdSize.m,
    double? customSize,
    Key? key,
  }) {
    return LdIndicator(
      type: LdIndicatorType.ongoing,
      size: size,
      customSize: customSize,
      key: key,
    );
  }

  final LdIndicatorType type;

  final LdSize size;

  final double? customSize;

  @override
  Widget build(BuildContext context) {
    return _LdIndicatorWidget(
      type: type,
      size: size,
      customSize: customSize,
    );
  }
}
