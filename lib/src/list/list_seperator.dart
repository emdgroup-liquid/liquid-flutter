import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdListSeperator extends StatelessWidget {
  final Widget child;
  final bool onSurface;

  const LdListSeperator({required this.child, this.onSurface = false, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return Consumer<LdSurfaceInfo>(
      builder: (context, info, _) => Container(
        padding: theme.balPad(LdSize.s),
        width: double.infinity,
        decoration: BoxDecoration(
          color: info.isSurface ? theme.background : theme.neutralShade(2),
          border: Border(
            bottom: BorderSide(
              color: theme.border,
              width: 1,
            ),
            top: BorderSide(
              color: theme.border,
              width: 1,
            ),
          ),
        ),
        child: DefaultTextStyle(
          child: child,
          style: ldBuildTextStyle(theme, LdTextType.label, LdSize.s),
        ),
      ),
    );
  }
}
