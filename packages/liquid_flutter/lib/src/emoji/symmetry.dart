import 'dart:math' as math;
import 'dart:typed_data';

/// Full symmetry analysis of a weight map.
class SymmetryResult {
  const SymmetryResult({
    required this.bilateralX,
    required this.bilateralY,
    required this.radial,
    required this.dominantAxis,
  });

  /// Left-right bilateral symmetry in [0, 1].
  final double bilateralX;

  /// Top-bottom bilateral symmetry in [0, 1].
  final double bilateralY;

  /// Rotational symmetry in [0, 1].
  final double radial;

  /// Angle (radians) of the strongest bilateral symmetry axis.
  final double dominantAxis;
}

/// Correction magnitude derived from symmetry (sign applied separately).
class SymmetryCorrection {
  const SymmetryCorrection({required this.dx, required this.dy});

  final double dx;
  final double dy;
}

/// Bilateral symmetry via flip-and-compare.
double computeBilateralSymmetry(
  Float32List weights,
  int width,
  int height,
  String axis,
) {
  var diffSum = 0.0;
  var totalWeight = 0.0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final idx = y * width + x;
      final w = weights[idx];
      totalWeight += w;

      final flippedIdx = axis == 'x'
          ? y * width + (width - 1 - x)
          : (height - 1 - y) * width + x;
      diffSum += (w - weights[flippedIdx]).abs();
    }
  }

  if (totalWeight == 0) return 1.0;

  final score = 1 - diffSum / (2 * totalWeight);
  return score.clamp(0.0, 1.0);
}

/// Radial (rotational) symmetry around [cx], [cy].
double computeRadialSymmetry(
  Float32List weights,
  int width,
  int height,
  double cx,
  double cy, {
  int folds = 4,
}) {
  if (folds < 2) return 1.0;

  var totalDiff = 0.0;
  var totalWeight = 0.0;
  var comparisons = 0;

  for (var k = 1; k < folds; k++) {
    final theta = (2 * math.pi * k) / folds;
    final cosT = math.cos(theta);
    final sinT = math.sin(theta);

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final w = weights[y * width + x];

        final dx = x - cx;
        final dy = y - cy;
        final rx = dx * cosT - dy * sinT + cx;
        final ry = dx * sinT + dy * cosT + cy;

        final x0 = rx.floor();
        final y0 = ry.floor();
        final x1 = x0 + 1;
        final y1 = y0 + 1;

        if (x0 < 0 || x1 >= width || y0 < 0 || y1 >= height) {
          continue;
        }

        final fx = rx - x0;
        final fy = ry - y0;
        final wRotated = weights[y0 * width + x0] * (1 - fx) * (1 - fy) +
            weights[y0 * width + x1] * fx * (1 - fy) +
            weights[y1 * width + x0] * (1 - fx) * fy +
            weights[y1 * width + x1] * fx * fy;

        totalDiff += (w - wRotated).abs();
        totalWeight += w + wRotated;
        comparisons++;
      }
    }
  }

  if (totalWeight == 0 || comparisons == 0) return 1.0;

  final score = 1 - totalDiff / totalWeight;
  return score.clamp(0.0, 1.0);
}

/// Scan [numAngles] axes in [0, π) for the best bilateral symmetry axis.
({double angle, double score}) computeSymmetryAxis(
  Float32List weights,
  int width,
  int height, {
  int numAngles = 36,
}) {
  final cx = width / 2.0;
  final cy = height / 2.0;

  var bestAngle = 0.0;
  var bestScore = 0.0;

  for (var i = 0; i < numAngles; i++) {
    final theta = (math.pi * i) / numAngles;
    final cos2t = math.cos(2 * theta);
    final sin2t = math.sin(2 * theta);

    var diffSum = 0.0;
    var totalWeight = 0.0;
    var validPixels = 0;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final w = weights[y * width + x];
        totalWeight += w;

        final dx = x - cx;
        final dy = y - cy;
        final rx = dx * cos2t + dy * sin2t + cx;
        final ry = dx * sin2t - dy * cos2t + cy;

        final x0 = rx.floor();
        final y0 = ry.floor();

        if (x0 < 0 || x0 + 1 >= width || y0 < 0 || y0 + 1 >= height) {
          continue;
        }

        final fx = rx - x0;
        final fy = ry - y0;
        final wReflected = weights[y0 * width + x0] * (1 - fx) * (1 - fy) +
            weights[y0 * width + (x0 + 1)] * fx * (1 - fy) +
            weights[(y0 + 1) * width + x0] * (1 - fx) * fy +
            weights[(y0 + 1) * width + (x0 + 1)] * fx * fy;

        diffSum += (w - wReflected).abs();
        validPixels++;
      }
    }

    if (totalWeight == 0 || validPixels == 0) continue;

    final score = (1 - diffSum / (2 * totalWeight)).clamp(0.0, 1.0);
    if (score > bestScore) {
      bestScore = score;
      bestAngle = theta;
    }
  }

  return (angle: bestAngle, score: bestScore);
}

/// Magnitude of symmetry-based correction (sign from asymmetry analysis).
SymmetryCorrection computeSymmetryCorrection(
  SymmetryResult symmetry,
  int width,
  int height,
) {
  const scaleFactor = 0.03;
  final radialDamping = symmetry.radial;

  final asymFactorX = 1 - symmetry.bilateralX;
  final asymFactorY = 1 - symmetry.bilateralY;

  final dx = asymFactorX * (1 - radialDamping) * width * scaleFactor;
  final dy = asymFactorY * (1 - radialDamping) * height * scaleFactor;

  return SymmetryCorrection(dx: dx, dy: dy);
}

/// Full symmetry analysis pipeline.
SymmetryResult analyzeSymmetry(
  Float32List weights,
  int width,
  int height,
) {
  final bilateralX = computeBilateralSymmetry(weights, width, height, 'x');
  final bilateralY = computeBilateralSymmetry(weights, width, height, 'y');
  final radial = computeRadialSymmetry(
    weights,
    width,
    height,
    width / 2.0,
    height / 2.0,
  );
  final axis = computeSymmetryAxis(weights, width, height);

  return SymmetryResult(
    bilateralX: bilateralX,
    bilateralY: bilateralY,
    radial: radial,
    dominantAxis: axis.angle,
  );
}
