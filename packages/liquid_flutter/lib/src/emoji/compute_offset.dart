import 'dart:math' as math;
import 'dart:typed_data';

import 'package:liquid_flutter/src/emoji/analyzer.dart';
import 'package:liquid_flutter/src/emoji/convex_hull.dart';
import 'package:liquid_flutter/src/emoji/perceptual.dart';
import 'package:liquid_flutter/src/emoji/preprocessing.dart';
import 'package:liquid_flutter/src/emoji/symmetry.dart';

/// Raw V2 optical offset in raster pixels (before [correctionScale]).
class OpticalOffset {
  const OpticalOffset({
    required this.dx,
    required this.dy,
  });

  /// Positive = shift content right.
  final double dx;

  /// Positive = shift content down.
  final double dy;
}

/// Biologically-inspired V2 optical-center pipeline.
///
/// Port of `computeOffsetV2` from
/// https://github.com/Grkmyldz148/optical-center (MIT).
OpticalOffset computeOffsetV2(
  Uint8List data, {
  required int width,
  required int height,
  int hullStep = 2,
  double edgeWeight = 0.40,
  double hullWeight = 0.30,
  double symmetryWeight = 0.30,
  PreprocessingConfig preprocessing = defaultPreprocessingConfig,
  PerceptualConfig perceptual = defaultPerceptualConfig,
}) {
  final pixelData = buildWeightMap(data, width: width, height: height);
  final rawMass = computeWeightedCentroid(pixelData);

  if (rawMass.totalWeight == 0) {
    return const OpticalOffset(dx: 0, dy: 0);
  }

  final processedWeights = preprocessWeightMap(
    pixelData.weights,
    width,
    height,
    preprocessing,
  );

  // Edge centroid from DoG+compressed map (DoG is the edge detector).
  final edgeMass = computeWeightedCentroid(
    PixelData(width: width, height: height, weights: processedWeights),
  );
  final edgeCx = edgeMass.cx;
  final edgeCy = edgeMass.cy;

  // Hull + symmetry from raw weight map (full shape envelope).
  final boundaryPoints = extractBoundaryPoints(
    pixelData.weights,
    width,
    height,
    threshold: 0.01,
    step: hullStep,
  );
  final hull = convexHull(boundaryPoints);
  final hullCenter = hullCentroid(hull);

  final symmetry = analyzeSymmetry(pixelData.weights, width, height);
  final massCentroid = computeWeightedCentroid(pixelData);

  final geoCx = width / 2.0;
  final geoCy = height / 2.0;
  final axisAngle = symmetry.dominantAxis;
  final cosA = math.cos(axisAngle);
  final sinA = math.sin(axisAngle);

  final dmx = massCentroid.cx - geoCx;
  final dmy = massCentroid.cy - geoCy;
  final proj = dmx * cosA + dmy * sinA;
  final symStrength = math.max(symmetry.bilateralX, symmetry.bilateralY);

  final symmetryAxisCx = geoCx + proj * cosA * symStrength;
  final symmetryAxisCy = geoCy + proj * sinA * symStrength;

  var opticalX = edgeCx * edgeWeight +
      hullCenter.x * hullWeight +
      symmetryAxisCx * symmetryWeight;
  var opticalY = edgeCy * edgeWeight +
      hullCenter.y * hullWeight +
      symmetryAxisCy * symmetryWeight;

  final asymmetry = analyzeAsymmetry(pixelData.weights, width, height);
  final symCorr = computeSymmetryCorrection(symmetry, width, height);
  opticalX += symCorr.dx * asymmetry.asymX.sign;
  opticalY += symCorr.dy * asymmetry.asymY.sign;

  opticalY = applyVerticalBias(opticalY, height, perceptual.verticalBias);

  return OpticalOffset(
    dx: geoCx - opticalX,
    dy: geoCy - opticalY,
  );
}
