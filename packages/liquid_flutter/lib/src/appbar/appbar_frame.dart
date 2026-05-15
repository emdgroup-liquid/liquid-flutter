import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:provider/provider.dart';

class AppBarFrame extends StatefulWidget {
  /// The bar surface content (the visual bar widget).
  final Widget child;

  /// Optional: the subtree that this bar wraps. When provided, [AppBarFrame]
  /// builds a [Stack] layout: the [wrappedChild] fills the background and the
  /// bar surface is pinned to the relevant edge. [MediaQuery.padding] inside
  /// [wrappedChild] is augmented with the bar's [LdAppBarMetrics.consumedInsets].
  ///
  /// When null the legacy scaffold-injection behaviour is used (bar surface
  /// only, no Stack). This keeps the old [LdScaffold.appBars] API compiling
  /// until Stage 3/4 removes it.
  final Widget? wrappedChild;

  final LdAppBarPosition position;

  final BoxDecoration? insideDecoration;
  final BoxDecoration? outsideDecoration;

  /// Optional builders that override [insideDecoration] / [outsideDecoration]
  /// when dynamic decoration based on scroll state is needed (stack mode only).
  final BoxDecoration? Function(bool isScrolledUnder)? insideDecorationBuilder;
  final BoxDecoration? Function(bool isScrolledUnder)? outsideDecorationBuilder;
  final EdgeInsets? insidePadding;
  final EdgeInsets? outsideMinPadding;
  final bool addContainer;
  final bool insetBorderRadius;
  final bool avoidViewInsets;
  final String? debugName;

  /// Scroll-hide behaviour. Only meaningful when [wrappedChild] is provided.
  final LdAppBarScrollBehavior scrollBehavior;

  /// Whether the appbar is attached to the scaffold or floating.
  /// A floating appbar has some margin on the outside and padding on the inside.
  /// An attached appbar has no margin on the outside and padding on the inside.
  final bool attached;

  const AppBarFrame({
    super.key,
    required this.child,
    required this.position,
    this.wrappedChild,
    this.attached = true,
    this.addContainer = false,
    this.insideDecoration,
    this.outsideDecoration,
    this.insideDecorationBuilder,
    this.outsideDecorationBuilder,
    this.avoidViewInsets = false,
    this.insetBorderRadius = true,
    this.insidePadding,
    this.outsideMinPadding,
    this.debugName,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
  });

  @override
  State<AppBarFrame> createState() => _AppBarFrameState();
}

class _AppBarFrameState extends State<AppBarFrame> {
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  // ── Stack-mode state ──────────────────────────────────────────────────────

  /// Measured height of the bar surface (pixels).
  double _barHeight = 0.0;

  /// Scroll-hide offset (0 = fully visible, _barHeight = fully hidden).
  double _hideOffset = 0.0;

  /// Last scroll offset used to compute delta.
  double _lastScrollOffset = 0.0;

  /// Whether scrollable content has moved under the bar.
  bool _isScrolledUnder = false;

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
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  double _calculateOtherAppBarHeight(LdAppBarPosition position) {
    // Read from outer MediaQuery padding (already accumulated
    // by ancestor AppBarFrame instances) — no registry walk needed.
    final outerPadding = MediaQuery.paddingOf(context);
    return widget.position == LdAppBarPosition.top ? outerPadding.top : outerPadding.bottom;
  }

  int _calculateLevel() {
    // Read from parent LdAppBarMetrics provider.
    final parentMetrics = context.watch<LdAppBarMetrics?>();
    if (parentMetrics == null) return 0;
    return parentMetrics.position == widget.position ? parentMetrics.level + 1 : 0;
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
        ? EdgeInsets.only(top: viewPadding.top, left: viewPadding.left, right: viewPadding.right)
        : EdgeInsets.only(bottom: viewPadding.bottom, left: viewPadding.left, right: viewPadding.right);

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
    // Stack-mode: store height locally; metrics are exposed via Provider.
    if (_barHeight != size.height) {
      setState(() => _barHeight = size.height);
    }
  }

  // ── Scroll-hide logic ────────────────────────────────────────────────────

