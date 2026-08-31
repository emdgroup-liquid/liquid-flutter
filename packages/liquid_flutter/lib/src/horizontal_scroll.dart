import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Layout mode for [LdHorizontalScroll].
enum LdHorizontalScrollLayout {
  /// Always use a horizontal scroll view.
  scroll,

  /// Always wrap children to multiple lines.
  wrap,

  /// Wrap on desktop; horizontal scroll on mobile and tablet.
  adaptive,
}

/// Scroll overflow hint for [LdHorizontalScroll].
enum LdHorizontalScrollHint {
  /// No overflow hint.
  none,

  /// Fade gradients on the leading/trailing scroll edges.
  edgeFade,
}

/// Horizontal row of children with scroll discoverability hints.
///
/// On mobile, overflows horizontally with optional edge fades and a one-time
/// peek animation. On desktop ([LdHorizontalScrollLayout.adaptive]), children
/// wrap instead of scrolling.
///
/// Use [edgeBleed] to extend the scroll viewport past ancestor padding (for
/// example app bar inside padding) while keeping content inset from the screen
/// edge:
///
/// ```dart
/// LdHorizontalScroll(
///   edgeBleed: EdgeInsets.symmetric(
///     horizontal: LdTheme.of(context).pad(size: LdSize.s).horizontal,
///   ),
///   children: chips,
/// )
/// ```
class LdHorizontalScroll extends StatefulWidget {
  /// Key for the horizontal [SingleChildScrollView] (tests).
  static const scrollViewKey = ValueKey<String>('LdHorizontalScroll.scroll');

  const LdHorizontalScroll({
    super.key,
    required this.children,
    this.spacing = LdSize.s,
    this.layout = LdHorizontalScrollLayout.adaptive,
    this.hint = LdHorizontalScrollHint.edgeFade,
    this.initialPeek = true,
    this.peekDistance,
    this.edgeBleed,
    this.fadeColor,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.runSpacing,
  });

  final List<Widget> children;
  final LdSize spacing;
  final LdHorizontalScrollLayout layout;
  final LdHorizontalScrollHint hint;
  final bool initialPeek;
  final double? peekDistance;
  final EdgeInsets? edgeBleed;
  final Color? fadeColor;
  final CrossAxisAlignment crossAxisAlignment;
  final LdSize? runSpacing;

  @override
  State<LdHorizontalScroll> createState() => _LdHorizontalScrollState();
}

class _LdHorizontalScrollState extends State<LdHorizontalScroll> {
  static const _scrollEpsilon = 0.5;
  static const _peekDuration = Duration(milliseconds: 300);

  late final ScrollController _controller;
  bool _peekCompleted = false;
  bool _peekRunning = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_schedulePeekIfNeeded);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeRunPeek();
    });
  }

  void _schedulePeekIfNeeded() {
    if (_peekCompleted || _peekRunning) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeRunPeek();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _useWrap(BuildContext context, {bool listen = false}) {
    final platform = LdTheme.of(context, listen: listen).platform;
    return switch (widget.layout) {
      LdHorizontalScrollLayout.wrap => true,
      LdHorizontalScrollLayout.scroll => false,
      LdHorizontalScrollLayout.adaptive => platform.isDesktop,
    };
  }

  Future<void> _maybeRunPeek() async {
    if (!mounted || _peekCompleted || _peekRunning || !widget.initialPeek || ldDisableAnimations || _useWrap(context)) {
      return;
    }

    if (!_controller.hasClients) {
      return;
    }

    final position = _controller.position;
    if (position.maxScrollExtent <= _scrollEpsilon) {
      return;
    }

    _peekCompleted = true;
    _peekRunning = true;

    final theme = LdTheme.of(context);
    final distance = widget.peekDistance ?? theme.pad(size: LdSize.m).left;
    final target = distance.clamp(0.0, position.maxScrollExtent);

    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      await _controller.animateTo(
        target,
        duration: _peekDuration,
        curve: Curves.easeOut,
      );
      if (!mounted) return;
      await _controller.animateTo(
        0,
        duration: _peekDuration,
        curve: Curves.easeOut,
      );
    } finally {
      _peekRunning = false;
    }
  }

  Widget _buildRow(BuildContext context) {
    final theme = LdTheme.of(context);
    final gap = theme.paddingSize(size: widget.spacing);

    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      key: LdHorizontalScroll.scrollViewKey,
      controller: _controller,
      scrollDirection: Axis.horizontal,
      padding: widget.edgeBleed,
      child: Row(
        crossAxisAlignment: widget.crossAxisAlignment,
        spacing: gap,
        children: widget.children,
      ),
    );
  }

  Widget _buildWrap(BuildContext context) {
    final theme = LdTheme.of(context);
    final gap = theme.paddingSize(size: widget.spacing);
    final runGap = theme.paddingSize(size: widget.runSpacing ?? widget.spacing);

    return Wrap(
      crossAxisAlignment: switch (widget.crossAxisAlignment) {
        CrossAxisAlignment.start => WrapCrossAlignment.start,
        CrossAxisAlignment.end => WrapCrossAlignment.end,
        CrossAxisAlignment.center => WrapCrossAlignment.center,
        CrossAxisAlignment.stretch => WrapCrossAlignment.center,
        CrossAxisAlignment.baseline => WrapCrossAlignment.center,
      },
      spacing: gap,
      runSpacing: runGap,
      children: widget.children,
    );
  }

  Widget _buildContent({required bool useWrap}) {
    if (useWrap) {
      return _buildWrap(context);
    }

    final row = _buildRow(context);

    if (widget.hint == LdHorizontalScrollHint.edgeFade) {
      return LdScrollEdgeFade(
        axis: Axis.horizontal,
        controller: _controller,
        fadeColor: widget.fadeColor ?? context.surfaceColor,
        child: row,
      );
    }

    return row;
  }

  Widget _applyEdgeBleed({
    required Widget child,
    required bool useWrap,
    required double viewportWidth,
    required bool hasBoundedHeight,
    required double? maxHeight,
  }) {
    final bleed = widget.edgeBleed;
    if (bleed == null || bleed == EdgeInsets.zero || useWrap) {
      return child;
    }

    final laidOutChild = useWrap
        ? SizedBox(
            width: viewportWidth,
            child: child,
          )
        : child;

    final bleedChild = Transform.translate(
      offset: Offset(-bleed.left, 0),
      child: laidOutChild,
    );

    final overflow = OverflowBox(
      maxWidth: viewportWidth + bleed.horizontal,
      maxHeight: hasBoundedHeight ? maxHeight : null,
      alignment: Alignment.centerLeft,
      child: bleedChild,
    );

    if (hasBoundedHeight) {
      return overflow;
    }

    // App bar bottom slots often pass unbounded max height; size to content.
    return IntrinsicHeight(child: overflow);
  }

  @override
  Widget build(BuildContext context) {
    final useWrap = _useWrap(context, listen: true);

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = _buildContent(useWrap: useWrap);

        return _applyEdgeBleed(
          child: content,
          useWrap: useWrap,
          viewportWidth: constraints.maxWidth,
          hasBoundedHeight: constraints.hasBoundedHeight,
          maxHeight: constraints.maxHeight,
        );
      },
    );
  }
}
