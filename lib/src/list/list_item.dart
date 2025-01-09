import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

typedef OnSelectionChange = void Function(bool selected);

class LdListItem extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets? padding;
  final Widget? title;
  final bool active;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final double? width;
  final bool selectDisabled;
  final OnSelectionChange? onSelectionChange;
  final bool radioSelection;
  final Widget? subContent;
  final bool isSelected;
  final bool trailingForward;
  final bool disabled;
  final bool tradeLeadingForSelectionControl;

  final bool showSelectionControls;

  const LdListItem({
    super.key,
    this.leading,
    this.trailing,
    this.title,
    this.active = false,
    this.isSelected = false,
    this.radioSelection = false,
    this.disabled = false,
    this.selectDisabled = false,
    this.trailingForward = false,
    this.showSelectionControls = false,
    this.onSelectionChange,
    this.tradeLeadingForSelectionControl = false,
    this.padding,
    this.onTap,
    this.subtitle,
    this.width,
    this.subContent,
  });

  @override
  Widget build(BuildContext context) {
    bool disabled;

    if (showSelectionControls) {
      if (selectDisabled) {
        disabled = false;
      } else {
        disabled = this.disabled;
      }
    } else {
      disabled = this.disabled;
    }

    final theme = LdTheme.of(context, listen: true);

    final effectiveWidth = width ?? double.infinity;

    return LdTouchableSurface(
      onTap: () {
        if (showSelectionControls) {
          onSelectionChange?.call(!isSelected);
        } else {
          onTap?.call();
        }
      },
      active: active || (showSelectionControls && isSelected),
      disabled: disabled,
      color: theme.palette.primary,
      builder: (contxt, colors, status) {
        return LdAutoBackground(
          invert: true,
          child: Container(
            width: effectiveWidth,
            padding: padding ?? theme.balPad(LdSize.m),
            decoration: BoxDecoration(
              color: colors.surface,
            ),
            child: Row(
                mainAxisSize: effectiveWidth != double.infinity
                    ? MainAxisSize.min
                    : MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LdReveal.quick(
                    child: Row(
                      children: [
                        if (radioSelection)
                          LdRadio(
                              checked: isSelected,
                              disabled: disabled,
                              onChanged: (value) {
                                onSelectionChange?.call(value);
                              })
                        else
                          LdCheckbox(
                              checked: isSelected,
                              disabled: disabled,
                              onChanged: (value) {
                                onSelectionChange?.call(value);
                              }),
                        ldSpacerM,
                      ],
                    ),
                    revealed: showSelectionControls,
                    initialRevealed: showSelectionControls,
                  ),
                  if (leading != null)
                    LdReveal.quick(
                      child: Row(
                        children: [
                          leading!,
                          ldSpacerM,
                        ],
                      ),
                      //axis: Axis.horizontal,
                      revealed: !(showSelectionControls &&
                          tradeLeadingForSelectionControl),
                      initialRevealed: !(showSelectionControls &&
                          tradeLeadingForSelectionControl),
                    ),
                  Flexible(
                    fit: effectiveWidth == double.infinity
                        ? FlexFit.tight
                        : FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          DefaultTextStyle(
                            child: title!,
                            style: ldBuildTextStyle(
                                theme, LdTextType.label, LdSize.m,
                                color: colors.text),
                          ),
                        if (subtitle != null)
                          DefaultTextStyle(
                              style: ldBuildTextStyle(
                                  theme, LdTextType.paragraph, LdSize.s),
                              child: subtitle!),
                        if (subContent != null) subContent!,
                      ],
                    ),
                  ),
                  if (trailing != null) ...[ldSpacerM, trailing!],
                  if (trailing == null && trailingForward) ...[
                    ldSpacerM,
                    Icon(
                      Icons.chevron_right,
                      color: colors.text,
                    )
                  ],
                ]),
          ),
        );
      },
    );
  }
}

class LdAvatar extends StatelessWidget {
  final Widget child;

  final LdColor? color;

  const LdAvatar({super.key, required this.child, this.color});

  @override
  build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final foreground = color ?? theme.primary;

    return Container(
      height: theme.paddingSize() * 3,
      width: theme.paddingSize() * 3,
      decoration: BoxDecoration(
        color: foreground.idle(theme.isDark),
        borderRadius: theme.radius(LdSize.s),
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
              color: foreground.idle(theme.isDark),
              size: theme.paragraphSize(null) * 1.2),
          child: DefaultTextStyle(
            child: child,
            maxLines: 1,
            style: ldBuildTextStyle(
              theme,
              LdTextType.label,
              LdSize.l,
              color: foreground.contrastingText(
                foreground.idle(theme.isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