  bool _shouldHideAppBar() {
    final isMobile = LdTheme.of(context).platform.isMobile;
    return switch (widget.scrollBehavior) {
      LdAppBarScrollBehavior.static => false,
      LdAppBarScrollBehavior.mobileOnly => isMobile,
      LdAppBarScrollBehavior.always => true,
    };
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (!_shouldHideAppBar()) return;

    final scrollOffset = notification.metrics.pixels;
    final scrollDelta = scrollOffset - _lastScrollOffset;

    final isScrollingDown = scrollDelta > 0 && scrollOffset > 100;
    final isScrollingUp = scrollDelta < 0;
    final isScrolledUnder = scrollOffset > 10;

    final maxOffset = _barHeight;

    double newHideOffset;
    if (isScrollingDown) {
      newHideOffset = min(_hideOffset + scrollDelta * 0.5, maxOffset);
    } else if (isScrollingUp) {
      newHideOffset = max(_hideOffset + scrollDelta, 0);
    } else {
      newHideOffset = _hideOffset;
    }

    _lastScrollOffset = scrollOffset;

    if (newHideOffset != _hideOffset || isScrolledUnder != _isScrolledUnder) {
      setState(() {
        _hideOffset = newHideOffset;
        _isScrolledUnder = isScrolledUnder;
      });
    }
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  /// The bar surface widget (padding + decorations + child content).
  Widget _buildBarSurface(BoxConstraints constraints) {
    final outsideDeco = widget.outsideDecorationBuilder != null
        ? widget.outsideDecorationBuilder!(_isScrolledUnder)
        : widget.outsideDecoration;
    final insideDeco = widget.insideDecorationBuilder != null
        ? widget.insideDecorationBuilder!(_isScrolledUnder)
        : widget.insideDecoration;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: _outsideContainerPadding(constraints),
      decoration: outsideDeco,
      // Only clip when there is a decoration; Container asserts if clipBehavior
      // is non-none but decoration is null.
      clipBehavior: outsideDeco != null ? Clip.hardEdge : Clip.none,
      key: Key("appbar_frame_outside_${widget.position.name}"),
      child: MeasureSize(
        onSizeChange: _onSizeChange,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: insideDeco,
          padding: _insidePadding(constraints),
          clipBehavior: insideDeco != null ? Clip.hardEdge : Clip.none,
          key: Key("appbar_frame_inside_${widget.position.name}"),
          child: widget.child,
        ),
      ),
    );
  }

  // ── Stack-mode build ──────────────────────────────────────────────────────

  Widget _buildStackMode(BuildContext context) {
    // Edge margin: the system inset on the bar's edge (e.g. top safe-area for a
    // top bar). We read this from the *outer* MediaQuery (before we patch it).
    final outerPadding = MediaQuery.paddingOf(context);
    final edgeMargin = widget.position == LdAppBarPosition.top ? outerPadding.top : outerPadding.bottom;

    final level = _calculateLevel();

    final currentMetrics = LdAppBarMetrics(
      position: widget.position,
      barHeight: _barHeight,
      edgeMargin: edgeMargin,
      hideOffset: _hideOffset,
      isScrolledUnder: _isScrolledUnder,
      level: level,
    );

    final consumedInsets = currentMetrics.consumedInsets;

    // Patch MediaQuery for the subtree: add our consumed insets to the existing
    // outer padding (additive 4-directional merge).
    final patchedPadding = EdgeInsets.only(
      top: outerPadding.top + consumedInsets.top,
      bottom: outerPadding.bottom + consumedInsets.bottom,
      left: outerPadding.left + consumedInsets.left,
      right: outerPadding.right + consumedInsets.right,
    );

    final outerMediaQuery = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hideOffset = _hideOffset;
        final translateY = widget.position == LdAppBarPosition.top ? -hideOffset : hideOffset;

        final barPositioned = Positioned(
          top: widget.position == LdAppBarPosition.top ? 0 : null,
          bottom: widget.position == LdAppBarPosition.bottom ? 0 : null,
          left: 0,
          right: 0,
          // Also expose metrics to the bar surface so the bar content can
          // read isScrolledUnder / level for decoration and button logic.
          child: Provider<LdAppBarMetrics>.value(
            value: currentMetrics,
            child: Transform.translate(
              offset: Offset(0, translateY),
              child: _buildBarSurface(constraints),
            ),
          ),
        );

        final wrappedChild = widget.wrappedChild;
        if (wrappedChild == null) {
          // Bar-only mode: just render the bar surface with metrics exposed.
          return Provider<LdAppBarMetrics>.value(
            value: currentMetrics,
            child: _buildBarSurface(constraints),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _handleScrollNotification(notification);
            return false; // allow bubble
          },
          child: Stack(
            children: [
              // The wrapped subtree fills the stack; MediaQuery is patched so
              // descendants know the bar's consumed space.
              Positioned.fill(
                child: MediaQuery(
                  data: outerMediaQuery.copyWith(
                    padding: patchedPadding,
                  ),
                  child: Provider<LdAppBarMetrics>.value(
                    value: currentMetrics,
                    child: wrappedChild,
                  ),
                ),
              ),
              // The bar surface sits on top, pinned to its edge.
              barPositioned,
            ],
          ),
        );
      },
    );
  }

  // ── Main build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return _buildStackMode(context);
  }
}
