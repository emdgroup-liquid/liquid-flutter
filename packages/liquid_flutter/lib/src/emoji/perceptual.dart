import 'dart:typed_data';

/// Perceptual correction knobs (vertical bias + shape awareness).
class PerceptualConfig {
  const PerceptualConfig({
    this.verticalBias = 0.035,
    this.hullWeight = 0.3,
    this.shapeCorrection = true,
  });

  /// Humans perceive centre ~3–5% higher than geometric midpoint.
  final double verticalBias;

  /// V1 mass/hull blend weight (kept for parity; V2 uses explicit blend).
  final double hullWeight;

  final bool shapeCorrection;
}

const defaultPerceptualConfig = PerceptualConfig();

/// Shift optical centre upward by [bias] × [height].
double applyVerticalBias(double cy, int height, double bias) {
  return cy - height * bias;
}

/// Asymmetry of mass about the midlines (−1…1).
({double asymX, double asymY}) analyzeAsymmetry(
  Float32List weights,
  int width,
  int height,
) {
  final midX = width / 2.0;
  final midY = height / 2.0;

  var leftWeight = 0.0;
  var rightWeight = 0.0;
  var topWeight = 0.0;
  var bottomWeight = 0.0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final w = weights[y * width + x];
      if (w <= 0) continue;

      if (x < midX) {
        leftWeight += w;
      } else {
        rightWeight += w;
      }

      if (y < midY) {
        topWeight += w;
      } else {
        bottomWeight += w;
      }
    }
  }

  final totalH = leftWeight + rightWeight;
  final totalV = topWeight + bottomWeight;

  return (
    asymX: totalH > 0 ? (rightWeight - leftWeight) / totalH : 0.0,
    asymY: totalV > 0 ? (bottomWeight - topWeight) / totalV : 0.0,
  );
}
