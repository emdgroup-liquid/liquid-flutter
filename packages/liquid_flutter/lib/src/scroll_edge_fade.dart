import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Paints fade gradients on scrollable edges when more content is available.
///
/// Wraps a scrollable [child] (for example a [CustomScrollView]) and listens for
/// [ScrollNotification]s to show overlays on the edges where more content exists.
class LdScrollEdgeFade extends StatefulWidget {
  /// Keys for the top and bottom fade overlays (for tests and debugging).
  static const topFadeKey = ValueKey<String>('LdScrollEdgeFade.top');
  static const bottomFadeKey = ValueKey<String>('LdScrollEdgeFade.bottom');

  /// Keys for the left and right fade overlays (for tests and debugging).
  static const leftFadeKey = ValueKey<String>('LdScrollEdgeFade.left');
  static const rightFadeKey = ValueKey<String>('LdScrollEdgeFade.right');

  final Widget child;

  /// Scroll axis this fade listens to. Defaults to [Axis.vertical].
  final Axis axis;

  /// Color at the opaque edge of each gradient. Defaults to [LdTheme.absolute].
  final Color? fadeColor;

  /// Extra fade height below [topScrimExtent] / above [bottomScrimExtent].
  ///
  /// For horizontal fades, used as the fade band width on each side.
  ///
  /// When null, uses at least medium theme padding × 2 or the device safe inset.
  final double? fadeExtent;

  /// Height kept nearly opaque at the top (status bar / notch only).
  ///
  /// Does not include app bars, which move away while scrolling. When null,
  /// uses [MediaQuery.viewPadding.top]. Ignored for horizontal axis.
  final double? topScrimExtent;

  /// Height kept nearly opaque at the bottom (home indicator only).
  ///
  /// When null, uses [MediaQuery.viewPadding.bottom]. Ignored for horizontal axis.
  final double? bottomScrimExtent;

  /// When set, listens to this controller in addition to [ScrollNotification]s.
  ///
  /// Required for horizontal fades when the scroll view does not use
  /// [PrimaryScrollController].
  final ScrollController? controller;

  const LdScrollEdgeFade({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.controller,
    this.fadeColor,
    this.fadeExtent,
    this.topScrimExtent,
    this.bottomScrimExtent,
  });

  @override
  State<LdScrollEdgeFade> createState() => _LdScrollEdgeFadeState();
}

class _LdScrollEdgeFadeState extends State<LdScrollEdgeFade> {
  static const _scrollEpsilon = 0.5;

