import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';

enum LdContextZoomMode {
  /// Zoom on mobile
  mobileOnly,

  /// Always zoom
  always,

  /// Never zoom
  never,
}

enum LdContextPositionMode {
  /// Automatically position the menu uses [relativeTrigger] on mobile and [relativeCursor] on desktop
  auto,

  /// Position relative to the trigger
  relativeTrigger,

  /// Position relative to the cursor
  relativeCursor,
}

typedef LdContextMenuBuilder = Widget Function(
    BuildContext context, bool isShuttle, VoidCallback trigger, bool isOpen, Widget? child);

class LdContextMenuDissmissNotification extends Notification {}

class LdContextMenu extends StatefulWidget {
  const LdContextMenu({
    super.key,
    required this.builder,
    required this.menuBuilder,
    this.dismissOnOutsideTap = true,
    this.placeAboveTrigger = false,
    this.inheritTriggerWidth = false,
    this.scaleFromTrigger = true,
    this.zoomMode = LdContextZoomMode.mobileOnly,
    this.listenForTaps = true,
    this.visible,
    this.disabled = false,
    this.positionMode = LdContextPositionMode.auto,
    this.child,
    this.triggerColor,
    this.menuProviders,
  });

  final bool? visible;

  final bool placeAboveTrigger;

  final bool disabled;

  final bool dismissOnOutsideTap;

  final bool inheritTriggerWidth;

  final LdColor? triggerColor;

  final bool listenForTaps;

  final bool scaleFromTrigger;

  final List<SingleChildWidget>? Function(BuildContext context)? menuProviders;

  final LdContextZoomMode zoomMode;
  final LdContextPositionMode positionMode;

  final Widget? child;

  final LdContextMenuBuilder builder;

  final Widget Function(
    BuildContext context,
  ) menuBuilder;

  @override
  State<LdContextMenu> createState() => LdContextMenuState();
}

class LdContextMenuState extends State<LdContextMenu> {
  final GlobalKey _triggerKey = GlobalKey(debugLabel: "Trigger Key");

  RenderBox? _triggerBox;

  Offset? _cursorPosition;

  final ValueNotifier<Size> _menuSizeNotifier = ValueNotifier(Size.zero);

  bool get _mobile => LdTheme.of(context).platform.isMobile;

  bool _isOpen = false;

  @override
  void dispose() {
    _menuSizeNotifier.dispose();
    super.dispose();
  }

  bool get _shouldZoom {
    return switch (widget.zoomMode) {
      (LdContextZoomMode.mobileOnly) => _mobile,
      (LdContextZoomMode.always) => true,
      (LdContextZoomMode.never) => false,
    };
  }

  LdContextPositionMode get _effectivePositionMode {
    if (widget.positionMode == LdContextPositionMode.auto) {
      return _mobile ? LdContextPositionMode.relativeTrigger : LdContextPositionMode.relativeCursor;
    }
    return widget.positionMode;
  }

  Offset? _getTriggerPosition() {
    _triggerBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    return _triggerBox?.localToGlobal(Offset.zero);
  }

  Size? _getTriggerSize() {
    _triggerBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    return _triggerBox?.size;
  }

  void open({Offset? globalPosition}) async {
    if (widget.disabled) {
      return;
    }
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }
    _cursorPosition = globalPosition;
    setState(() {
      _isOpen = true;
    });

