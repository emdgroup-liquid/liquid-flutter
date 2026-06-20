import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_decoration.dart';
import 'package:liquid_flutter/src/haptics.dart';
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
  final Widget wrappedChild;

  final LdAppBarPosition position;

  final BoxDecoration? insideDecoration;
  final BoxDecoration? outsideDecoration;

  /// Optional builders that override [insideDecoration] / [outsideDecoration]
  /// when dynamic decoration based on scroll state is needed (stack mode only).
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

  /// Scroll-hide behaviour. Only meaningful when [wrappedChild] is provided.
  final LdAppBarScrollBehavior scrollBehavior;

  /// Whether the appbar is attached to the scaffold or floating.
  final bool attached;

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
    this.scrollBehavior = LdAppBarScrollBehavior.static,
  });

  @override
  State<AppBarFrame> createState() => _AppBarFrameState();
}

class _AppBarFrameState extends State<AppBarFrame> {
  late final FocusScopeNode _focusScopeNode;
  late final bool _ownsFocusScopeNode;

  EdgeInsets _lastOuterMargin = EdgeInsets.zero;

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

  EdgeInsets _effectiveSystemInsets(BuildContext context, LdAppBarMetrics? parentMetrics) {
    EdgeInsets systemInsets = EdgeInsets.zero;
    MediaQueryData effectiveMediaQuery = parentMetrics?.appbarLayerMediaQuery ?? MediaQuery.of(context);
    systemInsets = effectiveMediaQuery.viewPadding;
    if (_shouldApplyViewInsets()) {
      systemInsets = systemInsets.atLeast(effectiveMediaQuery.viewInsets);
    }

    if (widget.insetBorderRadius) {
      final theme = LdTheme.of(context);

      systemInsets =
          systemInsets.atLeast(EdgeInsets.symmetric(horizontal: (theme.screenRadius) / 2 - systemInsets.left));
    }

    return systemInsets;
  }

  /// Build the EdgeInsets we need to apply to place the app bar such that it is not overlapping
  /// system UI or other app bars.
  EdgeInsets _ownMargin(BuildContext context, LdAppBarMetrics? parentMetrics, BoxConstraints constraints) {
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
      result += widget.outsideAdditionalPadding!;
    }

    return result;
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

  bool _shouldApplyViewInsets() {
    if (widget.avoidViewInsets) {
      return true;
    }
    return ldAppBarFocusScopeHasInputFocus(_focusScopeNode);
  }

  EdgeInsets _insidePadding(BoxConstraints constraints) {
    EdgeInsets result = EdgeInsets.zero;
    if (widget.insidePadding != null) {
      result = widget.insidePadding!;
    }
    final theme = LdTheme.of(context);
    if (widget.attached) {
      result = theme.pad(size: LdSize.s).atLeast(_containerPadding(constraints));
    } else {
      result = theme.pad(size: LdSize.s);
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
      LdAppBarScrollBehavior.hidden => false,
    };
  }

  void _handleScrollNotification(ScrollMetricsNotification notification, BoxConstraints constraints) {
    if (notification.depth != 0) return;
    if (notification.metrics.axis != Axis.vertical) return;

    final metrics = notification.metrics;

    final isScrolledUnder = switch (widget.position) {
      LdAppBarPosition.top => metrics.extentBefore > 0,
      LdAppBarPosition.bottom => metrics.extentAfter > 0,
    };

    if (metrics.extentBefore == 0 && _visualTarget != 0) {
      setState(() {
        _visualTarget = 0;
        _snapOverriding = false;
        _hideOffset = 0;
      });
    }

    if (isScrolledUnder != _isScrolledUnder) {
      setState(() => _isScrolledUnder = isScrolledUnder);
    }
  }

