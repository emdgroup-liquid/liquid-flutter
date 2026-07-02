import 'package:flutter/widgets.dart';

/// App-bar-specific scroll notification dispatched upward from the scroll-owning
/// [LdAppBarScrollNotifier] so ancestor app bars can react without each frame
/// also handling the raw [ScrollNotification].
///
/// Raw [ScrollNotification]s continue to bubble unchanged for other listeners.
class LdAppBarScrollNotification extends Notification {
  const LdAppBarScrollNotification({
    required this.source,
    required this.scrollDelta,
    required this.momentumVelocity,
  });

  /// The original scroll notification from the body scrollable.
  final ScrollNotification source;

  /// The scroll delta since the last scroll notification.
  final double scrollDelta;

  /// Estimated scroll velocity in logical pixels per second during the
  /// momentum (fling) phase — i.e. when the finger is no longer touching the
  /// screen and [ScrollUpdateNotification.dragDetails] is null.
  ///
  /// Positive = scrolling down, negative = scrolling up.
  ///
  /// Zero during active finger drag ([ScrollUpdateNotification] with non-null
  /// [dragDetails]), on [ScrollStartNotification], on [ScrollEndNotification],
  /// and for programmatic (non-gesture) scrolls.
  final double momentumVelocity;
}

/// Bridges body [ScrollNotification]s to [LdAppBarScrollNotification]s for
/// ancestor app bars.
///
/// The nearest [LdAppBarScrollNotifier] to the scrollable receives
/// [onRawScrollNotification] and dispatches [LdAppBarScrollNotification]
/// upward. Ancestor notifiers receive [onAppBarScrollNotification] instead.
///
/// Raw scroll notifications are never absorbed so other listeners keep working.
class LdAppBarScrollNotifier extends StatefulWidget {
  const LdAppBarScrollNotifier({
    super.key,
    required this.child,
    required this.onAppBarScrollNotification,
  });

  final Widget child;

  /// Called when a descendant scroll-owning notifier forwarded a scroll event.
  final bool Function(LdAppBarScrollNotification notification) onAppBarScrollNotification;

  static Element? _nearestNotifierElement(BuildContext context) {
    Element? found;
    context.visitAncestorElements((element) {
      if (element.widget is LdAppBarScrollNotifier) {
        found = element;
        return false;
      }
      return true;
    });
    return found;
  }

  @override
  State<LdAppBarScrollNotifier> createState() => _LdAppBarScrollNotifierState();
}

class _LdAppBarScrollNotifierState extends State<LdAppBarScrollNotifier> {
  double _lastScrollOffset = 0;

  /// Timestamp of the last [ScrollUpdateNotification] in the momentum phase,
  /// used to compute instantaneous velocity as `delta / dt`.
  DateTime? _lastMomentumFrameTime;

  bool _isScrollOwner(BuildContext notifierContext, ScrollNotification notification) {
    final scrollContext = notification.context;
    if (scrollContext == null) {
      return false;
    }
    return LdAppBarScrollNotifier._nearestNotifierElement(scrollContext) == notifierContext;
  }

  /// Computes instantaneous velocity (px/s) for momentum-phase scroll updates.
  ///
  /// During the momentum phase ([ScrollUpdateNotification] with null
  /// [dragDetails]) the scroll position changes by [scrollDelta] px between
  /// two consecutive frames. Dividing by the elapsed wall-clock time gives
  /// an instantaneous velocity that decays toward zero as iOS
  /// [BouncingScrollPhysics] decelerates the fling.
  ///
  /// Returns zero when not in momentum phase or when timing data is
  /// unavailable (first momentum frame, programmatic scrolls, etc.).
  double _momentumVelocity(ScrollUpdateNotification notification, double scrollDelta) {
    // Only meaningful during the momentum (fling) phase — finger is off screen.
    if (notification.dragDetails != null) {
      _lastMomentumFrameTime = null;
      return 0.0;
    }

    final now = DateTime.now();
    final last = _lastMomentumFrameTime;
    _lastMomentumFrameTime = now;

    if (last == null) return 0.0; // first momentum frame — no dt available yet

    final dt = now.difference(last).inMicroseconds / Duration.microsecondsPerSecond;
    if (dt <= 0) return 0.0;

    return scrollDelta / dt;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<LdAppBarScrollNotification>(
      onNotification: (notification) {
        return widget.onAppBarScrollNotification(notification);
      },
      child: Builder(builder: (childContext) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification || notification is ScrollEndNotification) {
              _lastScrollOffset = notification.metrics.pixels;
              _lastMomentumFrameTime = null;
            }
            final scrollDelta = notification.metrics.pixels - _lastScrollOffset;
            _lastScrollOffset = notification.metrics.pixels;
            if (_isScrollOwner(context, notification)) {
              final momentumVelocity =
                  notification is ScrollUpdateNotification ? _momentumVelocity(notification, scrollDelta) : 0.0;
              LdAppBarScrollNotification(
                source: notification,
                scrollDelta: scrollDelta,
                momentumVelocity: momentumVelocity,
              ).dispatch(childContext);
            }
            return false;
          },
          child: widget.child,
        );
      }),
    );
  }
}
