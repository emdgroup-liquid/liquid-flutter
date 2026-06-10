import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

part 'counter.variants.g.dart';

const _counterTextHeightBehavior = TextHeightBehavior(applyHeightToFirstAscent: false);

({double baseline, double lineHeight}) _counterTextMetrics(TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: '0', style: style),
    textDirection: TextDirection.ltr,
    textHeightBehavior: _counterTextHeightBehavior,
  )..layout();

  return (
    baseline: painter.computeDistanceToActualBaseline(TextBaseline.alphabetic),
    lineHeight: painter.height,
  );
}

@Variants([
  Variant('s', defaults: {'size': 'LdSize.s'}),
  Variant('l', defaults: {'size': 'LdSize.l'}),
  Variant('xs', defaults: {'size': 'LdSize.xs'}),
])
class _LdCounterWidget extends StatefulWidget {
  final double value;

  final LdSize size;
  final LdTextType type;
  final int precision;
  final int? minDigits;
  final bool inline;

  const _LdCounterWidget({
    required this.value,
    this.precision = 0,
    this.size = LdSize.m,
    this.type = LdTextType.headline,
    this.minDigits,
    this.inline = false,
  });

  @override
  State<_LdCounterWidget> createState() => _LdCounterState();
}

class _LdCounterState extends State<_LdCounterWidget> {
  final List<(bool, String)> _digits = [];
  @override
  void initState() {
    super.initState();
    _generateDigits();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.precision != widget.precision ||
        oldWidget.minDigits != widget.minDigits) {
      _generateDigits();
      setState(() {});
    }
  }

  String _formatValue() {
    final fixed = widget.value.toStringAsFixed(widget.precision);
    final minDigits = widget.minDigits;
    if (minDigits == null) {
      return fixed;
    }

    final decimalIndex = fixed.indexOf('.');
    final integerEnd = decimalIndex == -1 ? fixed.length : decimalIndex;

    var integerPart = fixed.substring(0, integerEnd);
    var sign = '';
    if (integerPart.startsWith('-')) {
      sign = '-';
      integerPart = integerPart.substring(1);
    }

    final paddedInteger = integerPart.padLeft(minDigits, '0');
    final decimalPart = decimalIndex == -1 ? '' : fixed.substring(decimalIndex);

    return '$sign$paddedInteger$decimalPart';
  }

  void _generateDigits() {
    final str = _formatValue().split('');

    for (var i = 0; i < str.length; i++) {
      if (_digits.length > i) {
        _digits[i] = (true, str[i]);
      } else {
        _digits.add((true, str[i]));
      }
    }

    for (var i = str.length; i < _digits.length; i++) {
      _digits[i] = (false, _digits[i].$2);
    }

    if (widget.inline) {
      _digits.removeWhere((entry) => !entry.$1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.inline ? CrossAxisAlignment.baseline : CrossAxisAlignment.center,
      textBaseline: TextBaseline.alphabetic,
      children: [
        ..._digits.mapIndexed((index, e) {
          final digit = _LdCounterDigit(
            digit: e.$2,
            size: widget.size,
            type: widget.type,
            inline: widget.inline,
          );

          if (widget.inline) {
            return digit;
          }

          return LdReveal(
            revealed: e.$1,
            onAnimationEnd: (context, states) {
              if (e.$1 == false) {
                if (index >= _digits.length) {
                  return;
                }
                setState(() {
                  _digits.removeAt(index);
                });
              }
            },
            child: digit,
          );
        }),
      ],
    );
  }
}

class _LdCounterDigit extends StatefulWidget {
  final String digit;
  final LdSize size;
  final LdTextType type;
  final bool inline;

  const _LdCounterDigit({
    required this.digit,
    required this.size,
    required this.type,
    this.inline = false,
  });

  @override
  State<_LdCounterDigit> createState() => _LdCounterDigitState();
}

class _LdCounterDigitState extends State<_LdCounterDigit> {
  List<double> _textWidths = [];

