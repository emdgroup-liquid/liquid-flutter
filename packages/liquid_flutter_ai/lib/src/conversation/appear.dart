import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Fade / slide / size-open entrance for conversation rows (agent pieces).
///
/// Opt-in, like [LdSendFlyTarget]: wrap newly inserted items so seed content
/// does not animate on first paint. Respects [ldDisableAnimations].
class LdConversationAppear extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  /// When false, [child] is shown immediately (useful while ids are tracked).
  final bool animate;

  final VoidCallback? onCompleted;

  const LdConversationAppear({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 360),
    this.curve = Curves.easeOutCubic,
    this.animate = true,
    this.onCompleted,
  });

  @override
  State<LdConversationAppear> createState() => _LdConversationAppearState();
}

class _LdConversationAppearState extends State<LdConversationAppear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(_animation);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCompleted?.call();
      }
    });

    if (!widget.animate || ldDisableAnimations) {
      _controller.value = 1;
      return;
    }

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant LdConversationAppear oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate && !widget.animate && _controller.value < 1) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate || ldDisableAnimations) {
      return widget.child;
    }

    // Reverse lists grow from the compose edge (bottom). Keep left-aligned —
    // bottomCenter was sliding content from the horizontal center as it grew.
    return SizeTransition(
      sizeFactor: _animation,
      alignment: Alignment.bottomLeft,
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: _slide,
          child: SizedBox(
            width: double.infinity,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
