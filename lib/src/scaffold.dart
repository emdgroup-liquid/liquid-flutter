import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:provider/provider.dart';

enum LdAppBarScrollBehavior {
  static,
  mobileOnly,
  always,
}

enum EffectivePosition {
  top,
  bottom,
}

enum AppBarRole {
  primary,
  secondary,
}

class LdScaffold extends StatefulWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? secondaryAppBar;

  final Color? backgroundColor;
  final Widget? drawer;
  final String? debugName;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final double drawerWidth;

  final double? reflowBreakpoint;
  final SingleActivator? toggleDrawerShortcut;
  final LdScaffoldAppBarPlacement secondaryAppBarPlacement;
  final LdScaffoldAppBarPlacement appBarPlacement;
  final LdAppBarScrollBehavior appBarScrollBehavior;
  final LdAppBarScrollBehavior secondaryAppBarScrollBehavior;

  final TextEditingController? searchController;
  final ScrollController? primaryScrollController;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('debugName', debugName));
    properties.add(EnumProperty<LdScaffoldAppBarPlacement>('appBarPlacement', appBarPlacement));
    properties.add(EnumProperty<LdScaffoldAppBarPlacement>('secondaryAppBarPlacement', secondaryAppBarPlacement));
    properties.add(EnumProperty<LdAppBarScrollBehavior>('appBarScrollBehavior', appBarScrollBehavior));
    properties
        .add(EnumProperty<LdAppBarScrollBehavior>('secondaryAppBarScrollBehavior', secondaryAppBarScrollBehavior));
    properties.add(FlagProperty('extendBodyBehindAppBar', value: extendBodyBehindAppBar, ifTrue: 'enabled'));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(DoubleProperty('drawerWidth', drawerWidth));
    properties.add(DoubleProperty('reflowBreakpoint', reflowBreakpoint));
    properties.add(DiagnosticsProperty<bool?>('resizeToAvoidBottomInset', resizeToAvoidBottomInset));
    properties.add(DiagnosticsProperty<Widget?>('appBar', appBar));
    properties.add(DiagnosticsProperty<Widget?>('secondaryAppBar', secondaryAppBar));
    properties.add(DiagnosticsProperty<Widget?>('drawer', drawer));
    properties.add(DiagnosticsProperty<TextEditingController?>('searchController', searchController));
    properties.add(DiagnosticsProperty<ScrollController?>('primaryScrollController', primaryScrollController));
    properties.add(DiagnosticsProperty<SingleActivator?>('toggleDrawerShortcut', toggleDrawerShortcut));
  }

  const LdScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.debugName,
    this.toggleDrawerShortcut,
    this.secondaryAppBar,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.drawer,
    this.drawerWidth = 304,
    this.reflowBreakpoint = 900,
    this.resizeToAvoidBottomInset,
    this.secondaryAppBarPlacement = LdScaffoldAppBarPlacement.mobileBottomDesktopTop,
    this.appBarPlacement = LdScaffoldAppBarPlacement.top,
    this.appBarScrollBehavior = LdAppBarScrollBehavior.static,
    this.secondaryAppBarScrollBehavior = LdAppBarScrollBehavior.static,
    this.searchController,
    this.primaryScrollController,
  });

  @override
  State<LdScaffold> createState() => LdScaffoldState();
}

class LdScaffoldAppBarState {
  final double verticalMargin;
  final double innerHeight;
  final double offset;
  final bool willHide;
  final EffectivePosition effectivePosition;

  const LdScaffoldAppBarState({
    required this.verticalMargin,
    required this.innerHeight,
    required this.offset,
    required this.effectivePosition,
    required this.willHide,
  });

  LdScaffoldAppBarState copyWith({
    double? verticalMargin,
    double? innerHeight,
    double? offset,
    EffectivePosition? effectivePosition,
    bool? willHide,
  }) {
    return LdScaffoldAppBarState(
      verticalMargin: verticalMargin ?? this.verticalMargin,
      innerHeight: innerHeight ?? this.innerHeight,
      offset: offset ?? this.offset,
      effectivePosition: effectivePosition ?? this.effectivePosition,
      willHide: willHide ?? this.willHide,
    );
  }

  double get effectiveHeight {
    return verticalMargin + innerHeight + (willHide ? offset : 0);
  }