  bool _showLeading = false;
  bool _showTrailing = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _readMetricsFromController();
    });
  }

  @override
  void didUpdateWidget(LdScrollEdgeFade oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      _readMetricsFromController();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted || widget.controller == null || !widget.controller!.hasClients) {
      return;
    }

    for (final position in widget.controller!.positions) {
      if (position.axis == widget.axis) {
        _updateFromMetrics(position);
        return;
      }
    }
  }

  void _readMetricsFromController() {
    if (!mounted) return;

    final controller = widget.controller ?? PrimaryScrollController.maybeOf(context);
    if (controller == null || !controller.hasClients) {
      return;
    }

    // During rebuilds the primary controller can briefly have multiple clients.
    final positions = controller.positions;
    if (positions.isEmpty) {
      return;
    }

    for (final position in positions) {
      if (position.axis == widget.axis) {
        _updateFromMetrics(position);
        return;
      }
    }
  }

  void _updateFromMetrics(ScrollMetrics metrics) {
    if (metrics.axis != widget.axis) {
      return;
    }

    final isReversed = metrics.axisDirection == AxisDirection.up;

    final canScroll = metrics.maxScrollExtent > metrics.minScrollExtent + _scrollEpsilon;
    bool showLeading = false;
    bool showTrailing = false;

    if (canScroll) {
      if (isReversed) {
        showLeading = metrics.pixels < metrics.maxScrollExtent - _scrollEpsilon;
        showTrailing = metrics.pixels > metrics.minScrollExtent + _scrollEpsilon;
      } else {
        showTrailing = metrics.pixels < metrics.maxScrollExtent - _scrollEpsilon;
        showLeading = metrics.pixels > metrics.minScrollExtent + _scrollEpsilon;
      }
    }

    if (showLeading == _showLeading && showTrailing == _showTrailing) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _showLeading = showLeading;
      _showTrailing = showTrailing;
    });
  }

  bool _onScrollNotification(ScrollMetricsNotification notification) {
    if (notification.depth != 0) {
      return false;
    }

    if (notification.metrics.axis != widget.axis) {
      return false;
    }

    _updateFromMetrics(notification.metrics);

    return false;
  }

  double _fadeBandExtent(LdTheme theme, double safeInset) {
    final themeBand = theme.paddingSize(size: LdSize.m);
    return widget.fadeExtent ?? max(themeBand, safeInset);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _readMetricsFromController();
    });

    final theme = LdTheme.of(context, listen: true);
    final fadeColor = widget.fadeColor ?? theme.absolute;
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _onScrollNotification,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          ...switch (widget.axis) {
            Axis.vertical => _buildVerticalOverlays(
                theme: theme,
                fadeColor: fadeColor,
                viewPadding: viewPadding,
              ),
            Axis.horizontal => _buildHorizontalOverlays(
                theme: theme,
                fadeColor: fadeColor,
                viewPadding: viewPadding,
              ),
          },
        ],
      ),
    );
  }

  List<Widget> _buildVerticalOverlays({
    required LdTheme theme,
    required Color fadeColor,
    required EdgeInsets viewPadding,
  }) {
    final topScrim = widget.topScrimExtent ?? viewPadding.top;
    final bottomScrim = widget.bottomScrimExtent ?? viewPadding.bottom;
    final topFadeBand = _fadeBandExtent(theme, topScrim);
    final bottomFadeBand = _fadeBandExtent(theme, bottomScrim);

    return [
      _ScrollEdgeFadeOverlay(
        key: LdScrollEdgeFade.topFadeKey,
        axis: Axis.vertical,
        visible: _showLeading,
        fadeColor: fadeColor,
        scrimExtent: topScrim,
        fadeBand: topFadeBand,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      _ScrollEdgeFadeOverlay(
        key: LdScrollEdgeFade.bottomFadeKey,
        axis: Axis.vertical,
        visible: _showTrailing,
        fadeColor: fadeColor,
        scrimExtent: bottomScrim,
        fadeBand: bottomFadeBand,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ];
  }

  List<Widget> _buildHorizontalOverlays({
    required LdTheme theme,
    required Color fadeColor,
    required EdgeInsets viewPadding,
  }) {
    final leadingScrim = viewPadding.left;
    final trailingScrim = viewPadding.right;
    final leadingFadeBand = _fadeBandExtent(theme, leadingScrim);
    final trailingFadeBand = _fadeBandExtent(theme, trailingScrim);

    return [
      _ScrollEdgeFadeOverlay(
        key: LdScrollEdgeFade.leftFadeKey,
        axis: Axis.horizontal,
        visible: _showLeading,
        fadeColor: fadeColor,
        scrimExtent: leadingScrim,
        fadeBand: leadingFadeBand,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      _ScrollEdgeFadeOverlay(
        key: LdScrollEdgeFade.rightFadeKey,
        axis: Axis.horizontal,
        visible: _showTrailing,
        fadeColor: fadeColor,
        scrimExtent: trailingScrim,
        fadeBand: trailingFadeBand,
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ),
    ];
  }
}

class _ScrollEdgeFadeOverlay extends StatelessWidget {
  /// Alpha at the end of the scrim region (status bar / app bar). High enough for
  /// system chrome legibility, low enough to show a visible fade in that band.
  static const _scrimEndAlpha = 230;

  final Axis axis;
  final bool visible;
  final Color fadeColor;
  final double scrimExtent;
  final double fadeBand;
  final Alignment begin;
  final Alignment end;

  const _ScrollEdgeFadeOverlay({
    super.key,
    required this.axis,
    required this.visible,
    required this.fadeColor,
    required this.scrimExtent,
    required this.fadeBand,
    required this.begin,
    required this.end,
  });

  bool get _isLeading => switch (axis) {
        Axis.vertical => begin == Alignment.topCenter,
        Axis.horizontal => begin == Alignment.centerLeft,
      };

  double get _totalExtent => scrimExtent + fadeBand;

  BoxDecoration get _decoration {
    if (_totalExtent <= 0) {
      return const BoxDecoration();
    }

    if (scrimExtent <= 0) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [
            fadeColor,
            fadeColor.withAlpha(0),
          ],
        ),
      );
    }

    final scrimStop = (scrimExtent / _totalExtent).clamp(0.0, 1.0);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: [
          fadeColor,
          fadeColor.withAlpha(_scrimEndAlpha),
          fadeColor.withAlpha(0),
        ],
        stops: [
          0,
          scrimStop,
          1,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (axis) {
      Axis.vertical => Positioned(
          top: _isLeading ? 0 : null,
          bottom: _isLeading ? null : 0,
          left: 0,
          right: 0,
          height: _totalExtent,
          child: _fadeOverlay(),
        ),
      Axis.horizontal => Positioned(
          left: _isLeading ? 0 : null,
          right: _isLeading ? null : 0,
          top: 0,
          bottom: 0,
          width: _totalExtent,
          child: _fadeOverlay(),
        ),
    };
  }

  Widget _fadeOverlay() {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: _decoration,
        ),
      ),
    );
  }
}
