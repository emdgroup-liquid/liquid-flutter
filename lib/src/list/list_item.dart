import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
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

  const LdListItemWidget({
    super.key,
    @ContextConfigurable() this.active = false,
    @ContextConfigurable() this.borderRadius,
    @ContextConfigurable() this.disabled = false,
    @ContextConfigurable() this.isSelected = false,
    this.leading,
    @ContextConfigurable() this.onSelectionChanged,
    @ContextConfigurable() this.onPressed,
    @ContextConfigurable() this.padding,
    this.selectDisabled = false,
    this.subContent,
    this.subtitle,
    this.title,
    this.tradeLeadingForSelectionControl = true,
    @ContextConfigurable() this.focusNode,
    @ContextConfigurable() this.trailing,
    @ContextConfigurable() this.color,
    this.width,
    @ContextConfigurable() this.selectionControl = LdSelectionControl.none,
  });

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

    Widget _buildSelectionControls() {
      if (selectionControl == LdSelectionControl.none) return const SizedBox.shrink();
      return Row(
        children: [
          switch (selectionControl) {
            LdSelectionControl.radio => LdRadio(
                checked: isSelected,
                color: color,
                disabled: disabledState,
                onChanged: (value) {
                  onSelectionChanged?.call(value);
                },
              ),
            LdSelectionControl.checkbox => LdCheckbox(
                checked: isSelected,
                color: color,
                disabled: disabledState,
                onChanged: (value) {
                  onSelectionChanged?.call(value);
                },
              ),
            LdSelectionControl.none => const SizedBox.shrink(),
          },
          ldSpacerM,
        ],
      );
    }

    Widget _buildIconTheme(Widget child) {
      return IconTheme(
        data: IconThemeData(
          color: theme.text,
          size: theme.labelSize(LdSize.l),
        ),
        child: child,
      );
    }

    Widget _buildLeading() {
      if (leading == null) return const SizedBox.shrink();
      return LdAvatarConfigProvider(
        LdAvatarConfig(
          color: color,
        ),
        _buildIconTheme(
          LdReveal.quick(
            axes: const {Axis.horizontal},
            child: Row(
              children: [
                leading!,
                ldSpacerM,
              ],
            ),
            revealed: !(selectionControl != LdSelectionControl.none && tradeLeadingForSelectionControl),
            initialRevealed: !(selectionControl != LdSelectionControl.none && tradeLeadingForSelectionControl),
          ),
        ),
      );
    }

    Widget _buildTrailing() {
      if (trailing == null) return const SizedBox.shrink();
      return _buildIconTheme(
        Row(
          children: [ldSpacerM, trailing!],
        ),
      );
    }

    Widget _buildTitle() {
      if (title == null) return const SizedBox.shrink();
      return DefaultTextStyle(
        child: title!,
        style: ldBuildTextStyle(
          theme,
          LdTextType.label,
          LdSize.m,
          color: theme.text,
        ),
      );
    }

    Widget _buildSubtitle() {
      if (subtitle == null) return const SizedBox.shrink();
      return DefaultTextStyle(
        style: ldBuildTextStyle(
          theme,
          LdTextType.paragraph,
          lineHeight: 1.5,
          LdSize.s,
          color: theme.textMuted,
        ),
        child: subtitle!,
      );
    }

    Widget _buildSubContent() {
      if (subContent == null) return const SizedBox.shrink();
      return subContent!;
    }

    return LdTouchableSurface(
      focusNode: focusNode,
      onPressed: () {
        if (selectionControl != LdSelectionControl.none) {
          onSelectionChanged?.call(!isSelected);
        } else {
          onPressed?.call();
        }
      },
      active: active || (selectionControl != LdSelectionControl.none && isSelected),
      disabled: disabledState || (selectionControl == LdSelectionControl.none && onPressed == null),
      color: color ?? theme.palette.primary,
      builder: (contxt, colors, status, _) {
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
              border: Border.all(
                color: colors.border,
                width: theme.borderWidth,
              ),
            ),
            child: Row(
              mainAxisSize: effectiveWidth != double.infinity ? MainAxisSize.min : MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LdReveal.quick(
                  axes: const {Axis.horizontal},
                  child: _buildSelectionControls(),
                  revealed: selectionControl != LdSelectionControl.none,
                  initialRevealed: selectionControl != LdSelectionControl.none,
                ),
                if (leading != null) _buildLeading(),
                Flexible(
                  fit: effectiveWidth == double.infinity ? FlexFit.tight : FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null) _buildTitle(),
                      if (subtitle != null) _buildSubtitle(),
                      if (subContent != null) _buildSubContent(),
                    ],
                  ),
                ),
                if (trailing != null) _buildTrailing(),
              ],
            ),
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
