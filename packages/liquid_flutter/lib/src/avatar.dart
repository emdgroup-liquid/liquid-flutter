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

  final bool emoji;
  final bool circular;

  final LdSize size;

  const _LdAvatarWidget({
    required this.child,
    this.emoji = false,
    @ContextConfigurable() this.color,
    @ContextConfigurable() this.circular = false,
    @ContextConfigurable() this.size = LdSize.m,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final foreground = color ?? theme.primary;

    final fillColor = foreground.idle(theme.isDark).withAlpha(26);

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
            ),
            child: LdWrapConditional(
                condition: emoji,
                builder: (context, child) {
                  return Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: child,
                  );
                },
                child: child),
          ),
        ),
      ),
    );
  }
}