  double get effectiveInnerHeight {
    return max(0, innerHeight - (willHide ? offset : 0));
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DoubleProperty('verticalMargin', verticalMargin));
    properties.add(DoubleProperty('innerHeight', innerHeight));
    properties.add(DoubleProperty('offset', offset));
    properties.add(DoubleProperty('effectiveHeight', effectiveHeight));
    properties.add(EnumProperty<EffectivePosition>('effectivePosition', effectivePosition));
  }

  @override
  String toString() {
    return '''LdScaffoldAppBarState(
      verticalMargin: $verticalMargin,
      innerHeight: $innerHeight,
      offset: $offset,
      effectivePosition: $effectivePosition,
    )''';
  }
}

class LdScaffoldLayoutState {
  final ValueNotifier<double> bodyScrollOffset;
  final ValueNotifier<double> drawerScrollOffset;
  final LdScaffoldSlot slot;
  final LdScaffoldLayoutState? parentLayoutState;
  final String? debugName;
  final bool isScrolled;

  final LdScaffoldAppBarState? appBarState;
  final LdScaffoldAppBarState? secondaryAppBarState;

  const LdScaffoldLayoutState({
    required this.slot,
    required this.bodyScrollOffset,
    required this.drawerScrollOffset,
    required this.parentLayoutState,
    this.debugName,
    this.isScrolled = false,
    this.appBarState,
    this.secondaryAppBarState,
  });

  int get level {
    if (parentLayoutState == null) {
      return 0;
    }
    return parentLayoutState!.level + 1;
  }

  /// Returns the total height of the app bars in the tree. Does not take into account the scroll effect.
  EdgeInsets get totalInsets {
    List<LdScaffoldAppBarState> topAppBars = [];
    List<LdScaffoldAppBarState> bottomAppBars = [];

    // Walk up the tree and collect the app bars
    LdScaffoldLayoutState? currentLayoutState = this;
    while (currentLayoutState != null) {
      final appBarState = currentLayoutState.appBarState;
      final secondaryAppBarState = currentLayoutState.secondaryAppBarState;
      if (secondaryAppBarState?.effectivePosition == EffectivePosition.top) {
        topAppBars.add(secondaryAppBarState!);
      } else if (secondaryAppBarState?.effectivePosition == EffectivePosition.bottom) {
        bottomAppBars.add(secondaryAppBarState!);
      }
      if (appBarState?.effectivePosition == EffectivePosition.top) {
        topAppBars.add(appBarState!);
      } else if (appBarState?.effectivePosition == EffectivePosition.bottom) {
        bottomAppBars.add(appBarState!);
      }

      currentLayoutState = currentLayoutState.parentLayoutState;
    }

    double top = 0;
    double bottom = 0;

    for (var appBar in topAppBars) {
      top += appBar.innerHeight;
    }
    for (var appBar in bottomAppBars) {
      bottom += appBar.innerHeight;
    }

    if (topAppBars.isNotEmpty) {
      top += topAppBars.last.verticalMargin;
    }
    if (bottomAppBars.isNotEmpty) {
      bottom += bottomAppBars.last.verticalMargin;
    }

    return EdgeInsets.only(top: top, bottom: bottom);
  }

  String toDebugString() {
    return "$level - $debugName - $slot - ${appBarState?.effectiveHeight} - ${secondaryAppBarState?.effectiveHeight} \n ${parentLayoutState?.toDebugString()}";
  }

  int levelForEffectivePosition() {
    final effectivePosition = slot.effectivePosition;
    int level = 0;
    LdScaffoldLayoutState? currentLayoutState = parentLayoutState;
    while (currentLayoutState != null) {
      if (currentLayoutState.appBarState?.effectivePosition == effectivePosition) {
        level++;
      }
      if (currentLayoutState.secondaryAppBarState?.effectivePosition == effectivePosition) {
        level++;
      }
      currentLayoutState = currentLayoutState.parentLayoutState;
    }
    return level;
  }

  double effectiveHeightOfOthers(EffectivePosition effectivePosition, AppBarRole appBarRole) {
    List<LdScaffoldAppBarState> appBars = [];

    // Walk up the tree and collect the app bars
    LdScaffoldLayoutState? currentLayoutState = parentLayoutState;
    while (currentLayoutState != null) {
      final appBarState = currentLayoutState.appBarState;
      final secondaryAppBarState = currentLayoutState.secondaryAppBarState;
      if (appBarState?.effectivePosition == effectivePosition) {
        appBars.add(appBarState!);
      }
      if (secondaryAppBarState?.effectivePosition == effectivePosition) {
        appBars.add(secondaryAppBarState!);
      }
      currentLayoutState = currentLayoutState.parentLayoutState;
    }

    double total = 0;

    for (var appBar in appBars) {
      total += appBar.effectiveInnerHeight;
    }

    if (slot.role == AppBarRole.secondary && appBarState?.effectivePosition == effectivePosition) {
      total += appBarState?.effectiveInnerHeight ?? 0;
    }

    return total;
  }

