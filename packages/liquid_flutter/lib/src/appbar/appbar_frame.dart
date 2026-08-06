import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_decoration.dart';
import 'package:liquid_flutter/src/appbar/appbar_scrolled_under.dart';
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

  /// The subtree that this bar wraps. [AppBarFrame] builds a [Stack] layout:
  /// [wrappedChild] fills the background and the bar surface is pinned to the
  /// relevant edge.
  final Widget wrappedChild;

  final LdAppBarPosition position;

  final BoxDecoration? insideDecoration;
  final BoxDecoration? outsideDecoration;

  /// Optional builders that override [insideDecoration] / [outsideDecoration]
  /// when dynamic decoration based on scroll state is needed.
  final BoxDecoration? Function(bool isScrolledUnder)? insideDecorationBuilder;
  final BoxDecoration? Function(bool isScrolledUnder)? outsideDecorationBuilder;

  final EdgeInsets? insidePadding;
  final EdgeInsets? outsideMinPadding;

  /// Additional padding to apply to the outside of the app bar. This is not merged into other
  /// insets but is always applied in addition.
  final EdgeInsets? outsideAdditionalPadding;
  final bool addContainer;
  final bool insetBorderRadius;
  final bool avoidViewInsets;

  /// Tracks focus inside the bar surface for keyboard/view-inset padding.
  ///
  /// When omitted, [AppBarFrame] creates and owns an internal scope. When
  /// provided (e.g. by [LdAppBarWidget]), the caller owns disposal.
  final FocusScopeNode? focusScopeNode;

  final String? debugName;

  /// Scroll-hide behaviour for this bar.
  final LdAppBarScrollBehavior scrollBehavior;

  /// Whether the appbar is attached to the scaffold or floating.
  final bool attached;

  /// When true, metrics from this frame are tagged as tab navigation chrome.
  final bool isTabNavigation;

  /// The scrim color
  final Color? scrimColor;

  const AppBarFrame({
    super.key,
    required this.child,
    required this.position,
    required this.wrappedChild,
    this.attached = true,
    this.addContainer = false,
    this.insideDecoration,
    this.outsideDecoration,
    this.outsideAdditionalPadding,
    this.insideDecorationBuilder,
    this.outsideDecorationBuilder,
    this.avoidViewInsets = false,
    this.focusScopeNode,
    this.insetBorderRadius = true,
    this.insidePadding,
    this.outsideMinPadding,
    this.debugName,
    this.scrimColor,
    this.scrollBehavior = LdAppBarScrollBehavior.static,
    this.isTabNavigation = false,
  });

  @override
  State<AppBarFrame> createState() => _AppBarFrameState();
}

/// Momentum scroll velocity (px/s) below which the app bar triggers an early
/// position snap during the fling deceleration phase.
///
/// On iOS, [ScrollEndNotification] fires only after [BouncingScrollPhysics]
/// has fully dissipated the fling, which can take several seconds. By watching
/// [ScrollUpdateNotification]s that arrive during the momentum phase (finger
/// already lifted, [ScrollUpdateNotification.dragDetails] == null) and snapping
/// once the velocity decays below this threshold, we get a snap that feels
/// natural and immediate without waiting for the physics to fully settle.
///
/// The threshold is intentionally low so the snap fires close to the moment
/// the content visually "slows down" rather than at the very end.
const double _kMomentumSnapVelocityThreshold = 200.0;

class _AppBarFrameState extends State<AppBarFrame> {
  late final FocusScopeNode _focusScopeNode;
  late final bool _ownsFocusScopeNode;

  // ── Scroll-hide state ─────────────────────────────────────────────────────

  /// Measured height of the inner container only (insidePadding + child).
  /// Does NOT include the outer edge padding (safe-area / ancestor offset).
  double _innerHeight = 0.0;

  /// Cached total bar height = outer margin + _innerHeight. Updated each build
  /// so the scroll handler can use it without [BuildContext].
  double _barHeight = 0.0;

  /// Scroll-hide offset (0 = fully visible, _barHeight = fully hidden).
  double _hideOffset = 0.0;

