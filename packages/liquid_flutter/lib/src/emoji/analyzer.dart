import 'dart:typed_data';

/// Flat visual-weight map derived from an RGBA raster.
class PixelData {
  const PixelData({
    required this.width,
    required this.height,
    required this.weights,
  });

  final int width;
  final int height;

  /// Row-major weights, length = [width] × [height].
  final Float32List weights;
}

/// Build a visual weight map from raw RGBA pixels.
///
/// For colour emoji we use alpha alone (shape silhouette). Dark-on-transparent
/// icon pipelines often use `alpha × (1 − luminance)` instead; that biases
/// filled emoji incorrectly.
PixelData buildWeightMap(
  Uint8List data, {
  required int width,
  required int height,
}) {
  final weights = Float32List(width * height);

  for (var i = 0; i < width * height; i++) {
    final offset = i * 4;
    final a = data[offset + 3] / 255.0;
    weights[i] = a < 0.01 ? 0.0 : a;
  }

  return PixelData(width: width, height: height, weights: weights);
}

/// Weighted centroid in pixel space (pixel centres at +0.5).
({double cx, double cy, double totalWeight}) computeWeightedCentroid(
  PixelData pixelData,
) {
  final width = pixelData.width;
  final height = pixelData.height;
  final weights = pixelData.weights;

  var sumW = 0.0;
  var sumXW = 0.0;
  var sumYW = 0.0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final w = weights[y * width + x];
      if (w > 0) {
        sumW += w;
        sumXW += (x + 0.5) * w;
        sumYW += (y + 0.5) * w;
      }
    }
  }

  if (sumW == 0) {
    return (cx: width / 2.0, cy: height / 2.0, totalWeight: 0.0);
  }

  return (cx: sumXW / sumW, cy: sumYW / sumW, totalWeight: sumW);
}

/// Tight ink AABB in pixel coordinates, or `null` if no opaque pixels.
({int left, int top, int width, int height})? findInkBounds(
  Uint8List data, {
  required int width,
  required int height,
  int alphaThreshold = 12,
}) {
  var minX = width;
  var minY = height;
  var maxX = -1;
  var maxY = -1;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final a = data[(y * width + x) * 4 + 3];
      if (a <= alphaThreshold) continue;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
  }

  if (maxX < 0) return null;

  return (
    left: minX,
    top: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
}

/// Offset that centres the tight ink AABB on the raster's geometric centre.
///
/// This corrects platform emoji advance-width padding (opaque glyph sits left
/// of a wider layout box with empty space on the right). Positive [dx]/[dy]
/// mean shift content right/down.
({double dx, double dy}) computeInkCenterOffset(
  Uint8List data, {
  required int width,
  required int height,
  int alphaThreshold = 12,
}) {
  final bounds = findInkBounds(
    data,
    width: width,
    height: height,
    alphaThreshold: alphaThreshold,
  );
  if (bounds == null) {
    return (dx: 0.0, dy: 0.0);
  }

  final inkCx = bounds.left + bounds.width / 2.0;
  final inkCy = bounds.top + bounds.height / 2.0;

  return (
    dx: width / 2.0 - inkCx,
    dy: height / 2.0 - inkCy,
  );
}
