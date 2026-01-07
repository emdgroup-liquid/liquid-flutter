part of 'counter.dart';

class LdCounter extends StatelessWidget {
  const LdCounter({
    required this.value,
    this.precision = 0,
    this.size = LdSize.m,
  });

  factory LdCounter.s({
    required double value,
    int precision = 0,
    LdSize size = LdSize.m,
    super.key,
  }) {
    return LdCounter(
      value: value,
      precision: precision,
      size: LdSize.s,
      key: key,
    );
  }

  factory LdCounter.l({
    required double value,
    int precision = 0,
    LdSize size = LdSize.m,
    super.key,
  }) {
    return LdCounter(
      value: value,
      precision: precision,
      size: LdSize.l,
      key: key,
    );
  }

  factory LdCounter.xs({
    required double value,
    int precision = 0,
    LdSize size = LdSize.m,
    super.key,
  }) {
    return LdCounter(
      value: value,
      precision: precision,
      size: LdSize.xs,
      key: key,
    );
  }

  final double value;

  final LdSize size;

  final int precision;

  @override
  Widget build(BuildContext context) {
    return _LdCounterWidget(
      value: value,
      precision: precision,
      size: size,
    );
  }
}
