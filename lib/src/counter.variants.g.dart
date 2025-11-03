part of 'counter.dart';

class LdCounter extends StatelessWidget {
  const LdCounter({
    super.key,
    required this.value,
    this.precision = 0,
    this.size = LdSize.m,
  });

  factory LdCounter.s({
    Key? key,
    required double value,
    int precision = 0,
    LdSize size = LdSize.m,
  }) {
    return LdCounter(
      key: key,
      value: value,
      precision: precision,
      size: LdSize.s,
    );
  }

  factory LdCounter.l({
    Key? key,
    required double value,
    int precision = 0,
    LdSize size = LdSize.m,
  }) {
    return LdCounter(
      key: key,
      value: value,
      precision: precision,
      size: LdSize.l,
    );
  }

  factory LdCounter.xs({
    Key? key,
    required double value,
    int precision = 0,
    LdSize size = LdSize.m,
  }) {
    return LdCounter(
      key: key,
      value: value,
      precision: precision,
      size: LdSize.xs,
    );
  }

  final double value;

  final LdSize size;

  final int precision;

  @override
  Widget build(BuildContext context) {
    return LdCounterWidget(
      value: value,
      precision: precision,
      size: size,
    );
  }
}
