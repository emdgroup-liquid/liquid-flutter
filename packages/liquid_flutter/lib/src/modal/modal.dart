import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/sheet_transition.dart';
import 'package:provider/provider.dart';

/// A Page implementation for use with GoRouter that displays an LdModal.
///
/// This replaces the deprecated LdModalPage class.
class LdModalPage<T> extends Page<T> {
  final LdModalRoute<T> Function(BuildContext context) builder;

  const LdModalPage({
    super.key,
    required this.builder,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    final route = builder(context);
    // Ensure the route's settings is set to this Page for page-based navigation
    return LdModalRoute<T>(
      context: route.context,
      barrierDismissible: route.barrierDismissible,
      pageBuilder: route.pageBuilder,
      modalTypeMode: route.modalTypeMode,
      scaleParent: route.scaleParent,
      maintainState: route.maintainState,
      dialogSize: route.dialogSize,
      sheetBorderRadius: route.sheetBorderRadius,
      fixedDialogSize: route.fixedDialogSize,
      sheetAspectRatio: route.sheetAspectRatio,
      topGapRatio: route.topGapRatio,
      dialogBorderRadius: route.dialogBorderRadius,
      sheetBreakpoint: route.sheetBreakpoint,
      sheetInsets: route.sheetInsets,
      barrierLabel: route.barrierLabel ?? LiquidLocalizations.of(context).close,
      settings: this,
    );
  }
}

class LdModalRoute<T> extends PageRoute<T> {
  final BuildContext context;

  final String? _barrierLabel;

  final LdModalTypeMode modalTypeMode;

  final LdSize? dialogSize;

  final Size? fixedDialogSize;

  final double? sheetAspectRatio;

  final double? sheetBreakpoint;

  final bool? scaleParent;

  final BorderRadius? sheetBorderRadius;
  final BorderRadius? dialogBorderRadius;
  final EdgeInsets? sheetInsets;

  @override
  final bool maintainState;

  final Widget Function(BuildContext context) pageBuilder;

  final double topGapRatio;

  LdModalRoute({
    required this.context,
    super.barrierDismissible = true,
    required this.pageBuilder,
    this.modalTypeMode = LdModalTypeMode.auto,
    this.scaleParent = true,
    this.maintainState = true,
    this.dialogSize,
    this.sheetBorderRadius,
    this.fixedDialogSize,
    this.sheetAspectRatio,
    this.dialogBorderRadius,
    this.sheetBreakpoint,
    this.sheetInsets,
    this.topGapRatio = 0.08,
    String? barrierLabel,
    super.settings,
  }) : _barrierLabel = barrierLabel;
  @override
  Color? get barrierColor {
    final theme = LdTheme.of(navigator!.context);
    return theme.palette.neutral.shades[8].withAlpha(150);
  }

  @override
  String? get barrierLabel {
    return _barrierLabel;
  }

  static bool hasParentSheet(BuildContext context) {
    final modalRoute = ModalRoute.of(context);
    return modalRoute is LdModalRoute;
  }

  Future<T?> show(
    BuildContext context, {
    bool useRootNavigator = false,
  }) =>
      (useRootNavigator ? Navigator.of(context, rootNavigator: true) : Navigator.of(context)).push<T>(this);

  /// Determines if this route should behave as a sheet based on modalTypeMode and screen size.
  bool _shouldBeSheet(BoxConstraints constraints) {
    return switch (modalTypeMode) {
      LdModalTypeMode.sheet => true,
      LdModalTypeMode.dialog => false,
      LdModalTypeMode.auto => _autoShowsSheet(constraints),
    };
  }

  bool _autoShowsSheet(BoxConstraints constraints) {
    final breakpoint = sheetBreakpoint ?? 900;
    return constraints.maxWidth < breakpoint;
  }

  double _topPadding(BuildContext context) {
    final maxWidth = MediaQuery.widthOf(context);
    final maxHeight = MediaQuery.heightOf(context);
    final topPadding = maxHeight * topGapRatio;
    if (sheetAspectRatio != null) {
      final desiredHeight = maxWidth / sheetAspectRatio!;
      final finalHeight = desiredHeight.clamp(0, maxHeight);

      return maxHeight - finalHeight;
    }
    return topPadding;
  }

  /// Builds content for sheet mode with top gap and rounded corners.
  ///
  /// The sheet is bottom-anchored and shrinks to fit its child's intrinsic
  /// height; if the child wants more vertical space (e.g. an [LdScaffold] or
  /// any expanding widget) the sheet grows up to the cap derived from
  /// [topGapRatio] / [sheetAspectRatio].
  Widget _buildSheetContent(BuildContext context, Widget child) {
    final theme = LdTheme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final double topPadding = _topPadding(context);
    final double maxSheetHeight = (mediaQuery.size.height - topPadding).clamp(
      0.0,
      mediaQuery.size.height,
    );
    final BorderRadius effectiveBorderRadius = sheetBorderRadius ??
        theme.radius(LdSize.l).copyWith(
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            );

    Widget sheet = Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: theme.border,
          width: theme.borderWidth,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: CupertinoUserInterfaceLevel(
        data: CupertinoUserInterfaceLevelData.elevated,
        child: child,
      ),
    );

