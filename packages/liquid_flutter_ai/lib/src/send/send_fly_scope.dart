import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_ai/src/models/compose_attachment.dart';
import 'package:liquid_flutter_ai/src/models/conversation_item.dart';
import 'package:provider/provider.dart';

/// Opt-in scope for compose → list send-fly.
///
/// Measures the compose origin and list target, then animates a bubble copy
/// in a local [Stack] (keeps theme/ancestors; no local_hero).
///
/// Flight position is driven by [LdSpring] so mid-flight target moves
/// (list slot opening, scroll) are chased smoothly instead of jumping.
class LdSendFlyScope extends StatefulWidget {
  final Widget child;
  final double mass;
  final double springConstant;
  final double dampingCoefficient;

  const LdSendFlyScope({
    super.key,
    required this.child,
    this.mass = 4,
    this.springConstant = 5,
    this.dampingCoefficient = 9,
  });

  /// Watches fly state (rebuilds on start/complete). Null outside a scope.
  static LdSendFlyScopeState? maybeOf(BuildContext context) {
    return context.watch<LdSendFlyScopeState?>();
  }

  /// Reads fly state without listening. Throws if no scope is above.
  static LdSendFlyScopeState of(BuildContext context) {
    return context.read<LdSendFlyScopeState>();
  }

  @override
  State<LdSendFlyScope> createState() => _LdSendFlyScopeState();
}

/// Fly controller: [flyingId] / [isAnimating] notify listeners when they change.
class LdSendFlyScopeState extends ChangeNotifier {
  LdSendFlyScopeState({
    required double mass,
    required double springConstant,
    required double dampingCoefficient,
  }) : _mass = mass,
       _springConstant = springConstant,
       _dampingCoefficient = dampingCoefficient;

  final GlobalKey originKey = GlobalKey(debugLabel: 'ld-send-fly-origin');
  final GlobalKey targetKey = GlobalKey(debugLabel: 'ld-send-fly-target');
  final GlobalKey stackKey = GlobalKey(debugLabel: 'ld-send-fly-stack');

  double _mass;
  double _springConstant;
  double _dampingCoefficient;
  var _disposed = false;

  /// Message id currently in flight (null when idle).
  String? flyingId;

  /// True while the flight layer is visible / springing.
  bool get isAnimating => _showFlight;

  double get mass => _mass;
  double get springConstant => _springConstant;
  double get dampingCoefficient => _dampingCoefficient;

  Widget? _flightBubble;
  Rect? _from;
  Rect? _to;
  var _showFlight = false;

  Widget? get flightBubble => _flightBubble;
  Rect? get from => _from;
  Rect? get to => _to;

  void updateSpringParams({
    required double mass,
    required double springConstant,
    required double dampingCoefficient,
  }) {
    _mass = mass;
    _springConstant = springConstant;
    _dampingCoefficient = dampingCoefficient;
  }

  /// Whether [messageId] is the in-flight list target (hide real bubble).
  bool isFlyingTarget(String messageId) => flyingId == messageId;

  /// Start a send-fly from the compose origin to the list target.
  ///
  /// 1. Captures the origin rect ([originKey], usually the compose input).
  /// 2. Sets [flyingId] and calls [onCommitted] so the caller can insert
  ///    [message] wrapped in [LdSendFlyTarget].
  /// 3. Measures the target, then springs [bubble] over the scope [Stack].
  void dispatch(
    LdUserMessageItem message, {
    required Widget bubble,
    VoidCallback? onCommitted,
  }) {
    _cancelFlight(notify: false);

    if (ldDisableAnimations) {
      flyingId = null;
      onCommitted?.call();
      return;
    }

    final from = _rectInStack(originKey);
    if (from == null) {
      onCommitted?.call();
      return;
    }

    _from = from;
    _flightBubble = bubble;
    flyingId = message.id;
    _notify();
    onCommitted?.call();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_disposed || flyingId != message.id) {
        return;
      }
      _startFlightWhenTargetReady(message.id, attempt: 0);
    });
  }

  void _startFlightWhenTargetReady(String id, {required int attempt}) {
    if (_disposed || flyingId != id) {
      return;
    }

    final to = _rectInStack(targetKey);
    if (to == null || to.isEmpty) {
      if (attempt >= 8) {
        clearFlying();
        return;
      }
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _startFlightWhenTargetReady(id, attempt: attempt + 1);
      });
      return;
    }

    _to = to;
    _beginFlight();
  }

  void _beginFlight() {
    final from = _from;
    final to = _to;
    if (from == null || to == null || _flightBubble == null) {
      clearFlying();
      return;
    }

    _from = from;
    _to = to;
    _showFlight = true;
    _notify();
  }

  Rect? _rectInStack(GlobalKey key) {
    final stackCtx = stackKey.currentContext;
    final targetCtx = key.currentContext;
    if (stackCtx == null || targetCtx == null) {
      return null;
    }

    final stackBox = stackCtx.findRenderObject() as RenderBox?;
    final targetBox = targetCtx.findRenderObject() as RenderBox?;
    if (stackBox == null ||
        targetBox == null ||
        !stackBox.hasSize ||
        !targetBox.hasSize ||
        !stackBox.attached ||
        !targetBox.attached) {
      return null;
    }

    final topLeft = stackBox.globalToLocal(
      targetBox.localToGlobal(Offset.zero),
    );
    return topLeft & targetBox.size;
  }

  Rect? measureTarget() => _rectInStack(targetKey);

  void _cancelFlight({required bool notify}) {
    _flightBubble = null;
    _from = null;
    _to = null;
    _showFlight = false;
    if (flyingId != null) {
      flyingId = null;
      if (notify) {
        _notify();
      }
    } else if (notify) {
      _notify();
    }
  }

  /// Clears fly state and removes any in-flight layer.
  void clearFlying() {
    if (flyingId == null && _flightBubble == null && !_showFlight) {
      return;
    }
    _cancelFlight(notify: true);
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelFlight(notify: false);
    super.dispose();
  }
}

