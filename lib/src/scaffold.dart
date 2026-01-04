import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/drawer_layout.dart';
import 'package:liquid_flutter/src/monkey/intents.dart';
import 'package:liquid_flutter/src/appbar/appbar_registry.dart';

enum LdAppBarScrollBehavior {
  static,
  mobileOnly,
  always,
}

class LdScaffold extends StatefulWidget {
  final Widget body;
  final List<Widget>? appBars;

  final Color? backgroundColor;
  final Widget? drawer;
  final String? debugName;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final double drawerWidth;

  final double? reflowBreakpoint;
  final SingleActivator? toggleDrawerShortcut;

  final TextEditingController? searchController;
  final ScrollController? primaryScrollController;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('debugName', debugName));
    properties.add(FlagProperty('extendBodyBehindAppBar', value: extendBodyBehindAppBar, ifTrue: 'enabled'));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(DoubleProperty('drawerWidth', drawerWidth));
    properties.add(DoubleProperty('reflowBreakpoint', reflowBreakpoint));
    properties.add(DiagnosticsProperty<bool?>('resizeToAvoidBottomInset', resizeToAvoidBottomInset));
    properties.add(DiagnosticsProperty<List<Widget>?>('appBars', appBars));
    properties.add(DiagnosticsProperty<Widget?>('drawer', drawer));
    properties.add(DiagnosticsProperty<TextEditingController?>('searchController', searchController));
    properties.add(DiagnosticsProperty<ScrollController?>('primaryScrollController', primaryScrollController));
    properties.add(DiagnosticsProperty<SingleActivator?>('toggleDrawerShortcut', toggleDrawerShortcut));
  }

  const LdScaffold({
    super.key,
    required this.body,
    this.appBars,
    this.debugName,
    this.toggleDrawerShortcut,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.drawer,
    this.drawerWidth = 304,
    this.reflowBreakpoint = 900,
    this.resizeToAvoidBottomInset,
    this.searchController,
    this.primaryScrollController,
  });

  @override
  State<LdScaffold> createState() => LdScaffoldState();
}

class LdScaffoldState extends State<LdScaffold> {
  final StreamController<bool> _drawerStreamController = StreamController<bool>.broadcast();

  final _bodyScrollOffset = ValueNotifier<double>(0);
  final _drawerScrollOffset = ValueNotifier<double>(0);

  final double _lastScrollOffset = 0.0;

  final FocusNode _bottomNavigationBarFocusNode = FocusNode();
  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  ScrollController? _internalScrollController;

  Stream<bool> get drawerStream => _drawerStreamController.stream;
  bool get hasDrawer => widget.drawer != null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('bodyScrollOffset', _bodyScrollOffset.value));
    properties.add(DoubleProperty('drawerScrollOffset', _drawerScrollOffset.value));
    properties.add(DoubleProperty('lastScrollOffset', _lastScrollOffset));
    properties.add(FlagProperty('hasDrawer', value: hasDrawer, ifTrue: 'enabled'));
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

    // Create internal scroll controller if none provided
    if (widget.primaryScrollController == null) {
      _internalScrollController = ScrollController();
    }
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

  @override
  Widget build(BuildContext context) {
    return LdNotificationProvider(
      debugLabel: "Scaffold Body Provider ${widget.debugName}",
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: _scaffoldDecoration ?? const BoxDecoration(),
        child: Shortcuts(
          shortcuts: {
            toggleDrawerShortcut: const ToggleDrawerIntent(),
            const SingleActivator(LogicalKeyboardKey.keyF, meta: true): const SearchIntent(),
          },
          child: Builder(builder: (context) {
            return Material(
              type: MaterialType.transparency,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: _scaffoldDecoration,
                // Apply the drawer layout if there is a drawer
                child: LdWrapConditional(
                  condition: widget.drawer != null,
                  builder: (context, child) => LdDrawerLayout(
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
                    body: child,
                    reflowBreakpoint: widget.reflowBreakpoint ?? 900,
                  ),
                  // Apply the app bar registry to the body
                  child: AppBarRegistry(
                    appBars: widget.appBars ?? [],
                    builder: (context, appBars) => Stack(children: [
                      // Body
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        // Obtain context with registry.
                        child: Builder(builder: (context) {
                          return ValueListenableBuilder(
                            valueListenable: AppBarRegistry.maybeStateOf(context)!.bodyPadding,
                            builder: (context, value, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(
                                  padding: value as EdgeInsets?,
                                ),
                                child: child!,
                              );
                            },
                            child: ScrollObserver(
                              position: _bodyScrollOffset,
                              child: PrimaryScrollController(
                                controller: effectiveScrollController,
                                child: LdNotificationPortal(
                                  debugLabel: "Scaffold Body ${widget.debugName}",
                                  child: widget.body,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),

                      // App Bars
                      ...appBars.reversed,
                    ]),
                  ),
                ),
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
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    _drawerStreamController.close();
    _bottomNavigationBarFocusNode.dispose();

    _internalScrollController?.dispose();

    super.dispose();
  }

  static LdScaffoldState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<LdScaffoldState>();
  }

  ValueNotifier<double> get bodyScrollOffset => _bodyScrollOffset;
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
