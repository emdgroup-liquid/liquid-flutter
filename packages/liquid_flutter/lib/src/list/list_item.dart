import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/shuttle_safe_key.dart';
import 'package:liquid_flutter/src/touchable/neutral_ghost_color.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

part 'list_item.variants.g.dart';

typedef OnSelectionChanged = void Function(bool selected);

enum LdSelectionControl { none, radio, checkbox }

@Variants([
  Variant('trailingForward', defaults: {'trailing': 'const LdListDefaultTrailingForward()'}),
])
class LdListItemWidget extends StatelessWidget {
  final Widget? leading;
  final Widget? trailing;
  final Widget? title;
  final bool active;
  final Widget? subtitle;
  final VoidCallback? onPressed;
  final double? width;
  final bool selectDisabled;
  final OnSelectionChanged? onSelectionChanged;
  final LdSelectionControl selectionControl;
  final Widget? subContent;
  final bool isSelected;
  final FocusNode? focusNode;
  final bool disabled;
  final bool tradeLeadingForSelectionControl;
  final LdColor? color;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool isOdd;

  @ContextConfigurable()
  const LdListItemWidget({
    super.key,
    this.active = false,
    this.borderRadius,
    this.disabled = false,
    this.isSelected = false,
    this.leading,
    this.onSelectionChanged,
    this.onPressed,
    this.padding,
    this.selectDisabled = false,
    this.subContent,
    this.subtitle,
    this.title,
    this.tradeLeadingForSelectionControl = true,
    this.focusNode,
    this.trailing,
    this.color,
    this.width,
    this.isOdd = false,
    this.selectionControl = LdSelectionControl.none,
  });

  Widget _buildSelectionControls(BuildContext context, bool disabledState) {
    if (selectionControl == LdSelectionControl.none) return const SizedBox.shrink();
    return Row(
      children: [
        switch (selectionControl) {
          LdSelectionControl.radio => ExcludeFocus(
              child: LdRadio(
                checked: isSelected,
                color: color,
                disabled: disabledState,
                onChanged: (value) {
                  onSelectionChanged?.call(value);
                },
              ),
            ),
          LdSelectionControl.checkbox => ExcludeFocus(
              child: LdCheckbox(
                checked: isSelected,
                color: color,
                disabled: disabledState,
                onChanged: (value) {
                  onSelectionChanged?.call(value);
                },
              ),
            ),
          LdSelectionControl.none => const SizedBox.shrink(),
        },
        ldSpacerM,
      ],
    );
  }

  Widget _buildIconTheme(Widget child, LdTheme theme) {
    return IconTheme(
      data: IconThemeData(
        color: theme.text,
        size: theme.labelSize(LdSize.l),
      ),
      child: child,
    );
  }

  Widget _buildLeading(BuildContext context, LdTheme theme) {
    if (leading == null) return const SizedBox.shrink();
    return LdAvatarConfigProvider(
      config: LdAvatarConfig(
        color: color,
      ),
      child: _buildIconTheme(
        LdReveal.quick(
          axes: const {Axis.horizontal},
          revealed: !(selectionControl != LdSelectionControl.none && tradeLeadingForSelectionControl),
          initialRevealed: !(selectionControl != LdSelectionControl.none && tradeLeadingForSelectionControl),
          child: Row(
            children: [
              leading!,
              ldSpacerM,
            ],
          ),
        ),
        theme,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, LdTheme theme) {
    if (trailing == null) return const SizedBox.shrink();
    return _buildIconTheme(
      Row(
        children: [ldSpacerM, trailing!],
      ),
      theme,
    );
  }

  Widget _buildTitle(BuildContext context, LdTheme theme) {
    if (title == null) return const SizedBox.shrink();
    return DefaultTextStyle(
      style: ldBuildTextStyle(
        theme,
        LdTextType.label,
        LdSize.m,
        color: theme.text,
      ),
      maxLines: 1,
      child: title!,
    );
  }

  Widget _buildSubtitle(BuildContext context, LdTheme theme) {
    if (subtitle == null) return const SizedBox.shrink();
    return DefaultTextStyle(
      style: ldBuildTextStyle(
        theme,
        LdTextType.paragraph,
        lineHeight: 1.5,
        LdSize.s,
        color: theme.textMuted,
      ),
      maxLines: 1,
      child: subtitle!,
    );
  }

  Widget _buildSubContent(BuildContext context, LdTheme theme) {
    if (subContent == null) return const SizedBox.shrink();
    return subContent!;
  }

  @override
  Widget build(BuildContext context) {
    bool disabledState;

    if (selectionControl != LdSelectionControl.none) {
      if (selectDisabled) {
        disabledState = false;
      } else {
        disabledState = disabled;
      }
    } else {
      disabledState = disabled;
    }

    final theme = LdTheme.of(context, listen: true);
    final effectiveWidth = width ?? double.infinity;
    final isShuttle = Provider.of<LdIsShuttle?>(context, listen: true)?.value ?? false;
    final effectiveFocusNode = isShuttle ? null : focusNode;

    return LdTouchableSurface(
      focusNode: effectiveFocusNode,
      isOdd: isOdd,
      onPressed: () {
        if (selectionControl != LdSelectionControl.none) {
          onSelectionChanged?.call(!isSelected);
        } else {
          onPressed?.call();
        }
      },
      active: active || (selectionControl != LdSelectionControl.none && isSelected),
      disabled: disabledState || (selectionControl == LdSelectionControl.none && onPressed == null),
      builder: (contxt, status, _) {
        final colorBundle = neutralGhostColor(theme, status);
        return Container(
          width: effectiveWidth,
          padding: padding ?? theme.balPad(LdSize.s),
          decoration: BoxDecoration(
            color: colorBundle.surface,
            borderRadius: borderRadius,
            border: Border.all(
              color: colorBundle.border,
              width: theme.borderWidth,
            ),
          ),
          child: Row(
            mainAxisSize: effectiveWidth != double.infinity ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LdReveal.quick(
                axes: const {Axis.horizontal},
                revealed: selectionControl != LdSelectionControl.none,
                initialRevealed: selectionControl != LdSelectionControl.none,
                child: _buildSelectionControls(context, disabledState),
              ),
              if (leading != null) _buildLeading(context, theme),
              Flexible(
                fit: effectiveWidth == double.infinity ? FlexFit.tight : FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null) _buildTitle(context, theme),
                    if (subtitle != null) _buildSubtitle(context, theme),
                    if (subContent != null) _buildSubContent(context, theme),
                  ],
                ),
              ),
              if (trailing != null) _buildTrailing(context, theme),
            ],
          ),
        );
      },
    );
  }
}

class LdListDefaultTrailingForward extends StatelessWidget {
  const LdListDefaultTrailingForward({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Icon(
      LucideIcons.chevronRight,
      size: theme.labelSize(LdSize.l) * 1.2,
      color: theme.textMuted,
    );
  }
}
