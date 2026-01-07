import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

part 'counter.variants.g.dart';

@Variants([
  Variant('s', defaults: {'size': 'LdSize.s'}),
  Variant('l', defaults: {'size': 'LdSize.l'}),
  Variant('xs', defaults: {'size': 'LdSize.xs'}),
])
class _LdCounterWidget extends StatefulWidget {
  final double value;

  final LdSize size;
  final int precision;

  const _LdCounterWidget({required this.value, this.precision = 0, this.size = LdSize.m});

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
    if (oldWidget.value != widget.value) {
      _generateDigits();
      setState(() {});
    }
  }

  void _generateDigits() {
    final str = widget.value.toStringAsFixed(widget.precision).split("");

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
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._digits.mapIndexed((
          index,
          e,
        ) =>
            LdReveal(
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
              child: _LdCounterDigit(digit: e.$2, size: widget.size),
            )),
      ],
    );
  }
}

class _LdCounterDigit extends StatefulWidget {
  final String digit;
  final LdSize size;

  const _LdCounterDigit({required this.digit, required this.size});

  @override
  State<_LdCounterDigit> createState() => _LdCounterDigitState();
}

class _LdCounterDigitState extends State<_LdCounterDigit> {
  List<double> _textWidths = [];

  static const chars = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".", "-"];

  double calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }

  @override
  void initState() {
    super.initState();

    _generateTextWidths();
  }

  void _generateTextWidths() {
    final theme = LdTheme.of(context);
    _textWidths =
        chars.map((e) => calculateTextWidth(e, ldBuildTextStyle(theme, LdTextType.headline, widget.size))).toList();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.size != widget.size) {
      _generateTextWidths();
    }
  }

  @override
  Widget build(BuildContext context) {
    final offset = chars.indexOf(widget.digit);
    final theme = LdTheme.of(context);

    final fontSize = theme.headlineSize(widget.size);

    final height = fontSize * 1.5;

    return SizedBox(
      height: height,
      width: _textWidths[offset],
      child: LdSpring(
        mass: 30,
        springConstant: 8,
        dampingCoefficient: 20,
        position: offset.toDouble(),
        builder: (context, state, child) {
          return Stack(
            fit: StackFit.loose,
            children: [
              ...List.generate(
                  10,
                  (index) => Positioned(
                        top: index * height - state.position * height,
                        child: SizedBox(
                          height: height,
                          child: LdText.h(index.toString(), size: widget.size),
                        ),
                      )),
              Positioned(
                top: 10 * height - state.position * height,
                child: SizedBox(height: height, child: LdText.h(".", size: widget.size)),
              ),
              Positioned(
                top: 11 * height - state.position * height,
                child: SizedBox(height: height, child: LdText.h("-", size: widget.size)),
              ),
            ],
          );
        },
      ),
    );
  }
}
