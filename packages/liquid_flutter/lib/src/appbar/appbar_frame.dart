import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';

class AppBarFrame extends StatefulWidget {
  final Widget child;
  final LdAppBarPosition position;

  final BoxDecoration? insideDecoration;
  final BoxDecoration? outsideDecoration;
  final EdgeInsets? insidePadding;
  final EdgeInsets? outsideMinPadding;
  final bool addContainer;
  final bool insetBorderRadius;
  final bool avoidViewInsets;
  final String? debugName;

  /// Whether the appbar is attached to the scaffold or floating.
  /// A floating appbar has some margin on the outside and padding on the inside.
  /// An attached appbar has no margin on the outside and padding on the inside.
  final bool attached;

  const AppBarFrame({
    super.key,
    required this.child,
    required this.position,
    this.attached = true,
    this.addContainer = false,
    this.insideDecoration,
    this.outsideDecoration,
    this.avoidViewInsets = false,
    this.insetBorderRadius = true,
    this.insidePadding,
    this.outsideMinPadding,
    this.debugName,
  });

  @override
  State<AppBarFrame> createState() => _AppBarFrameState();
}

class _AppBarFrameState extends State<AppBarFrame> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  late final _registry = AppBarRegistry.maybeStateOf(context)!;

  @override
  debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty("debugName", widget.debugName));
    properties.add(StringProperty("position", widget.position.name));
    properties.add(StringProperty("attached", widget.attached.toString()));
    properties.add(StringProperty("addContainer", widget.addContainer.toString()));
    properties.add(StringProperty("insetBorderRadius", widget.insetBorderRadius.toString()));
    properties.add(StringProperty("avoidViewInsets", widget.avoidViewInsets.toString()));
    properties.add(StringProperty("insideDecoration", widget.insideDecoration?.toString()));
    properties.add(StringProperty("outsideDecoration", widget.outsideDecoration?.toString()));
    properties.add(StringProperty("insidePadding", widget.insidePadding?.toString()));
    properties.add(StringProperty("outsideMinPadding", widget.outsideMinPadding?.toString()));
    properties.add(StringProperty("child", widget.child.toString()));
  }

  @override
  void initState() {
    super.initState();
    _registry.addListener(_onRegistryChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setInitialPosition();
      }
    });
  }

  void _setInitialPosition() {
    final key = _getKey();
    if (key == null) return;
    final currentInfo = _registry.getAppBarInfo(key);
    if (currentInfo == null) return;

    _registry.updateAppBarInfo(
      key,
      currentInfo.copyWith(
        position: widget.position,
      ),
    );
  }

  void _onRegistryChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  LdAppBarRegistryKey? _getKey() {
    return context.maybeAppBarRegistryKey();
  }

  double _calculateOtherAppBarHeight(LdAppBarPosition position) {
    final registry = AppBarRegistry.maybeStateOf(context);
    final key = _getKey();
    if (registry == null || key == null) {
      return 0.0;
    }
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is LdModalRoute) {
      return registry.getEffectiveHeightOfOthers(key, limitToChildrenOf: modalRoute.subtreeContext);
    }
    return registry.getEffectiveHeightOfOthers(
      key,
    );
  }

  int _calculateLevel() {
    // Get the registry state and use its getLevel method
    final registryState = AppBarRegistry.maybeStateOf(context);
    final key = _getKey();
    if (registryState == null || key == null) {
      return 0;
    }
    return registryState.getLevel(key, widget.position);
  }

  EdgeInsets _containerPadding(BoxConstraints constraints) {
    if (widget.addContainer) {
      final maxWidth = LdTheme.of(context).sizingConfig.containerMaxWidth;
      return EdgeInsets.symmetric(horizontal: ((constraints.maxWidth - maxWidth) / 2).clamp(0.0, double.infinity));
    }
    return EdgeInsets.zero;
  }

  EdgeInsets _outsideContainerPadding(BoxConstraints constraints) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final theme = LdTheme.of(context);

    // Trim viewPadding to only the relevant side
    final trimmedViewPadding = widget.position == LdAppBarPosition.top
        ? EdgeInsets.only(top: viewPadding.top)
        : EdgeInsets.only(bottom: viewPadding.bottom);

    // We add the viewInsets to the padding in case something inside the appbar is focused.
    final viewInsets =
        _focusScopeNode.hasFocus || widget.avoidViewInsets ? MediaQuery.of(context).viewInsets : EdgeInsets.zero;

    final trimmedViewInsets = widget.position == LdAppBarPosition.top
        ? EdgeInsets.only(top: viewInsets.top)
        : EdgeInsets.only(bottom: viewInsets.bottom);

    final otherAppBarHeight = _calculateOtherAppBarHeight(widget.position);

    EdgeInsets otherPadding;
    if (widget.position == LdAppBarPosition.top) {
      otherPadding = EdgeInsets.only(top: otherAppBarHeight);
    } else {
      otherPadding = EdgeInsets.only(bottom: otherAppBarHeight);
    }

    final extraPadding = widget.outsideMinPadding ??
        (widget.attached
            ? EdgeInsets.zero
            : theme.pad(size: LdSize.s).atLeast(
                  _containerPadding(constraints),
                ));

    final level = _calculateLevel();

    EdgeInsets result =
        trimmedViewPadding.atLeast(otherPadding + extraPadding).atLeast(trimmedViewInsets).atLeast(extraPadding);
    if (level == 0 && widget.insetBorderRadius) {
      // In case we already inset from the radius, we need to reduce the padding by the inset amount.
      final inset = widget.position == LdAppBarPosition.top ? result.top : result.bottom;
      return result.atLeast(EdgeInsets.symmetric(horizontal: (theme.screenRadius) / 2 - inset));
    }

    return result;
  }

  EdgeInsets _insidePadding(BoxConstraints constraints) {
    if (widget.insidePadding != null) {
      return widget.insidePadding!;
    }
    final theme = LdTheme.of(context);
    if (widget.attached) {
      return theme.pad(size: LdSize.s).atLeast(_containerPadding(constraints));
    } else {
      return theme.pad(size: LdSize.s);
    }
  }

  void _onSizeChange(Size size) {
    final registry = AppBarRegistry.maybeStateOf(context);
    final key = _getKey();
    if (registry == null || key == null) return;

    final currentInfo = registry.getAppBarInfo(key) ?? AppBarInfo.initial(widget.position);

    registry.updateAppBarInfo(
      key,
      currentInfo.copyWith(
        position: widget.position,
        innerHeight: size.height,
      ),
    );
  }

  EdgeInsets _previousOutsidePadding = EdgeInsets.zero;

  void _updateMargin(EdgeInsets outsidePadding) {
    final registry = AppBarRegistry.maybeStateOf(context);
    final key = _getKey();
    if (registry == null || key == null) return;

    final verticalMargin = widget.position == LdAppBarPosition.top ? outsidePadding.top : outsidePadding.bottom;

    final currentInfo = registry.getAppBarInfo(key) ?? AppBarInfo.initial(widget.position);
    registry.updateAppBarInfo(
      key,
      currentInfo.copyWith(
        verticalMargin: verticalMargin,
        position: widget.position,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.viewInsetsOf(context);
    return LayoutBuilder(builder: (context, constraints) {
      final outsidePadding = _outsideContainerPadding(constraints);
      if (outsidePadding != _previousOutsidePadding) {
        _previousOutsidePadding = outsidePadding;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _updateMargin(outsidePadding);
        });
      }

      return ValueListenableBuilder(
        valueListenable: LdScaffoldState.maybeOf(context)?.bodyScrollOffset ?? ValueNotifier(0.0),
        builder: (context, value, child) {
          return FocusScope(
            node: _focusScopeNode,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: outsidePadding,
              decoration: widget.outsideDecoration,
              key: Key("appbar_frame_outside_${widget.position.name}"),
              child: MeasureSize(
                onSizeChange: _onSizeChange,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: widget.insideDecoration,
                  padding: _insidePadding(constraints),
                  clipBehavior: Clip.hardEdge,
                  key: Key("appbar_frame_inside_${widget.position.name}"),
                  child: child,
                ),
              ),
            ),
          );
        },
        child: widget.child,
      );
    });
  }
}
