import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdAnimatedLoadingGradient extends StatelessWidget {
  final double height;
  final double? width;

  const LdAnimatedLoadingGradient({super.key, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: LdTheme.of(context).neutralShade(3),
        borderRadius: LdTheme.of(context).radius(LdSize.m),
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .shimmer(
          color: LdTheme.of(context).neutralShade(5),
          duration: const Duration(milliseconds: 1000),
        );
  }
}
