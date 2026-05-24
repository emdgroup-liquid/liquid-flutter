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
  /// bar surface is pinned to the relevant edge.
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

  /// Measured height of the inner container only (insidePadding + child).
  /// Does NOT include the outer edge padding (safe-area / ancestor offset).
  double _innerHeight = 0.0;

  /// Cached total bar height = stableEdgeMargin + _innerHeight. Updated each
  /// build so the scroll handler can use it for clamping without BuildContext.
  double _barHeight = 0.0;

  /// Scroll-hide offset (0 = fully visible, _barHeight = fully hidden).
  double _hideOffset = 0.0;

  /// The visual target passed to [LdSpring.position].
  double _visualTarget = 0.0;

  /// When true the spring tracks [_visualTarget] 1:1 (active drag).
  bool _snapOverriding = true;

  /// Live animated position from [LdSpring].
  double _springLivePosition = 0.0;

  double _lastScrollOffset = 0.0;
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _calculateLevel(LdAppBarMetrics? parentMetrics) {
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

  /// Outside container padding.
  ///
  /// For the top/bottom edge we use [edgeMargin] (= the currently accumulated
  /// MediaQuery.padding on that edge, already including device safe-area and
  /// all ancestor bars' stable net heights). This is read from the *patched*
  /// MediaQuery provided by ancestor AppBarFrames, so nested bars automatically
  /// sit below their parents without any extra bookkeeping.
  EdgeInsets _outsideContainerPadding(BoxConstraints constraints, {required double edgeMargin}) {
    final theme = LdTheme.of(context);
    final level = _calculateLevel(context.read<LdAppBarMetrics?>());

    final edgePadding = widget.position == LdAppBarPosition.top
        ? EdgeInsets.only(top: edgeMargin)
        : EdgeInsets.only(bottom: edgeMargin);

    // Keyboard inset when bar is focused.
    final viewInsets =
        _focusScopeNode.hasFocus || widget.avoidViewInsets ? MediaQuery.of(context).viewInsets : EdgeInsets.zero;
    final trimmedViewInsets = widget.position == LdAppBarPosition.top
        ? EdgeInsets.only(top: viewInsets.top)
        : EdgeInsets.only(bottom: viewInsets.bottom);

    // Left/right device safe-area (notch sides). viewPaddingOf is not patched by
    // AppBarFrame so it always reflects the true device insets.
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final sideViewPadding = EdgeInsets.only(
      left: viewPadding.left,
      right: viewPadding.right,
    );

    final extraPadding = widget.outsideMinPadding ??
        (widget.attached
            ? EdgeInsets.zero
            : theme.pad(size: LdSize.s).atLeast(
                  _containerPadding(constraints),
                ));

    EdgeInsets result = edgePadding.atLeast(sideViewPadding).atLeast(extraPadding).atLeast(trimmedViewInsets);
    if (level == 0 && widget.insetBorderRadius) {
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

  void _onInnerSizeChange(Size size) {
    if (_innerHeight != size.height) {
      setState(() => _innerHeight = size.height);
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

    if (notification.depth != 0) return;
    if (notification.metrics.axis != Axis.vertical) return;

    final scrollOffset = notification.metrics.pixels;
    final isScrolledUnder = scrollOffset > 10;

    if (notification is ScrollStartNotification) {
      _lastScrollOffset = scrollOffset;
      setState(() {
        _hideOffset = _springLivePosition;
        _visualTarget = _springLivePosition;
        _snapOverriding = true;
        _isScrolledUnder = isScrolledUnder;
      });
      return;
    }

    if (notification is ScrollEndNotification) {
      final double target;
      if (scrollOffset < 100) {
        target = 0.0;
      } else if (_hideOffset >= _barHeight * 0.5) {
        target = _barHeight;
      } else {
        target = 0.0;
      }

      setState(() {
        _hideOffset = target;
        _visualTarget = target;
        _snapOverriding = false;
        _isScrolledUnder = isScrolledUnder;
      });
      return;
    }

    if (notification is ScrollUpdateNotification) {
      final scrollDelta = scrollOffset - _lastScrollOffset;

      final isScrollingDown = scrollDelta > 0 && scrollOffset > 100;
      final isScrollingUp = scrollDelta < 0;

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
          _visualTarget = newHideOffset;
          _isScrolledUnder = isScrolledUnder;
        });
      }
    }
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  /// The bar surface widget.
  ///
  /// [animatedEdgeMargin] is the live outer padding for this bar's edge:
  /// - For the outermost bar it equals the device safe-area (constant).
  /// - For nested bars it tracks the animated visible height of the parent bar,
  ///   so the surface slides with its ancestor while still respecting the
  ///   device safe-area as a floor.
  ///
  /// MeasureSize wraps the **inner** container so [_innerHeight] captures only
  /// the content height (insidePadding + child). The full bar height is then
  /// stableEdgeMargin + _innerHeight, which never changes while the bar hides.
  Widget _buildBarSurface(
    BoxConstraints constraints, {
    required double animatedEdgeMargin,
  }) {
    final outsideDeco = widget.outsideDecorationBuilder != null
        ? widget.outsideDecorationBuilder!(_isScrolledUnder)
        : widget.outsideDecoration;
    final insideDeco = widget.insideDecorationBuilder != null
        ? widget.insideDecorationBuilder!(_isScrolledUnder)
        : widget.insideDecoration;

    return Container(
      padding: _outsideContainerPadding(constraints, edgeMargin: animatedEdgeMargin),
      decoration: outsideDeco,
      clipBehavior: outsideDeco != null ? Clip.hardEdge : Clip.none,
      key: Key("appbar_frame_outside_${widget.position.name}"),
      child: MeasureSize(
        onSizeChange: _onInnerSizeChange,
        child: Container(
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
    // Read (watch) parent metrics so nested bars rebuild when the parent hides.
    final parentMetrics = context.watch<LdAppBarMetrics?>();
    final level = _calculateLevel(parentMetrics);

    // stableEdgeMargin: the accumulated padding on this edge from the *patched*
    // (stable) MediaQuery injected by ancestor AppBarFrames. For the outermost
    // bar this equals the raw device safe-area; for nested bars it equals the
    // device safe-area + sum of all ancestor inner heights. It never shrinks
    // while bars are hiding.
    final outerPadding = MediaQuery.paddingOf(context);
    final stableEdgeMargin = widget.position == LdAppBarPosition.top ? outerPadding.top : outerPadding.bottom;

    // barHeight = stableEdgeMargin + inner content height.
    // Using _innerHeight (measured from inner container only) keeps barHeight
    // stable while the outer padding animates. Cached in _barHeight so the
    // scroll handler can use it without a BuildContext.
    final barHeight = stableEdgeMargin + _innerHeight;
    _barHeight = barHeight;

    // Stable padding patch for the body subtree.
    //
    // stableIncrementalInset = _innerHeight (own inner content height).
    // We add this on top of the existing stableEdgeMargin so LdScaffoldBody's
    //   padding.atLeast(viewPadding)
    // produces a scroll-content floor that never shifts while this bar hides.
    final stableIncrementalInset = _innerHeight;
    final stablePadding = switch (widget.position) {
      LdAppBarPosition.top =>
        outerPadding.copyWith(top: outerPadding.top + stableIncrementalInset),
      LdAppBarPosition.bottom =>
        outerPadding.copyWith(bottom: outerPadding.bottom + stableIncrementalInset),
    };

    final outerMediaQuery = MediaQuery.of(context);

    // animatedEdgeMargin (for bar surface outer padding):
    // For the outermost bar this is constant = stableEdgeMargin (device safe-area).
    // For nested bars we want the live visible height of the parent so the
    // surface stays flush with the parent's bottom edge as it hides.
    // Floor: parentMetrics.edgeMargin (= the parent's own stableEdgeMargin,
    // i.e. the device safe-area portion that must always be preserved).
    final parentAtSamePositionGlobal =
        parentMetrics != null && parentMetrics.position == widget.position;
    final double animatedEdgeMarginBase;
    if (parentAtSamePositionGlobal) {
      // parentMetrics.hideOffset is the parent bar's own animated hide (0=visible,
      // barHeight=fully hidden). Subtract only this to get the parent's visible height.
      final parentVisibleHeight = (parentMetrics!.barHeight - parentMetrics.hideOffset)
          .clamp(parentMetrics.edgeMargin, double.infinity);
      animatedEdgeMarginBase = parentVisibleHeight;
    } else {
      animatedEdgeMarginBase = stableEdgeMargin;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wrappedChild = widget.wrappedChild;

        // Legacy mode (no wrappedChild): just render the bar surface.
        if (wrappedChild == null) {
          final parentAccumulatedHide =
              parentAtSamePositionGlobal ? parentMetrics!.accumulatedHideOffset : 0.0;
          final barMetrics = LdAppBarMetrics(
            position: widget.position,
            barHeight: barHeight,
            edgeMargin: stableEdgeMargin,
            hideOffset: 0.0,
            accumulatedHideOffset: parentAccumulatedHide,
            isScrolledUnder: _isScrolledUnder,
            level: level,
          );
          return Provider<LdAppBarMetrics>.value(
            value: barMetrics,
            child: _buildBarSurface(constraints, animatedEdgeMargin: animatedEdgeMarginBase),
          );
        }

        // Stack mode.
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _handleScrollNotification(notification);
            return false;
          },
          child: LdSpring(
            key: const Key('appbar_snap_spring'),
            position: _visualTarget,
            initialPosition: _hideOffset,
            overriden: _snapOverriding,
            builder: (springContext, springState, child) {
              _springLivePosition = springState.position;
              final animatedHideOffset = springState.position;

              // The cumulative hide offset for children of this bar:
              // = parent's accumulatedHideOffset + this bar's own hideOffset.
              // This lets nested bars add the right translation to follow
              // all ancestors as they hide.
              final parentAccumulatedHide =
                  parentAtSamePositionGlobal ? parentMetrics!.accumulatedHideOffset : 0.0;
              final childAccumulatedHide = parentAccumulatedHide + animatedHideOffset;

              // animatedEdgeMargin for the bar surface this frame:
              // same logic as above — use parent's own hideOffset (not accumulated)
              // so we only subtract the parent's own hide, not grandparent's.
              final double animatedEdgeMargin;
              if (parentAtSamePositionGlobal) {
                final parentVisibleHeight =
                    (parentMetrics!.barHeight - parentMetrics.hideOffset)
                        .clamp(parentMetrics.edgeMargin, double.infinity);
                animatedEdgeMargin = parentVisibleHeight;
              } else {
                animatedEdgeMargin = stableEdgeMargin;
              }

              final animatedMetrics = LdAppBarMetrics(
                position: widget.position,
                barHeight: barHeight,
                edgeMargin: stableEdgeMargin,
                hideOffset: animatedHideOffset,
                accumulatedHideOffset: childAccumulatedHide,
                isScrolledUnder: _isScrolledUnder,
                level: level,
              );

              // Translation: slide the bar surface off-screen by its OWN hide only.
              // Tracking the parent bar's position is handled by animatedEdgeMargin
              // (the outer padding shrinks as the parent hides), so we must NOT add
              // parentAccumulatedHide here — that would double-count the parent's hide.
              final translateY =
                  widget.position == LdAppBarPosition.top ? -animatedHideOffset : animatedHideOffset;

              // Body subtree: MediaQuery.padding is patched with the stable
              // floor (never shrinks). The provider carries animatedMetrics
              // so child bars and other consumers see live hideOffset/barHeight.
              final bodySubtree = Positioned.fill(
                child: MediaQuery(
                  data: outerMediaQuery.copyWith(padding: stablePadding),
                  child: Provider<LdAppBarMetrics>.value(
                    value: animatedMetrics,
                    child: wrappedChild,
                  ),
                ),
              );

              return Stack(
                children: [
                  bodySubtree,
                  Positioned(
                    top: widget.position == LdAppBarPosition.top ? 0 : null,
                    bottom: widget.position == LdAppBarPosition.bottom ? 0 : null,
                    left: 0,
                    right: 0,
                    child: Provider<LdAppBarMetrics>.value(
                      value: animatedMetrics,
                      child: Transform.translate(
                        offset: Offset(0, translateY),
                        child: _buildBarSurface(constraints, animatedEdgeMargin: animatedEdgeMargin),
                      ),
                    ),
                  ),
                ],
              );
            },
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
