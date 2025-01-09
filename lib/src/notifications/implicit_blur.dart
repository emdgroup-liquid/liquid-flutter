import 'dart:ui';

import 'package:flutter/material.dart';

class ImplicitBlur extends StatefulWidget {
  final double sigma;
  final Widget child;
  final Duration duration;

  const ImplicitBlur({
    super.key,
    required this.sigma,
    required this.child,
    required this.duration,
  });

  @override
  State<ImplicitBlur> createState() => _ImplicitBlurState();
}

class _ImplicitBlurState extends State<ImplicitBlur>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  Tween<double> _tween = Tween<double>(begin: 0, end: 0);

  @override
  void initState() {
    _controller.value = widget.sigma;
    _tween = Tween<double>(begin: widget.sigma, end: widget.sigma);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ImplicitBlur oldWidget) {
    if (oldWidget.sigma != widget.sigma) {
      _tween = Tween<double>(begin: oldWidget.sigma, end: widget.sigma);
      _controller.forward(from: 0);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sigma = _tween.evaluate(_controller);
        if (sigma == 0) {
          return widget.child;
        }
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: sigma,
            sigmaY: sigma,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
