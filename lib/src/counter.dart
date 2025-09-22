import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdCounter extends StatefulWidget {
  final double value;

  final LdSize size;
  final int precision;

  const LdCounter({super.key, required this.value, this.precision = 0, this.size = LdSize.m});

  @override
  State<LdCounter> createState() => _LdCounterState();
}

class _LdCounterState extends State<LdCounter> {
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

class _LdCounterDigit extends StatelessWidget {
  final String digit;
  final LdSize size;
  const _LdCounterDigit({required this.digit, required this.size});

  @override
  Widget build(BuildContext context) {
    final offset = switch (digit) {
      "." => 10,
      "-" => 11,
      _ => int.parse(digit),
    };
    final theme = LdTheme.of(context);

    final fontSize = theme.headlineSize(size);

    final height = fontSize * 1.5;

    return SizedBox(
      height: height,
      child: LdSpring(
        mass: 30,
        springConstant: 8,
        dampingCoefficient: 20,
        position: offset.toDouble(),
        builder: (context, state, child) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Transform.translate(
              offset: Offset(0, -state.position * height),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(
                    10,
                    (index) => SizedBox(
                      height: height,
                      child: LdTextH(index.toString(), size: size),
                    ),
                  ),
                  SizedBox(height: height, child: LdTextH(".", size: size)),
                  SizedBox(height: height, child: LdTextH("-", size: size)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
