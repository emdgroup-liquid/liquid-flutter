import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class ComponentWell extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool onSurface;
  final Color? color;
  const ComponentWell(
      {Key? key,
      this.padding,
      required this.child,
      this.color,
      this.onSurface = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color ?? (onSurface ? theme.surface : theme.background),
          borderRadius: theme.radius(LdSize.m),
          border: Border.all(color: theme.border, width: theme.borderWidth),
        ),
        padding: padding ??
            const EdgeInsets.symmetric(
              vertical: 32,
              horizontal: 16,
            ),
        child: Provider.value(
          value: LdSurfaceInfo(isSurface: onSurface),
          child: child,
        ));
  }
}
