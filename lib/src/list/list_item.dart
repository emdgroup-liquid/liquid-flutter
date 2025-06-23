import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

typedef OnSelectionChange = void Function(bool selected);

class LdListItemConfig {
  final bool active;
  final bool disabled;
  final bool isSelected;
  final bool radioSelection;
  final bool selectDisabled;
  final bool showBothTrailingAndTrailingForward;
  final bool showSelectionControls;
  final bool tradeLeadingForSelectionControl;
  final bool trailingForward;
  final BorderRadius? borderRadius;
  final double? width;
  final EdgeInsets? padding;
  final Key? key;
  final OnSelectionChange? onSelectionChange;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? subContent;
  final Widget? subtitle;
  final Widget? title;
  final Widget? trailing;
  final LdColor? color;
  final FocusNode? focusNode;

  const LdListItemConfig({
    this.active = false,
    this.focusNode,
    this.borderRadius,
    this.disabled = false,
    this.isSelected = false,
    this.key,
    this.leading,
    this.onSelectionChange,
    this.onTap,
    this.padding,
    this.radioSelection = false,
    this.selectDisabled = false,
    this.showBothTrailingAndTrailingForward = false,
    this.showSelectionControls = false,
    this.subContent,
    this.subtitle,
    this.title,
    this.tradeLeadingForSelectionControl = false,
    this.trailing,
    this.trailingForward = false,
    this.color,
    this.width,
  });

