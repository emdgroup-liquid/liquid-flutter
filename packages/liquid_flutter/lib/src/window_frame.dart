import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Show a frame around the window that has a surface color. Only is shown on
/// Windows, Linux, and MacOS.
class LdWindowFrame extends StatelessWidget {
  const LdWindowFrame({super.key, required this.title, required this.child, required this.frameBuilder});
  final Widget child;

  /// The frameBuilder can be used to wrap the child in a frame. This is useful
  /// for wrapping it in a [MoveWindow] widget.
  final Widget Function(BuildContext context, Widget child) frameBuilder;
  final Widget title;

  bool showWindowFrame(BuildContext context) {
    return LdTheme.of(context).platform.isDesktop;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Column(
      children: [
        if (showWindowFrame(context))
          frameBuilder(
            context,
            Container(
              decoration: BoxDecoration(
                color: theme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.border,
                    width: 1,
                  ),
                ),
              ),
              padding: theme.pad(size: LdSize.s),
              child: Row(children: [
                Expanded(
                  child: DefaultTextStyle(
                    style: ldBuildTextStyle(
                      theme,
                      LdTextType.label,
                      LdSize.m,
                    ).copyWith(
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                    child: title,
                  ),
                )
              ]),
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}
