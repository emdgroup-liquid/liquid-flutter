import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

part 'avatar.variants.g.dart';

@Variants([
  Variant('success', defaults: {'color': 'LdTheme.of(context).success'}),
  Variant('warning', defaults: {'color': 'LdTheme.of(context).warning'}),
  Variant('error', defaults: {'color': 'LdTheme.of(context).error'}),
])
class _LdAvatarWidget extends StatelessWidget {
  final Widget child;

  final LdColor? color;

  final bool circular;

  final LdSize size;

  const _LdAvatarWidget({
    required this.child,
    @ContextConfigurable() this.color,
    @ContextConfigurable() this.circular = false,
    @ContextConfigurable() this.size = LdSize.m,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final foreground = color ?? theme.primary;

    final touchable = context.watch<LdTouchableStatus?>();

    var fillColor = foreground.fromCenter(1, theme.isDark).withAlpha(50);

    if (touchable != null) {
      if (touchable.active) {
        fillColor = foreground.fromCenter(3, theme.isDark);
      }
      if (touchable.pressed) {
        fillColor = foreground.fromCenter(2, theme.isDark);
      }
    }

    final textIconColor = foreground.idle(theme.isDark);

    return Container(
      height: theme.paddingSize(size: size) * 3,
      width: theme.paddingSize(size: size) * 3,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: circular ? null : theme.radius(LdSize.s),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: textIconColor,
            size: theme.paragraphSize(size) * 1.2,
          ),
          child: DefaultTextStyle(
            maxLines: 1,
            style: ldBuildTextStyle(
              theme,
              LdTextType.label,
              LdSize.l,
              color: textIconColor,
              lineHeight: 1,
            ).copyWith(shadows: [
              Shadow(
                color: foreground.fromCenter(-2, theme.isDark),
                offset: Offset(0, 0),
                blurRadius: 1,
              ),
            ]),
            textAlign: TextAlign.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
