import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/src/emoji/analyzer.dart';
import 'package:liquid_flutter/src/emoji/optical_center.dart';

Uint8List _rgba(int width, int height, int Function(int x, int y) alphaAt) {
  final data = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = (y * width + x) * 4;
      final a = alphaAt(x, y).clamp(0, 255);
      data[i] = 0;
      data[i + 1] = 0;
      data[i + 2] = 0;
      data[i + 3] = a;
    }
  }
  return data;
}

void main() {
  group('computeInkCenterOffset', () {
    test('empty raster returns zero', () {
      final data = _rgba(20, 17, (_, __) => 0);
      final result = computeInkCenterOffset(data, width: 20, height: 17);
      expect(result.dx, 0);
      expect(result.dy, 0);
    });

    test('ink left-aligned in advance box shifts right', () {
      // Mimics Apple emoji: 20×17 layout, opaque glyph in columns 0–15.
      const w = 20;
      const h = 17;
      final data = _rgba(w, h, (x, y) {
        if (y < 1 || y > 15) return 0;
        return x <= 15 ? 255 : 0;
      });

      final result = computeInkCenterOffset(data, width: w, height: h);
      // Ink spans x=0..15 → centre 8; layout centre 10 → dx = +2.
      expect(result.dx, closeTo(2.0, 0.01));
      expect(result.dy.abs(), lessThan(0.5));
    });

    test('centred ink returns near-zero', () {
      const w = 32;
      const h = 32;
      final data = _rgba(w, h, (x, y) {
        return x >= 8 && x < 24 && y >= 8 && y < 24 ? 255 : 0;
      });

      final result = computeInkCenterOffset(data, width: w, height: h);
      expect(result.dx.abs(), lessThan(0.01));
      expect(result.dy.abs(), lessThan(0.01));
    });
  });

  group('getOpticalCenter', () {
    test('empty raster returns zero offset', () {
      final data = _rgba(32, 32, (_, __) => 0);
      final result = getOpticalCenter(data, width: 32, height: 32);
      expect(result.dx, 0);
      expect(result.dy, 0);
    });

    test('right-heavy rectangle corrects leftward', () {
      const w = 64;
      const h = 64;

      final data = _rgba(w, h, (x, y) {
        if (y < 16 || y >= 48) return 0;
        return x >= 36 && x < 56 ? 255 : 0;
      });

      final result = getOpticalCenter(data, width: w, height: h);
      expect(result.dx, lessThan(-1));
    });
  });
}