  LdScaffoldLayoutState copyWith({
    ValueNotifier<double>? bodyScrollOffset,
    ValueNotifier<double>? drawerScrollOffset,
    LdScaffoldSlot? slot,
    LdScaffoldLayoutState? parentLayoutState,
    String? debugName,
    LdScaffoldAppBarState? appBarState,
    LdScaffoldAppBarState? secondaryAppBarState,
    bool? isScrolled,
  }) {
    return LdScaffoldLayoutState(
      debugName: debugName ?? this.debugName,
      bodyScrollOffset: bodyScrollOffset ?? this.bodyScrollOffset,
      drawerScrollOffset: drawerScrollOffset ?? this.drawerScrollOffset,
      parentLayoutState: parentLayoutState ?? this.parentLayoutState,
      slot: slot ?? this.slot,
      appBarState: appBarState ?? this.appBarState,
      secondaryAppBarState: secondaryAppBarState ?? this.secondaryAppBarState,
      isScrolled: isScrolled ?? this.isScrolled,
    );
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(StringProperty('debugName', debugName));
    properties.add(IntProperty('level', level));
    properties.add(EnumProperty<LdScaffoldSlot>('slot', slot));
    properties.add(DoubleProperty('bodyScrollOffset', bodyScrollOffset.value));
    properties.add(DoubleProperty('drawerScrollOffset', drawerScrollOffset.value));
    properties.add(DiagnosticsProperty<EdgeInsets>('effectiveInsets', totalInsets));
    properties.add(DiagnosticsProperty<LdScaffoldAppBarState?>('appBarState', appBarState));
    properties.add(DiagnosticsProperty<LdScaffoldAppBarState?>('secondaryAppBarState', secondaryAppBarState));
    properties.add(DiagnosticsProperty<LdScaffoldLayoutState?>('parentLayoutState', parentLayoutState));
  }

  @override
  String toString() {
    return '''LdScaffoldLayoutState(
    level: $level, 
    parentLayoutState: ${parentLayoutState?.toString().split('\n').join('\n    ')}, 
    slot: $slot,
    bodyScrollOffset: $bodyScrollOffset,
    drawerScrollOffset: $drawerScrollOffset,
    appBarState: ${appBarState?.toString().split('\n').join('\n    ')},
    secondaryAppBarState: ${secondaryAppBarState?.toString().split('\n').join('\n    ')},
    )''';
  }
}

enum LdScaffoldAppBarPlacement {
  mobileTopDesktopBottom,
  mobileBottomDesktopTop,
  bottom,
  top,
}

enum LdScaffoldSlot {
  body,
  appBarTop,
  appBarBottom,
  secondaryAppBarTop,
  secondaryAppBarBottom,
}

extension EffectivePositionExtension on LdScaffoldSlot {
  EffectivePosition? get effectivePosition {
    return switch (this) {
      LdScaffoldSlot.appBarTop => EffectivePosition.top,
      LdScaffoldSlot.appBarBottom => EffectivePosition.bottom,
      LdScaffoldSlot.secondaryAppBarTop => EffectivePosition.top,
      LdScaffoldSlot.secondaryAppBarBottom => EffectivePosition.bottom,
      _ => null,
    };
  }

  AppBarRole? get role {
    return switch (this) {
      LdScaffoldSlot.appBarTop => AppBarRole.primary,
      LdScaffoldSlot.appBarBottom => AppBarRole.primary,
      LdScaffoldSlot.secondaryAppBarTop => AppBarRole.secondary,
      LdScaffoldSlot.secondaryAppBarBottom => AppBarRole.secondary,
      _ => null,
    };
  }
}

class LdScaffoldState extends State<LdScaffold> {
  final StreamController<bool> _drawerStreamController = StreamController<bool>.broadcast();
  final StreamController<Intent> _intentRouterController = StreamController.broadcast();

  final _bodyScrollOffset = ValueNotifier<double>(0);
  final _drawerScrollOffset = ValueNotifier<double>(0);

  double _lastScrollOffset = 0.0;

  final FocusNode _bottomNavigationBarFocusNode = FocusNode();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  ScrollController? _internalScrollController;

