import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// a loading indicator (indeterminate)
class LdLoader extends StatefulWidget {
  final double size;
  final Duration speed;
  final bool neutral;
  const LdLoader({
    super.key,
    this.size = 32,
    this.neutral = false,
    this.speed = const Duration(seconds: 3),
  });

  @override
  State<LdLoader> createState() => _LdLoaderState();
}

class _LdLoaderState extends State<LdLoader> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.speed,
    );
    if (!ldDisableAnimations) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LdLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _animationController.duration = widget.speed;
      if (_animationController.isAnimating) {
        _animationController.repeat();
      }
    }
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
    final accentColor = widget.neutral ? theme.neutralShade(4) : theme.primaryColor;
    final accentColor2 = widget.neutral ? theme.neutralShade(2) : theme.secondaryColor;

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _LoadingPainter(
            animation: _animationController,
            loaderSize: widget.size,
            baseColor: baseColor,
            accentColor: accentColor,
            accentColor2: accentColor2,
          ),
        ),
      ),
    );
  }
}

class _LoadingPainter extends CustomPainter {
  final Animation<double> animation;
  final double loaderSize;
  final Color baseColor;
  final Color accentColor;
  final Color accentColor2;

  _LoadingPainter({
    required this.animation,
    required this.loaderSize,
    required this.baseColor,
    required this.accentColor,
    required this.accentColor2,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final value = animation.value;
    final middle = Offset(loaderSize / 2, loaderSize / 2);
    final oscilatorB = sin(2 * value * pi) * 0.5 + 0.5;
    final startAngle = value * 2 * pi;
    final blend = Color.lerp(accentColor, accentColor2, oscilatorB)!;

    final paint = Paint()..color = baseColor;
    final accent = Paint()
      ..color = blend
      ..strokeWidth = loaderSize / 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(middle.dx, middle.dy);
    canvas.rotate(value * 4 * pi);
    canvas.translate(-middle.dx, -middle.dy);

    canvas.saveLayer(Offset.zero & size, Paint());

    canvas.clipRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: middle, width: loaderSize, height: loaderSize),
        Radius.circular(loaderSize / 2),
      ),
    );

    canvas.drawArc(
      Rect.fromCenter(center: middle, width: loaderSize, height: loaderSize),
      startAngle,
      2 * pi,
      false,
      paint,
    );

    final arcRect = Rect.fromCenter(
      center: middle,
      width: loaderSize / 2 + (loaderSize / 4),
      height: loaderSize / 2 + (loaderSize / 4),
    );

    canvas.drawArc(
      arcRect,
      oscilatorB,
      oscilatorB,
      false,
      accent,
    );
    canvas.drawArc(
      arcRect,
      pow(oscilatorB, 4) + pi,
      oscilatorB + 0.8 * pi,
      false,
      accent,
    );

    canvas.drawCircle(middle, loaderSize / 4, Paint()..blendMode = BlendMode.clear);

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LoadingPainter oldDelegate) {
    return oldDelegate.loaderSize != loaderSize ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.accentColor2 != accentColor2;
  }

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