    await Navigator.of(context, rootNavigator: true).push(
      LdContextMenuRoute(
        scaleFromTrigger: widget.scaleFromTrigger,
        inheritTriggerWidth: widget.inheritTriggerWidth,
        placeAboveTrigger: widget.placeAboveTrigger,
        menuBuilder: (ctx) => widget.menuBuilder(ctx),
        effectivePositionMode: _effectivePositionMode,
        triggerKey: _triggerKey,
        cursorPosition: _cursorPosition,
        triggerPosition: _getTriggerPosition() ?? Offset.zero,
        triggerSize: _getTriggerSize() ?? Size.zero,
        shouldZoom: _shouldZoom,
        backgroundColor: null,
        providers: [
          ...(widget.menuProviders?.call(context) ?? []),
          ListenableProvider.value(value: LdTheme.of(context)),
          ListenableProvider.value(value: LdNotificationsController.maybeOf(context))
        ],
        child: widget.child,
      ),
    );
    setState(() {
      _isOpen = false;
    });
  }

  Widget _buildTriggerDetector(BuildContext context) {
    return GestureDetector(
      key: _triggerKey,
      onSecondaryTapDown: (details) {
        open(globalPosition: details.globalPosition);
      },
      onLongPressStart: (details) {
        if (!_mobile) {
          return;
        }
        LdHaptics.vibrate(HapticsType.heavy);
        open(globalPosition: details.globalPosition);
      },
      child: widget.builder(
        context,
        false,
        () {
          open();
        },
        _isOpen,
        widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTriggerDetector(context);
  }
}

/// A modal route for displaying a context menu, supporting custom positioning, blur, and zoom.
class LdContextMenuRoute extends ModalRoute<void> {
  final Widget Function(BuildContext) menuBuilder;

  final Offset triggerPosition;
  final GlobalKey triggerKey;
  final bool inheritTriggerWidth;
  final Size triggerSize;
  final bool scaleFromTrigger;

  final LdContextPositionMode effectivePositionMode;
  final Offset? cursorPosition;
  final bool shouldZoom;
  final Color? backgroundColor;
  final VoidCallback? onDismiss;
  final List<SingleChildWidget>? providers;
  final Widget? child;
  final bool placeAboveTrigger;

  final ValueNotifier<Size> _menuSizeNotifier = ValueNotifier(Size.zero);

  /// [providers] allows you to inject providers into the context menu route.
  LdContextMenuRoute({
    required this.menuBuilder,
    required this.effectivePositionMode,
    this.cursorPosition,
    this.placeAboveTrigger = false,
    this.shouldZoom = false,
    this.backgroundColor,
    this.scaleFromTrigger = false,
    this.onDismiss,
    required this.triggerPosition,
    required this.triggerSize,
    this.providers,
    required this.triggerKey,
    required this.child,
    required this.inheritTriggerWidth,
  });

  @override
  void dispose() {
    _menuSizeNotifier.dispose();
    super.dispose();
  }

  @override
  RouteSettings get settings => const RouteSettings(name: "ContextMenu");
  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => backgroundColor ?? Colors.transparent;

  @override
  String? get barrierLabel => 'ContextMenu';

  @override
  bool get maintainState => true;

  @override
  void didComplete(result) {
    super.didComplete(result);
    onDismiss?.call();
  }

  (Rect, Alignment, Size) _resizeMenuToScreen(
    BuildContext context,
    Size menuSize,
  ) {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;

    var mediaQuery = MediaQuery.of(context);

    if (view != null) {
      mediaQuery = MediaQueryData.fromView(view);
    }

    // Determine the reference point and size for positioning the menu
    // This can be either the trigger widget or the cursor position
    Offset triggerPosition;
    Size triggerSize;

    if (effectivePositionMode == LdContextPositionMode.relativeTrigger || cursorPosition == null) {
      // Position relative to the trigger widget (e.g., button or widget that opened the menu)
      // Add small padding (5px) to create visual spacing from the trigger
      triggerPosition = this.triggerPosition;
      if (inheritTriggerWidth) {
        triggerSize = Size(this.triggerSize.width, this.triggerSize.height + 5);
      } else {
        triggerSize = Size(this.triggerSize.width + 5, this.triggerSize.height + 5);
      }
    } else {
      // Position relative to cursor position (e.g., right-click location)
      // Use a small 5x5 size as a virtual trigger point at the cursor
      triggerPosition = cursorPosition ?? Offset.zero;
      triggerSize = const Size(5, 5);
    }

    // Calculate available screen space accounting for keyboard/insets
    // Add theme padding to ensure menu doesn't touch screen edges
    final themePadding = LdTheme.of(context).pad(size: LdSize.m);
    final viewInsets = mediaQuery.viewInsets + themePadding;

    final screenSize = mediaQuery.size;

    // Calculate the actual available space after accounting for insets
    final availableLeft = viewInsets.left;
    final availableRight = screenSize.width - viewInsets.right;
    final availableTop = viewInsets.top;
    final availableBottom = screenSize.height - viewInsets.bottom;
    final availableWidth = availableRight - availableLeft;
    final availableHeight = availableBottom - availableTop;

    // Constrain menu size to available space
    final constrainedMenuWidth = min(inheritTriggerWidth ? triggerSize.width : menuSize.width, availableWidth);
    final constrainedMenuHeight = min(menuSize.height, availableHeight);

    // Step 1: Try default position (below and right of trigger/cursor)
    // This follows reading direction
    double menuX = triggerPosition.dx;
    double menuY = triggerPosition.dy + triggerSize.height;
    bool isRightOfTrigger = true;
    bool isBelowTrigger = true;

    // Step 2: Check if menu fits on the right side
    // If not, align right edge with cursor (menu left of cursor)
    if (menuX + constrainedMenuWidth > availableRight) {
      // No space on right, place menu to the left of trigger
      menuX = triggerPosition.dx - constrainedMenuWidth;
      isRightOfTrigger = false;
    }

    // Ensure menu doesn't go off screen edges horizontally
    if (menuX < availableLeft) {
      menuX = availableLeft;
    }
    if (menuX + constrainedMenuWidth > availableRight) {
      menuX = availableRight - constrainedMenuWidth;
    }

    // Step 3: Check if menu fits below trigger
    // If not, shift up until bottom aligns with screen bottom
    if (menuY + constrainedMenuHeight > availableBottom) {
      // No space below, shift menu up
      menuY = availableBottom - constrainedMenuHeight;
      isBelowTrigger = false;
    }

    // Ensure menu doesn't go off screen edges vertically
    if (menuY < availableTop) {
      menuY = availableTop;
    }
    if (menuY + constrainedMenuHeight > availableBottom) {
      menuY = availableBottom - constrainedMenuHeight;
    }

    // Step 4: If menu still can't fit horizontally, try placing above trigger (last resort)
    // This only happens if the menu is wider than available horizontal space
    if (constrainedMenuWidth > availableWidth) {
      // Menu is too wide to fit anywhere horizontally
      // Try placing above trigger as last resort
      final aboveY = triggerPosition.dy - constrainedMenuHeight;
      if (aboveY >= availableTop) {
        menuY = aboveY;
        isBelowTrigger = false;
      }
      // If it still doesn't fit, we'll constrain it to available space
    }

    // Calculate final menu rectangle
    final menuRect = Rect.fromLTWH(
      menuX,
      menuY,
      constrainedMenuWidth,
      constrainedMenuHeight,
    );

    // Calculate alignment based on final position relative to trigger
    // Alignment determines the animation origin point
    final alignment = switch ((isRightOfTrigger, isBelowTrigger)) {
      (true, true) => Alignment.topLeft, // Menu is right and below trigger
      (true, false) => Alignment.bottomLeft, // Menu is right and above trigger
      (false, true) => Alignment.topRight, // Menu is left and below trigger
      (false, false) => Alignment.bottomRight, // Menu is left and above trigger
    };

    // Calculate maximum constraints for the menu container
    // These ensure the menu never exceeds available space
    final maxConstraints = Size(availableWidth, availableHeight);

    return (menuRect, alignment, maxConstraints);
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return ValueListenableBuilder<Size>(
        valueListenable: _menuSizeNotifier,
        builder: (context, size, child) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).maybePop();
                },
                behavior: HitTestBehavior.opaque,
              ),
            ],
          );
        });
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_menuSizeNotifier.value == Size.zero) {
      return Stack(
        children: [
          _buildOffstageMenuForMeasurement(context),
        ],
      );
    }

    return ValueListenableBuilder(
        valueListenable: _menuSizeNotifier,
        builder: (context, menuSize, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildAnimatedMenuTransition(context, menuSize, animation),
            ],
          );
        });
  }

  Widget _buildOffstageMenuForMeasurement(BuildContext context) {
    return Offstage(
      child: MeasureSize(
        onSizeChange: (size) {
          _menuSizeNotifier.value = size;
        },
        child: _wrapWithProviders(
          context,
          (context2) => menuBuilder(
            context2,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuTransition(BuildContext context, Size menuSize, Animation<double>? animation) {
    final (endRect, alignment, maxConstraints) = _resizeMenuToScreen(context, menuSize);

    // Calculate triggerRect from triggerPosition and triggerSize
    final triggerRect = Rect.fromLTWH(
      triggerPosition.dx,
      triggerPosition.dy,
      triggerSize.width,
      triggerSize.height,
    );

    return NotificationListener<LdContextMenuDissmissNotification>(
      onNotification: (notification) {
        Navigator.of(context).maybePop();

        return true;
      },
      child: Builder(builder: (context) {
        if (animation == null) {
          return Positioned(
            left: endRect.left,
            top: endRect.top,
            width: endRect.width,
            height: endRect.height,
            child: _wrapWithProviders(
              context,
              (context2) => _wrapMenuContent(
                context2,
                menuBuilder(context2),
                alignment,
                maxConstraints,
                false,
              ),
            ),
          );
        }

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            Rect animatedRect = endRect;

            animatedRect = RectTween(
              begin: triggerRect,
              end: endRect,
            ).evaluate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            )!;

            // Use Interval curve to stagger the content reveal after shape transformation
            // Content starts revealing at 70% of the animation
            final revealAnimation = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.7, 1.0, curve: Curves.decelerate),
            );

            return Positioned(
              left: animatedRect.left,
              top: animatedRect.top,
              width: animatedRect.width + 2,
              height: animatedRect.height + 2,
              child: _wrapWithProviders(
                context,
                (context2) => Stack(
                  children: [
                    // Decoration is always visible during shape transformation
                    Positioned.fill(
                      child: _wrapMenuDecoration(
                        context2,
                        alignment,
                        maxConstraints,
                        animation,
                        Opacity(
                          opacity: revealAnimation.value,
                          child: child,
                        ),
                      ),
                    ),
                    // Content is revealed with animation
                  ],
                ),
              ),
            );
          },
          child: _wrapMenuContent(
            context,
            menuBuilder(context),
            alignment,
            maxConstraints,
            animation.isAnimating,
          ),
        );
      }),
    );
  }

  Offset _getMenuOffset(Alignment alignment) {
    if (inheritTriggerWidth) {
      return switch (alignment) {
        Alignment.bottomRight => const Offset(0, -20),
        Alignment.topRight => const Offset(0, -20),
        Alignment.bottomLeft => const Offset(0, 20),
        Alignment.topLeft => const Offset(0, -20),
        _ => Offset.zero,
      };
    }
    return switch (alignment) {
      Alignment.bottomRight => const Offset(-20, -20),
      Alignment.topRight => const Offset(20, -20),
      Alignment.bottomLeft => const Offset(-20, 20),
      Alignment.topLeft => const Offset(-20, -20),
      _ => Offset.zero,
    };
  }

  Widget _wrapMenuDecoration(
    BuildContext context,
    Alignment alignment,
    Size maxConstraints,
    Animation<double> animation,
    Widget child,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxConstraints.width,
          maxHeight: maxConstraints.height,
        ),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: ColorTween(
              begin: LdTheme.of(context).surface.withAlpha(0),
              end: LdTheme.of(context).surface,
            ).evaluate(
              CurvedAnimation(
                parent: animation,
                curve: Interval(
                  0.1,
                  0.8,
                ),
              ),
            ),
            borderRadius: scaleFromTrigger
                ? BorderRadius.circular(
                    Tween<double>(
                      begin: 100,
                      end: LdTheme.of(context).radiusSize(LdSize.s),
                    ).evaluate(animation),
                  )
                : LdTheme.of(context).radius(LdSize.s),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha((animation.value * 55).toInt()), blurRadius: 12),
            ],
            border: Border.all(
              color: LdTheme.of(context).floatingBorder.withAlpha(
                    (animation.value * 255).toInt(),
                  ),
              width: LdTheme.of(context).borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _wrapMenuContent(
      BuildContext context, Widget menu, Alignment alignment, Size maxConstraints, bool isAnimating) {
    return Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxConstraints.width,
          maxHeight: maxConstraints.height,
        ),
        child: LdSpring(
          mass: 15,
          springConstant: 10,
          dampingCoefficient: 15,
          initialPosition: 1.0,
          position: 0,
          builder: (context, state, child) {
            return Opacity(
              opacity: (1 - state.position.clamp(0, 1)),
              child: Transform.translate(
                offset: _getMenuOffset(alignment) * state.position,
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            child: MeasureSize(
              onSizeChange: (size) {
                if (isAnimating) {
                  return;
                }
                _menuSizeNotifier.value = size;
              },
              child: Provider.value(
                value: LdAppBarActionDisplayMode.contextMenu,
                child: menu,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapWithProviders(BuildContext context, Widget Function(BuildContext context) builder) {
    return providers != null && providers!.isNotEmpty
        ? MultiProvider(
            providers: providers!,
            builder: (context, child) => builder(context),
          )
        : builder(context);
  }

  @override
  bool get opaque => false;
}

Future<bool> maybePopContextMenu(BuildContext context) async {
  final rootNavigatorContext = Navigator.of(context, rootNavigator: true);

  final result = await rootNavigatorContext.maybePop();
  return result;
}
