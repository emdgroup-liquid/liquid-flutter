part of 'list_item.dart';

class LdListItemConfig {
  const LdListItemConfig({
    this.active,
    this.borderRadius,
    this.disabled,
    this.isSelected,
    this.onSelectionChanged,
    this.onPressed,
    this.padding,
    this.focusNode,
    this.trailing,
    this.color,
    this.selectionControl,
  });

  final bool? active;

  final BorderRadius? borderRadius;

  final bool? disabled;

  final bool? isSelected;

  final void Function(bool)? onSelectionChanged;

  final void Function()? onPressed;

  final EdgeInsets? padding;

  final FocusNode? focusNode;

  final Widget? trailing;

  final LdColor? color;

  final LdSelectionControl? selectionControl;
}

class LdListItemConfigProvider extends StatelessWidget {
  const LdListItemConfigProvider(
    this.config,
    this.child, {
    super.key,
  });

  final LdListItemConfig config;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final parentConfig = Provider.of<LdListItemConfig?>(context, listen: false);
    final mergedConfig = parentConfig != null
        ? LdListItemConfig(
            active: config.active ?? parentConfig.active,
            borderRadius: config.borderRadius ?? parentConfig.borderRadius,
            disabled: config.disabled ?? parentConfig.disabled,
            isSelected: config.isSelected ?? parentConfig.isSelected,
            onSelectionChanged:
                config.onSelectionChanged ?? parentConfig.onSelectionChanged,
            onPressed: config.onPressed ?? parentConfig.onPressed,
            padding: config.padding ?? parentConfig.padding,
            focusNode: config.focusNode ?? parentConfig.focusNode,
            trailing: config.trailing ?? parentConfig.trailing,
            color: config.color ?? parentConfig.color,
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
    super.key,
    this.active,
    this.borderRadius,
    this.disabled,
    this.isSelected,
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
    this.selectionControl,
  });

  factory LdListItem.trailingForward({
    Key? key,
    bool? active,
    BorderRadius? borderRadius,
    bool? disabled,
    bool? isSelected,
    Widget? leading,
    void Function(bool)? onSelectionChanged,
    void Function()? onPressed,
    EdgeInsets? padding,
    bool selectDisabled = false,
    Widget? subContent,
    Widget? subtitle,
    Widget? title,
    bool tradeLeadingForSelectionControl = true,
    FocusNode? focusNode,
    Widget? trailing,
    LdColor? color,
    double? width,
    LdSelectionControl? selectionControl,
  }) {
    return LdListItem(
      key: key,
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
      focusNode: focusNode,
      trailing: const LdListDefaultTrailingForward(),
      color: color,
      width: width,
      selectionControl: selectionControl,
    );
  }

  final Widget? leading;

  final Widget? trailing;

  final Widget? title;

  final bool? active;

  final Widget? subtitle;

  final void Function()? onPressed;

  final double? width;

  final bool selectDisabled;

  final void Function(bool)? onSelectionChanged;

  final LdSelectionControl? selectionControl;

  final Widget? subContent;

  final bool? isSelected;

  final FocusNode? focusNode;

  final bool? disabled;

  final bool tradeLeadingForSelectionControl;

  final LdColor? color;

  final EdgeInsets? padding;

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<LdListItemConfig?>(context, listen: false);
    return LdListItemWidget(
      active: active ?? config?.active ?? false,
      borderRadius: borderRadius ?? config?.borderRadius,
      disabled: disabled ?? config?.disabled ?? false,
      isSelected: isSelected ?? config?.isSelected ?? false,
      leading: leading,
      onSelectionChanged: onSelectionChanged ?? config?.onSelectionChanged,
      onPressed: onPressed ?? config?.onPressed,
      padding: padding ?? config?.padding,
      selectDisabled: selectDisabled,
      subContent: subContent,
      subtitle: subtitle,
      title: title,
      tradeLeadingForSelectionControl: tradeLeadingForSelectionControl,
      focusNode: focusNode ?? config?.focusNode,
      trailing: trailing ?? config?.trailing,
      color: color ?? config?.color,
      width: width,
      selectionControl: selectionControl ??
          config?.selectionControl ??
          LdSelectionControl.none,
    );
  }
}
