import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:provider/provider.dart';

import 'liquid_material_theme.dart';

/// Allows you to build a styled material app
/// ```dart
/// LdThemedAppBuilder((context,themeData) => MaterialApp(
///  theme: themeData,
/// home: ....))
/// ```
class LdThemedAppBuilder extends StatefulWidget {
  final MaterialApp Function(
    BuildContext context,
    ThemeData themeData,
  ) appBuilder;

  const LdThemedAppBuilder({
    Key? key,
    required this.appBuilder,
  }) : super(key: key);

  @override
  State<LdThemedAppBuilder> createState() => _LdThemedAppBuilderState();
}

class _LdThemedAppBuilderState extends State<LdThemedAppBuilder> {
  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LdTheme>(
      builder: (context, value, child) => widget.appBuilder(
        context,
        getMaterialTheme(value),
      ),
    );
  }
}
