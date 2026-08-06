import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/list/shuttle_safe_key.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

part 'list_item.variants.g.dart';

typedef OnSelectionChanged = void Function(bool selected);

enum LdSelectionControl { none, radio, checkbox }

@Variants([
  Variant('trailingForward', defaults: {'trailing': 'const LdListDefaultTrailingForward()'}),
])
class LdListItemWidget extends StatefulWidget {
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
  final BoxShadow? shadow;

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
    this.shadow,
    this.focusNode,
    this.trailing,
    this.color,
    this.width,
    this.isOdd = false,
    this.selectionControl = LdSelectionControl.none,
  });

  @override
  State<LdListItemWidget> createState() => _LdListItemWidgetState();
}

class _LdListItemWidgetState extends State<LdListItemWidget> {
  final _innerContentKey = GlobalKey();

  Widget _buildSelectionControls(BuildContext context, bool disabledState) {
    if (widget.selectionControl == LdSelectionControl.none) return const SizedBox.shrink();
    return Row(
      children: [
        switch (widget.selectionControl) {
          LdSelectionControl.radio => ExcludeFocus(
              child: LdRadio(
                checked: widget.isSelected,
                color: widget.color,
                disabled: disabledState,
                onChanged: (value) {
                  widget.onSelectionChanged?.call(value);
                },
              ),
            ),
          LdSelectionControl.checkbox => ExcludeFocus(
              child: LdCheckbox(
                checked: widget.isSelected,
                color: widget.color,
                disabled: disabledState,
                onChanged: (value) {
                  widget.onSelectionChanged?.call(value);
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
    if (widget.leading == null) return const SizedBox.shrink();
    return LdAvatarConfigProvider(
      config: LdAvatarConfig(
        color: widget.color,
      ),
      child: _buildIconTheme(
        LdReveal.quick(
          axes: const {Axis.horizontal},
          revealed: !(widget.selectionControl != LdSelectionControl.none && widget.tradeLeadingForSelectionControl),
          initialRevealed:
              !(widget.selectionControl != LdSelectionControl.none && widget.tradeLeadingForSelectionControl),
          child: Row(
            children: [
              widget.leading!,
              ldSpacerM,
            ],
          ),
        ),
        theme,
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, LdTheme theme) {
    if (widget.trailing == null) return const SizedBox.shrink();
    return _buildIconTheme(
      Row(
        children: [ldSpacerM, widget.trailing!],
      ),
      theme,
    );
  }

  Widget _buildTitle(BuildContext context, LdTheme theme) {
    if (widget.title == null) return const SizedBox.shrink();
    return DefaultTextStyle(
      style: ldBuildTextStyle(
        theme,
        LdTextType.label,
        LdSize.m,
        color: theme.text,
      ),
      maxLines: 1,
      child: widget.title!,
    );
  }

  Widget _buildSubtitle(BuildContext context, LdTheme theme) {
    if (widget.subtitle == null) return const SizedBox.shrink();
    return DefaultTextStyle(
      style: ldBuildTextStyle(
        theme,
        LdTextType.paragraph,
        lineHeight: 1.5,
        LdSize.s,
        color: theme.textMuted,
      ),
      maxLines: 1,
      child: widget.subtitle!,
    );
  }

  EdgeInsets _effectivePadding(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    if (widget.padding != null) return widget.padding!;
    if (widget.subContent != null || widget.subtitle != null || widget.leading != null) return theme.balPad(LdSize.s);
    // In title only mode we apply a bit more padding
    return EdgeInsets.symmetric(
        horizontal: theme.paddingSize(size: LdSize.m), vertical: theme.paddingSize(size: LdSize.l));
  }

  Widget _buildSubContent(BuildContext context, LdTheme theme) {
    if (widget.subContent == null) return const SizedBox.shrink();
    return widget.subContent!;
  }

  bool get _isDisabled {
    return switch (widget.selectionControl) {
      (LdSelectionControl.none) => widget.disabled,
      (LdSelectionControl.radio) => widget.selectDisabled,
      (LdSelectionControl.checkbox) => widget.selectDisabled,
    };
  }

  Widget _buildInnerContent(BuildContext context, LdColorBundle? bundle) {
    final theme = LdTheme.of(context, listen: true);
    return Container(
      key: _innerContentKey,
      width: widget.width ?? double.infinity,
      padding: _effectivePadding(context),
      decoration: BoxDecoration(
        boxShadow: widget.shadow != null ? [widget.shadow!] : null,
        color: bundle?.surface ?? context.surfaceColor,
        borderRadius: widget.borderRadius,
        border: bundle != null
            ? Border.all(
                color: bundle.border,
                width: theme.borderWidth,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: widget.width != double.infinity ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LdReveal.quick(
            axes: const {Axis.horizontal},
            revealed: widget.selectionControl != LdSelectionControl.none,
            initialRevealed: widget.selectionControl != LdSelectionControl.none,
            child: _buildSelectionControls(context, _isDisabled),
          ),
          if (widget.leading != null) _buildLeading(context, theme),
          Flexible(
            fit: widget.width != double.infinity ? FlexFit.tight : FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null) _buildTitle(context, theme),
                if (widget.subtitle != null) _buildSubtitle(context, theme),
                if (widget.subContent != null) _buildSubContent(context, theme),
              ],
            ),
          ),
          if (widget.trailing != null) _buildTrailing(context, theme),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final isShuttle = Provider.of<LdIsShuttle?>(context, listen: true)?.value ?? false;
    final effectiveFocusNode = isShuttle ? null : widget.focusNode;

    final bool isInteractive = widget.selectionControl != LdSelectionControl.none || widget.onPressed != null;

    if (!isInteractive) {
      return _buildInnerContent(context, null);
    }

    return LdTouchableSurface(
      focusNode: effectiveFocusNode,
      isOdd: widget.isOdd,
      onPressed: () {
        if (widget.selectionControl != LdSelectionControl.none) {
          widget.onSelectionChanged?.call(!widget.isSelected);
        } else {
          widget.onPressed?.call();
        }
      },
      active: widget.active || (widget.selectionControl != LdSelectionControl.none && widget.isSelected),
      disabled: _isDisabled,
      builder: (contxt, status, _) {
        final colorBundle = neutralGhostColor(theme, status);
        return _buildInnerContent(context, colorBundle);
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