  static const chars = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '-'];

  double calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textHeightBehavior: _counterTextHeightBehavior,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }

  double _digitHeight(LdTheme theme) {
    final style = ldBuildTextStyle(theme, widget.type, widget.size);
    return _counterTextMetrics(style).lineHeight;
  }

  @override
  void initState() {
    super.initState();

    _generateTextWidths();
  }

  void _generateTextWidths() {
    final theme = LdTheme.of(context);
    final style = ldBuildTextStyle(theme, widget.type, widget.size);
    _textWidths = chars.map((e) => calculateTextWidth(e, style)).toList();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.size != widget.size || oldWidget.type != widget.type) {
      _generateTextWidths();
    }
  }

  Widget _buildDigitText(String text) {
    return LdText(
      text,
      type: widget.type,
      size: widget.size,
    );
  }

  Widget _buildDigitCell(String text, {required double height}) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.topCenter,
        child: _buildDigitText(text),
      ),
    );
  }

  List<Widget> _buildDigitColumn(double height) {
    return [
      for (var i = 0; i < 10; i++)
        _buildDigitCell('$i', height: height),
      _buildDigitCell('.', height: height),
      _buildDigitCell('-', height: height),
    ];
  }

  Widget _buildInlineDigit({
    required int offset,
    required double height,
    required double width,
    required ({double baseline, double lineHeight}) metrics,
  }) {
    return Baseline(
      baseline: metrics.baseline,
      baselineType: TextBaseline.alphabetic,
      child: SizedBox(
        height: metrics.lineHeight,
        width: width,
        child: ClipRect(
          child: LdSpring(
            mass: 30,
            springConstant: 8,
            dampingCoefficient: 20,
            position: offset.toDouble(),
            builder: (context, state, child) {
              return OverflowBox(
                maxHeight: height * chars.length,
                alignment: Alignment.topCenter,
                child: Transform.translate(
                  offset: Offset(0, -state.position * height),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildDigitColumn(height),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStandaloneDigit({
    required int offset,
    required double height,
    required double width,
  }) {
    return SizedBox(
      height: height,
      width: width,
      child: LdSpring(
        mass: 30,
        springConstant: 8,
        dampingCoefficient: 20,
        position: offset.toDouble(),
        builder: (context, state, child) {
          return Stack(
            clipBehavior: Clip.hardEdge,
            fit: StackFit.expand,
            children: [
              ...List.generate(
                10,
                (index) => Positioned(
                  top: index * height - state.position * height,
                  child: _buildDigitCell(index.toString(), height: height),
                ),
              ),
              Positioned(
                top: 10 * height - state.position * height,
                child: _buildDigitCell('.', height: height),
              ),
              Positioned(
                top: 11 * height - state.position * height,
                child: _buildDigitCell('-', height: height),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offset = chars.indexOf(widget.digit);
    final theme = LdTheme.of(context);
    final height = _digitHeight(theme);
    final style = ldBuildTextStyle(theme, widget.type, widget.size);
    final metrics = _counterTextMetrics(style);
    final width = _textWidths[offset];

    if (widget.inline) {
      return _buildInlineDigit(
        offset: offset,
        height: height,
        width: width,
        metrics: metrics,
      );
    }

    return _buildStandaloneDigit(
      offset: offset,
      height: height,
      width: width,
    );
  }
}

/// Inline text with an animated [LdCounter] between [before] and [after].
///
/// Lays out text and counter on a shared baseline so the number sits naturally
/// in a sentence. For custom [RichText] with other spans, use [LdCounter] with
/// [LdCounter.inline] inside a baseline [WidgetSpan].
class LdCounterText extends StatelessWidget {
  const LdCounterText({
    required this.value,
    this.before = '',
    this.after = '',
    this.type = LdTextType.paragraph,
    this.size = LdSize.m,
    this.precision = 0,
    this.minDigits,
    this.color,
    this.lineHeight,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    super.key,
  });

  /// Splits [template] on `{value}` and builds an [LdCounterText].
  factory LdCounterText.template(
    String template, {
    required double value,
    LdTextType type = LdTextType.paragraph,
    LdSize size = LdSize.m,
    int precision = 0,
    int? minDigits,
    Color? color,
    double? lineHeight,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Key? key,
  }) {
    const placeholder = '{value}';
    final index = template.indexOf(placeholder);
    if (index == -1) {
      throw ArgumentError.value(
        template,
        'template',
        'Must contain exactly one {value} placeholder',
      );
    }

    return LdCounterText(
      before: template.substring(0, index),
      after: template.substring(index + placeholder.length),
      value: value,
      type: type,
      size: size,
      precision: precision,
      minDigits: minDigits,
      color: color,
      lineHeight: lineHeight,
      fontWeight: fontWeight,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      key: key,
    );
  }

  final String before;
  final String after;
  final double value;
  final LdTextType type;
  final LdSize size;
  final int precision;
  final int? minDigits;
  final Color? color;
  final double? lineHeight;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final LdMute? ldMute = context.findAncestorWidgetOfExactType<LdMute>();
    final theme = LdTheme.of(context, listen: true);

    final style = ldBuildTextStyle(
      theme,
      type,
      size,
      color: color ?? (ldMute != null ? theme.textMuted : null),
      lineHeight: lineHeight,
      fontWeight: fontWeight,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (before.isNotEmpty)
          Text(
            before,
            style: style,
            textHeightBehavior: _counterTextHeightBehavior,
          ),
        LdCounter(
          value: value,
          type: type,
          size: size,
          precision: precision,
          minDigits: minDigits,
          inline: true,
        ),
        if (after.isNotEmpty)
          Text(
            after,
            style: style,
            textHeightBehavior: _counterTextHeightBehavior,
          ),
      ],
    );
  }
}
