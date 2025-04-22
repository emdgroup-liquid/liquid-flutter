import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'package:sensors_plus/sensors_plus.dart';

/// an animated illustration of an orb filled with liquid that has some waves and a [filling] level.
class LdOrb extends StatefulWidget {
  final double size;
  final double filling;
  final bool paintBackground;

  const LdOrb(this.filling,
      {this.size = 150, this.paintBackground = false, Key? key})
      : super(key: key);

  @override
  State<LdOrb> createState() => _LdOrbState();
}

class _LdOrbState extends State<LdOrb> with TickerProviderStateMixin {
  AnimationController? _animationController;
  final Tween<double> _tween = Tween(begin: 0.0, end: 1);
  Animation<double>? _animation;

  double _angle = 0.0;
  StreamSubscription<AccelerometerEvent>? _streamSubscription;
  double get _fill => 1 - ((widget.filling * 0.9) + 0.1);

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = _tween.animate(_animationController!);

    _animationController!.repeat(reverse: false);
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _streamSubscription =
          accelerometerEventStream().listen((AccelerometerEvent event) {
        setState(() {
          double x = event.x, y = event.y, z = event.z;
          // Normalize vector
          double norm = sqrt(x * x + y * y + z * z);

          // Angle of the phone in x
          x = event.x / norm;

          _angle = x;
        });
      });
    }

    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<LdTheme>(context, listen: false);
    if (_animation == null) {
      return Container();
    }
    return Stack(
      children: [
        AnimatedRotation(
          turns: _angle / pi,
          // Determines the viscosity of the fluid in the bowl
          duration: const Duration(milliseconds: 500),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                boxShadow: const [],
                borderRadius: BorderRadius.circular(widget.size / 2)),
            height: widget.size,
            width: widget.size,
            child: LdSpring(
              position: _fill,
              initialPosition: 0,
              builder: (context, spring) => AnimatedBuilder(
                  animation: _animation!,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _OrbPainter(
                        Size(widget.size, widget.size),
                        spring.position,
                        _animation!.value + spring.velocity,
                        widget.paintBackground,
                        theme,
                      ),
                    );
                  }),
            ),
          ),
        ),
        CustomPaint(
            painter: ReflectionPainter(theme, Size(widget.size, widget.size)))
      ],
    );
  }
}

class ReflectionPainter extends CustomPainter {
  final LdTheme theme;
  final double inset = 5.0;

  final Size orbSize;
  ReflectionPainter(this.theme, this.orbSize);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var height = orbSize.height - 2 * inset;
    var width = orbSize.width - 2 * inset;

    var center = Offset(orbSize.height / 2, orbSize.width / 2);
    canvas.drawArc(
        Rect.fromCenter(center: center, width: width - 30, height: height - 30),
        3.5 * pi,
        pi / 5,
        false,
        Paint()
          ..color = shadZinc.shades[3]
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke);

    canvas.drawArc(
        Rect.fromCenter(center: center, width: width - 30, height: height - 30),
        3.75 * pi,
        pi / 15,
        false,
        Paint()
          ..color = shadZinc.shades[3]
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke);
  }
}

class _OrbPainter extends CustomPainter {
  final Size _orbSize;
  final double fillPercentage;
  final bool paintBackground;
  final double animationProgress;
  final LdTheme theme;
  final double inset = 5.0;

  _OrbPainter(this._orbSize, this.fillPercentage, this.animationProgress,
      this.paintBackground, this.theme);

  double get width => _orbSize.width - 2 * inset;

  double get height => _orbSize.height - 2 * inset;