  Stream<bool> get drawerStream => _drawerStreamController.stream;
  bool get hasDrawer => widget.drawer != null;
  Stream<Intent> get intentRouter => _intentRouterController.stream;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('bodyScrollOffset', _bodyScrollOffset.value));
    properties.add(DoubleProperty('drawerScrollOffset', _drawerScrollOffset.value));
    properties.add(DoubleProperty('lastScrollOffset', _lastScrollOffset));
    properties.add(FlagProperty('hasDrawer', value: hasDrawer, ifTrue: 'enabled'));
    properties.add(DiagnosticsProperty<LdScaffoldAppBarState?>('appBarState', _appBarState));
    properties.add(DiagnosticsProperty<LdScaffoldAppBarState?>('secondaryAppBarState', _secondaryAppBarState));
    properties.add(DiagnosticsProperty<LdDrawerState?>('drawerState', _drawerState));
    properties.add(DiagnosticsProperty<ScrollController?>('effectiveScrollController', effectiveScrollController));
    properties.add(DiagnosticsProperty<ScrollController?>('internalScrollController', _internalScrollController));
    properties.add(DiagnosticsProperty<FocusNode>('bottomNavigationBarFocusNode', _bottomNavigationBarFocusNode));
    properties.add(DiagnosticsProperty<FocusScopeNode>('focusScopeNode', _focusScopeNode));
  }

  ScrollController get effectiveScrollController {
    final controller = widget.primaryScrollController ?? _internalScrollController!;
    return controller;
  }

  LdScaffoldAppBarState? _appBarState;
  LdScaffoldAppBarState? _secondaryAppBarState;

  void onAppBarMarginChange(LdScaffoldSlot slot, EdgeInsets margin) {
    if (slot.role == AppBarRole.primary) {
      if (_appBarState?.verticalMargin == margin.vertical) {
        return;
      }
      _appBarState = _appBarState?.copyWith(
        verticalMargin: margin.vertical,
      );
    } else {
      if (_secondaryAppBarState?.verticalMargin == margin.vertical) {
        return;
      }
      _secondaryAppBarState = _secondaryAppBarState?.copyWith(
        verticalMargin: margin.vertical,
      );
    }
    setState(() {});
  }

  void onAppBarSizeChange(AppBarRole role, Size size) {
    if (role == AppBarRole.primary) {
      if (_appBarState?.innerHeight == size.height) {
        return;
      }
      _appBarState = _appBarState?.copyWith(
        innerHeight: size.height,
      );
    } else {
      if (_secondaryAppBarState?.innerHeight == size.height) {
        return;
      }
      _secondaryAppBarState = _secondaryAppBarState?.copyWith(
        innerHeight: size.height,
      );
    }
    setState(() {});
  }

  LdDrawerState? _drawerState;

  SingleActivator get toggleDrawerShortcut =>
      widget.toggleDrawerShortcut ??
      const SingleActivator(
        LogicalKeyboardKey.keyS,
        meta: true,
      );

  BoxDecoration? get _scaffoldDecoration {
    final theme = LdTheme.of(context, listen: true);
    Color backgroundColor = widget.backgroundColor ?? theme.background;

    return BoxDecoration(
      color: backgroundColor,
    );
  }

  @override
  void initState() {
    super.initState();

    _bodyScrollOffset.addListener(_handleBodyScrollOffsetChange);

    // Create internal scroll controller if none provided
    if (widget.primaryScrollController == null) {
      _internalScrollController = ScrollController();
    }
  }

  LdScaffoldLayoutState? _parentLayoutState(BuildContext context) {
    return context.watch<LdScaffoldLayoutState?>();
  }

  bool get isDrawerOpen => _drawerState?.isOpen ?? false;

  void _onDrawerStateChange(LdDrawerState drawerState) {
    setState(() {
      _drawerState = drawerState;
    });
  }

  void scrollToTop() {
    final controller = effectiveScrollController;
    if (controller.hasClients) {
      controller.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  LdScaffoldLayoutState _layoutState(BuildContext context) {
    return LdScaffoldLayoutState(
      debugName: widget.debugName,
      parentLayoutState: _parentLayoutState(context),
      slot: LdScaffoldSlot.body,
      appBarState: _appBarState,
      secondaryAppBarState: _secondaryAppBarState,
      bodyScrollOffset: _bodyScrollOffset,
      drawerScrollOffset: _drawerScrollOffset,
      isScrolled: _lastScrollOffset > 5,
    );
  }

  void openDrawer() {
    _intentRouterController.add(const OpenDrawerIntent());
  }

  void closeDrawer() {
    if (!hasDrawer) {
      final parent = context.findAncestorStateOfType<LdScaffoldState>();
      if (parent != null) {
        parent.closeDrawer();
      }
    }
    _intentRouterController.add(const CloseDrawerIntent());
  }

  void toggleDrawer() {
    _intentRouterController.add(const ToggleDrawerIntent());
  }

  EdgeInsets _bodyPadding(BuildContext context) {
    return _layoutState(context).totalInsets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: _scaffoldDecoration ?? const BoxDecoration(),
      child: Shortcuts(
        shortcuts: {
          toggleDrawerShortcut: const ToggleDrawerIntent(),
          const SingleActivator(LogicalKeyboardKey.keyF, meta: true): const SearchIntent(),
        },
        child: Actions(
          actions: {
            SearchIntent: CallbackAction(
              onInvoke: (intent) {
                _intentRouterController.add(intent);
                return null;
              },
            )
          },
          child: LayoutBuilder(builder: (context, constraints) {
            final layoutState = _layoutState(context);

            final bodyStack = Stack(children: [
              // Body
              Positioned(
                  top: 0,
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: Stack(
                    children: [
                      // Body
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            padding: _bodyPadding(context),
                          ),
                          child: ScrollObserver(
                            position: _bodyScrollOffset,
                            child: Provider.value(
                              value: layoutState.copyWith(slot: LdScaffoldSlot.body),
                              child: PrimaryScrollController(
                                controller: effectiveScrollController,
                                child: LdNotificationProvider(
                                  debugLabel: "Scaffold Body Provider ${widget.debugName}",
                                  child: LdNotificationPortal(
                                    debugLabel: "Scaffold Body ${widget.debugName}",
                                    child: widget.body,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Navigation Bar
                      if (widget.secondaryAppBar != null)
                        _placeSecondaryNavigationBar(
                          context,
                          Focus(
                            focusNode: _bottomNavigationBarFocusNode,
                            child: Provider.value(
                              value: layoutState.copyWith(
                                slot: _effectiveSecondaryAppBarPosition == EffectivePosition.top
                                    ? LdScaffoldSlot.secondaryAppBarTop
                                    : LdScaffoldSlot.secondaryAppBarBottom,
                              ),
                              child: widget.secondaryAppBar!,
                            ),
                          ),
                        ),
                      // AppBar
                      if (widget.appBar != null)
                        _placeAppBar(
                          context,
                          Provider.value(
                            value: layoutState.copyWith(
                              slot: _effectiveAppBarPosition == EffectivePosition.top
                                  ? LdScaffoldSlot.appBarTop
                                  : LdScaffoldSlot.appBarBottom,
                            ),
                            child: widget.appBar!,
                          ),
                        ),
                    ],
                  ))
            ]);

            if (widget.drawer != null) {
              return _LdDrawerLayout(
                intents: intentRouter,
                drawerWidth: widget.drawerWidth,
                onStateChange: _onDrawerStateChange,
                drawer: RepaintBoundary(
                  child: FocusScope(
                    node: _focusScopeNode,
                    child: ScrollObserver(
                      position: _drawerScrollOffset,
                      child: widget.drawer!,
                    ),
                  ),
                ),
                body: bodyStack,
                reflowBreakpoint: widget.reflowBreakpoint ?? 900,
              );
            }

            return Material(
              type: MaterialType.transparency,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: _scaffoldDecoration,
                child: bodyStack,
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(LdScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appBar == null) {
      _appBarState = null;
    }

    if (widget.appBar == null) {
      _appBarState = null;
    }

    if (widget.secondaryAppBar == null) {
      _secondaryAppBarState = null;
    }

    if (oldWidget.appBarScrollBehavior != widget.appBarScrollBehavior) {
      _appBarState = _appBarState?.copyWith(
        offset: 0.0,
      );
    }
    if (oldWidget.secondaryAppBarScrollBehavior != widget.secondaryAppBarScrollBehavior) {
      _secondaryAppBarState = _secondaryAppBarState?.copyWith(
        offset: 0.0,
      );
    }
    if (oldWidget.appBarPlacement != widget.appBarPlacement) {
      _appBarState = null;
    }
    if (oldWidget.secondaryAppBarPlacement != widget.secondaryAppBarPlacement) {
      _secondaryAppBarState = null;
    }
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _drawerStreamController.close();
    _bottomNavigationBarFocusNode.dispose();
    _intentRouterController.close();
    _internalScrollController?.dispose();

    super.dispose();
  }

  void _handleBodyScrollOffsetChange() async {
    await Future.delayed(Duration.zero);
    double scrollOffset = _bodyScrollOffset.value;

    if (_lastScrollOffset == scrollOffset) {
      return;
    }

    final layoutState = context.read<LdScaffoldLayoutState?>();
    final level = layoutState?.level ?? 0;
    scrollOffset = scrollOffset - level * 150;

    _updateAppBarOffset(AppBarRole.primary, scrollOffset);
    _updateAppBarOffset(AppBarRole.secondary, scrollOffset);

    _lastScrollOffset = scrollOffset;
    if (mounted) {
      setState(() {});
    }
  }

  void _updateAppBarOffset(AppBarRole role, double scrollOffset) {
    var appBarState = role == AppBarRole.primary ? _appBarState : _secondaryAppBarState;

    if (appBarState == null) {
      return;
    }

    // Calculate scroll direction and velocity
    final double scrollDelta = scrollOffset - _lastScrollOffset;
    final bool isScrollingDown = scrollDelta > 0;
    final bool isScrollingUp = scrollDelta < 0;

    double maxOffset = appBarState.innerHeight + appBarState.verticalMargin;

    // Bottom appBar: hide downward (positive offset) down means delta is positive.
    if (isScrollingDown) {
      appBarState = appBarState.copyWith(
        offset: min(appBarState.offset + scrollDelta * 0.5, maxOffset),
      );
    } else if (isScrollingUp) {
      appBarState = appBarState.copyWith(
        offset: max(appBarState.offset + scrollDelta, 0),
      );
    }

    switch (role) {
      case AppBarRole.primary:
        _appBarState = appBarState;
        break;
      case AppBarRole.secondary:
        _secondaryAppBarState = appBarState;
        break;
    }
  }

  EffectivePosition get _effectiveAppBarPosition {
    return switch (widget.appBarPlacement) {
      LdScaffoldAppBarPlacement.mobileTopDesktopBottom => switch (LdTheme.of(context).platform.isMobile) {
          true => EffectivePosition.top,
          false => EffectivePosition.bottom,
        },
      LdScaffoldAppBarPlacement.mobileBottomDesktopTop => switch (LdTheme.of(context).platform.isMobile) {
          true => EffectivePosition.bottom,
          false => EffectivePosition.top,
        },
      LdScaffoldAppBarPlacement.bottom => EffectivePosition.bottom,
      LdScaffoldAppBarPlacement.top => EffectivePosition.top,
    };
  }

  EffectivePosition get _effectiveSecondaryAppBarPosition {
    return switch (widget.secondaryAppBarPlacement) {
      LdScaffoldAppBarPlacement.mobileTopDesktopBottom => switch (LdTheme.of(context).platform.isMobile) {
          true => EffectivePosition.bottom,
          false => EffectivePosition.top,
        },
      LdScaffoldAppBarPlacement.mobileBottomDesktopTop => switch (LdTheme.of(context).platform.isMobile) {
          true => EffectivePosition.bottom,
          false => EffectivePosition.top,
        },
      LdScaffoldAppBarPlacement.bottom => EffectivePosition.bottom,
      LdScaffoldAppBarPlacement.top => EffectivePosition.top,
    };
  }

  Widget _placeAppBar(BuildContext context, Widget appBar) {
    final effectivePosition = _effectiveAppBarPosition;
    final shouldHideAppBar = _shouldHideAppBar(AppBarRole.primary);

    _appBarState = LdScaffoldAppBarState(
      verticalMargin: _appBarState?.verticalMargin ?? 0,
      innerHeight: _appBarState?.innerHeight ?? 0,
      offset: _appBarState?.offset ?? 0,
      effectivePosition: effectivePosition,
      willHide: shouldHideAppBar,
    );

    double offset = ((_appBarState?.offset ?? 0));

    if (effectivePosition == EffectivePosition.top) {
      offset = -offset;
    }

    final transformedAppBar = LdWrapConditional(
      condition: shouldHideAppBar,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, offset),
        child: child,
      ),
      child: appBar,
    );

    if (effectivePosition == EffectivePosition.top) {
      // Place the appBar at the top
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: transformedAppBar,
      );
    }

    // Place the appBar at the bottom
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: transformedAppBar,
    );
  }

  Widget _placeSecondaryNavigationBar(BuildContext context, Widget secondaryNavigationBar) {
    final effectivePosition = _effectiveSecondaryAppBarPosition;
    final shouldHideSecondaryAppBar = _shouldHideAppBar(AppBarRole.secondary);

    _secondaryAppBarState ??= LdScaffoldAppBarState(
      verticalMargin: _secondaryAppBarState?.verticalMargin ?? 0,
      innerHeight: _secondaryAppBarState?.innerHeight ?? 0,
      offset: _secondaryAppBarState?.offset ?? 0,
      effectivePosition: effectivePosition,
      willHide: shouldHideSecondaryAppBar,
    );
    double offset = ((_secondaryAppBarState?.offset ?? 0) - 100).clamp(0, double.infinity);
    if (effectivePosition == EffectivePosition.top) {
      offset = -offset;
    }
    final transformedSecondaryAppBar = LdWrapConditional(
      condition: shouldHideSecondaryAppBar,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, offset),
        child: child,
      ),
      child: secondaryNavigationBar,
    );

    if (effectivePosition == EffectivePosition.top) {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: transformedSecondaryAppBar,
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: transformedSecondaryAppBar,
    );
  }

  bool _shouldHideAppBar(AppBarRole role) {
    final isMobile = LdTheme.of(context).platform.isMobile;
    return switch (role) {
      AppBarRole.primary => switch (widget.appBarScrollBehavior) {
          LdAppBarScrollBehavior.static => false,
          LdAppBarScrollBehavior.mobileOnly => isMobile,
          LdAppBarScrollBehavior.always => true,
        },
      AppBarRole.secondary => switch (widget.secondaryAppBarScrollBehavior) {
          LdAppBarScrollBehavior.static => false,
          LdAppBarScrollBehavior.mobileOnly => isMobile,
          LdAppBarScrollBehavior.always => true,
        },
    };
  }

  static LdScaffoldState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<LdScaffoldState>();
  }
}

class ScrollObserver extends StatelessWidget {
  final Widget child;
  final ValueNotifier<double> position;

  const ScrollObserver({super.key, required this.child, required this.position});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth == 0) {
          if (notification.metrics.axis == Axis.vertical) {
            position.value = notification.metrics.pixels;
          }
        }
        return false;
        //return true;
      },
      child: child,
    );
  }
}

