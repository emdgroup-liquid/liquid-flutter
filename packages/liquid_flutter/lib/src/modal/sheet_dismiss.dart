import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Callbacks wired from [LdSheetScrollDismissListener] into sheet scroll physics.
class LdSheetDismissClient {
  bool Function()? canAbsorbOverscroll;
  void Function(double scrollDelta)? onDismissDragUpdate;
}

/// Routes downward pulls at scroll top into sheet dismiss instead of overscroll.
///
/// Keeps scroll content pinned while the sheet moves, matching native sheet UX.
class LdSheetDismissScrollPhysics extends ScrollPhysics {
  const LdSheetDismissScrollPhysics({
    super.parent,
    this.client,
  });

  final LdSheetDismissClient? client;

  @override
  LdSheetDismissScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return LdSheetDismissScrollPhysics(
      parent: buildParent(ancestor),
      client: client,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final LdSheetDismissClient? client = this.client;
    if (client != null &&
        client.canAbsorbOverscroll?.call() == true &&
        position.pixels <= position.minScrollExtent + toleranceFor(position).distance &&
        offset > 0) {
      client.onDismissDragUpdate?.call(offset);
      return 0.0;
    }

    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.minScrollExtent) {
      return value - position.minScrollExtent;
    }

    return super.applyBoundaryConditions(position, value);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    if (position.pixels <= position.minScrollExtent &&
        velocity > 0 &&
        client?.canAbsorbOverscroll?.call() == true) {
      return null;
    }

    return super.createBallisticSimulation(position, velocity);
  }
}

class _LdSheetScrollBehavior extends ScrollBehavior {
  const _LdSheetScrollBehavior({
    required this.client,
    required this.parent,
  });

  final LdSheetDismissClient client;
  final ScrollBehavior parent;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return LdSheetDismissScrollPhysics(
      parent: parent.getScrollPhysics(context),
      client: client,
    );
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return parent.buildScrollbar(context, child, details);
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return parent.buildOverscrollIndicator(context, child, details);
  }
}

/// Whether the sheet's primary vertical scroll view is at its top edge.
bool ldSheetPrimaryScrollIsAtTop(BuildContext context) {
  final ScrollController? controller = PrimaryScrollController.maybeOf(context);
  if (controller == null || !controller.hasClients) {
    return true;
  }

  for (final ScrollPosition position in controller.positions) {
    if (position.axis == Axis.vertical) {
      return position.pixels <= position.minScrollExtent + 0.5;
    }
  }

  return true;
}