  Offset _positionOnCircle({
    bool left = true,
    double offset = 0,
  }) {
    if (left) {
      return Offset(
          cos(pi * (1 - (fillPercentage - offset)) + 0.5 * pi) * width / 2 +
              width / 2 +
              inset,
          sin(pi * (1 - (fillPercentage - offset)) + 0.5 * pi) * height / 2 +
              height / 2 +
              inset);
    } else {
      return Offset(
          sin(pi * (1 - max((fillPercentage - offset), 0))) * width / 2 +
              width / 2 +
              inset,
          cos(pi * (1 - max((fillPercentage - offset), 0))) * height / 2 +
              height / 2 +
              inset);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Inset the orb a bit to draw borders around it
    var height = _orbSize.height - 2 * inset;
    var width = _orbSize.width - 2 * inset;

    var center = Offset(_orbSize.height / 2, _orbSize.width / 2);

    // Draw a white circle if the option paintBackground is given
    if (paintBackground) {
      canvas.drawCircle(center, _orbSize.width / 2 - 10,
          Paint()..color = theme.neutralShade(0));
    }

    // Wave height is biggest in the middle of the bowl at upper and lower bounds the waves become smaller
    var waveHeight = sin(fillPercentage * pi) * height / 10;

    // Calculate where the wave starts and ends
    var waveStart = _positionOnCircle(
      left: true,
    );
    var waveEnd = _positionOnCircle(left: false);

    var waveWidth = (waveEnd.dx - waveStart.dx);

    // Wave offset is responsible for moving the waves
    var waveOffset =
        sin(animationProgress * 2 * pi) * waveWidth * 0.125 + waveWidth * 0.125;

    Path path = Path();

    // Move to start
    path.moveTo(waveStart.dx, waveStart.dy);

    // First part of the wave, approx half of the width, wit a control point moving up and down but constant in x
    path.quadraticBezierTo(
      waveStart.dx + waveWidth * 0.25,
      waveStart.dy + sin(animationProgress * 2 * pi) * waveHeight,
      waveStart.dx + waveWidth / 2,
      waveStart.dy,
    );
    // Second part of the wave with same moving control point
    path.quadraticBezierTo(
      waveStart.dx + waveWidth * 0.75,
      waveStart.dy - sin(animationProgress * 2 * pi) * waveHeight,
      waveEnd.dx,
      waveEnd.dy,
    );

    // Circle to the bottom middle
    path.arcToPoint(Offset(center.dx, inset + height),
        radius: Radius.circular(height / 2));

    // To the start of the wave to close the path
    path.arcToPoint(waveStart, radius: Radius.circular(height / 2));

    canvas.drawPath(
        path,
        Paint()
          ..color = theme.palette.primary.active(theme.isDark).withAlpha(100)
          ..style = PaintingStyle.fill);

    Path secondWave = Path();

    secondWave.moveTo(waveStart.dx, waveStart.dy);

    // Second wave also has waveOffset to move the wave horizontally
    secondWave.quadraticBezierTo(
      waveStart.dx + waveWidth * 0.25 + waveOffset,
      waveStart.dy + sin(animationProgress * 2 * pi) * waveHeight,
      waveStart.dx + waveWidth / 2 + waveOffset,
      waveStart.dy,
    );

    secondWave.quadraticBezierTo(
      waveStart.dx + waveWidth * 0.75 + waveOffset,
      waveStart.dy - sin(animationProgress * 2 * pi) * waveHeight,
      waveEnd.dx,
      waveEnd.dy,
    );

    secondWave.arcToPoint(Offset(center.dx, inset + height),
        radius: Radius.circular(height / 2));

    secondWave.arcToPoint(waveStart, radius: Radius.circular(height / 2));

    canvas.drawPath(
      secondWave,
      Paint()..color = theme.palette.primary.hover(theme.isDark).withAlpha(50),
    );

    // Grey border
    var border = Paint()..color = theme.border;
    border.strokeWidth = 2;
    border.style = PaintingStyle.stroke;

    // Alpha ramp (todo: smooth out) for bubbles
    double alphaRamp = 1;

    // Bubbles disappear if theres not a lot of liquid
    if (fillPercentage > 0.5) {
      alphaRamp = 0;
    }

    var bubbleColor = theme.palette.primary
        .active(theme.isDark)
        .withAlpha((alphaRamp * 255).toInt());

    // draw to bubbles
    canvas.drawCircle(
        Offset(width * 0.75, fillPercentage * height + height / 3),
        width / 30,
        Paint()..color = bubbleColor);
    canvas.drawCircle(
        Offset(width * 0.8, fillPercentage * height + height / 2.5),
        width / 50,
        Paint()..color = bubbleColor);

    // draw border last
    canvas.drawCircle(center, height / 2, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