extension on List<Widget> {
  List<Widget> reverseIf(bool condition) {
    if (condition) {
      return reversed.toList();
    }
    return this;
  }
}

extension AtLeastEdgeInsets on EdgeInsets {
  EdgeInsets atLeast(EdgeInsets other) {
    return EdgeInsets.fromLTRB(
      max(left, other.left),
      max(top, other.top),
      max(right, other.right),
      max(bottom, other.bottom),
    );
  }
}

enum LdDrawerSlot {
  drawer,
  body,
}

class LdDrawerState {
  final bool isOpen;
  final bool isSideBySide;

  const LdDrawerState({required this.isOpen, required this.isSideBySide});

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(FlagProperty('isOpen', value: isOpen, ifTrue: 'open'));
    properties.add(FlagProperty('isSideBySide', value: isSideBySide, ifTrue: 'enabled'));
  }
}

class _LdDrawerLayout extends StatefulWidget {
  final Widget drawer;
  final Widget body;
  final double reflowBreakpoint;
  final Stream<Intent> intents;
  final void Function(LdDrawerState) onStateChange;

  final double drawerWidth;
  const _LdDrawerLayout({
    required this.drawer,
    required this.body,
    required this.reflowBreakpoint,
    required this.drawerWidth,
    required this.onStateChange,
    required this.intents,
  });

