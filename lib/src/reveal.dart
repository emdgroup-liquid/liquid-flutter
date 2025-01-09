import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/spring.dart';

/// A utility to reveal some content, with a fade in and collapse effect
class LdReveal extends StatelessWidget {
  final bool revealed;

  final Widget child;

  final double transformXOffset;
  final double transformYOffset;

  final double springConstant;
  final double dampingCoefficient;
  final double mass;
  final bool? initialRevealed;
  final int? bufferSprings;

  const LdReveal({
    required this.revealed,
    this.transformXOffset = 0,
    this.transformYOffset = 0,
    this.initialRevealed,
    this.mass = 5,

    /// Springs that are added as a buffer to the reveal effect effectively delaying the opacity / scale effect to prevent clipping the content visibly. Increase this value if the reveal effect is clipping the content.
    this.bufferSprings = 5,
    this.springConstant = 5,
    this.dampingCoefficient = 10,
    required this.child,
    Key? key,
  }) : super(key: key);

  factory LdReveal.quick(
      {required bool revealed,
      required Widget child,
      bool? initialRevealed,
      double transformXOffset = 0,
      double transformYOffset = 0}) {
    return LdReveal(
      revealed: revealed,
      child: child,
      transformXOffset: transformXOffset,
      transformYOffset: transformYOffset,
      mass: 2,
      bufferSprings: 5,
      springConstant: 25,
      dampingCoefficient: 15,
      initialRevealed: initialRevealed,
    );
  }

  factory LdReveal.slow(
      {required bool revealed,
      required Widget child,
      bool? initialRevealed,
      double transformXOffset = 0,
      double transformYOffset = 0}) {
    return LdReveal(
      revealed: revealed,
      child: child,
      transformXOffset: transformXOffset,
      transformYOffset: transformYOffset,
      mass: 2,
      bufferSprings: 5,
      springConstant: 10,
      dampingCoefficient: 15,
      initialRevealed: initialRevealed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LdChainedSprings(
        count: bufferSprings ?? 10,
        reversed: !revealed,
        targetPosition: revealed ? 1 : 0,
        initialPosition:
            initialRevealed != null ? (initialRevealed! ? 1 : 0) : 0,
        dampingCoefficient: dampingCoefficient,
        springConstant: springConstant,
        mass: mass,
        builder: (context, states) {
          final scaleValue = states.first.position.clamp(0.0, 1.0);
          final opacityValue = states.last.position.clamp(0.0, 1.0);

          double dx = 0.0, dy = 0.0, heightFactor = 1, widthFactor = 1;

          heightFactor = scaleValue.clamp(0, 1);
          widthFactor = scaleValue.clamp(0, 1);

          dy = (1 - opacityValue) * transformYOffset;

          dx = (1 - opacityValue) * transformXOffset;

          return Transform.translate(
            offset: Offset(dx, dy),
            child: ClipRRect(
              child: Align(
                heightFactor: heightFactor,
                widthFactor: widthFactor,
                child: Transform.scale(
                  scale: scaleValue.clamp(0, double.infinity),
                  child: Opacity(
                    opacity: opacityValue.clamp(0, 1),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        });
  }
}
