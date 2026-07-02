part of 'appbar.dart';

class LdAppBarConfig {
  const LdAppBarConfig({
    this.child,
    this.actions,
    this.addContainer,
    this.attachedMode,
    this.autoAttachToKeyboard,
    this.backgroundColor,
    this.backgroundMode,
    this.borderMode,
    this.bottom,
    this.debugName,
    this.insetScreenRadius,
    this.implyFeatures,
    this.avoidViewInsets,
    this.leading,
    this.overflowMenuProviders,
    this.positionMode,
    this.scrollBehavior,
    this.searchConfig,
    this.shadowMode,
    this.title,
    this.trailing,
    this.padding,
  });

  final Widget? child;

  final List<Widget>? actions;

  final bool? addContainer;

  final LdAppBarAttachedMode? attachedMode;

  final bool? autoAttachToKeyboard;

  final Color? backgroundColor;

  final LdAppBarBackgroundMode? backgroundMode;

  final LdAppBarBorderMode? borderMode;

  final Widget? bottom;

  final String? debugName;

  final bool? insetScreenRadius;

  final Set<LdAppBarImpliedFeature>? implyFeatures;

  final bool? avoidViewInsets;

  final Widget? leading;

  final List<SingleChildWidget> Function(BuildContext)? overflowMenuProviders;

  final LdAppBarPositionMode? positionMode;

  final LdAppBarScrollBehavior? scrollBehavior;

  final LdSearchConfig? searchConfig;

  final LdAppBarShadowMode? shadowMode;

  final Widget? title;

  final Widget? trailing;

  final EdgeInsets? padding;
}

class LdAppBarConfigProvider extends StatelessWidget {
  const LdAppBarConfigProvider({
    required this.config,
    required this.child,
    this.ignoreParent = false,
    super.key,
  });

  final LdAppBarConfig config;

  final Widget child;

  final bool ignoreParent;

  @override
  Widget build(BuildContext context) {
    if (ignoreParent) {
      return Provider<LdAppBarConfig>.value(
        value: config,
        child: child,
      );
    }
    final parentConfig = Provider.of<LdAppBarConfig?>(context, listen: true);
    final mergedConfig = parentConfig != null
        ? LdAppBarConfig(
            child: config.child ?? parentConfig.child,
            actions: config.actions ?? parentConfig.actions,
            addContainer: config.addContainer ?? parentConfig.addContainer,
            attachedMode: config.attachedMode ?? parentConfig.attachedMode,
            autoAttachToKeyboard: config.autoAttachToKeyboard ??
                parentConfig.autoAttachToKeyboard,
            backgroundColor:
                config.backgroundColor ?? parentConfig.backgroundColor,
            backgroundMode:
                config.backgroundMode ?? parentConfig.backgroundMode,
            borderMode: config.borderMode ?? parentConfig.borderMode,
            bottom: config.bottom ?? parentConfig.bottom,
            debugName: config.debugName ?? parentConfig.debugName,
            insetScreenRadius:
                config.insetScreenRadius ?? parentConfig.insetScreenRadius,
            implyFeatures: config.implyFeatures ?? parentConfig.implyFeatures,
            avoidViewInsets:
                config.avoidViewInsets ?? parentConfig.avoidViewInsets,
            leading: config.leading ?? parentConfig.leading,
            overflowMenuProviders: config.overflowMenuProviders ??
                parentConfig.overflowMenuProviders,
            positionMode: config.positionMode ?? parentConfig.positionMode,
            scrollBehavior:
                config.scrollBehavior ?? parentConfig.scrollBehavior,
            searchConfig: config.searchConfig ?? parentConfig.searchConfig,
            shadowMode: config.shadowMode ?? parentConfig.shadowMode,
            title: config.title ?? parentConfig.title,
            trailing: config.trailing ?? parentConfig.trailing,
            padding: config.padding ?? parentConfig.padding)
        : config;
    return Provider<LdAppBarConfig>.value(
      value: mergedConfig,
      child: child,
    );
  }
}

class LdAppBar extends StatelessWidget {
  const LdAppBar({
    this.child,
    this.actions,
    this.addContainer,
    this.attachedMode,
    this.autoAttachToKeyboard,
    this.backgroundColor,
    this.backgroundMode,
    this.borderMode,
    this.bottom,
    this.debugName,
    this.insetScreenRadius,
    this.implyFeatures,
    this.avoidViewInsets,
    this.leading,
    this.overflowMenuProviders,
    this.positionMode,
    this.scrollBehavior,
    this.searchConfig,
    this.shadowMode,
    this.title,
    this.trailing,
    this.padding,
    super.key,
  });

  factory LdAppBar.top({
    required Widget child,
    List<Widget>? actions,
    bool? addContainer,
    LdAppBarAttachedMode? attachedMode,
    bool? autoAttachToKeyboard,
    Color? backgroundColor,
    LdAppBarBackgroundMode? backgroundMode,
    LdAppBarBorderMode? borderMode,
    Widget? bottom,
    String? debugName,
    bool? insetScreenRadius,
    Set<LdAppBarImpliedFeature>? implyFeatures,
    bool? avoidViewInsets,
    Widget? leading,
    List<SingleChildWidget> Function(BuildContext)? overflowMenuProviders,
    LdAppBarPositionMode? positionMode,
    LdAppBarScrollBehavior? scrollBehavior,
    LdSearchConfig? searchConfig,
    LdAppBarShadowMode? shadowMode,
    Widget? title,
    Widget? trailing,
    EdgeInsets? padding,
    Key? key,
  }) {
    return LdAppBar(
      actions: actions,
      addContainer: addContainer,
      attachedMode: attachedMode,
      autoAttachToKeyboard: autoAttachToKeyboard,
      backgroundColor: backgroundColor,
      backgroundMode: backgroundMode,
      borderMode: borderMode,
      bottom: bottom,
      debugName: debugName,
      insetScreenRadius: insetScreenRadius,
      implyFeatures: implyFeatures,
      avoidViewInsets: avoidViewInsets,
      leading: leading,
      overflowMenuProviders: overflowMenuProviders,
      positionMode: LdAppBarPositionMode.top,
      scrollBehavior: scrollBehavior,
      searchConfig: searchConfig,
      shadowMode: shadowMode,
      title: title,
      trailing: trailing,
      padding: padding,
      key: key,
      child: child,
    );
  }