  @override
  State<_LdDrawerLayout> createState() => _LdDrawerLayoutState();
}

class _LdDrawerLayoutState extends State<_LdDrawerLayout> {
  bool _isDragging = false;
  LocalHistoryEntry? _historyEntry;

  double _drawerOffset = 0;
  double _effectiveDrawerWidth = 0;
  bool _isSideBySide = false;

  StreamSubscription<Intent>? _intentSubscription;

  @override
  initState() {
    super.initState();
    _intentSubscription = widget.intents.listen(_handleIntent);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_isSideBySide) {
        _showDrawer();
      }
    });
  }

  void _handleIntent(Intent intent) {
    if (intent is OpenDrawerIntent) {
      _showDrawer();
    } else if (intent is CloseDrawerIntent) {
      _hideDrawer();
    } else if (intent is ToggleDrawerIntent) {
      if (_isDrawerOpen) {
        _hideDrawer();
      } else {
        _showDrawer();
      }
    }
  }

  @override
  void dispose() {
    _intentSubscription?.cancel();
    _historyEntry?.remove();
    super.dispose();
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isDragging) {
      _isDragging = false;
    }
    if (_drawerOffset > _effectiveDrawerWidth / 2) {
      _ensureHistoryEntry();
      setState(() {
        _drawerOffset = _effectiveDrawerWidth;
      });
    } else {
      _handleHistoryEntryRemoved();
    }
    _onStateChange();
  }

  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(
          onRemove: _handleHistoryEntryRemoved,
          impliesAppBarDismissal: false,
        );
      }
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging && (details.localPosition.dx - _drawerOffset).abs() <= 75) {
      _isDragging = true;
    }
    if (_isDragging) {
      setState(() {
        _drawerOffset = details.localPosition.dx;
        _drawerOffset = _drawerOffset.clamp(0, _effectiveDrawerWidth);
      });
    }
  }

  void _onStateChange() {
    widget.onStateChange(LdDrawerState(isOpen: _isDrawerOpen, isSideBySide: _isSideBySide));
  }

  void _handleHistoryEntryRemoved() {
    _hideDrawer();
  }

  void _showDrawer() {
    setState(() {
      _drawerOffset = _effectiveDrawerWidth;
    });
    _ensureHistoryEntry();
    _onStateChange();
  }

  void _hideDrawer() {
    setState(() {
      _drawerOffset = 0;
    });
    _historyEntry?.remove();
    _onStateChange();
  }

  bool get _isDrawerOpen => _drawerOffset > _effectiveDrawerWidth / 2;

  Border? get _drawerBorder {
    return Border(
      right: BorderSide(
        color: LdTheme.of(context).border,
        width: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Actions(
        actions: {
          ToggleDrawerIntent: ToggleDrawerAction(
            onToggleDrawer: () {
              if (_isDrawerOpen) {
                _hideDrawer();
              } else {
                _showDrawer();
              }
            },
          ),
          OpenDrawerIntent: CallbackAction(
            onInvoke: (intent) {
              _showDrawer();
              return null;
            },
          ),
          CloseDrawerIntent: CallbackAction(
            onInvoke: (intent) {
              _hideDrawer();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _isSideBySide = constraints.maxWidth >= widget.reflowBreakpoint;
              _effectiveDrawerWidth = min(constraints.maxWidth * 0.75, widget.drawerWidth);

              return Stack(
                children: [
                  LdSpring(
                    mass: 1,
                    springConstant: 12,
                    dampingCoefficient: 9,
                    initialPosition: 0,
                    position: _drawerOffset,
                    builder: (context, state, child) {
                      double bodyLeft, bodyWidth;
                      if (_isSideBySide) {
                        bodyLeft = state.position;
                        bodyWidth = constraints.maxWidth - state.position;
                      } else {
                        bodyLeft = 0;
                        bodyWidth = constraints.maxWidth;
                      }

                      return Positioned(
                        top: 0,
                        width: bodyWidth,
                        bottom: 0,
                        left: bodyLeft,
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                              boxShadow: [ldShadowSticky],
                              color: LdTheme.of(context).background,
                            ),
                            child: child!),
                      );
                    },
                    child: Provider.value(
                      value: LdDrawerSlot.body,
                      child: Provider.value(
                        value: LdDrawerState(isOpen: _isDrawerOpen, isSideBySide: _isSideBySide),
                        child: widget.body,
                      ),
                    ),
                  ),
                  if (_isDrawerOpen && !_isSideBySide)
                    ModalBarrier(
                      color: Colors.black.withValues(alpha: 0.5),
                      onDismiss: () {
                        _hideDrawer();
                      },
                    ),
                  LdSpring(
                    mass: 1,
                    springConstant: 12,
                    dampingCoefficient: 9,
                    initialPosition: 0,
                    position: _drawerOffset,
                    builder: (context, state, child) {
                      double drawerLeft, drawerWidth;
                      if (_isSideBySide) {
                        drawerLeft = state.position - _effectiveDrawerWidth;
                        drawerWidth = _effectiveDrawerWidth;
                      } else {
                        drawerLeft = min(0, state.position - _effectiveDrawerWidth);
                        drawerWidth = _effectiveDrawerWidth;
                      }

                      return Positioned(
                        top: 0,
                        bottom: 0,
                        width: drawerWidth,
                        left: drawerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            border: _drawerBorder,
                            color: LdTheme.of(context).background,
                          ),
                          child: child!,
                        ),
                      );
                    },
                    child: Provider.value(
                      value: LdDrawerSlot.drawer,
                      child: Provider.value(
                        value: LdDrawerState(isOpen: _isDrawerOpen, isSideBySide: _isSideBySide),
                        child: widget.drawer,
                      ),
                    ),
                  )
                ].reverseIf(_isSideBySide),
              );
            },
          ),
        ),
      ),
    );
  }
}
