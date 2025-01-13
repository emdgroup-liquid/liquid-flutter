import 'dart:ui';

import 'package:liquid_flutter/src/color/tokens/absolutes.dart';

class LdColor {
  final List<Color> shades;
  final int _center;
  final int _darkCenter;

  const LdColor(
    this.shades,
    this._center,
    this._darkCenter, {
    this.luminanceThreshold = 0.179,
    this.disabledAlpha = 50,
  });

  Color center(bool isDark) => isDark ? shades[_darkCenter] : shades[_center];

  // Get the center color of the palette
  Color fromCenter(int offset, bool isDark) {
    final center = isDark ? _darkCenter : _center;
    return shades[(center + offset).clamp(0, shades.length - 1)];
  }

  /// Get the dark center color of the palette
  Color fromDarkCenter(int offset) =>
      shades[(_darkCenter + offset).clamp(0, shades.length - 1)];

  /// Move the color relative to the palette
  /// returns the new color
  Color moveRelative(Color color, int offset) {
    final index = shades.indexOf(color);
    final newIndex = index + offset;
    return shades[newIndex.clamp(0, shades.length - 1)];
  }

  Color relative(bool isDark, int offset) {
    final list = isDark ? shades.reversed.toList() : shades;
    return list[offset.clamp(0, list.length - 1)];
  }

  /*
    UI States
  */

  Color idle(bool dark) => fromCenter(0, dark);
  Color hover(bool dark) => fromCenter(1, dark);
  Color active(bool dark) => fromCenter(2, dark);
  Color focus(bool dark) => fromCenter(-1, dark);

  /*
    DEBUG FUNCTIONS
  */

  /// Locate the color in the palette
  /// Prints the palette with the color highlighted, and the center and
  /// dark center marked
  String locateColor(Color color) {
    var found = false;
    final result = StringBuffer();
    for (final shade in shades) {
      final isCenter = _center == shades.indexOf(shade);
      final isDarkCenter = _darkCenter == shades.indexOf(shade);
      final suffix = " (${isCenter ? "C" : ""}${isDarkCenter ? "D" : ""})";

      if (shade == color) {
        result.write("> ${shade.toString()}$suffix\n");
        found = true;
      } else {
        result.write("  ${shade.toString()}$suffix\n");
      }
    }
    if (!found) {
      result.write("NOT PART OF PALLETE:  ${color.toString()}\n");
    }
    return result.toString();
  }

  @override
  String toString() => locateColor(center(false));

  final double luminanceThreshold;

  /// Get the contrasting text color for the given color
  Color contrastingText(Color color) {
    return color.computeLuminance() > luminanceThreshold ? ldBlk : ldWht;
  }

  final int disabledAlpha;

  LdColor disabled(bool isDark) => LdColor(
        shades
            .map((e) => Color.alphaBlend(
                isDark
                    ? ldWht.withAlpha(disabledAlpha)
                    : ldBlk.withAlpha(disabledAlpha),
                e))
            .toList(),
        _center,
        _darkCenter,
      );
}
