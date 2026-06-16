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
    this.implyCloseModalButton,
    this.implyLeading,
    this.avoidViewInsets,
    this.leading,
    this.overflowMenuProviders,
    this.positionMode,
    this.scrollBehavior,
    this.searchConfig,
    this.shadowMode,
    this.showWindowControls,
    this.title,
    this.trailing,
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

  final bool? implyCloseModalButton;

  final bool? implyLeading;

  final bool? avoidViewInsets;

  final Widget? leading;

  final List<SingleChildWidget> Function(BuildContext)? overflowMenuProviders;

  final LdAppBarPositionMode? positionMode;

  final LdAppBarScrollBehavior? scrollBehavior;

  final LdSearchConfig? searchConfig;

  final LdAppBarShadowMode? shadowMode;

  final bool? showWindowControls;

  final Widget? title;

  final Widget? trailing;
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
            implyCloseModalButton: config.implyCloseModalButton ??
                parentConfig.implyCloseModalButton,
            implyLeading: config.implyLeading ?? parentConfig.implyLeading,
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
            showWindowControls:
                config.showWindowControls ?? parentConfig.showWindowControls,
            title: config.title ?? parentConfig.title,
            trailing: config.trailing ?? parentConfig.trailing)
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
    this.implyCloseModalButton,
    this.implyLeading,
    this.avoidViewInsets,
    this.leading,
    this.overflowMenuProviders,
    this.positionMode,
    this.scrollBehavior,
    this.searchConfig,
    this.shadowMode,
    this.showWindowControls,
    this.title,
    this.trailing,
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
    bool? implyCloseModalButton,
    bool? implyLeading,
    bool? avoidViewInsets,
    Widget? leading,
    List<SingleChildWidget> Function(BuildContext)? overflowMenuProviders,
    LdAppBarPositionMode? positionMode,
    LdAppBarScrollBehavior? scrollBehavior,
    LdSearchConfig? searchConfig,
    LdAppBarShadowMode? shadowMode,
    bool? showWindowControls,
    Widget? title,
    Widget? trailing,
    Key? key,
  }) {
    return LdAppBar(
      child: child,
      actions: actions,
      addContainer: addContainer,
      attachedMode: attachedMode,
      autoAttachToKeyboard: autoAttachToKeyboard,
      backgroundColor: backgroundColor,
      backgroundMode: backgroundMode,
      borderMode: borderMode,
      bottom: bottom,
      debugName: debugName,
      implyCloseModalButton: implyCloseModalButton,
      implyLeading: implyLeading,
      avoidViewInsets: avoidViewInsets,
      leading: leading,
      overflowMenuProviders: overflowMenuProviders,
      positionMode: LdAppBarPositionMode.top,
      scrollBehavior: scrollBehavior,
      searchConfig: searchConfig,
      shadowMode: shadowMode,
      showWindowControls: showWindowControls,
      title: title,
      trailing: trailing,
      key: key,
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
    bool? implyCloseModalButton,
    bool? implyLeading,
    bool? avoidViewInsets,
    Widget? leading,
    List<SingleChildWidget> Function(BuildContext)? overflowMenuProviders,
    LdAppBarPositionMode? positionMode,
    LdAppBarScrollBehavior? scrollBehavior,
    LdSearchConfig? searchConfig,
    LdAppBarShadowMode? shadowMode,
    bool? showWindowControls,
    Widget? title,
    Widget? trailing,
    Key? key,
  }) {
    return LdAppBar(
      child: child,
      actions: actions,
      addContainer: addContainer,
      attachedMode: attachedMode,
      autoAttachToKeyboard: autoAttachToKeyboard,
      backgroundColor: backgroundColor,
      backgroundMode: backgroundMode,
      borderMode: borderMode,
      bottom: bottom,
      debugName: debugName,
      implyCloseModalButton: implyCloseModalButton,
      implyLeading: implyLeading,
      avoidViewInsets: avoidViewInsets,
      leading: leading,
      overflowMenuProviders: overflowMenuProviders,
      positionMode: LdAppBarPositionMode.bottom,
      scrollBehavior: scrollBehavior,
      searchConfig: searchConfig,
      shadowMode: shadowMode,
      showWindowControls: showWindowControls,
      title: title,
      trailing: trailing,
      key: key,
    );
  }

  final Widget? title;

  final Widget? leading;

  final Widget? trailing;

  final Color? backgroundColor;

  final bool? implyLeading;

  final bool? addContainer;

  final Widget? bottom;

  final LdAppBarShadowMode? shadowMode;

  final LdAppBarBorderMode? borderMode;

  final LdAppBarBackgroundMode? backgroundMode;

  final LdAppBarAttachedMode? attachedMode;

  final bool? showWindowControls;

  final bool? implyCloseModalButton;

  final bool? avoidViewInsets;

  final bool? autoAttachToKeyboard;

  final List<Widget>? actions;

  final List<SingleChildWidget> Function(BuildContext)? overflowMenuProviders;

  final LdSearchConfig? searchConfig;

  final String? debugName;

  final LdAppBarPositionMode? positionMode;

  final LdAppBarScrollBehavior? scrollBehavior;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<LdAppBarConfig?>(context, listen: true);
    assert(config?.child != null || child != null,
        "Parameter child is required and it was neither provided nor directly passed");
    return LdAppBarWidget(
      child: child ?? config!.child!,
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
      implyCloseModalButton:
          implyCloseModalButton ?? config?.implyCloseModalButton ?? true,
      implyLeading: implyLeading ?? config?.implyLeading,
      avoidViewInsets: avoidViewInsets ?? config?.avoidViewInsets ?? false,
      leading: leading ?? config?.leading,
      overflowMenuProviders:
          overflowMenuProviders ?? config?.overflowMenuProviders,
      positionMode:
          positionMode ?? config?.positionMode ?? LdAppBarPositionMode.top,
      scrollBehavior: scrollBehavior ??
          config?.scrollBehavior ??
          LdAppBarScrollBehavior.static,
      searchConfig: searchConfig ?? config?.searchConfig,
      shadowMode:
          shadowMode ?? config?.shadowMode ?? LdAppBarShadowMode.adaptive,
      showWindowControls:
          showWindowControls ?? config?.showWindowControls ?? true,
      title: title ?? config?.title,
      trailing: trailing ?? config?.trailing,
    );
  }
}
