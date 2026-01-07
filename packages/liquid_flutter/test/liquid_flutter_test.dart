import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  test('theme.dart', () {
    var themeService = LdTheme();

    themeService.setPalette(shadDefault);

    expect(themeService, isNotNull);

    var theme = themeService.palette;

    expect(theme, isNotNull);

    expect(theme.primary, shadSky);

    // Change theme

    themeService.setPalette(shadDefaultDark);

    expect(themeService.palette.primary, shadDefaultDark.primary);
  });

  test('getMaterialTheme()', () {
    var theme = LdTheme();

    var themedata = getMaterialTheme(theme);

    expect(themedata, isNotNull);
    expect(themedata.colorScheme.surface, theme.background);
    expect(themedata.colorScheme.primary, theme.palette.primary.idle(false));

    // Dark theme
    theme.setPalette(shadDefaultDark);
    themedata = getMaterialTheme(theme);

    expect(themedata, isNotNull);
    expect(themedata.colorScheme.surface, theme.background);
    expect(themedata.brightness == Brightness.dark, theme.isDark);
  });
}