/// Drives sheet route dismiss animations from drag and scroll gestures.
class LdSheetDragController {
  LdSheetDragController({
    required this.navigator,
    required this.controller,
    required this.getIsActive,
    required this.getIsCurrent,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;

  final ValueGetter<bool> getIsActive;
  final ValueGetter<bool> getIsCurrent;

  static const double minFlingVelocity = 2.0;
  static const Duration droppedDragAnimationDuration = Duration(milliseconds: 300);

  bool _userGestureStopped = false;

  /// Ends the navigator's user gesture at most once. The gesture can finish
  /// either from the drag itself or from the listener being disposed, and the
  /// navigator asserts on an unbalanced stop.
  void stopUserGesture() {
    if (_userGestureStopped) return;
    _userGestureStopped = true;
    navigator.didStopUserGesture();
  }

  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  /// Ends a dismiss drag.
  ///
  /// When [useVelocityForDismiss] is false (scroll affordance), only the drag
  /// position decides whether the sheet pops. Upward flings never dismiss.
  void dragEnd(
    double velocity, {
    bool useVelocityForDismiss = true,
  }) {
    const Curve animationCurve = Curves.easeOut;
    final bool isCurrent = getIsCurrent();
    final bool animateForward;

    if (!isCurrent) {
      animateForward = getIsActive();
    } else if (useVelocityForDismiss && velocity >= minFlingVelocity) {
      animateForward = false;
    } else if (useVelocityForDismiss && velocity <= -minFlingVelocity) {
      animateForward = true;
    } else {
      animateForward = controller.value > 0.52;
    }

    if (animateForward) {
      controller.animateTo(
        1.0,
        duration: droppedDragAnimationDuration,
        curve: animationCurve,
      );
    } else {
      if (isCurrent) {
        navigator.pop();
      }

      if (controller.isAnimating) {
        controller.animateBack(
          0.0,
          duration: droppedDragAnimationDuration,
          curve: animationCurve,
        );
      } else if (controller.value > 0.0) {
        controller.animateTo(
          0.0,
          duration: droppedDragAnimationDuration,
          curve: animationCurve,
        );
      }
    }

    if (controller.isAnimating) {
      void animationStatusCallback(AnimationStatus status) {
        stopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      }

      controller.addStatusListener(animationStatusCallback);
    } else {
      stopUserGesture();
    }
  }
}

/// Published by [_LdSheetDragGestureDetector] with the laid-out sheet height.
class LdSheetDismissHeight extends InheritedWidget {
  const LdSheetDismissHeight({
    required this.sheetHeight,
    required super.child,
    super.key,
  });

  final double? sheetHeight;

  static double? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LdSheetDismissHeight>()?.sheetHeight;
  }

  @override
  bool updateShouldNotify(LdSheetDismissHeight oldWidget) {
    return sheetHeight != oldWidget.sheetHeight;
  }
}

/// Listens for downward pulls at the top of sheet scroll content and drives
/// route dismiss, so users do not need to reach for the app bar to close.
class LdSheetScrollDismissListener extends StatefulWidget {
  const LdSheetScrollDismissListener({
    super.key,
    required this.routeAnimation,
    required this.child,
    this.enabled = true,
  });

  final Animation<double> routeAnimation;
  final Widget child;
  final bool enabled;

  @override
  State<LdSheetScrollDismissListener> createState() => _LdSheetScrollDismissListenerState();
}

class _LdSheetScrollDismissListenerState extends State<LdSheetScrollDismissListener> {
  LdSheetDragController? _dragController;
  int _activePointers = 0;
  bool _pointerDownAtScrollTop = false;
  bool _scrollGestureStartedAtTop = false;
  bool _scrolledAwayFromTopDuringGesture = false;
  final LdSheetDismissClient _dismissClient = LdSheetDismissClient();

  AnimationController? get _routeController {
    final Animation<double> animation = widget.routeAnimation;
    return animation is AnimationController ? animation : null;
  }

  @override
  void initState() {
    super.initState();
    _dismissClient.canAbsorbOverscroll = _canAbsorbScrollIntoDismiss;
    _dismissClient.onDismissDragUpdate = _onPhysicsDismissDragUpdate;
  }

