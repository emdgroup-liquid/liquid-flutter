import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'dart:math';

/// a loading indicator (indeterminate)
class LdLoader extends StatefulWidget {
  final double size;
  final Duration speed;
  final bool neutral;
  const LdLoader(
      {Key? key,
      this.size = 32,
      this.neutral = false,
      this.speed = const Duration(seconds: 3)})
      : super(key: key);

  @override
  State<LdLoader> createState() => _LdLoaderState();
}

class _LdLoaderState extends State<LdLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.speed,
    );
    if (!ldDisableAnimations) {
      _animationController.repeat();
    }

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final baseColor = theme.neutralShade(3).withAlpha(100);
    final accentColor =
        widget.neutral ? theme.neutralShade(4) : theme.primaryColor;
    final accentColor2 =
        widget.neutral ? theme.neutralShade(2) : theme.secondaryColor;

    return SizedBox(
        height: widget.size,
        width: widget.size,
        child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Transform.rotate(
                  angle: _animationController.value * 4 * pi,
                  child: CustomPaint(
                    painter: _LoadingPainter(
                        CurvedAnimation(
                            curve: Curves.linear, parent: _animationController),
                        widget.size,
                        baseColor: baseColor,
                        accentColor: accentColor,
                        accentColor2: accentColor2),
                  ),
                )));
  }
}

class _LoadingPainter extends CustomPainter {
  Animation<double> animation;
  double loaderSize;
  final Color baseColor;
  final Color accentColor;
  final Color accentColor2;

  _LoadingPainter(
    this.animation,
    this.loaderSize, {
    required this.baseColor,
    required this.accentColor,
    required this.accentColor2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Offset middle = Offset(loaderSize / 2, loaderSize / 2);

    var oscilatorB = sin(2 * animation.value * pi) * 0.5 + 0.5;

    Paint paint = Paint()..color = baseColor;

    final blend = Color.lerp(accentColor, accentColor2, oscilatorB)!;

    Paint accent3 = Paint()
      ..color = blend
      ..strokeWidth = loaderSize / 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var startAngle = animation.value * 2 * pi;

    canvas.saveLayer(Offset.zero & size, Paint());

    canvas.clipRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: middle, width: loaderSize, height: loaderSize),
        Radius.circular(loaderSize / 2)));

    canvas.drawArc(
        Rect.fromCenter(center: middle, width: loaderSize, height: loaderSize),
        startAngle,
        2 * pi,
        false,
        paint);

    canvas.drawArc(
        Rect.fromCenter(
            center: middle,
            width: loaderSize / 2 + (loaderSize / 4),
            height: loaderSize / 2 + (loaderSize / 4)),
        oscilatorB,
        oscilatorB,
        false,
        accent3);

    canvas.drawArc(
        Rect.fromCenter(
            center: middle,
            width: loaderSize / 2 + (loaderSize / 4),
            height: loaderSize / 2 + (loaderSize / 4)),
        pow(oscilatorB, 4) + pi,
        oscilatorB + 0.8 * pi,
        false,
        accent3);

    canvas.drawCircle(
        middle, loaderSize / 4, Paint()..blendMode = BlendMode.clear);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