  LdListItemConfig copyWith({
    Widget? leading,
    Widget? trailing,
    EdgeInsets? padding,
    Widget? title,
    bool? active,
    Widget? subtitle,
    VoidCallback? onTap,
    double? width,
    bool? selectDisabled,
    OnSelectionChange? onSelectionChange,
    bool? radioSelection,
    BorderRadius? borderRadius,
    Widget? subContent,
    bool? isSelected,
    bool? trailingForward,
    bool? disabled,
    bool? tradeLeadingForSelectionControl,
    bool? showBothTrailingAndTrailingForward,
    bool? showSelectionControls,
    FocusNode? focusNode,
    LdColor? color,
    Key? key,
  }) {
    return LdListItemConfig(
      leading: leading ?? this.leading,
      trailing: trailing ?? this.trailing,
      padding: padding ?? this.padding,
      focusNode: focusNode ?? this.focusNode,
      title: title ?? this.title,
      active: active ?? this.active,
      subtitle: subtitle ?? this.subtitle,
      onTap: onTap ?? this.onTap,
      width: width ?? this.width,
      selectDisabled: selectDisabled ?? this.selectDisabled,
      onSelectionChange: onSelectionChange ?? this.onSelectionChange,
      radioSelection: radioSelection ?? this.radioSelection,
      borderRadius: borderRadius ?? this.borderRadius,
      subContent: subContent ?? this.subContent,
      isSelected: isSelected ?? this.isSelected,
      trailingForward: trailingForward ?? this.trailingForward,
      disabled: disabled ?? this.disabled,
      color: color ?? this.color,
      tradeLeadingForSelectionControl: tradeLeadingForSelectionControl ?? this.tradeLeadingForSelectionControl,
      showBothTrailingAndTrailingForward: showBothTrailingAndTrailingForward ?? this.showBothTrailingAndTrailingForward,
      showSelectionControls: showSelectionControls ?? this.showSelectionControls,
      key: key ?? this.key,
    );
  }
}

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
  final BorderRadius? borderRadius;
  final Widget? subContent;
  final bool isSelected;
  final bool trailingForward;
  final FocusNode? focusNode;
  final bool disabled;
  final bool tradeLeadingForSelectionControl;
  final bool showBothTrailingAndTrailingForward;
  final LdColor? color;

  final bool showSelectionControls;

  const LdListItem({
    super.key,
    this.active = false,
    this.borderRadius,
    this.disabled = false,
    this.isSelected = false,
    this.leading,
    this.onSelectionChange,
    this.onTap,
    this.padding,
    this.radioSelection = false,
    this.selectDisabled = false,
    this.showBothTrailingAndTrailingForward = false,
    this.showSelectionControls = false,
    this.subContent,
    this.subtitle,
    this.title,
    this.tradeLeadingForSelectionControl = false,
    this.focusNode,
    this.trailing,
    this.trailingForward = false,
    this.color,
    this.width,
  });

  factory LdListItem.fromConfig(LdListItemConfig config) {
    return LdListItem(
      active: config.active,
      borderRadius: config.borderRadius,
      disabled: config.disabled,
      isSelected: config.isSelected,
      key: config.key,
      leading: config.leading,
      onSelectionChange: config.onSelectionChange,
      onTap: config.onTap,
      padding: config.padding,
      radioSelection: config.radioSelection,
      selectDisabled: config.selectDisabled,
      focusNode: config.focusNode,
      showBothTrailingAndTrailingForward: config.showBothTrailingAndTrailingForward,
      showSelectionControls: config.showSelectionControls,
      subContent: config.subContent,
      subtitle: config.subtitle,
      color: config.color,
      title: config.title,
      tradeLeadingForSelectionControl: config.tradeLeadingForSelectionControl,
      trailing: config.trailing,
      trailingForward: config.trailingForward,
      width: config.width,
    );
  }

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
      focusNode: focusNode,
      onTap: () {
        if (showSelectionControls) {
          onSelectionChange?.call(!isSelected);
        } else {
          onTap?.call();
        }
      },
      active: active || (showSelectionControls && isSelected),
      disabled: disabled || (!showSelectionControls && onTap == null),
      color: color ?? theme.palette.primary,
      builder: (contxt, colors, status) {
        return IconTheme(
          data: IconThemeData(
            color: colors.text,
            size: theme.labelSize(LdSize.l) * 1.2,
          ),
          child: Container(
            width: effectiveWidth,
            padding: padding ?? theme.balPad(LdSize.m),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: borderRadius,
            ),
            child: Row(
                mainAxisSize: effectiveWidth != double.infinity ? MainAxisSize.min : MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LdReveal.quick(
                    child: Row(
                      children: [
                        if (radioSelection)
                          LdRadio(
                              checked: isSelected,
                              color: color,
                              disabled: disabled,
                              onChanged: (value) {
                                onSelectionChange?.call(value);
                              })
                        else
                          GestureDetector(
                            onPanUpdate: (details) {
                              print("start $title");
                            },
                            child: LdCheckbox(
                                checked: isSelected,
                                color: color,
                                disabled: disabled,
                                onChanged: (value) {
                                  onSelectionChange?.call(value);
                                }),
                          ),
                        ldSpacerM,
                      ],
                    ),
                    revealed: showSelectionControls,
                    initialRevealed: showSelectionControls,
                  ),
                  if (leading != null)
                    IconTheme(
                      data: IconThemeData(
                        color: theme.text,
                        size: theme.labelSize(LdSize.l) * 1.2,
                      ),
                      child: LdReveal.quick(
                        child: Row(
                          children: [
                            leading!,
                            ldSpacerM,
                          ],
                        ),
                        //axis: Axis.horizontal,
                        revealed: !(showSelectionControls && tradeLeadingForSelectionControl),
                        initialRevealed: !(showSelectionControls && tradeLeadingForSelectionControl),
                      ),
                    ),
                  Flexible(
                    fit: effectiveWidth == double.infinity ? FlexFit.tight : FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null)
                          DefaultTextStyle(
                            child: title!,
                            style: ldBuildTextStyle(
                              theme,
                              LdTextType.label,
                              LdSize.m,
                              color: theme.text,
                            ),
                          ),
                        if (subtitle != null) ...[
                          DefaultTextStyle(
                              style: ldBuildTextStyle(
                                theme,
                                LdTextType.paragraph,
                                lineHeight: 1.5,
                                LdSize.s,
                                color: theme.textMuted,
                              ),
                              child: subtitle!),
                        ],
                        if (subContent != null) subContent!,
                      ],
                    ),
                  ),
                  if (trailing != null) ...[ldSpacerM, trailing!],
                  if (trailingForward && (trailing == null || showBothTrailingAndTrailingForward)) ...[
                    ldSpacerM,
                    Icon(
                      LucideIcons.chevronRight,
                      size: theme.labelSize(LdSize.l) * 1.2,
                      color: theme.textMuted,
                    )
                  ],
                ]),
          ),
        );
      },
    );
  }
}