  factory LdAppBar.bottom({
    required Widget child,
    List<Widget>? actions,
    bool? addContainer,
    LdAppBarAttachedMode? attachedMode,
    bool? autoAttachToKeyboard,
    Color? backgroundColor,
    LdAppBarBackgroundMode? backgroundMode,
    LdAppBarBorderMode? borderMode,
    Widget? bottom,
    String? debugName,
    bool? insetScreenRadius,
    Set<LdAppBarImpliedFeature>? implyFeatures,
    bool? avoidViewInsets,
    Widget? leading,
    List<SingleChildWidget> Function(BuildContext)? overflowMenuProviders,
    LdAppBarPositionMode? positionMode,
    LdAppBarScrollBehavior? scrollBehavior,
    LdSearchConfig? searchConfig,
    LdAppBarShadowMode? shadowMode,
    Widget? title,
    Widget? trailing,
    EdgeInsets? padding,
    Key? key,
  }) {
    return LdAppBar(
      actions: actions,
      addContainer: addContainer,
      attachedMode: attachedMode,
      autoAttachToKeyboard: autoAttachToKeyboard,
      backgroundColor: backgroundColor,
      backgroundMode: backgroundMode,
      borderMode: borderMode,
      bottom: bottom,
      debugName: debugName,
      insetScreenRadius: insetScreenRadius,
      implyFeatures: implyFeatures,
      avoidViewInsets: avoidViewInsets,
      leading: leading,
      overflowMenuProviders: overflowMenuProviders,
      positionMode: LdAppBarPositionMode.bottom,
      scrollBehavior: scrollBehavior,
      searchConfig: searchConfig,
      shadowMode: shadowMode,
      title: title,
      trailing: trailing,
      padding: padding,
      key: key,
      child: child,
    );
  }

  final Widget? title;

  final Widget? leading;

  final Widget? trailing;

  final Color? backgroundColor;

  final Set<LdAppBarImpliedFeature>? implyFeatures;

  final bool? addContainer;

  final Widget? bottom;

  final LdAppBarShadowMode? shadowMode;

  final LdAppBarBorderMode? borderMode;

  final LdAppBarBackgroundMode? backgroundMode;

  final LdAppBarAttachedMode? attachedMode;

  final bool? avoidViewInsets;

  final bool? autoAttachToKeyboard;

  final List<Widget>? actions;

  final List<SingleChildWidget> Function(BuildContext)? overflowMenuProviders;

  final LdSearchConfig? searchConfig;

  final String? debugName;

  final LdAppBarPositionMode? positionMode;

  final LdAppBarScrollBehavior? scrollBehavior;

  final Widget? child;

  final EdgeInsets? padding;

  final bool? insetScreenRadius;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<LdAppBarConfig?>(context, listen: true);
    assert(config?.child != null || child != null,
        "Parameter child is required and it was neither provided nor directly passed");
    return LdAppBarWidget(
      actions: actions ?? config?.actions ?? const [],
      addContainer: addContainer ?? config?.addContainer ?? false,
      attachedMode:
          attachedMode ?? config?.attachedMode ?? LdAppBarAttachedMode.adaptive,
      autoAttachToKeyboard:
          autoAttachToKeyboard ?? config?.autoAttachToKeyboard ?? true,
      backgroundColor: backgroundColor ?? config?.backgroundColor,
      backgroundMode: backgroundMode ??
          config?.backgroundMode ??
          LdAppBarBackgroundMode.adaptive,
      borderMode:
          borderMode ?? config?.borderMode ?? LdAppBarBorderMode.adaptive,
      bottom: bottom ?? config?.bottom,
      debugName: debugName ?? config?.debugName,
      insetScreenRadius: insetScreenRadius ?? config?.insetScreenRadius ?? true,
      implyFeatures: implyFeatures ??
          config?.implyFeatures ??
          const {
            LdAppBarImpliedFeature.back,
            LdAppBarImpliedFeature.close,
            LdAppBarImpliedFeature.windowControls,
            LdAppBarImpliedFeature.drawerToggle
          },
      avoidViewInsets: avoidViewInsets ?? config?.avoidViewInsets ?? false,
      leading: leading ?? config?.leading,
      overflowMenuProviders:
          overflowMenuProviders ?? config?.overflowMenuProviders,
      positionMode:
          positionMode ?? config?.positionMode ?? LdAppBarPositionMode.top,
      scrollBehavior: scrollBehavior ??
          config?.scrollBehavior ??
          LdAppBarScrollBehavior.mobileOnly,
      searchConfig: searchConfig ?? config?.searchConfig,
      shadowMode: shadowMode ?? config?.shadowMode ?? LdAppBarShadowMode.hidden,
      title: title ?? config?.title,
      trailing: trailing ?? config?.trailing,
      padding: padding ?? config?.padding,
      child: child ?? config!.child!,
    );
  }
}