class _LdSendFlyScopeState extends State<LdSendFlyScope> {
  late final LdSendFlyScopeState _controller;

  @override
  void initState() {
    super.initState();
    _controller = LdSendFlyScopeState(
      mass: widget.mass,
      springConstant: widget.springConstant,
      dampingCoefficient: widget.dampingCoefficient,
    );
  }

  @override
  void didUpdateWidget(covariant LdSendFlyScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.updateSpringParams(
      mass: widget.mass,
      springConstant: widget.springConstant,
      dampingCoefficient: widget.dampingCoefficient,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<LdSendFlyScopeState>.value(
      value: _controller,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) {
          final from = _controller.from;
          final to = _controller.to;
          final bubble = _controller.flightBubble;
          final showFlight =
              _controller.isAnimating &&
              from != null &&
              to != null &&
              bubble != null;

          return Stack(
            key: _controller.stackKey,
            clipBehavior: Clip.none,
            children: [
              child!,
              if (showFlight)
                Positioned.fill(
                  child: IgnorePointer(
                    child: _LdSendFlyShuttle(
                      key: ValueKey(_controller.flyingId),
                      from: from,
                      initialTo: to,
                      measureTarget: _controller.measureTarget,
                      mass: _controller.mass,
                      springConstant: _controller.springConstant,
                      dampingCoefficient: _controller.dampingCoefficient,
                      onArrived: _controller.clearFlying,
                      child: bubble,
                    ),
                  ),
                ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Springs a bubble rect from [from] toward a live-measured destination.
class _LdSendFlyShuttle extends StatefulWidget {
  final Rect from;
  final Rect initialTo;
  final Rect? Function() measureTarget;
  final double mass;
  final double springConstant;
  final double dampingCoefficient;
  final VoidCallback onArrived;
  final Widget child;

  const _LdSendFlyShuttle({
    super.key,
    required this.from,
    required this.initialTo,
    required this.measureTarget,
    required this.mass,
    required this.springConstant,
    required this.dampingCoefficient,
    required this.onArrived,
    required this.child,
  });

  @override
  State<_LdSendFlyShuttle> createState() => _LdSendFlyShuttleState();
}

class _LdSendFlyShuttleState extends State<_LdSendFlyShuttle> {
  var _arrived = false;

  Rect _destination() {
    final live = widget.measureTarget();
    if (live == null || live.isEmpty) {
      return widget.initialTo;
    }
    // Prefer a live position as the list slot opens, but keep the destination
    // size from the initial full measure — mid-flight heightFactor frames can
    // report a tiny height.
    if (live.height >= widget.initialTo.height * 0.5) {
      return live;
    }
    return Rect.fromLTWH(
      live.left,
      live.top,
      widget.initialTo.width,
      widget.initialTo.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Progress spring: opacity / lift, and signals arrival. Rect springs below
    // chase the live dest so target moves retarget smoothly via [LdSpring].
    return LdSpring(
      mass: widget.mass,
      springConstant: widget.springConstant,
      dampingCoefficient: widget.dampingCoefficient,
      initialPosition: 0,
      position: 1,
      onAnimationEnd: (context, state) {
        if (!_arrived) {
          _arrived = true;
          widget.onArrived();
        }
      },
      builder: (context, progress, child) {
        final t = progress.position.clamp(0.0, 1.0);

        // Re-measure each spring tick so dest updates while the slot opens.
        final liveDest = _destination();

        return _LdSpringRect(
          from: widget.from,
          to: liveDest,
          mass: widget.mass,
          springConstant: widget.springConstant,
          dampingCoefficient: widget.dampingCoefficient,
          builder: (context, rect, child) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: rect.left,
                  top: rect.top,
                  width: rect.width.clamp(0.0, double.infinity),
                  height: rect.height.clamp(0.0, double.infinity),
                  child: Opacity(opacity: 0.85 + 0.15 * t, child: child),
                ),
              ],
            );
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Four [LdSpring]s chasing a [Rect] so each edge retargets independently.
class _LdSpringRect extends StatelessWidget {
  final Rect from;
  final Rect to;
  final double mass;
  final double springConstant;
  final double dampingCoefficient;
  final Widget Function(BuildContext context, Rect rect, Widget? child) builder;
  final Widget? child;

  const _LdSpringRect({
    required this.from,
    required this.to,
    required this.mass,
    required this.springConstant,
    required this.dampingCoefficient,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LdSpring(
      mass: mass,
      springConstant: springConstant,
      dampingCoefficient: dampingCoefficient,
      initialPosition: from.left,
      position: to.left,
      builder: (context, left, child) {
        return LdSpring(
          mass: mass,
          springConstant: springConstant,
          dampingCoefficient: dampingCoefficient,
          initialPosition: from.top,
          position: to.top,
          builder: (context, top, child) {
            return LdSpring(
              mass: mass,
              springConstant: springConstant,
              dampingCoefficient: dampingCoefficient,
              initialPosition: from.width,
              position: to.width,
              builder: (context, width, child) {
                return LdSpring(
                  mass: mass,
                  springConstant: springConstant,
                  dampingCoefficient: dampingCoefficient,
                  initialPosition: from.height,
                  position: to.height,
                  builder: (context, height, child) {
                    final rect = Rect.fromLTWH(
                      left.position,
                      top.position,
                      width.position,
                      height.position,
                    );
                    return builder(context, rect, child);
                  },
                  child: child,
                );
              },
              child: child,
            );
          },
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Provides a [GlobalKey] for the painted bubble chrome (not the aligning Row).
///
/// Used by [LdSendFlyTarget] so [LdUserBubble] can attach [LdSendFlyScopeState.targetKey]
/// to the real bubble bounds.
class LdSendFlyMeasureKey extends InheritedWidget {
  final GlobalKey measureKey;

  const LdSendFlyMeasureKey({
    super.key,
    required this.measureKey,
    required super.child,
  });

  static GlobalKey? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LdSendFlyMeasureKey>()
        ?.measureKey;
  }

  @override
  bool updateShouldNotify(LdSendFlyMeasureKey oldWidget) =>
      measureKey != oldWidget.measureKey;
}

/// Marks the compose origin for [LdSendFlyScope] measurements.
///
/// Prefer letting [LdComposeBar] attach [LdSendFlyScopeState.originKey]
/// automatically when under a scope; use this for custom compose UIs.
class LdSendFlyOrigin extends StatelessWidget {
  final Widget child;

  const LdSendFlyOrigin({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final fly = LdSendFlyScope.maybeOf(context);
    if (fly == null) {
      return child;
    }
    return KeyedSubtree(key: fly.originKey, child: child);
  }
}

/// List-side target: opens its slot in sync with the flight animation.
///
/// Places [LdSendFlyScopeState.targetKey] on the painted bubble via
/// [LdSendFlyMeasureKey] (see [LdUserBubble]). The real bubble stays invisible
/// while a spring-driven height factor grows the list space (no jump).
class LdSendFlyTarget extends StatelessWidget {
  final String id;
  final Widget child;

  const LdSendFlyTarget({super.key, required this.id, required this.child});

  @override
  Widget build(BuildContext context) {
    final fly = LdSendFlyScope.maybeOf(context);
    if (fly == null || !fly.isFlyingTarget(id)) {
      return child;
    }

    final measured = LdSendFlyMeasureKey(
      measureKey: fly.targetKey,
      child: Opacity(opacity: 0, child: child),
    );

    // Hold height at 0 until the flight layer mounts so slot open and shuttle
    // springs start together (same params on [LdSendFlyScope]).
    if (!fly.isAnimating) {
      return ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 0,
          child: measured,
        ),
      );
    }

    // Reverse lists grow from the compose edge (bottom). heightFactor 0 still
    // lays out [child] at full size so the measure key can read the final rect.
    return measured;
  }
}

/// Convenience data for a dispatch from compose.
class LdSendFlyPayload {
  final String id;
  final String text;
  final List<LdComposeAttachment> attachments;

  const LdSendFlyPayload({
    required this.id,
    required this.text,
    this.attachments = const [],
  });
}