  /// The visual target passed to [LdSpring.position].
  double _visualTarget = 0.0;

  /// When true the spring tracks [_visualTarget] 1:1 (active drag).
  bool _snapOverriding = true;

  /// Live animated position from [LdSpring], updated each spring build.
  double _springLivePosition = 0.0;

  final GlobalKey<LdAppBarScrolledUnderDetectorState> _scrolledUnderDetectorKey =
      GlobalKey<LdAppBarScrolledUnderDetectorState>();

  bool _scrollRebuildScheduled = false;

  /// Incremented when [wrappedChild] changes so stale post-frame rebuilds are ignored.
  int _scrollStateGeneration = 0;

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

  EdgeInsets _effectiveSystemInsets(BuildContext context, LdAppBarMetrics? parentMetrics, BoxConstraints constraints) {
    EdgeInsets systemInsets = EdgeInsets.zero;

    final parentMediaQuery = parentMetrics?.appbarLayerMediaQuery;
    final parrentPadding = parentMediaQuery?.padding;

    final contextMediaQuery = MediaQuery.of(context);
    final contextPadding = contextMediaQuery.padding;

    EdgeInsets effectivePadding = parrentPadding ?? contextPadding;

    if (LdTheme.of(context).platform == LdPlatform.ios) {
      // On iOS we can safely move appbars further down the screen, since we know the system is not drawing
      // over the app bar
      final outerMargin = _ownMargin(constraints, parentMetrics);
      effectivePadding = effectivePadding.copyWith(bottom: max(0, 14 - outerMargin.bottom));
    }

    systemInsets = effectivePadding.trimToAppBarPosition(widget.position);

    if (!widget.attached) {
      systemInsets = systemInsets + LdTheme.of(context).pad(size: LdSize.xs).positionOnly(widget.position);
    }

    return systemInsets;
  }

  BorderRadius _screenRelativeBorderRadius(BuildContext context, EdgeInsets outerPadding) {
    final theme = LdTheme.of(context);
    final innerRadius = theme.screenRadius -
        max(max(outerPadding.left, outerPadding.right), max(outerPadding.top, outerPadding.bottom));

    return BorderRadius.circular(max(innerRadius, theme.radiusSize(LdSize.s)));
  }

  /// Build the EdgeInsets we need to apply to place the app bar such that it is not overlapping
  /// system UI or other app bars.
  EdgeInsets _ownMargin(BoxConstraints constraints, LdAppBarMetrics? parentMetrics) {
    EdgeInsets configuredInsets = EdgeInsets.zero;

    if (widget.addContainer) {
      // The container padding is basically applying a maximum width to the app bar insetting it left/right
      configuredInsets = _containerPadding(constraints);
    }

    if (widget.outsideMinPadding != null) {
      configuredInsets = configuredInsets.atLeast(widget.outsideMinPadding!);
    }

    var result = configuredInsets;

    if (widget.outsideAdditionalPadding != null) {
      result += widget.outsideAdditionalPadding!.trimToAppBarPosition(widget.position);
    }

    return result;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  int _calculateLevel(LdAppBarMetrics? parentMetrics) {
    if (parentMetrics == null) return 0;
    return parentMetrics.position == widget.position ? parentMetrics.level + 1 : parentMetrics.level;
  }

  EdgeInsets _containerPadding(BoxConstraints constraints) {
    if (widget.addContainer) {
      final maxWidth = LdTheme.of(context).sizingConfig.containerMaxWidth;
      return EdgeInsets.symmetric(horizontal: ((constraints.maxWidth - maxWidth) / 2).clamp(0.0, double.infinity));
    }
    return EdgeInsets.zero;
  }

  bool _shouldApplyViewInsets() {
    if (widget.avoidViewInsets) {
      return true;
    }
    return ldAppBarFocusScopeHasInputFocus(_focusScopeNode);
  }

  /// True when [viewInsets] are folded into layout for this bar's edge.
  bool _isHonoringViewInsets(LdAppBarMetrics? parentMetrics) {
    if (!_shouldApplyViewInsets()) {
      return false;
    }
    final effectiveMediaQuery = parentMetrics?.appbarLayerMediaQuery ?? MediaQuery.of(context);
    return effectiveMediaQuery.viewInsets.atPosition(widget.position) > 0;
  }

  EdgeInsets _insidePadding(BoxConstraints constraints) {
    EdgeInsets result = EdgeInsets.zero;
    if (widget.insidePadding != null) {
      result = widget.insidePadding!;
    } else {
      final theme = LdTheme.of(context);
      if (widget.attached) {
        result = theme.pad(size: LdSize.s).atLeast(_containerPadding(constraints));
      } else {
        result = theme.balPad(LdSize.s);
      }
    }
    return result;
  }

  @override
  void didUpdateWidget(AppBarFrame oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollBehavior == LdAppBarScrollBehavior.hidden &&
        widget.scrollBehavior != LdAppBarScrollBehavior.hidden) {
      setState(() {
        _visualTarget = 0;
        _snapOverriding = false;
        _hideOffset = 0;
      });
    }

    if (oldWidget.wrappedChild != widget.wrappedChild) {
      _handleWrappedChildReplaced();
    }
  }

