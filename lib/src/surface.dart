import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:provider/provider.dart';

class LdSurfaceInfo {
  bool isSurface;
  LdSurfaceInfo({required this.isSurface});

  static LdSurfaceInfo of(BuildContext context, {bool listen = false}) {
    return Provider.of<LdSurfaceInfo>(context, listen: listen);
  }
}

/// A widget that will change its background color based on the parent surface
class LdAutoBackground extends StatelessWidget {
  final Widget child;
  final bool invert;
  const LdAutoBackground({super.key, required this.child, this.invert = false});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return Consumer<LdSurfaceInfo>(builder: (context, info, _) {
      final parentIsSurface = info.isSurface ^ invert;
      return ColoredBox(
        color: parentIsSurface ? theme.background : theme.surface,
        child: Provider.value(
          value: LdSurfaceInfo(isSurface: !parentIsSurface),
          child: child,
        ),
      );
    });
  }
}
