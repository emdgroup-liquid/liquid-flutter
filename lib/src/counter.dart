import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

part 'counter.variants.g.dart';

@Variants([
  Variant('s', defaults: {'size': 'LdSize.s'}),
  Variant('l', defaults: {'size': 'LdSize.l'}),
  Variant('xs', defaults: {'size': 'LdSize.xs'}),
])
class LdCounterWidget extends StatefulWidget {
  final double value;

  final LdSize size;
  final int precision;

  const LdCounterWidget({super.key, required this.value, this.precision = 0, this.size = LdSize.m});

  @override
  State<LdCounterWidget> createState() => _LdCounterState();
}

class _LdCounterState extends State<LdCounterWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final str = widget.value.toStringAsFixed(widget.precision);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...str
            .split("")
            .map((e) => LdReveal.quick(revealed: true, child: _LdCounterDigit(digit: e, size: widget.size)))
            .toList(),
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
  double calculateTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.size.width;
  }

  double _maxWidth = 10;

  @override
  void initState() {
    super.initState();
    _maxWidth = getMaxWidth(context);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.size != widget.size) {
      _maxWidth = getMaxWidth(context);
    }
  }

  double getMaxWidth(BuildContext context) {
    final theme = LdTheme.of(context);
    return List.generate(10,
            (index) => calculateTextWidth(index.toString(), ldBuildTextStyle(theme, LdTextType.headline, widget.size)))
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    final offset = switch (widget.digit) {
      "." => 10,
      "-" => 11,
      _ => int.parse(widget.digit),
    };
    final theme = LdTheme.of(context);

    final fontSize = theme.headlineSize(widget.size);

    final height = fontSize * 1.5;

    return SizedBox(
      height: height,
      width: _maxWidth,
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
