import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:provider/provider.dart';

class LdSurfaceInfo {
  bool isSurface;
  LdSurfaceInfo({required this.isSurface});

  static LdSurfaceInfo of(BuildContext context, {bool listen = false}) {
    return Provider.of<LdSurfaceInfo>(context, listen: listen);
  }

  /// Returns the closest [LdSurfaceInfo] or `null` when there is none.
  ///
  /// Useful for code that renders outside the widget tree of the app, such as
  /// content hosted in a native window, where the surface information may not
  /// have been provided.
  static LdSurfaceInfo? maybeOf(BuildContext context) {
    try {
      return Provider.of<LdSurfaceInfo>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }
}

extension LdSurfaceInfoExtension on BuildContext {
  bool get isSurface => LdSurfaceInfo.of(this).isSurface;
  Color get surfaceColor =>
      LdSurfaceInfo.of(this, listen: true).isSurface ? LdTheme.of(this).surface : LdTheme.of(this).background;
}

/// A widget that will change its background color based on the parent surface
class LdAutoBackground extends StatelessWidget {
  final Widget child;
  final bool invert;
  final bool? isSurface;
  final BorderRadius? borderRadius;
  const LdAutoBackground({
    super.key,
    required this.child,
    this.invert = false,
    this.borderRadius,
    this.isSurface,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return Consumer<LdSurfaceInfo>(builder: (context, info, _) {
      final parentIsSurface = isSurface ?? info.isSurface ^ invert;
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: parentIsSurface ? theme.background : theme.surface,
          borderRadius: borderRadius,
        ),
        child: Provider.value(
          value: LdSurfaceInfo(isSurface: !parentIsSurface),
          child: child,
        ),
      );
    });
  }
}
