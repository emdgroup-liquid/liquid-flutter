import 'dart:typed_data';

import 'package:liquid_flutter/src/emoji/compute_offset.dart';
import 'package:liquid_flutter/src/emoji/perceptual.dart';

/// Phase 2 pooled PSE — humans prefer ~74.5% of the raw V2 correction.
const double correctionScale = 0.745;

/// Optical center offset in raster pixels.
class OpticalCenterResult {
  const OpticalCenterResult({required this.dx, required this.dy});

  /// Positive = shift content right.
  final double dx;

  /// Positive = shift content down.
  final double dy;
}

/// Compute the perceptual optical-center offset for an RGBA raster.
///
/// Output is in raster pixels. Scale to display with
/// `displaySize / rasterSize`.
///
/// Port of `getOpticalCenter` from
/// https://github.com/Grkmyldz148/optical-center (MIT) — V2 × 0.745.
///
/// [verticalBias] defaults to `0` for emoji rasters (AABB crop already frames
/// the ink; the icon-calibrated 3.5% upward bias would nudge solid glyphs off
/// centre). Pass `0.035` to match the upstream icon pipeline.
OpticalCenterResult getOpticalCenter(
  Uint8List data, {
  required int width,
  required int height,
  double verticalBias = 0,
}) {
  final raw = computeOffsetV2(
    data,
    width: width,
    height: height,
    perceptual: PerceptualConfig(verticalBias: verticalBias),
  );
  return OpticalCenterResult(
    dx: raw.dx * correctionScale,
    dy: raw.dy * correctionScale,
  );
}
