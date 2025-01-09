import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/notifications/implicit_blur.dart';

enum LdContextMenuBlurMode {
  /// Blur on mobile
  mobileOnly,

  /// Always blur
  always,

  /// Never blur
  never,
}

enum LdContextZoomMode {
  /// Zoom on mobile
  mobileOnly,

  /// Always zoom
  always,

  /// Never zoom
  never,
}

class LdContextMenu extends StatefulWidget {
  const LdContextMenu({
    super.key,
    required this.builder,
    required this.menuBuilder,
    this.dismissOnOutsideTap = true,
    this.blurMode = LdContextMenuBlurMode.mobileOnly,
    this.zoomMode = LdContextZoomMode.mobileOnly,
    this.listenForTaps = true,
    this.visible,
  });

  final bool? visible;

  final bool dismissOnOutsideTap;

  final bool listenForTaps;

  final LdContextMenuBlurMode blurMode;
  final LdContextZoomMode zoomMode;

  final Widget Function(BuildContext context, bool isShuttle) builder;

  final Widget Function(BuildContext context, VoidCallback onDismiss)
      menuBuilder;

  @override
  State<LdContextMenu> createState() => _LdContextMenuState();
}

class _LdContextMenuState extends State<LdContextMenu> {
  final GlobalKey _triggerKey = GlobalKey();

  late bool _visible = widget.visible ?? false;

  bool _belowBottom = false;

  bool get _mobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get _shouldBlur {
    return switch (widget.blurMode) {
      (LdContextMenuBlurMode.mobileOnly) => _mobile,
      (LdContextMenuBlurMode.always) => true,
      (LdContextMenuBlurMode.never) => false,
    };
  }

  @override
  didUpdateWidget(LdContextMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != null && widget.visible != oldWidget.visible) {
      setState(() {
        _visible = widget.visible!;
      });
    }
  }

  bool get _shouldZoom {
    return switch (widget.zoomMode) {
      (LdContextZoomMode.mobileOnly) => _mobile,
      (LdContextZoomMode.always) => true,
      (LdContextZoomMode.never) => false,
    };
  }

  void _dismiss() {
    setState(() {
      _visible = false;
    });
  }

  void _open(BuildContext context) {
    final menuPosition =
        ((_triggerKey.currentContext?.findRenderObject() as RenderBox?)
            ?.localToGlobal(Offset.zero));

    if (menuPosition != null &&
        menuPosition.dy > MediaQuery.of(context).size.height / 2) {
      _belowBottom = true;
    } else {
      _belowBottom = false;
    }
    setState(() {
      _visible = true;
    });
  }

  Widget buildTrigger(BuildContext context) {
    return GestureDetector(
      onSecondaryTap: () {
        _open(context);
      },
      onLongPress: () {
        if (!_mobile) {
          return;
        }
        HapticFeedback.heavyImpact();
        _open(context);
      },
      child: widget.builder(context, false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    final zoomShuttle = LdSpring(
      initialPosition: 1,
      position: _visible && _shouldZoom ? 1.1 : 1,
      builder: (context, state) => ConstrainedBox(
        constraints: _triggerKey.currentContext != null
            ? BoxConstraints(
                maxWidth: (_triggerKey.currentContext!.findRenderObject()
                        as RenderBox)
                    .size
                    .width)
            : const BoxConstraints(),
        child: Column(
          children: [
            Transform.scale(
              scale: state.position,
              child: widget.builder(context, true),
            ),
          ],
        ),
      ),
    );

    final menu = LdSpring(
        initialPosition: 0,
        mass: 8,
        springConstant: 15,
        dampingCoefficient: 15,
        position: _visible ? 1 : 0,
        builder: (context, state) {
          return Opacity(
            opacity: state.position.clamp(0, 1),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: LdTheme.of(context).pad(size: LdSize.s),
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border.all(
                  color: theme.border,
                  width: theme.borderWidth,
                ),
                borderRadius: theme.radius(LdSize.s),
                boxShadow: [
                  BoxShadow(
                    color: theme.palette.neutral.shades.last.withAlpha(51),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  )
                ],
              ),
              child: ClipRRect(
                child: Align(
                  alignment: Alignment.topLeft,
                  widthFactor: state.position.clamp(0, double.infinity),
                  heightFactor: state.position.clamp(0, double.infinity),
                  child: widget.menuBuilder(context, _dismiss),
                ),
              ),
            ),
          );
        });

    return PortalTarget(
      visible: _visible,
      // Backdrop
      portalFollower: GestureDetector(
        onTap: () => widget.dismissOnOutsideTap ? _dismiss() : null,
        child: ImplicitBlur(
            sigma: _visible && _shouldBlur ? 10 : 0,
            duration: 300.ms,
            child: Container(
              color: _mobile
                  ? theme.palette.neutral.shades.last.withAlpha(100)
                  : Colors.transparent,
            )),
      ),
      child: PortalTarget(
        key: _triggerKey,
        closeDuration: 300.ms,
        visible: _visible,
        anchor: _belowBottom
            ? const Aligned(
                follower: Alignment.bottomCenter,
                target: Alignment.bottomCenter,
                shiftToWithinBound: AxisFlag(y: true, x: true),
              )
            : const Aligned(
                follower: Alignment.topCenter,
                target: Alignment.topCenter,
                shiftToWithinBound: AxisFlag(y: true, x: true),
              ),
        portalFollower: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _belowBottom
              ? [menu, ldSpacerM, zoomShuttle]
              : [zoomShuttle, ldSpacerM, menu],
        ),

        // Trigger
        child: widget.listenForTaps
            ? buildTrigger(context)
            : widget.builder(context, false),
      ),
    );
  }
}