  @override
  void dispose() {
    final LdSheetDragController? dragController = _dragController;
    _dragController = null;
    if (dragController != null) {
      // Stopping the gesture writes to a ValueNotifier that the navigator's
      // transitions listen to, so doing it straight from dispose rebuilds a
      // widget while the tree is locked. Deferred to after the frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (dragController.navigator.mounted) {
          dragController.stopUserGesture();
        }
      });
    }
    super.dispose();
  }

  bool _canAbsorbScrollIntoDismiss() {
    if (!widget.enabled) {
      return false;
    }

    if (_scrolledAwayFromTopDuringGesture) {
      return false;
    }

    if (_dragController != null) {
      return true;
    }

    return _pointerDownAtScrollTop || _scrollGestureStartedAtTop;
  }

  void _onPhysicsDismissDragUpdate(double scrollDelta) {
    _applyDismissDelta(scrollDelta);
  }

  double get _sheetHeight {
    final double? scopedHeight = LdSheetDismissHeight.maybeOf(context);
    if (scopedHeight != null && scopedHeight > 0) {
      return scopedHeight;
    }

    final double? height = context.size?.height;
    if (height != null && height > 0) {
      return height;
    }

    return MediaQuery.sizeOf(context).height;
  }

  ModalRoute<dynamic>? get _modalRoute => ModalRoute.of(context);

  void _cancelScrollDismiss() {
    final LdSheetDragController? dragController = _dragController;
    _dragController = null;
    if (dragController == null) {
      return;
    }

    dragController.dragEnd(0.0, useVelocityForDismiss: false);
  }

  void _ensureDragController() {
    final AnimationController? routeController = _routeController;
    final ModalRoute<dynamic>? modalRoute = _modalRoute;
    if (routeController == null || modalRoute == null) {
      return;
    }

    _dragController ??= LdSheetDragController(
      navigator: modalRoute.navigator!,
      controller: routeController,
      getIsCurrent: () => modalRoute.isCurrent,
      getIsActive: () => modalRoute.isActive,
    );
  }

  void _applyDismissDelta(double deltaPixels) {
    if (!widget.enabled || deltaPixels <= 0) {
      return;
    }

    final ModalRoute<dynamic>? modalRoute = _modalRoute;
    if (modalRoute == null || !modalRoute.isCurrent) {
      return;
    }

    final double sheetHeight = _sheetHeight;
    if (sheetHeight <= 0) {
      return;
    }

    _ensureDragController();
    _dragController?.dragUpdate(deltaPixels / sheetHeight);
  }

  void _finishDismissDrag() {
    final LdSheetDragController? dragController = _dragController;
    if (dragController == null) {
      return;
    }

    _dragController = null;
    dragController.dragEnd(0.0, useVelocityForDismiss: false);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (!widget.enabled) {
      return false;
    }

    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (_activePointers > 0 &&
        notification.metrics.pixels > notification.metrics.minScrollExtent + 0.5) {
      _scrolledAwayFromTopDuringGesture = true;
    }

    if (_routeController == null || _modalRoute == null || !_modalRoute!.isCurrent) {
      return false;
    }

    if (notification is UserScrollNotification) {
      _scrollGestureStartedAtTop =
          notification.metrics.pixels <= notification.metrics.minScrollExtent + 0.5;
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      return _handleScrollUpdate(notification);
    }

    return false;
  }

  bool _handleScrollUpdate(ScrollUpdateNotification notification) {
    if (_isUpwardScrollAtTop(notification) && _dragController != null) {
      _cancelScrollDismiss();
      return false;
    }

    return false;
  }

  bool _isUpwardScrollAtTop(ScrollUpdateNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    if (metrics.pixels > metrics.minScrollExtent + 0.5) {
      return false;
    }

    final DragUpdateDetails? dragDetails = notification.dragDetails;
    if (dragDetails != null && dragDetails.delta.dy < 0) {
      return true;
    }

    final double? scrollDelta = notification.scrollDelta;
    return scrollDelta != null && scrollDelta > 0;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled) {
      return;
    }

    _activePointers += 1;
    if (_activePointers == 1) {
      _pointerDownAtScrollTop = ldSheetPrimaryScrollIsAtTop(context);
      _scrolledAwayFromTopDuringGesture = !_pointerDownAtScrollTop;
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _activePointers = (_activePointers - 1).clamp(0, 1 << 30);
    if (_activePointers == 0) {
      _finishDismissDrag();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _activePointers = (_activePointers - 1).clamp(0, 1 << 30);
    if (_activePointers == 0) {
      if (_dragController != null) {
        _cancelScrollDismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollBehavior parentBehavior = ScrollConfiguration.of(context);

    return ScrollConfiguration(
      behavior: widget.enabled
          ? _LdSheetScrollBehavior(
              client: _dismissClient,
              parent: parentBehavior,
            )
          : parentBehavior,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: widget.child,
        ),
      ),
    );
  }
}
