import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/modal/size_notifier.dart';

class LdScaffold extends StatefulWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const LdScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
  });

  @override
  State<LdScaffold> createState() => _LdScaffoldState();
}

class _LdScaffoldState extends State<LdScaffold> {
  final _appBarSizeNotifier = ValueNotifier<Size>(const Size(0, 0));

  @override
  void didUpdateWidget(LdScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.appBar == null) {
      _appBarSizeNotifier.value = Size.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Material(
      type: MaterialType.transparency,
      child: ColoredBox(
        color: widget.backgroundColor ?? LdTheme.of(context).background,
        child: ValueListenableBuilder(
            valueListenable: _appBarSizeNotifier,
            builder: (context, value, child) {
              return Stack(
                children: [
                  if (!(widget.extendBodyBehindAppBar))
                    Positioned(
                      top: value.height,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          viewPadding: mediaQuery.viewPadding.copyWith(top: 0),
                          viewInsets: mediaQuery.viewPadding.copyWith(top: 0),
                          padding: mediaQuery.padding.copyWith(top: 0),
                        ),
                        child: widget.body,
                      ),
                    ),
                  if (widget.appBar != null)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: MeasureSize(
                        sizeNotifier: _appBarSizeNotifier,
                        child: widget.appBar!,
                      ),
                    ),
                  if (widget.bottomNavigationBar != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: widget.bottomNavigationBar!,
                    ),
                ],
              );
            }),
      ),
    );
  }
}
