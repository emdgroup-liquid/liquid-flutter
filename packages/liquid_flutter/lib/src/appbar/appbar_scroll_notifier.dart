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
  });

  /// The original scroll notification from the body scrollable.
  final ScrollNotification source;

  /// The scroll delta since the last scroll notification.
  final double scrollDelta;
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

  bool _isScrollOwner(BuildContext notifierContext, ScrollNotification notification) {
    final scrollContext = notification.context;
    if (scrollContext == null) {
      return false;
    }
    return LdAppBarScrollNotifier._nearestNotifierElement(scrollContext) == notifierContext;
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
            }
            final scrollDelta = notification.metrics.pixels - _lastScrollOffset;
            _lastScrollOffset = notification.metrics.pixels;
            if (_isScrollOwner(context, notification)) {
              LdAppBarScrollNotification(source: notification, scrollDelta: scrollDelta).dispatch(childContext);
            }
            return false;
          },
          child: widget.child,
        );
      }),
    );
  }
}
