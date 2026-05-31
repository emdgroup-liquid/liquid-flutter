import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:provider/provider.dart';

/// Whether [scope] currently contains the primary focus, including inputs in
/// nested scopes (e.g. [LdSearchInput]).
bool ldAppBarFocusScopeHasInputFocus(FocusScopeNode scope) {
  if (scope.hasFocus) {
    return true;
  }
  final primary = FocusManager.instance.primaryFocus;
  if (primary == null) {
    return false;
  }
  for (FocusNode? node = primary; node != null; node = node.parent) {
    if (node == scope) {
      return true;
    }
  }
  return false;
}

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

  /// Tracks focus inside the bar surface for keyboard/view-inset padding.
  ///
  /// When omitted, [AppBarFrame] creates and owns an internal scope. When
  /// provided (e.g. by [LdAppBarWidget]), the caller owns disposal.
  final FocusScopeNode? focusScopeNode;

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
    this.focusScopeNode,
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
  late final FocusScopeNode _focusScopeNode;
  late final bool _ownsFocusScopeNode;

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
  void initState() {
    super.initState();
    _ownsFocusScopeNode = widget.focusScopeNode == null;
    _focusScopeNode = widget.focusScopeNode ?? FocusScopeNode();
    _focusScopeNode.addListener(_handleFocusChange);
    FocusManager.instance.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusScopeNode.removeListener(_handleFocusChange);
    FocusManager.instance.removeListener(_handleFocusChange);
    if (_ownsFocusScopeNode) {
      _focusScopeNode.dispose();
    }
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
  /// The extra padding added on the edge axis for floating bars.
  /// Zero for attached bars. This is the gap between the parent bar (or screen
  /// edge) and the floating bar's visual surface.
  double _floatingEdgeGap(BoxConstraints constraints) {
    if (widget.outsideMinPadding != null) {
      return widget.position == LdAppBarPosition.top
          ? widget.outsideMinPadding!.top
          : widget.outsideMinPadding!.bottom;
    }
    if (widget.attached) return 0.0;
    final theme = LdTheme.of(context);
    final extra = theme.pad(size: LdSize.s).atLeast(_containerPadding(constraints));
    return widget.position == LdAppBarPosition.top ? extra.top : extra.bottom;
  }

  bool _shouldApplyViewInsets() {
    if (widget.avoidViewInsets) {
      return true;
    }
    return ldAppBarFocusScopeHasInputFocus(_focusScopeNode);
  }

  EdgeInsets _outsideContainerPadding(
    BoxConstraints constraints, {
    required double edgeMargin,
    required bool shouldApplyViewInsets,
  }) {
    final theme = LdTheme.of(context);
    final level = _calculateLevel(context.read<LdAppBarMetrics?>());

    final edgePadding = widget.position == LdAppBarPosition.top
        ? EdgeInsets.only(top: edgeMargin)
        : EdgeInsets.only(bottom: edgeMargin);

    // Keyboard inset when bar is focused.
    final viewInsets = shouldApplyViewInsets
        ? MediaQuery.of(context).viewInsets
        : EdgeInsets.zero;
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

    // For floating bars, extra padding is ADDED to the edge margin (not just
    // clamped) so the gap between the parent bar and the floating surface is
    // preserved. For attached bars extraPadding is zero so the + is a no-op.
    final edgePaddingWithExtra = widget.position == LdAppBarPosition.top
        ? edgePadding.copyWith(top: edgePadding.top + extraPadding.top)
        : edgePadding.copyWith(bottom: edgePadding.bottom + extraPadding.bottom);

    EdgeInsets result = edgePaddingWithExtra.atLeast(sideViewPadding).atLeast(extraPadding).atLeast(trimmedViewInsets);
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
      // Snap target is barHeight + 1 so the bar travels 1 extra pixel off-screen,
      // ensuring any bottom border/shadow is fully clipped and not visible.
      final double fullyHiddenTarget = _barHeight + 1;
      final double target;
      if (scrollOffset < 100) {
        target = 0.0;
      } else if (_hideOffset >= _barHeight * 0.5) {
        target = fullyHiddenTarget;
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

      // +1 so the scroll drag can also reach the fully-hidden+1 position,
      // consistent with the snap target above.
      final maxOffset = _barHeight + 1;

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

    final shouldApplyViewInsets = _shouldApplyViewInsets();

    return FocusScope(
      node: _focusScopeNode,
      child: Container(
        padding: _outsideContainerPadding(
          constraints,
          edgeMargin: animatedEdgeMargin,
          shouldApplyViewInsets: shouldApplyViewInsets,
        ),
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
      ),
    );
  }

  // ── Helpers for EdgeInsets-based metrics ─────────────────────────────────

  /// Returns the scalar value from [insets] for [widget.position]'s edge.
  double _edgeValue(EdgeInsets insets) {
    return widget.position == LdAppBarPosition.top ? insets.top : insets.bottom;
  }

  /// Returns a copy of [insets] with this bar's [widget.position] edge set to
  /// [value], leaving the opposite edge unchanged.
  EdgeInsets _withEdge(EdgeInsets insets, double value) {
    return widget.position == LdAppBarPosition.top
        ? insets.copyWith(top: value)
        : insets.copyWith(bottom: value);
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

    final outerMediaQuery = MediaQuery.of(context);

    // animatedEdgeMargin (for bar surface outer padding):
    // For the outermost bar this is constant = stableEdgeMargin (device safe-area).
    // For nested bars we want the live visible height of the parent so the
    // surface stays flush with the parent's bottom edge as it hides.
    // Floor: parentMetrics.edgeMargin (= the parent's own stableEdgeMargin,
    // i.e. the device safe-area portion that must always be preserved).
    //
    // Because barHeight/hideOffset/edgeMargin are now EdgeInsets we can look up
    // the correct edge even when the immediate parent is at the opposite position.
    final parentBarHeight = parentMetrics != null ? _edgeValue(parentMetrics.barHeight) : 0.0;
    final parentHideOffset = parentMetrics != null ? _edgeValue(parentMetrics.hideOffset) : 0.0;
    final parentEdgeMargin = parentMetrics != null ? _edgeValue(parentMetrics.edgeMargin) : 0.0;
    final parentAccumulatedHide =
        parentMetrics != null ? _edgeValue(parentMetrics.accumulatedHideOffset) : 0.0;

    // A "same-position" parent is one where the relevant edge has a non-zero
    // barHeight — meaning an ancestor bar at this edge has already written into
    // the metrics.
    final hasAncestorAtSameEdge = parentBarHeight > 0.0;

    final double animatedEdgeMarginBase;
    if (hasAncestorAtSameEdge) {
      // Use the live visible height of the nearest ancestor at this edge.
      final parentVisibleHeight =
          (parentBarHeight - parentHideOffset).clamp(parentEdgeMargin, double.infinity);
      animatedEdgeMarginBase = parentVisibleHeight;
    } else {
      animatedEdgeMarginBase = stableEdgeMargin;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // floatingEdgeGap: the extra outer padding on the edge axis for floating
        // bars (zero for attached). Must be included in barHeight and stablePadding
        // so nested bars know the true bottom of this bar's outer container.
        final floatingGap = _floatingEdgeGap(constraints);

        // Recalculate barHeight and stablePadding with the floating gap included.
        final barHeightWithGap = stableEdgeMargin + floatingGap + _innerHeight;
        _barHeight = barHeightWithGap;

        final stableIncrementalInsetWithGap = floatingGap + _innerHeight;
        final stablePaddingWithGap = switch (widget.position) {
          LdAppBarPosition.top => outerPadding.copyWith(
              top: outerPadding.top + stableIncrementalInsetWithGap),
          LdAppBarPosition.bottom => outerPadding.copyWith(
              bottom: outerPadding.bottom + stableIncrementalInsetWithGap),
        };

        final wrappedChild = widget.wrappedChild;

        // Legacy mode (no wrappedChild): just render the bar surface.
        if (wrappedChild == null) {
          final barMetrics = _buildMetrics(
            parentMetrics: parentMetrics,
            barHeightWithGap: barHeightWithGap,
            stableEdgeMargin: stableEdgeMargin,
            animatedHideOffset: 0.0,
            parentAccumulatedHide: parentAccumulatedHide,
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
              // Clamp so the spring can neither pull the bar below its resting
              // position (negative = detaches from edge) nor push it past
              // barHeight+1 (the fully-hidden-plus-border-bleed target).
              final animatedHideOffset =
                  springState.position.clamp(0.0, _barHeight + 1);

              // animatedEdgeMargin for the bar surface this frame:
              // same logic as above — use the live visible height of the nearest
              // ancestor at this edge (not accumulated) so we only subtract the
              // nearest ancestor's hide, not grandparent's.
              final double animatedEdgeMargin;
              if (hasAncestorAtSameEdge) {
                final parentVisibleHeight =
                    (parentBarHeight - parentHideOffset).clamp(parentEdgeMargin, double.infinity);
                animatedEdgeMargin = parentVisibleHeight;
              } else {
                animatedEdgeMargin = stableEdgeMargin;
              }

              final animatedMetrics = _buildMetrics(
                parentMetrics: parentMetrics,
                barHeightWithGap: barHeightWithGap,
                stableEdgeMargin: stableEdgeMargin,
                animatedHideOffset: animatedHideOffset,
                parentAccumulatedHide: parentAccumulatedHide,
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
                  data: outerMediaQuery.copyWith(padding: stablePaddingWithGap),
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

  /// Builds an [LdAppBarMetrics] that merges this bar's values into the parent
  /// metrics (if any) so every edge accumulates correctly as bars nest.
  LdAppBarMetrics _buildMetrics({
    required LdAppBarMetrics? parentMetrics,
    required double barHeightWithGap,
    required double stableEdgeMargin,
    required double animatedHideOffset,
    required double parentAccumulatedHide,
    required int level,
  }) {
    final childAccumulatedHide = parentAccumulatedHide + animatedHideOffset;

    // Merge: start from parent's EdgeInsets values (which cover both edges) and
    // overwrite only this bar's edge.  That way the opposite edge's data is
    // preserved and visible to deeper descendants regardless of position mixing.
    final parentBarHeight = parentMetrics?.barHeight ?? EdgeInsets.zero;
    final parentEdgeMarginInsets = parentMetrics?.edgeMargin ?? EdgeInsets.zero;
    final parentHideOffsetInsets = parentMetrics?.hideOffset ?? EdgeInsets.zero;
    final parentAccumulatedInsets = parentMetrics?.accumulatedHideOffset ?? EdgeInsets.zero;

    return LdAppBarMetrics(
      position: widget.position,
      barHeight: _withEdge(parentBarHeight, barHeightWithGap),
      edgeMargin: _withEdge(parentEdgeMarginInsets, stableEdgeMargin),
      hideOffset: _withEdge(parentHideOffsetInsets, animatedHideOffset),
      accumulatedHideOffset: _withEdge(parentAccumulatedInsets, childAccumulatedHide),
      isScrolledUnder: _isScrolledUnder,
      level: level,
    );
  }

  // ── Main build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return _buildStackMode(context);
  }
}