  bool _handleAppBarScrollNotification(LdAppBarScrollNotification appbarNotification, LdAppBarMetrics metrics) {
    final notification = appbarNotification.source;

    if (notification.depth != 0) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    final scrollOffset = notification.metrics.pixels;

    if (!_shouldHideAppBar()) {
      return false;
    }

    if (notification is ScrollStartNotification) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _hideOffset = _springLivePosition;
          //_visualTarget = _springLivePosition;
          _snapOverriding = true;
        });
      });
      return false;
    }

    if (notification is ScrollEndNotification) {
      // Snap target is barHeight + 1 so the bar travels 1 extra pixel off-screen,
      // ensuring any bottom border/shadow is fully clipped and not visible.
      final double fullyHiddenTarget = metrics.maximumSize.atPosition(widget.position);
      double target = _visualTarget;
      if (scrollOffset < 100) {
        target = 0.0;
      }
      if (target >
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

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });

      return false;
    }

    // Ignore overscroll
    if (scrollOffset < 0) {
      return false;
    }

    final scrollDelta = appbarNotification.scrollDelta;

    final scrollingDown = scrollDelta > 0;

    if (scrollingDown && !(metrics.parentMetrics?.ancestorFinishedScrolling(widget.position, scrollingDown) ?? true)) {
      return false;
    }

    // +1 so the scroll drag can also reach the fully-hidden+1 position,
    // consistent with the snap target above.
    final maxOffset = metrics.maximumSize.atPosition(widget.position);

    double newHideOffset = _hideOffset;

    newHideOffset = _hideOffset + scrollDelta * 0.5;

    newHideOffset = newHideOffset.clamp(0.0, maxOffset);

    if (newHideOffset != _hideOffset) {
      _hideOffset = newHideOffset;
      _visualTarget = newHideOffset;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {});
      });
    }

    // Return true to prevent bubbling
    return false;
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
  Widget _buildBarSurface({
    required BoxConstraints constraints,
    required LdAppBarMetrics? parentMetrics,
    required EdgeInsets outerMargin,
  }) {
    final outsideDeco = widget.outsideDecorationBuilder != null
        ? widget.outsideDecorationBuilder!(_isScrolledUnder)
        : widget.outsideDecoration;
    final insideDeco = widget.insideDecorationBuilder != null
        ? widget.insideDecorationBuilder!(_isScrolledUnder)
        : widget.insideDecoration;

    final theme = LdTheme.of(context);

    return FocusScope(
      node: _focusScopeNode,
      child: Container(
        padding: outerMargin.trimToAppBarPosition(widget.position),
        decoration: outsideDeco,
        key: Key("appbar_frame_outside_${widget.position.name}"),
        child: Provider.value(
          value: LdSurfaceInfo(isSurface: outsideDeco?.color == theme.surface),
          child: MeasureSize(
            onSizeChange: _onInnerSizeChange,
            child: Container(
              decoration: insideDeco,
              clipBehavior: insideDeco != null ? Clip.hardEdge : Clip.none,
              key: Key("appbar_frame_inside_${widget.position.name}"),
              child: Provider.value(
                value: LdSurfaceInfo(
                    isSurface: insideDeco?.color == theme.surface ||
                        (outsideDeco?.color == theme.surface && insideDeco?.color == null)),
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
      ),
    );
  }

  /// Builds an [LdAppBarMetrics] that merges this bar's values into the parent
  /// metrics (if any) so every edge accumulates correctly as bars nest.
  LdAppBarMetrics _buildMetrics({
    required LdAppBarMetrics? parentMetrics,
    required EdgeInsets ownMargin,
    required EdgeInsets scrollOffset,
    required EdgeInsets inheritedMargin,
    required EdgeInsets systemInsets,
  }) {
    return LdAppBarMetrics(
      appbarLayerMediaQuery: _buildAppBarMediaQuery(),
      configuredInsets: ownMargin,
      innerHeight: _innerHeight.toEdgeInsetsUsingPosition(widget.position),
      isScrolledUnder: _isScrolledUnder,
      level: _calculateLevel(parentMetrics),
      parentMetrics: parentMetrics,
      position: widget.position,
      scrollBehavior: widget.scrollBehavior,
      scrollOffset: scrollOffset,
      systemInsets: systemInsets,
      willHide: _shouldHideAppBar(),
    );
  }

  MediaQueryData _buildAppBarMediaQuery() {
    final data = MediaQuery.of(context);

    if (_shouldApplyViewInsets()) {
      return data.copyWith(
        viewInsets: data.viewInsets + _barHeight.toEdgeInsetsUsingPosition(widget.position),
      );
    }

    return data;
  }

  MediaQueryData _buildBodyMediaQuery(LdAppBarMetrics metrics) {
    final data = MediaQuery.of(context);

    EdgeInsets viewInsets = data.viewInsets;

    if (_shouldApplyViewInsets()) {
      viewInsets = viewInsets.atLeast(_barHeight.toEdgeInsetsUsingPosition(widget.position));
    }

    return data.copyWith(
      padding: data.padding.atLeast(metrics.bodyPadding),
      viewInsets: data.viewInsets.atLeast(viewInsets),
    );
  }

  Widget _buildScrim(LdAppBarMetrics metrics) {
    return Positioned(
        left: 0,
        right: 0,
        top: widget.position == LdAppBarPosition.top ? 0 : null,
        bottom: widget.position == LdAppBarPosition.bottom ? 0 : null,
        child: Container(
          height: (metrics.systemInsets + metrics.configuredInsets).atPosition(widget.position),
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
              colors: [
                LdTheme.of(context).absolute.withAlpha(200),
                LdTheme.of(context).absolute.withAlpha(0),
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
      final ownMargin = _ownMargin(context, parentMetrics, constraints);

      final inheritedMargin = parentMetrics?.accumulatedEffectiveSizes ?? EdgeInsets.zero;

      final accumulatedPlainSizes = parentMetrics?.cumulatedPlainSizes ?? EdgeInsets.zero;

      final systemInsets = _effectiveSystemInsets(context, parentMetrics);

      var outerMargin = (systemInsets + ownMargin + inheritedMargin);

      outerMargin = outerMargin.atLeast(systemInsets + ownMargin);

      _lastOuterMargin = outerMargin;

      _barHeight = switch (widget.position) {
            LdAppBarPosition.top => outerMargin.top,
            LdAppBarPosition.bottom => outerMargin.bottom,
          } +
          _innerHeight;

      if (widget.scrollBehavior == LdAppBarScrollBehavior.hidden) {
        _visualTarget = _barHeight;
        _snapOverriding = false;
        _hideOffset = _barHeight;
      }

      return NotificationListener<ScrollMetricsNotification>(
        onNotification: (notification) {
          _handleScrollNotification(notification, constraints);
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

            final animatedHideOffset = _springLivePosition;

            final translateY = widget.position == LdAppBarPosition.top ? -animatedHideOffset : animatedHideOffset;

            final scrollOffset = EdgeInsets.only(
              top: widget.position == LdAppBarPosition.top ? _springLivePosition : 0,
              bottom: widget.position == LdAppBarPosition.bottom ? _springLivePosition : 0,
            );
            final metrics = _buildMetrics(
              parentMetrics: parentMetrics,
              ownMargin: ownMargin,
              inheritedMargin: accumulatedPlainSizes,
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
                          constraints: constraints,
                          parentMetrics: parentMetrics,
                          outerMargin: outerMargin,
                        ),
                      ),
                    ),
                    _buildScrim(metrics),
                  ],
                ),
              ),
            );
          },
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
