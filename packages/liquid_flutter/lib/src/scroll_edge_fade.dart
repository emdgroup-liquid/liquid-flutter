import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Paints fade gradients on scrollable edges when more content is available.
///
/// Wraps a scrollable [child] (for example a [CustomScrollView]) and listens for
/// [ScrollNotification]s to show top and bottom overlays when the user can
/// scroll further in that direction.
class LdScrollEdgeFade extends StatefulWidget {
  /// Keys for the top and bottom fade overlays (for tests and debugging).
  static const topFadeKey = ValueKey<String>('LdScrollEdgeFade.top');
  static const bottomFadeKey = ValueKey<String>('LdScrollEdgeFade.bottom');

  final Widget child;

  /// Color at the opaque edge of each gradient. Defaults to [LdTheme.background].
  final Color? fadeColor;

  /// Extra fade height below [topScrimExtent] / above [bottomScrimExtent].
  ///
  /// When null, uses at least medium theme padding × 2 or the device safe inset.
  final double? fadeExtent;

  /// Height kept nearly opaque at the top (status bar / notch only).
  ///
  /// Does not include app bars, which move away while scrolling. When null,
  /// uses [MediaQuery.viewPadding.top].
  final double? topScrimExtent;

  /// Height kept nearly opaque at the bottom (home indicator only).
  ///
  /// When null, uses [MediaQuery.viewPadding.bottom].
  final double? bottomScrimExtent;

  const LdScrollEdgeFade({
    super.key,
    required this.child,
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

  bool _showTop = false;
  bool _showBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _readMetricsFromPrimaryController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _readMetricsFromPrimaryController();
  }

  void _readMetricsFromPrimaryController() {
    final controller = PrimaryScrollController.maybeOf(context);
    if (controller == null || !controller.hasClients) {
      return;
    }

    // During rebuilds the primary controller can briefly have multiple clients.
    final positions = controller.positions;
    if (positions.isEmpty) {
      return;
    }

    _updateFromMetrics(positions.first);
  }

  void _updateFromMetrics(ScrollMetrics metrics) {
    if (metrics.axis != Axis.vertical) {
      return;
    }

    final canScroll = metrics.maxScrollExtent > metrics.minScrollExtent + _scrollEpsilon;
    final showTop = canScroll && metrics.pixels > metrics.minScrollExtent + _scrollEpsilon;
    final showBottom = canScroll && metrics.pixels < metrics.maxScrollExtent - _scrollEpsilon;

    if (showTop == _showTop && showBottom == _showBottom) {
      return;
    }

    setState(() {
      _showTop = showTop;
      _showBottom = showBottom;
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) {
      return false;
    }

    if (notification is ScrollUpdateNotification ||
        notification is ScrollMetricsNotification ||
        notification is ScrollEndNotification) {
      _updateFromMetrics(notification.metrics);
    }

    return false;
  }

  double _fadeBandExtent(LdTheme theme, double safeInset) {
    final themeBand = theme.paddingSize(size: LdSize.m) * 2;
    return widget.fadeExtent ?? max(themeBand, safeInset);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final fadeColor = widget.fadeColor ?? theme.absolute;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final topScrim = widget.topScrimExtent ?? viewPadding.top;
    final bottomScrim = widget.bottomScrimExtent ?? viewPadding.bottom;
    final topFadeBand = _fadeBandExtent(theme, topScrim);
    final bottomFadeBand = _fadeBandExtent(theme, bottomScrim);

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          widget.child,
          _ScrollEdgeFadeOverlay(
            key: LdScrollEdgeFade.topFadeKey,
            visible: _showTop,
            fadeColor: fadeColor,
            scrimExtent: topScrim,
            fadeBand: topFadeBand,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          _ScrollEdgeFadeOverlay(
            key: LdScrollEdgeFade.bottomFadeKey,
            visible: _showBottom,
            fadeColor: fadeColor,
            scrimExtent: bottomScrim,
            fadeBand: bottomFadeBand,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ],
      ),
    );
  }
}

class _ScrollEdgeFadeOverlay extends StatelessWidget {
  /// Alpha at the end of the scrim region (status bar / app bar). High enough for
  /// system chrome legibility, low enough to show a visible fade in that band.
  static const _scrimEndAlpha = 230;

  final bool visible;
  final Color fadeColor;
  final double scrimExtent;
  final double fadeBand;
  final Alignment begin;
  final Alignment end;

  const _ScrollEdgeFadeOverlay({
    super.key,
    required this.visible,
    required this.fadeColor,
    required this.scrimExtent,
    required this.fadeBand,
    required this.begin,
    required this.end,
  });

  bool get _isTop => begin == Alignment.topCenter;

  double get _totalHeight => scrimExtent + fadeBand;

  BoxDecoration get _decoration {
    if (_totalHeight <= 0) {
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

    final scrimStop = (scrimExtent / _totalHeight).clamp(0.0, 1.0);

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
    return Positioned(
      top: _isTop ? 0 : null,
      bottom: _isTop ? null : 0,
      left: 0,
      right: 0,
      height: _totalHeight,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: DecoratedBox(
            decoration: _decoration,
          ),
        ),
      ),
    );
  }
}
