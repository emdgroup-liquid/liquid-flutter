import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

Widget wrapWidgetPreview(Widget child) {
  return Builder(builder: (context) {
    return LdThemeProvider(
        brightnessMode: switch (MediaQuery.platformBrightnessOf(context)) {
          Brightness.dark => LdThemeBrightnessMode.dark,
          Brightness.light => LdThemeBrightnessMode.light,
        },
        child: LdThemedAppBuilder(appBuilder: (context, theme) {
          return MaterialApp(debugShowCheckedModeBanner: false, home: LdScaffold(body: Center(child: child).padL()));
        }));
  });
}

/// Creates light and dark mode previews.
final class LiquidMultiPreview extends MultiPreview {
  const LiquidMultiPreview({required this.name});

  final String name;

  @override
  List<Preview> get previews => const [
        Preview(brightness: Brightness.light),
        Preview(brightness: Brightness.dark),
      ];

  @override
  List<Preview> transform() {
    final previews = super.transform();
    return previews.map((preview) {
      final builder = preview.toBuilder()
        ..group = 'Brightness'
        ..wrapper = wrapWidgetPreview
        ..name = '$name - ${preview.brightness!.name}';
      return builder.build();
    }).toList();
  }
}
