part of 'list_item.dart';

class LdListItemConfig {
  const LdListItemConfig({
    this.active,
    this.borderRadius,
    this.disabled,
    this.isSelected,
    this.leading,
    this.onSelectionChanged,
    this.onPressed,
    this.padding,
    this.selectDisabled,
    this.subContent,
    this.subtitle,
    this.title,
    this.tradeLeadingForSelectionControl,
    this.shadow,
    this.focusNode,
    this.trailing,
    this.color,
    this.width,
    this.isOdd,
    this.selectionControl,
  });

  final bool? active;

  final BorderRadius? borderRadius;

  final bool? disabled;

  final bool? isSelected;

  final Widget? leading;

  final void Function(bool)? onSelectionChanged;

  final void Function()? onPressed;

  final EdgeInsets? padding;

  final bool? selectDisabled;

  final Widget? subContent;

  final Widget? subtitle;

  final Widget? title;

  final bool? tradeLeadingForSelectionControl;

  final BoxShadow? shadow;

  final FocusNode? focusNode;

  final Widget? trailing;

  final LdColor? color;

  final double? width;

  final bool? isOdd;

  final LdSelectionControl? selectionControl;

  LdListItemConfig copyWith({
    bool? active,
    BorderRadius? borderRadius,
    bool? disabled,
    bool? isSelected,
    Widget? leading,
    void Function(bool)? onSelectionChanged,
    void Function()? onPressed,
    EdgeInsets? padding,
    bool? selectDisabled,
    Widget? subContent,
    Widget? subtitle,
    Widget? title,
    bool? tradeLeadingForSelectionControl,
    BoxShadow? shadow,
    FocusNode? focusNode,
    Widget? trailing,
    LdColor? color,
    double? width,
    bool? isOdd,
    LdSelectionControl? selectionControl,
  }) {
    return LdListItemConfig(
      active: active ?? this.active,
      borderRadius: borderRadius ?? this.borderRadius,
      disabled: disabled ?? this.disabled,
      isSelected: isSelected ?? this.isSelected,
      leading: leading ?? this.leading,
      onSelectionChanged: onSelectionChanged ?? this.onSelectionChanged,
      onPressed: onPressed ?? this.onPressed,
      padding: padding ?? this.padding,
      selectDisabled: selectDisabled ?? this.selectDisabled,
      subContent: subContent ?? this.subContent,
      subtitle: subtitle ?? this.subtitle,
      title: title ?? this.title,
      tradeLeadingForSelectionControl: tradeLeadingForSelectionControl ??
          this.tradeLeadingForSelectionControl,
      shadow: shadow ?? this.shadow,
      focusNode: focusNode ?? this.focusNode,
      trailing: trailing ?? this.trailing,
      color: color ?? this.color,
      width: width ?? this.width,
      isOdd: isOdd ?? this.isOdd,
      selectionControl: selectionControl ?? this.selectionControl,
    );
  }

  LdListItemConfig merge(LdListItemConfig? other) {
    if (other == null) return this;
    return LdListItemConfig(
      active: other.active ?? this.active,
      borderRadius: other.borderRadius ?? this.borderRadius,
      disabled: other.disabled ?? this.disabled,
      isSelected: other.isSelected ?? this.isSelected,
      leading: other.leading ?? this.leading,
      onSelectionChanged: other.onSelectionChanged ?? this.onSelectionChanged,
      onPressed: other.onPressed ?? this.onPressed,
      padding: other.padding ?? this.padding,
      selectDisabled: other.selectDisabled ?? this.selectDisabled,
      subContent: other.subContent ?? this.subContent,
      subtitle: other.subtitle ?? this.subtitle,
      title: other.title ?? this.title,
      tradeLeadingForSelectionControl: other.tradeLeadingForSelectionControl ??
          this.tradeLeadingForSelectionControl,
      shadow: other.shadow ?? this.shadow,
      focusNode: other.focusNode ?? this.focusNode,
      trailing: other.trailing ?? this.trailing,
      color: other.color ?? this.color,
      width: other.width ?? this.width,
      isOdd: other.isOdd ?? this.isOdd,
      selectionControl: other.selectionControl ?? this.selectionControl,
    );
  }
}

class LdListItemConfigProvider extends StatelessWidget {
  const LdListItemConfigProvider({
    required this.config,
    required this.child,
    this.ignoreParent = false,
    super.key,
  });

  final LdListItemConfig config;

  final Widget child;

  final bool ignoreParent;

