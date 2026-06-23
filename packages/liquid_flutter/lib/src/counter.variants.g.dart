part of 'counter.dart';

class LdCounter extends StatelessWidget {
  const LdCounter({
    required this.value,
    this.precision = 0,
    this.size = LdSize.m,
    this.type = LdTextType.headline,
    this.minDigits,
    this.inline = false,
    super.key,
  });

  factory LdCounter.s({
    required double value,
    int precision = 0,
    LdSize size = LdSize.m,
    LdTextType type = LdTextType.headline,
    int? minDigits,
    bool inline = false,
    Key? key,
  }) {
    return LdCounter(
      value: value,
      precision: precision,
      size: LdSize.s,
      type: type,
      minDigits: minDigits,
      inline: inline,
    );
  }

  factory LdCounter.l({
    required double value,
    int precision = 0,
    LdSize size = LdSize.m,
    LdTextType type = LdTextType.headline,
    int? minDigits,
    bool inline = false,
    Key? key,
  }) {
    return LdCounter(
      value: value,
      precision: precision,
      size: LdSize.l,
      type: type,
      minDigits: minDigits,
      inline: inline,
    );
  }

  factory LdCounter.xs({
    required double value,
    int precision = 0,
    LdSize size = LdSize.m,
    LdTextType type = LdTextType.headline,
    int? minDigits,
    bool inline = false,
    Key? key,
  }) {
    return LdCounter(
      value: value,
      precision: precision,
      size: LdSize.xs,
      type: type,
      minDigits: minDigits,
      inline: inline,
    );
  }

  final double value;

  final LdSize size;

  final LdTextType type;

  final int precision;

  final int? minDigits;

  final bool inline;

  @override
  Widget build(BuildContext context) {
    return _LdCounterWidget(
      value: value,
      precision: precision,
      size: size,
      type: type,
      minDigits: minDigits,
      inline: inline,
    );
  }
}
