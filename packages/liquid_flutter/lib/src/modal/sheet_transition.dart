import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// This code is heavily based on the CupertinoSheetTransition class in the Flutter framework.
/// See https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/cupertino/sheet.dart

const double _kTopGapRatio = 0.08;
const double _kStretchedTopGapRatio = 0.072;

final Animatable<Offset> _kBottomUpTween = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);

final Animatable<Offset> _kBottomUpTweenWhenCoveringOtherSheet = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: const Offset(0.0, -0.02),
);

final Animatable<Offset> _kMidUpTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(0.0, -0.005),
);

final Animatable<Offset> _kTopDownTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(0.0, 0.07),
);

final Animatable<double> _kOpacityTween = Tween<double>(begin: 0.0, end: 0.10);

const double _kSheetScaleFactor = 0.0835;

final Animatable<double> _kScaleTween = Tween<double>(begin: 1.0, end: 1.0 - _kSheetScaleFactor);

/// Provides an iOS-style sheet transition.
///
/// The page slides up and stops below the top of the screen. When covered by
/// another sheet view, it will slide slightly up and scale down to appear
/// stacked behind the new sheet.
class LdModalSheetTransition extends StatefulWidget {
  /// Creates an iOS style sheet transition.
  const LdModalSheetTransition({
    super.key,
    required this.primaryRouteAnimation,
    required this.secondaryRouteAnimation,
    required this.child,
    required this.linearTransition,
    required this.topGap,
  });

  /// `primaryRouteAnimation` is a linear route animation from 0.0 to 1.0 when
  /// this screen is being pushed.
  final Animation<double> primaryRouteAnimation;

  /// `secondaryRouteAnimation` is a linear route animation from 0.0 to 1.0 when
  /// another screen is being pushed on top of this one.
  final Animation<double> secondaryRouteAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Whether to perform the transition linearly.
  ///
  /// Used to respond to a drag gesture.
  final bool linearTransition;

  /// The gap between the top of the screen and the top of the sheet as a ratio
  /// of the screen height.
  ///
  /// This value should be between 0.0 and 0.9, where 0.0 means no gap (sheet
  /// extends to the top of the screen) and 0.9 means the sheet covers only the
  /// bottom 10% of the screen. A value of 0.08 represents 8% of the screen height.
  final double topGap;

