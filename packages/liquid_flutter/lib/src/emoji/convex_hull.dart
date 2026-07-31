import 'dart:typed_data';

/// 2D point in pixel space.
class Point {
  const Point(this.x, this.y);

  final double x;
  final double y;
}

double _cross(Point o, Point a, Point b) {
  return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
}

/// Andrew's monotone chain convex hull (CCW).
List<Point> convexHull(List<Point> points) {
  if (points.length < 3) return List<Point>.from(points);

  final sorted = List<Point>.from(points)
    ..sort((a, b) {
      final dx = a.x.compareTo(b.x);
      return dx != 0 ? dx : a.y.compareTo(b.y);
    });

  final n = sorted.length;
  final lower = <Point>[];
  for (var i = 0; i < n; i++) {
    while (lower.length >= 2 &&
        _cross(lower[lower.length - 2], lower[lower.length - 1], sorted[i]) <=
            0) {
      lower.removeLast();
    }
    lower.add(sorted[i]);
  }

  final upper = <Point>[];
  for (var i = n - 1; i >= 0; i--) {
    while (upper.length >= 2 &&
        _cross(upper[upper.length - 2], upper[upper.length - 1], sorted[i]) <=
            0) {
      upper.removeLast();
    }
    upper.add(sorted[i]);
  }

  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

/// Sample opaque pixels as hull candidates.
List<Point> extractBoundaryPoints(
  Float32List weights,
  int width,
  int height, {
  double threshold = 0.01,
  int step = 1,
}) {
  final points = <Point>[];

  for (var y = 0; y < height; y += step) {
    for (var x = 0; x < width; x += step) {
      if (weights[y * width + x] > threshold) {
        points.add(Point(x + 0.5, y + 0.5));
      }
    }
  }

  return points;
}

/// Polygon centroid of a convex hull (signed-area formula).
Point hullCentroid(List<Point> hull) {
  if (hull.isEmpty) return const Point(0, 0);
  if (hull.length == 1) return hull[0];
  if (hull.length == 2) {
    return Point(
      (hull[0].x + hull[1].x) / 2,
      (hull[0].y + hull[1].y) / 2,
    );
  }

  var signedArea = 0.0;
  var cx = 0.0;
  var cy = 0.0;

  for (var i = 0; i < hull.length; i++) {
    final j = (i + 1) % hull.length;
    final a = hull[i];
    final b = hull[j];
    final f = a.x * b.y - b.x * a.y;
    signedArea += f;
    cx += (a.x + b.x) * f;
    cy += (a.y + b.y) * f;
  }

  signedArea /= 2;

  if (signedArea.abs() < 1e-10) {
    final avgX = hull.fold<double>(0, (s, p) => s + p.x) / hull.length;
    final avgY = hull.fold<double>(0, (s, p) => s + p.y) / hull.length;
    return Point(avgX, avgY);
  }

  cx /= 6 * signedArea;
  cy /= 6 * signedArea;
  return Point(cx, cy);
}
