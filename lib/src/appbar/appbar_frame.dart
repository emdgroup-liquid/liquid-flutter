import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_wrapper.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';

class AppBarFrame extends StatefulWidget {
  final Widget child;
  final AppBarPosition position;

  final BoxDecoration? insideDecoration;
  final BoxDecoration? outsideDecoration;
  final EdgeInsets? insidePadding;
  final EdgeInsets? outsideMinPadding;
  final bool insetBorderRadius;
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
    this.insideDecoration,
    this.outsideDecoration,
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
    if (!mounted) return;
    setState(() {});
  }

  LdAppBarRegistryKey? _getKey() {
    return context.maybeAppBarRegistryKey();
  }

  double _calculateOtherAppBarHeight(AppBarPosition position) {
    final registry = AppBarRegistry.maybeStateOf(context);
    final key = _getKey();
    if (registry == null || key == null) {
      return 0.0;
    }
    return registry.getEffectiveHeightOfOthers(key);
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

  EdgeInsets _outsideContainerPadding() {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final theme = LdTheme.of(context);

    // Trim viewPadding to only the relevant side
    final trimmedViewPadding = widget.position == AppBarPosition.top
        ? EdgeInsets.only(top: viewPadding.top)
        : EdgeInsets.only(bottom: viewPadding.bottom);

    // We add the viewInsets to the padding in case something inside the appbar is focused.
    final viewInsets = _focusScopeNode.hasFocus ? MediaQuery.of(context).viewInsets : EdgeInsets.zero;
    final trimmedViewInsets = widget.position == AppBarPosition.top
        ? EdgeInsets.only(top: viewInsets.top)
        : EdgeInsets.only(bottom: viewInsets.bottom);

    final otherAppBarHeight = _calculateOtherAppBarHeight(widget.position);

    EdgeInsets otherPadding;
    if (widget.position == AppBarPosition.top) {
      otherPadding = EdgeInsets.only(top: otherAppBarHeight);
    } else {
      otherPadding = EdgeInsets.only(bottom: otherAppBarHeight);
    }

    final extraPadding = widget.outsideMinPadding ?? (widget.attached ? EdgeInsets.zero : theme.pad(size: LdSize.s));

    final level = _calculateLevel();

    EdgeInsets result =
        trimmedViewPadding.atLeast(otherPadding + extraPadding).atLeast(trimmedViewInsets).atLeast(extraPadding);
    if (level == 0 && widget.insetBorderRadius) {
      // In case we already inset from the radius, we need to reduce the padding by the inset amount.
      final inset = widget.position == AppBarPosition.top ? result.top : result.bottom;
      return result.atLeast(EdgeInsets.symmetric(horizontal: (theme.screenRadius) / 2 - inset));
    }

    return result;
  }

  EdgeInsets get _insidePadding {
    if (widget.insidePadding != null) {
      return widget.insidePadding!;
    }
    final theme = LdTheme.of(context);
    return theme.pad(size: LdSize.s);
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

    final verticalMargin = widget.position == AppBarPosition.top ? outsidePadding.top : outsidePadding.bottom;

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
    final outsidePadding = _outsideContainerPadding();
    if (outsidePadding != _previousOutsidePadding) {
      _previousOutsidePadding = outsidePadding;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _updateMargin(outsidePadding);
      });
    }

    return FocusScope(
      node: _focusScopeNode,
      child: Container(
        padding: outsidePadding,
        decoration: widget.outsideDecoration,
        key: Key("appbar_frame_outside_${widget.position.name}"),
        child: MeasureSize(
          onSizeChange: _onSizeChange,
          child: Container(
            decoration: widget.insideDecoration,
            padding: _insidePadding,
            clipBehavior: Clip.hardEdge,
            key: Key("appbar_frame_inside_${widget.position.name}"),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