  /// The primary delegated transition. Will slide a non [CupertinoSheetRoute] page down.
  ///
  /// Provided to the previous route to coordinate transitions between routes.
  ///
  /// If a [CupertinoSheetRoute] already exists in the stack, then it will
  /// slide the previous sheet upwards instead.
  static Widget delegateTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    bool allowSnapshotting,
    Widget? child,
  ) {
    if (LdModalRoute.hasParentSheet(context)) {
      return _delegatedCoverSheetSecondaryTransition(secondaryAnimation, child);
    }
    final bool linear = Navigator.of(context).userGestureInProgress;

    final Curve curve = linear ? Curves.linear : Curves.linearToEaseOut;
    final Curve reverseCurve = linear ? Curves.linear : Curves.easeInToLinear;
    final curvedAnimation = CurvedAnimation(
      curve: curve,
      reverseCurve: reverseCurve,
      parent: secondaryAnimation,
    );

    final double deviceCornerRadius = LdTheme.of(context).screenRadius;

    final Animatable<BorderRadiusGeometry> decorationTween = Tween<BorderRadiusGeometry>(
      begin: BorderRadius.vertical(
        top: Radius.circular(deviceCornerRadius),
      ),
      end: BorderRadius.circular(12),
    );

    final Animation<BorderRadiusGeometry> radiusAnimation = curvedAnimation.drive(decorationTween);
    final Animation<double> opacityAnimation = curvedAnimation.drive(_kOpacityTween);
    final Animation<Offset> slideAnimation = curvedAnimation.drive(_kTopDownTween);
    final Animation<double> scaleAnimation = curvedAnimation.drive(_kScaleTween);
    curvedAnimation.dispose();

    final isDarkMode = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final overlayColor = isDarkMode ? const Color(0xFFc8c8c8) : const Color(0xFF000000);

    final Widget? contrastedChild = child != null && !secondaryAnimation.isDismissed
        ? Stack(
            children: <Widget>[
              child,
              FadeTransition(
                opacity: opacityAnimation,
                child: ColoredBox(color: overlayColor, child: const SizedBox.expand()),
              ),
            ],
          )
        : child;

    final double topGapHeight = MediaQuery.sizeOf(context).height * _kTopGapRatio;

    return Stack(
      children: <Widget>[
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
          child: SizedBox(height: topGapHeight, width: double.infinity),
        ),
        SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            filterQuality: FilterQuality.medium,
            alignment: Alignment.topCenter,
            child: AnimatedBuilder(
              animation: radiusAnimation,
              child: child,
              builder: (BuildContext context, Widget? child) {
                return ClipRSuperellipse(
                  borderRadius: !secondaryAnimation.isDismissed ? radiusAnimation.value : BorderRadius.circular(0),
                  child: contrastedChild,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  static Widget _delegatedCoverSheetSecondaryTransition(
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    const Curve curve = Curves.linearToEaseOut;
    const Curve reverseCurve = Curves.easeInToLinear;
    final curvedAnimation = CurvedAnimation(
      curve: curve,
      reverseCurve: reverseCurve,
      parent: secondaryAnimation,
    );

    final Animation<Offset> slideAnimation = curvedAnimation.drive(_kMidUpTween);
    final Animation<double> scaleAnimation = curvedAnimation.drive(_kScaleTween);
    curvedAnimation.dispose();

    return SlideTransition(
      position: slideAnimation,
      transformHitTests: false,
      child: ScaleTransition(
        scale: scaleAnimation,
        filterQuality: FilterQuality.medium,
        alignment: Alignment.topCenter,
        child: ClipRSuperellipse(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: child,
        ),
      ),
    );
  }

  @override
  State<LdModalSheetTransition> createState() => _LdModalSheetTransitionState();
}

class _LdModalSheetTransitionState extends State<LdModalSheetTransition> with SingleTickerProviderStateMixin {
  // Controls the top padding animation when the sheet is being slightly stretched upward.
  late AnimationController _stretchDragController;

  // Animates the top padding of the sheet based on the _stretchDragController’s value.
  late Animation<double> _stretchDragAnimation;

  // The offset animation when this page is being covered by another sheet.
  late Animation<Offset> _secondaryPositionAnimation;

  // The scale animation when this page is being covered by another sheet.
  late Animation<double> _secondaryScaleAnimation;

  // Curve of primary page which is coming in to cover another route.
  CurvedAnimation? _primaryPositionCurve;

  // Curve of secondary page which is becoming covered by another sheet.
  CurvedAnimation? _secondaryPositionCurve;

  @override
  void initState() {
    super.initState();

    _stretchDragController = AnimationController(
      duration: const Duration(microseconds: 1),
      vsync: this,
    );
    _setupAnimation();
  }

  @override
  void didUpdateWidget(covariant LdModalSheetTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.primaryRouteAnimation != widget.primaryRouteAnimation ||
        oldWidget.secondaryRouteAnimation != widget.secondaryRouteAnimation) {
      _disposeCurve();
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    _disposeCurve();
    _stretchDragController.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _primaryPositionCurve = CurvedAnimation(
      curve: Curves.fastEaseInToSlowEaseOut,
      reverseCurve: Curves.fastEaseInToSlowEaseOut.flipped,
      parent: widget.primaryRouteAnimation,
    );
    _secondaryPositionCurve = CurvedAnimation(
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.easeInToLinear,
      parent: widget.secondaryRouteAnimation,
    );
    // Maintain the same stretch distance (0.008 of screen height) regardless of custom topGap.
    const double stretchDistance = _kTopGapRatio - _kStretchedTopGapRatio;
    final double stretchedTopGap = widget.topGap - stretchDistance;
    _stretchDragAnimation = _stretchDragController.drive(
      Tween<double>(begin: widget.topGap, end: stretchedTopGap),
    );
    _secondaryPositionAnimation = _secondaryPositionCurve!.drive(_kMidUpTween);
    _secondaryScaleAnimation = _secondaryPositionCurve!.drive(_kScaleTween);
  }

  void _disposeCurve() {
    _primaryPositionCurve?.dispose();
    _secondaryPositionCurve?.dispose();
    _primaryPositionCurve = null;
    _secondaryPositionCurve = null;
  }

  Widget _coverSheetPrimaryTransition(
    BuildContext context,
    Animation<double> animation,
    bool linearTransition,
    Widget? child,
  ) {
    final Animatable<Offset> offsetTween =
        CupertinoSheetRoute.hasParentSheet(context) ? _kBottomUpTweenWhenCoveringOtherSheet : _kBottomUpTween;

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: linearTransition ? Curves.linear : Curves.fastEaseInToSlowEaseOut,
      reverseCurve: linearTransition ? Curves.linear : Curves.fastEaseInToSlowEaseOut.flipped,
    );

    final Animation<Offset> positionAnimation = curvedAnimation.drive(offsetTween);

    curvedAnimation.dispose();

    return SlideTransition(position: positionAnimation, child: child);
  }

  Widget _coverSheetSecondaryTransition(Animation<double> secondaryAnimation, Widget? child) {
    return SlideTransition(
      position: _secondaryPositionAnimation,
      transformHitTests: false,
      child: ScaleTransition(
        scale: _secondaryScaleAnimation,
        filterQuality: FilterQuality.medium,
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider.value(
      value: _stretchDragController,
      child: SizedBox.expand(
        child: AnimatedBuilder(
          animation: _stretchDragAnimation,
          builder: (BuildContext context, Widget? child) {
            return Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.heightOf(context) * _stretchDragAnimation.value,
              ),
              child: _coverSheetSecondaryTransition(
                widget.secondaryRouteAnimation,
                  _coverSheetPrimaryTransition(
                  context,
                  widget.primaryRouteAnimation,
                  widget.linearTransition,
                  widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
