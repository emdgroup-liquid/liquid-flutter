import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/notifications/notifications_controller.dart';
import 'package:liquid_flutter/src/text.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:liquid_flutter/src/tokens.dart';
import 'package:liquid_flutter/src/windowing.dart';
import 'package:provider/provider.dart';

/// A tooltip that uses a real native tooltip window on supported desktop
/// platforms and falls back to [Tooltip] everywhere else.
///
/// The native window is positioned by the operating system, so it can extend
/// beyond the bounds of the parent window and cannot receive keyboard focus.
/// On mobile, web, or when windowing is disabled, this widget is a drop-in
/// replacement for [Tooltip].
class LdTooltip extends StatefulWidget {
  const LdTooltip({
    super.key,
    required this.message,
    required this.child,
    this.windowMode = LdWindowMode.auto,
    this.preferBelow = true,
    this.waitDuration = const Duration(milliseconds: 0),
    this.showDuration = const Duration(milliseconds: 1500),
    this.excludeFromSemantics = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  /// The text shown in the tooltip.
  final String message;

  /// The widget that triggers the tooltip.
  final Widget child;

  /// Whether a native window may be used.
  final LdWindowMode windowMode;

  /// Whether the tooltip should prefer to appear below its anchor.
  final bool preferBelow;

  /// How long the pointer must hover before the tooltip appears.
  final Duration waitDuration;

  /// How long the fallback Material tooltip stays visible for non-hover
  /// triggers.
  final Duration showDuration;

  /// Whether the fallback tooltip should be excluded from semantics.
  final bool excludeFromSemantics;

  /// Padding around the text in the native tooltip window.
  final EdgeInsets padding;

  @override
  State<LdTooltip> createState() => _LdTooltipState();
}

class _LdTooltipState extends State<LdTooltip> {
  final GlobalKey _anchorKey = GlobalKey(debugLabel: 'LdTooltip anchor');
  LdWindowHandle? _handle;
  LdWindowAnchorTracker? _tracker;
  Timer? _timer;
  bool _pointerInside = false;

  LdWindowingAdapter? get _adapter {
    if (widget.windowMode == LdWindowMode.disabled) {
      return null;
    }
    return LdWindowingScope.maybeAdapter(context);
  }

  @override
  void didUpdateWidget(covariant LdTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message && _handle != null) {
      _hide();
    }
    if (oldWidget.windowMode != widget.windowMode && widget.windowMode == LdWindowMode.disabled) {
      _hide();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tracker?.dispose();
    _handle?.close();
    super.dispose();
  }

  void _onEnter(PointerEnterEvent event) {
    _pointerInside = true;
    if (_handle != null) {
      return;
    }
    _timer?.cancel();
    _timer = Timer(widget.waitDuration, () {
      if (!mounted || !_pointerInside) {
        return;
      }
      _show();
    });
  }

  void _onExit(PointerExitEvent event) {
    _pointerInside = false;
    _timer?.cancel();
    _hide();
  }

  void _show() {
    final adapter = _adapter;
    if (adapter == null) {
      return;
    }
    final anchor = _anchorRect();
    if (anchor == null) {
      return;
    }

    final notifications = LdNotificationsController.maybeOf(context);
    final handle = adapter.showTooltip(
      context: context,
      anchorRect: anchor,
      position: LdWindowPosition(
        above: !widget.preferBelow,
        align: LdWindowAlign.center,
        offset: Offset(0, widget.preferBelow ? 4 : -4),
      ),
      constraints: const BoxConstraints(maxWidth: 360),
      providers: [
        ListenableProvider<LdTheme>.value(value: LdTheme.of(context)),
        if (notifications != null)
          ListenableProvider<LdNotificationsController>.value(
            value: notifications,
          ),
      ],
      builder: _buildWindowContent,
    );

    if (handle == null) {
      return;
    }

    setState(() {
      _handle = handle;
    });
    _tracker = LdWindowAnchorTracker(
      target: _anchorKey,
      onChanged: handle.updateAnchor,
    );
    unawaited(
      handle.closed.then((_) {
        if (mounted) {
          _hide();
        }
      }),
    );
  }

  void _hide() {
    _timer?.cancel();
    _tracker?.dispose();
    _tracker = null;
    final handle = _handle;
    if (handle != null) {
      _handle = null;
      handle.close();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Rect? _anchorRect() {
    final renderObject = _anchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    return MatrixUtils.transformRect(
      renderObject.getTransformTo(null),
      Offset.zero & renderObject.size,
    );
  }

  Widget _buildWindowContent(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: theme.radius(LdSize.s),
        border: Border.all(
          color: theme.floatingBorder,
          width: theme.borderWidth,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(32),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LdText(widget.message, size: LdSize.s, maxLines: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNative = _adapter != null;
    if (!isNative) {
      return Tooltip(
        message: widget.message,
        preferBelow: widget.preferBelow,
        waitDuration: widget.waitDuration,
        showDuration: widget.showDuration,
        excludeFromSemantics: widget.excludeFromSemantics,
        child: widget.child,
      );
    }

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _hide(),
        child: Semantics(
          tooltip: widget.excludeFromSemantics ? null : widget.message,
          child: KeyedSubtree(key: _anchorKey, child: widget.child),
        ),
      ),
    );
  }
}
