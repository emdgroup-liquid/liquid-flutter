import 'dart:math';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';
import 'package:provider/provider.dart';

class LdDrawer extends StatefulWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const LdDrawer({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
  });

  @override
  State<LdDrawer> createState() => LdDrawerState();
}

class LdDrawerState extends State<LdDrawer> {
  final _appBarSizeNotifier = ValueNotifier<Size>(const Size(0, 0));
  final _bottomNavigationBarSizeNotifier = ValueNotifier<Size>(const Size(0, 0));
  final _bodyScrollOffset = ValueNotifier<double>(0);

  @override
  void didUpdateWidget(LdDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appBar == null) {
      _appBarSizeNotifier.value = Size.zero;
    }
    if (widget.bottomNavigationBar == null) {
      _bottomNavigationBarSizeNotifier.value = Size.zero;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final mediaQuery = MediaQuery.of(context);

    Color backgroundColor = theme.background;
    if (widget.backgroundColor != null) {
      backgroundColor = widget.backgroundColor!;
    }

    final layoutState = context.read<LdScaffoldLayoutState>();

    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: backgroundColor,
        child: ValueListenableBuilder(
          valueListenable: _bottomNavigationBarSizeNotifier,
          builder: (context, bottomNavigationBarSize, child) {
            return ValueListenableBuilder(
              valueListenable: _appBarSizeNotifier,
              builder: (context, appBarSize, child) {
                return Stack(
                  children: [
                    // Body
                    Align(
                      alignment: Alignment.topLeft,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          viewPadding: mediaQuery.viewPadding.copyWith(top: 0),
                          viewInsets: mediaQuery.viewPadding.copyWith(top: 0),
                          padding: mediaQuery.padding.copyWith(
                            top: appBarSize.height,
                            bottom: max(
                              bottomNavigationBarSize.height,
                              mediaQuery.padding.bottom,
                            ),
                          ),
                        ),
                        child: ScrollNotificationObserver(
                          child: ScrollObserver(
                            position: _bodyScrollOffset,
                            child: Provider.value(
                              value: layoutState.copyWith(slot: LdScaffoldSlot.drawerBody),
                              child: widget.body,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // AppBar
                    if (widget.appBar != null)
                      Align(
                        alignment: Alignment.topLeft,
                        child: MeasureSize(
                          sizeNotifier: _appBarSizeNotifier,
                          child: Provider.value(
                            value: layoutState.copyWith(slot: LdScaffoldSlot.drawerAppBar),
                            child: widget.appBar!,
                          ),
                        ),
                      ),
                    // Bottom Navigation Bar
                    if (widget.bottomNavigationBar != null)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: MeasureSize(
                          sizeNotifier: _bottomNavigationBarSizeNotifier,
                          child: Provider.value(
                            value: layoutState.copyWith(
                              slot: LdScaffoldSlot.drawerBottomNavigationBar,
                            ),
                            child: widget.bottomNavigationBar!,
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
