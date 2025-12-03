import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:liquid_flutter/src/scaffold_layout_state.dart';
import 'package:provider/provider.dart';

class AppBarFrame extends StatefulWidget {
  final Widget child;
  final EffectivePosition effectivePosition;
  final AppBarRole appBarRole;

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
    required this.effectivePosition,
    required this.appBarRole,
    this.attached = true,
    this.insideDecoration,
    this.outsideDecoration,
    this.insetBorderRadius = true,
    this.insidePadding,
    this.outsideMinPadding,
    this.debugName,
  });

  factory AppBarFrame.fromSlot({
    String? debugName,
    required LdScaffoldSlot slot,
    required Widget child,
    BoxDecoration? insideDecoration,
    bool attached = false,
    BoxDecoration? outsideDecoration,
    EdgeInsets? insidePadding,
    EdgeInsets? outsideMinPadding,
    bool insetBorderRadius = true,
  }) {
    return AppBarFrame(
      effectivePosition: slot.effectivePosition ?? EffectivePosition.top,
      appBarRole: slot.role!,
      debugName: debugName,
      child: child,
      insideDecoration: insideDecoration,
      outsideDecoration: outsideDecoration,
      attached: attached,
      insidePadding: insidePadding,
      insetBorderRadius: insetBorderRadius,
      outsideMinPadding: outsideMinPadding,
    );
  }

  @override
  State<AppBarFrame> createState() => _AppBarFrameState();
}

class _AppBarFrameState extends State<AppBarFrame> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();
  @override
  void initState() {
    super.initState();
  }

  EdgeInsets _outsideContainerPadding(LdScaffoldLayoutState layoutState) {
    final viewPadding = MediaQuery.viewPaddingOf(context).trimToEffectivePosition(widget.effectivePosition);
    final theme = LdTheme.of(context);

    // We add the viewInsets to the padding in case something inside the appbar is focused.
    final viewInsets = (_focusScopeNode.hasFocus ? MediaQuery.of(context).viewInsets : EdgeInsets.zero)
        .trimToEffectivePosition(widget.effectivePosition);

    final otherAppBarHeight = layoutState.effectiveHeightOfOthers(widget.effectivePosition, widget.appBarRole);

    EdgeInsets otherPadding;

    if (widget.effectivePosition == EffectivePosition.top) {
      otherPadding = EdgeInsets.only(
        top: otherAppBarHeight,
      );
    } else {
      otherPadding = EdgeInsets.only(
        bottom: otherAppBarHeight,
      );
    }

    final extraPadding = widget.outsideMinPadding ?? theme.pad(size: LdSize.s);

    final level = layoutState.levelForEffectivePosition();

    EdgeInsets result = viewPadding.atLeast(otherPadding).atLeast(viewInsets).atLeast(extraPadding);
    if (level == 0 && widget.insetBorderRadius) {
      // In case we already inset from the radius, we need to reduce the padding by the inset amount.
      final inset = switch (widget.effectivePosition) {
        EffectivePosition.top => result.top,
        EffectivePosition.bottom => result.bottom,
      };
      return result.atLeast(EdgeInsets.symmetric(horizontal: (theme.screenRadius) / 2 - inset));
    }

    return result;
  }

  EdgeInsets get _insidePadding {
    if (widget.insidePadding != null) {
      return widget.insidePadding!;
    }
    final layoutState = context.watch<LdScaffoldLayoutState?>();
    if (layoutState == null) {
      throw Exception("AppbarFrame must be used within a LdScaffold");
    }
    final theme = LdTheme.of(context);

    return theme.pad(size: LdSize.s);
  }

  void _onSizeChange(Size size) {
    final scaffoldState = context.findAncestorStateOfType<LdScaffoldState>();
    if (scaffoldState == null) {
      return;
    }
    scaffoldState.onAppBarSizeChange(widget.appBarRole, size);
  }

  EdgeInsets _previousOutsidePadding = EdgeInsets.zero;

  @override
  Widget build(BuildContext context) {
    final layoutState = context.watch<LdScaffoldLayoutState?>();
    final scaffoldState = context.findAncestorStateOfType<LdScaffoldState>();
    if (layoutState == null) {
      throw Exception("AppbarFrame must be used within a LdScaffold");
    }

    final outsidePadding = _outsideContainerPadding(layoutState);
    if (outsidePadding != _previousOutsidePadding) {
      _previousOutsidePadding = outsidePadding;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        scaffoldState!.onAppBarMarginChange(layoutState.slot, outsidePadding);
      });
    }

    return FocusScope(
      node: _focusScopeNode,
      child: Container(
        padding: outsidePadding,
        decoration: widget.outsideDecoration,
        key: Key("appbar_frame_outside_${widget.effectivePosition.name}_${widget.appBarRole.name}"),
        child: MeasureSize(
          onSizeChange: _onSizeChange,
          child: Container(
            decoration: widget.insideDecoration,
            padding: _insidePadding,
            clipBehavior: Clip.hardEdge,
            key: Key("appbar_frame_inside_${widget.effectivePosition.name}_${widget.appBarRole.name}"),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