  @override
  Widget build(BuildContext context) {
    if (ignoreParent) {
      return Provider<LdListItemConfig>.value(
        value: config,
        child: child,
      );
    }
    final parentConfig = Provider.of<LdListItemConfig?>(context, listen: true);
    final mergedConfig = parentConfig != null
        ? LdListItemConfig(
            active: config.active ?? parentConfig.active,
            borderRadius: config.borderRadius ?? parentConfig.borderRadius,
            disabled: config.disabled ?? parentConfig.disabled,
            isSelected: config.isSelected ?? parentConfig.isSelected,
            leading: config.leading ?? parentConfig.leading,
            onSelectionChanged:
                config.onSelectionChanged ?? parentConfig.onSelectionChanged,
            onPressed: config.onPressed ?? parentConfig.onPressed,
            padding: config.padding ?? parentConfig.padding,
            selectDisabled:
                config.selectDisabled ?? parentConfig.selectDisabled,
            subContent: config.subContent ?? parentConfig.subContent,
            subtitle: config.subtitle ?? parentConfig.subtitle,
            title: config.title ?? parentConfig.title,
            tradeLeadingForSelectionControl:
                config.tradeLeadingForSelectionControl ??
                    parentConfig.tradeLeadingForSelectionControl,
            shadow: config.shadow ?? parentConfig.shadow,
            focusNode: config.focusNode ?? parentConfig.focusNode,
            trailing: config.trailing ?? parentConfig.trailing,
            color: config.color ?? parentConfig.color,
            width: config.width ?? parentConfig.width,
            isOdd: config.isOdd ?? parentConfig.isOdd,
            selectionControl:
                config.selectionControl ?? parentConfig.selectionControl)
        : config;
    return Provider<LdListItemConfig>.value(
      value: mergedConfig,
      child: child,
    );
  }
}

class LdListItem extends StatelessWidget {
  const LdListItem({
    this.active,
    this.borderRadius,
    this.disabled,
    this.isSelected,
    this.leading,
    this.onSelectionChanged,
    this.onPressed,
    this.padding,
    this.selectDisabled,
    this.subContent,
    this.subtitle,
    this.title,
    this.tradeLeadingForSelectionControl,
    this.shadow,
    this.focusNode,
    this.trailing,
    this.color,
    this.width,
    this.isOdd,
    this.selectionControl,
    super.key,
  });

  factory LdListItem.trailingForward({
    bool? active,
    BorderRadius? borderRadius,
    bool? disabled,
    bool? isSelected,
    Widget? leading,
    void Function(bool)? onSelectionChanged,
    void Function()? onPressed,
    EdgeInsets? padding,
    bool? selectDisabled,
    Widget? subContent,
    Widget? subtitle,
    Widget? title,
    bool? tradeLeadingForSelectionControl,
    BoxShadow? shadow,
    FocusNode? focusNode,
    LdColor? color,
    double? width,
    bool? isOdd,
    LdSelectionControl? selectionControl,
    Key? key,
  }) {
    return LdListItem(
      active: active,
      borderRadius: borderRadius,
      disabled: disabled,
      isSelected: isSelected,
      leading: leading,
      onSelectionChanged: onSelectionChanged,
      onPressed: onPressed,
      padding: padding,
      selectDisabled: selectDisabled,
      subContent: subContent,
      subtitle: subtitle,
      title: title,
      tradeLeadingForSelectionControl: tradeLeadingForSelectionControl,
      shadow: shadow,
      focusNode: focusNode,
      trailing: const LdListDefaultTrailingForward(),
      color: color,
      width: width,
      isOdd: isOdd,
      selectionControl: selectionControl,
      key: key,
    );
  }

  final Widget? leading;

  final Widget? trailing;

  final Widget? title;

  final bool? active;

  final Widget? subtitle;

  final void Function()? onPressed;

  final double? width;

  final bool? selectDisabled;

  final void Function(bool)? onSelectionChanged;

  final LdSelectionControl? selectionControl;

  final Widget? subContent;

  final bool? isSelected;

  final FocusNode? focusNode;

  final bool? disabled;

  final bool? tradeLeadingForSelectionControl;

  final LdColor? color;

  final EdgeInsets? padding;

  final BorderRadius? borderRadius;

  final bool? isOdd;

  final BoxShadow? shadow;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<LdListItemConfig?>(context, listen: true);
    return LdListItemWidget(
      active: active ?? config?.active ?? false,
      borderRadius: borderRadius ?? config?.borderRadius,
      disabled: disabled ?? config?.disabled ?? false,
      isSelected: isSelected ?? config?.isSelected ?? false,
      leading: leading ?? config?.leading,
      onSelectionChanged: onSelectionChanged ?? config?.onSelectionChanged,
      onPressed: onPressed ?? config?.onPressed,
      padding: padding ?? config?.padding,
      selectDisabled: selectDisabled ?? config?.selectDisabled ?? false,
      subContent: subContent ?? config?.subContent,
      subtitle: subtitle ?? config?.subtitle,
      title: title ?? config?.title,
      tradeLeadingForSelectionControl: tradeLeadingForSelectionControl ??
          config?.tradeLeadingForSelectionControl ??
          true,
      shadow: shadow ?? config?.shadow,
      focusNode: focusNode ?? config?.focusNode,
      trailing: trailing ?? config?.trailing,
      color: color ?? config?.color,
      width: width ?? config?.width,
      isOdd: isOdd ?? config?.isOdd ?? false,
      selectionControl: selectionControl ??
          config?.selectionControl ??
          LdSelectionControl.none,
    );
  }
}