  void _handleWrappedChildReplaced() {
    _invalidateScrollState();

    final wasNotScrolledUnder = _scrolledUnderDetectorKey.currentState?.isScrolledUnder == false;
    final isSafeTopState = widget.position == LdAppBarPosition.top && wasNotScrolledUnder;

    _scrolledUnderDetectorKey.currentState?.handleWrappedChildReplaced();

    if (isSafeTopState) {
      setState(() {
        _visualTarget = 0;
        _snapOverriding = false;
        _hideOffset = 0;
      });
    }
  }

  void _onInnerSizeChange(Size size) {
    if (_innerHeight != size.height) {
      setState(() => _innerHeight = size.height);
    }
  }

  // ── Scroll-hide logic ────────────────────────────────────────────────────

  void _invalidateScrollState() {
    _scrollStateGeneration++;
    _scrollRebuildScheduled = false;
  }

  /// Schedules at most one [setState] per frame for scroll-hide updates.
  ///
  /// Scroll notifications can arrive during layout; field updates happen
  /// synchronously in the handler and the rebuild is deferred to post-frame.
  void _scheduleScrollRebuild() {
    if (_scrollRebuildScheduled) {
      return;
    }
    _scrollRebuildScheduled = true;
    final generation = _scrollStateGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollRebuildScheduled = false;
      if (!mounted || generation != _scrollStateGeneration) {
        return;
      }
      setState(() {});
    });
  }

  void _handleScrollAtTop(ScrollMetricsNotification notification) {
    if (notification.depth != 0) {
      return;
    }
    if (notification.metrics.axis != Axis.vertical) {
      return;
    }

    if (notification.metrics.extentBefore == 0 && _visualTarget != 0) {
      _visualTarget = 0;
      _snapOverriding = false;
      _hideOffset = 0;
      _scheduleScrollRebuild();
    }
  }

  bool _handleAppBarScrollNotification(LdAppBarScrollNotification appbarNotification, LdAppBarMetrics metrics) {
    final notification = appbarNotification.source;

    if (notification.metrics.axis != Axis.vertical) return false;

    final scrollOffset = notification.metrics.pixels;

    if (!widget.scrollBehavior.willHideAppBar(context)) {
      return false;
    }

    if (_isHonoringViewInsets(metrics.parentMetrics)) {
      return false;
    }

    if (notification is ScrollStartNotification) {
      // Resync only when transitioning from spring snap back to drag tracking.
      if (!_snapOverriding) {
        _hideOffset = _springLivePosition;
        _visualTarget = _springLivePosition;
      }
      _snapOverriding = true;
      _scheduleScrollRebuild();
      return false;
    }

    if (notification is ScrollEndNotification) {
      // Snap target is barHeight + 1 so the bar travels 1 extra pixel off-screen,
      // ensuring any bottom border/shadow is fully clipped and not visible.
      final double fullyHiddenTarget = metrics.maximumSize.atPosition(widget.position) + 1;
      double target = _visualTarget;
      if (scrollOffset < 100) {
        target = 0.0;
      } else if (target >
          (metrics.configuredInsets + metrics.innerHeight + metrics.systemInsets + metrics.accumulatedEffectiveSizes)
                  .atPosition(widget.position) /
              2) {
        target = max(target, fullyHiddenTarget);
      } else {
        target = 0.0;
      }
      _hideOffset = target;
      _visualTarget = target;
      _snapOverriding = false;
      _scheduleScrollRebuild();

      return false;
    }

    if (notification is! ScrollUpdateNotification) {
      return false;
    }

    // Ignore overscroll

    if (notification.metrics.outOfRange) {
      return false;
    }

    final scrollDelta = appbarNotification.scrollDelta;

    final scrollingDown = scrollDelta > 0;

    if (scrollingDown && !(metrics.parentMetrics?.ancestorFinishedScrolling(widget.position, scrollingDown) ?? true)) {
      return false;
    }

    final maxOffset = metrics.maximumSize.atPosition(widget.position) + 1;

    // If the remaining scroll extent is less than the remaining hide offset we can apply we should not apply any more scroll delta.
    if (scrollingDown && notification.metrics.extentAfter < maxOffset - metrics.minSize.atPosition(widget.position)) {
      return false;
    }

    double newHideOffset = _hideOffset;

    newHideOffset = _hideOffset + scrollDelta * 0.5;

    newHideOffset = newHideOffset.clamp(0.0, maxOffset);

    if (newHideOffset != _hideOffset) {
      _hideOffset = newHideOffset;
      _visualTarget = newHideOffset;
      _scheduleScrollRebuild();
    }

    // Early momentum snap: once the fling decelerates below the threshold the
    // bar snaps to its final position without waiting for ScrollEndNotification
    // (which fires very late on iOS with BouncingScrollPhysics).
    //
    // Only fires during the momentum phase (dragDetails == null on the source
    // notification), so active finger drags are never interrupted.
    final momentumVelocity = appbarNotification.momentumVelocity;
    final isMomentumPhase = momentumVelocity != 0.0;
    if (isMomentumPhase && momentumVelocity.abs() < _kMomentumSnapVelocityThreshold) {
      final double fullyHiddenTarget = metrics.maximumSize.atPosition(widget.position) + 1;
      final double snapTarget;
      if (scrollOffset < 100) {
        snapTarget = 0.0;
      } else if (_hideOffset >
          (metrics.configuredInsets + metrics.innerHeight + metrics.systemInsets + metrics.accumulatedEffectiveSizes)
                  .atPosition(widget.position) /
              2) {
        snapTarget = fullyHiddenTarget;
      } else {
        snapTarget = 0.0;
      }
      _hideOffset = snapTarget;
      _visualTarget = snapTarget;
      _snapOverriding = false;
      _scheduleScrollRebuild();
    }

    return false;
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  /// The bar surface widget.
  ///
  /// [outerMargin] is the outer padding for this bar's edge:
  /// - For the outermost bar it equals the device safe-area (constant).
  /// - For nested bars it tracks the animated visible height of the parent bar,
  ///   so the surface slides with its ancestor while still respecting the
  ///   device safe-area as a floor.
  ///
  /// [MeasureSize] wraps the inner container so [_innerHeight] captures only
  /// the content height (insidePadding + child). The full bar height is then
  /// outer margin + _innerHeight, which stays stable while the bar hides.
  Widget _buildBarSurface({
    required BuildContext context,
    required BoxConstraints constraints,
    required EdgeInsets outerMargin,
  }) {
    final isScrolledUnder = LdAppBarScrolledUnderScope.of(context);
    var outsideDeco = widget.outsideDecorationBuilder != null
        ? widget.outsideDecorationBuilder!(isScrolledUnder)
        : widget.outsideDecoration;
    final insideDeco = widget.insideDecorationBuilder != null
        ? widget.insideDecorationBuilder!(isScrolledUnder)
        : widget.insideDecoration;

    if (widget.insetBorderRadius && !widget.attached) {
      outsideDeco = outsideDeco?.copyWith(
        borderRadius: _screenRelativeBorderRadius(context, outerMargin),
      );
    }

    return FocusScope(
      node: _focusScopeNode,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        decoration: outsideDeco,
        key: Key("appbar_frame_outside_${widget.position.name}"),
        child: Padding(
          padding: outerMargin.trimToAppBarPosition(widget.position),
          child: MeasureSize(
            onSizeChange: _onInnerSizeChange,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              decoration: insideDeco,
              clipBehavior: insideDeco != null ? Clip.hardEdge : Clip.none,
              key: Key("appbar_frame_inside_${widget.position.name}"),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: _insidePadding(constraints),
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds an [LdAppBarMetrics] that merges this bar's values into the parent
  /// metrics (if any) so every edge accumulates correctly as bars nest.
  LdAppBarMetrics _buildMetrics({
    required BuildContext context,
    required LdAppBarMetrics? parentMetrics,
    required EdgeInsets ownMargin,
    required EdgeInsets scrollOffset,
    required EdgeInsets systemInsets,
  }) {
    return LdAppBarMetrics(
      appbarLayerMediaQuery:
          _buildAppBarMediaQuery(_innerHeight.toEdgeInsetsUsingPosition(widget.position), parentMetrics),
      configuredInsets: ownMargin,
      innerHeight: _innerHeight.toEdgeInsetsUsingPosition(widget.position),
      isScrolledUnder: LdAppBarScrolledUnderScope.of(context),
      isTabNavigation: widget.isTabNavigation,
      level: _calculateLevel(parentMetrics),
      parentMetrics: parentMetrics,
      position: widget.position,
      scrollBehavior: widget.scrollBehavior,
      scrollOffset: scrollOffset,
      systemInsets: systemInsets,
      willHide: widget.scrollBehavior.willHideAppBar(context),
    );
  }

  MediaQueryData _buildAppBarMediaQuery(EdgeInsets ownSize, LdAppBarMetrics? parentMetrics) {
    final data = parentMetrics?.appbarLayerMediaQuery ?? MediaQuery.of(context);

    return data;
  }

  MediaQueryData _buildBodyMediaQuery(LdAppBarMetrics metrics) {
    final data = MediaQuery.of(context);

    EdgeInsets viewInsets = data.viewInsets;
    EdgeInsets padding = metrics.bodyPadding.atLeast(data.padding);

    return data.copyWith(
      padding: padding,
      viewInsets: data.viewInsets.atLeast(viewInsets),
    );
  }

  Widget _buildScrim(LdAppBarMetrics metrics, Color scrimColor) {
    var height = (metrics.systemInsets + metrics.configuredInsets).atPosition(widget.position);

    final visiblePortion = (metrics.maximumSize - metrics.scrollOffset).atPosition(widget.position);

    height = visiblePortion.clamp(0.0, max(1, height.toDouble()));

    if (!metrics.willHide) {
      height = 0;
    }

    return Positioned(
        left: 0,
        right: 0,
        top: widget.position == LdAppBarPosition.top ? 0 : null,
        bottom: widget.position == LdAppBarPosition.bottom ? 0 : null,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: switch (widget.position) {
                LdAppBarPosition.top => Alignment.topCenter,
                LdAppBarPosition.bottom => Alignment.bottomCenter,
              },
              end: switch (widget.position) {
                LdAppBarPosition.top => Alignment.bottomCenter,
                LdAppBarPosition.bottom => Alignment.topCenter,
              },
              stops: [0, 0.7, 1],
              colors: [
                scrimColor,
                scrimColor.withAlpha((255 * (0.9)).toInt()),
                scrimColor.withAlpha(0),
              ],
            ),
          ),
        ));
  }

  // ── Main build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final parentMetrics = ldAppBarParentMetrics(context);

    return LayoutBuilder(builder: (context, constraints) {
      final ownMargin = _ownMargin(constraints, parentMetrics);

      var inheritedMargin = (parentMetrics?.accumulatedEffectiveSizes ?? EdgeInsets.zero).inDirection(widget.position);

      var systemInsets = _effectiveSystemInsets(context, parentMetrics, constraints);

      final honoringViewInsets = _isHonoringViewInsets(parentMetrics);
      if (honoringViewInsets) {
        _hideOffset = 0;
        _visualTarget = 0;
        _snapOverriding = false;

        // Appbars that are honoring view insets add themselves to the view insets, so we dont
        // need to account for them in the inherited margin.
        final parentMediaQuery = parentMetrics?.appbarLayerMediaQuery;
        final contextMediaQuery = MediaQuery.of(context);
        final viewInsets = parentMediaQuery?.viewInsets ?? contextMediaQuery.viewInsets;
        inheritedMargin = inheritedMargin.atLeast(
          viewInsets,
        );

        if (viewInsets.vertical > systemInsets.vertical) {
          systemInsets = EdgeInsets.zero;
        }
      }

      var outerMargin = ownMargin + (inheritedMargin + systemInsets);

      outerMargin = outerMargin.atLeast(EdgeInsets.zero);

      _barHeight = switch (widget.position) {
            LdAppBarPosition.top => outerMargin.top,
            LdAppBarPosition.bottom => outerMargin.bottom,
          } +
          _innerHeight;

      if (widget.scrollBehavior == LdAppBarScrollBehavior.hidden) {
        _visualTarget = _barHeight + 1;
        _snapOverriding = false;
        _hideOffset = _barHeight + 1;
      }

      return LdAppBarScrolledUnderDetector(
        key: _scrolledUnderDetectorKey,
        position: widget.position,
        onChanged: (_) => _scheduleScrollRebuild(),
        child: NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            _handleScrollAtTop(notification);
            return false;
          },
          child: LdSpring(
            key: const Key('appbar_snap_spring'),
            position: _visualTarget,
            initialPosition: _visualTarget,
            overriden: _snapOverriding,
            springConstant: 10,
            builder: (springContext, springState, child) {
              _springLivePosition = springState.position;

              final animatedHideOffset = honoringViewInsets ? 0.0 : _springLivePosition;

              final translateY = widget.position == LdAppBarPosition.top ? -animatedHideOffset : animatedHideOffset;

              final scrollOffset = EdgeInsets.only(
                top: widget.position == LdAppBarPosition.top ? animatedHideOffset : 0,
                bottom: widget.position == LdAppBarPosition.bottom ? animatedHideOffset : 0,
              );
              final metrics = _buildMetrics(
                context: springContext,
                parentMetrics: parentMetrics,
                ownMargin: ownMargin,
                systemInsets: systemInsets,
                scrollOffset: scrollOffset,
              );

              return LdAppBarScrollNotifier(
                onAppBarScrollNotification: (notification) {
                  return _handleAppBarScrollNotification(notification, metrics);
                },
                child: Provider<LdAppBarMetrics>.value(
                  value: metrics,
                  child: Stack(
                    children: [
                      MediaQuery(
                        data: _buildBodyMediaQuery(metrics),
                        child: widget.wrappedChild,
                      ),
                      Positioned(
                        top: widget.position == LdAppBarPosition.top ? 0 : null,
                        bottom: widget.position == LdAppBarPosition.bottom ? 0 : null,
                        left: 0,
                        right: 0,
                        child: Transform.translate(
                          offset: Offset(0, translateY),
                          child: _buildBarSurface(
                            context: springContext,
                            constraints: constraints,
                            outerMargin: outerMargin,
                          ),
                        ),
                      ),
                      if (widget.scrimColor != null) _buildScrim(metrics, widget.scrimColor!),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

extension DoubleToEdgeInsets on double {
  EdgeInsets toEdgeInsetsUsingPosition(LdAppBarPosition position) {
    return switch (position) {
      LdAppBarPosition.top => EdgeInsets.only(top: this),
      LdAppBarPosition.bottom => EdgeInsets.only(bottom: this),
    };
  }
}