    // Drag-to-dismiss is wrapped around the actual visible sheet so that
    // hit-testing and the drag math use the sheet's real rendered height
    // (instead of the full route area above it).
    final AnimationController? sheetController = controller;
    if (barrierDismissible && sheetController != null) {
      sheet = _LdSheetDragGestureDetector<T>(
        route: this,
        controller: sheetController,
        child: sheet,
      );
    }

    return MediaQuery(
      data: mediaQuery.copyWith(
        padding: mediaQuery.padding.copyWith(top: 0),
        viewPadding: mediaQuery.viewPadding.copyWith(top: 0),
        viewInsets: mediaQuery.viewInsets.copyWith(top: 0),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: Container(
            margin: sheetInsets,
            child: sheet,
          ),
        ),
      ),
    );
  }

  /// Builds content for dialog mode with centered positioning.
  Widget _buildDialogContent(BuildContext context, Widget child) {
    final theme = LdTheme.of(context);
    final availableSize = MediaQuery.sizeOf(context);
    late Size configuredSize;

    // Determine size based on dialogSize parameter or default to medium
    final size = dialogSize ?? LdSize.m;
    switch (size) {
      case LdSize.xs:
        configuredSize = const Size(400, 300);
        break;
      case LdSize.s:
        configuredSize = const Size(500, 400);
        break;
      case LdSize.m:
        configuredSize = const Size(600, 500);
        break;
      case LdSize.l:
        configuredSize = const Size(900, 700);
        break;
    }

    // Override with fixedDialogSize if provided
    if (fixedDialogSize != null) {
      configuredSize = fixedDialogSize!;
    }

    final minPadding = theme.pad(size: LdSize.l);

    double maxWidth = configuredSize.width.clamp(
      0.0,
      availableSize.width - minPadding.horizontal,
    );
    double maxHeight = configuredSize.height.clamp(
      0.0,
      availableSize.height - minPadding.vertical,
    );

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: maxWidth,
            minHeight: 0,
            maxHeight: maxHeight,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: dialogBorderRadius ?? theme.radius(LdSize.m),
              border: Border.all(
                color: theme.stroke,
                width: LdTheme.of(context).borderWidth,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _wrapContent(BuildContext context) {
    return pageBuilder(context);
  }

  /// Blocks [LdAppBarMetrics] inherited from ancestor routes (e.g. a shell
  /// [LdAppBar] wrapping the navigator). Without this, modal bars are treated
  /// as nested level-1 bars and pick up incorrect outer padding.
  Widget _isolateAppBarMetrics(Widget child) {
    return Provider<LdAppBarMetrics?>.value(
      value: null,
      child: child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isSheet = _shouldBeSheet(constraints);
      final Widget content = _isolateAppBarMetrics(_wrapContent(context));

      if (isSheet) {
        return _buildSheetContent(context, content);
      } else {
        return _buildDialogContent(context, content);
      }
    });
  }

  /// Builds transitions for sheet mode using CupertinoSheetTransition.
  Widget _buildSheetTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final bool linearTransition = popGestureInProgress;

    // The drag-to-dismiss gesture detector is mounted inside the sheet
    // content (see [_buildSheetContent]) so it wraps only the visible sheet.
    return LdModalSheetTransition(
      topGap: topGapRatio,
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: linearTransition,
      child: child,
    );
  }

  /// Builds transitions for dialog mode using fade and scale.
  Widget _buildDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isSheet = _shouldBeSheet(constraints);

      if (isSheet) {
        return _buildSheetTransitions(context, animation, secondaryAnimation, child);
      } else {
        return _buildDialogTransitions(context, animation, secondaryAnimation, child);
      }
    });
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Allow transitions to other modal routes (CupertinoSheetRoute or LdModalRoute in sheet/dialog mode)
    // The delegated transition will handle the actual transition coordination
    return nextRoute is CupertinoSheetRoute || nextRoute is LdModalRoute;
  }

  // Constants for dialog stacking behavior (matching sheet behavior)
  static const double _kDialogScaleFactor = 0.0835;
  static final Animatable<double> _kDialogScaleTween = Tween<double>(
    begin: 1.0,
    end: 1.0 - _kDialogScaleFactor,
  );
  static final Animatable<Offset> _kDialogMidUpTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0.0, -0.1),
  );

  /// Delegated transition for dialog mode that scales down and moves up when covered.
  static Widget _delegatedDialogSecondaryTransition(
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    const Curve curve = Curves.linearToEaseOut;
    const Curve reverseCurve = Curves.easeInToLinear;
    final CurvedAnimation curvedAnimation = CurvedAnimation(
      curve: curve,
      reverseCurve: reverseCurve,
      parent: secondaryAnimation,
    );

    final Animation<Offset> slideAnimation = curvedAnimation.drive(_kDialogMidUpTween);
    final Animation<double> scaleAnimation = curvedAnimation.drive(_kDialogScaleTween);
    curvedAnimation.dispose();

    return SlideTransition(
      position: slideAnimation,
      transformHitTests: false,
      child: ScaleTransition(
        scale: scaleAnimation,
        filterQuality: FilterQuality.medium,
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }

  /// Creates a delegated transition builder that checks if this route is a dialog.
  DelegatedTransitionBuilder _createDelegatedTransition() {
    final LdModalRoute route = this;
    return (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      bool allowSnapshotting,
      Widget? child,
    ) {
      // Determine dialog mode based on current MediaQuery instead of LayoutBuilder
      final Size screenSize = MediaQuery.sizeOf(context);
      final BoxConstraints constraints = BoxConstraints(
        maxWidth: screenSize.width,
        maxHeight: screenSize.height,
      );
      final bool isDialog = !route._shouldBeSheet(constraints);
      final modalRoute = ModalRoute.of(context);
      final parentIsModal = modalRoute is LdModalRoute;

      if (route.scaleParent == false) {
        return child ?? const SizedBox.shrink();
      }

      if (isDialog && !secondaryAnimation.isDismissed) {
        if (!parentIsModal) {
          return child ?? const SizedBox.shrink();
        }
        // Apply dialog stacking transition
        return _delegatedDialogSecondaryTransition(secondaryAnimation, child);
      }

      // For sheets or when dismissed, fall back to sheet transition
      return LdModalSheetTransition.delegateTransition(
        context,
        animation,
        secondaryAnimation,
        allowSnapshotting,
        child,
      );
    };
  }

  @override
  DelegatedTransitionBuilder? get delegatedTransition {
    // Provide delegated transition for both sheet and dialog modes
    return _createDelegatedTransition();
  }

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration {
    // Match CupertinoSheetRoute duration for sheet mode
    // Default to dialog duration, will be effectively longer for sheets due to transition
    return const Duration(milliseconds: 500);
  }
}

/// Gesture detector for drag-to-dismiss on sheet routes.
class _LdSheetDragGestureDetector<T> extends StatefulWidget {
  const _LdSheetDragGestureDetector({
    required this.route,
    required this.controller,
    required this.child,
  });

  final LdModalRoute<T> route;
  final AnimationController controller;
  final Widget child;

  @override
  State<_LdSheetDragGestureDetector<T>> createState() => _LdSheetDragGestureDetectorState<T>();
}

class _LdSheetDragGestureDetectorState<T> extends State<_LdSheetDragGestureDetector<T>> {
  _LdSheetDragController<T>? _dragController;
  late VerticalDragGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = VerticalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    if (_dragController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dragController?.navigator.mounted ?? false) {
          _dragController?.navigator.didStopUserGesture();
        }
        _dragController = null;
      });
    }
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_dragController == null);
    _dragController = _LdSheetDragController<T>(
      navigator: widget.route.navigator!,
      controller: widget.controller,
      getIsCurrent: () => widget.route.isCurrent,
      getIsActive: () => widget.route.isActive,
    );
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    assert(_dragController != null);
    final double sheetHeight = context.size?.height ?? 0;
    if (sheetHeight <= 0) return;

    _dragController!.dragUpdate(details.primaryDelta! / sheetHeight);
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    assert(_dragController != null);
    final double sheetHeight = context.size?.height ?? 0;
    if (sheetHeight <= 0) {
      _dragController = null;
      return;
    }

    final double velocity = details.velocity.pixelsPerSecond.dy / sheetHeight;
    _dragController!.dragEnd(velocity);
    _dragController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    _dragController?.dragEnd(0.0);
    _dragController = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    // Only enable drag if barrierDismissible is true (defaults to true)
    final bool canDismiss = widget.route.barrierDismissible;
    if (canDismiss) {
      _recognizer.addPointer(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _handlePointerDown,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

/// Controller for managing drag gestures on sheet routes.
class _LdSheetDragController<T> {
  _LdSheetDragController({
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

  // Constants from CupertinoSheetRoute
  static const double _kMinFlingVelocity = 2.0;
  static const Duration _kDroppedSheetDragAnimationDuration = Duration(milliseconds: 300);

  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  void dragEnd(double velocity) {
    const Curve animationCurve = Curves.easeOut;
    final bool isCurrent = getIsCurrent();
    final bool animateForward;

    if (!isCurrent) {
      // If the route has been navigated away from, animate direction depends on
      // whether it's still active in the navigation stack.
      animateForward = getIsActive();
    } else if (velocity.abs() >= _kMinFlingVelocity) {
      // If sufficient velocity, animate based on velocity direction.
      animateForward = velocity <= 0;
    } else {
      // If low velocity, pop if dragged past halfway point.
      animateForward = controller.value > 0.52;
    }

    if (animateForward) {
      controller.animateTo(
        1.0,
        duration: _kDroppedSheetDragAnimationDuration,
        curve: animationCurve,
      );
    } else {
      if (isCurrent) {
        final NavigatorState rootNavigator = Navigator.of(navigator.context, rootNavigator: true);
        rootNavigator.maybePop();
      }

      if (controller.isAnimating) {
        controller.animateBack(
          0.0,
          duration: _kDroppedSheetDragAnimationDuration,
          curve: animationCurve,
        );
      }
    }

    if (controller.isAnimating) {
      void animationStatusCallback(AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      }

      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}
