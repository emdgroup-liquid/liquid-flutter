import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

PreferredSizeWidget buildAdaptableAppBar(
    {required Text title,
    required BuildContext context,
    required bool compact}) {
  if (!kIsWeb &&
      (Platform.isMacOS |
          Platform.isWindows |
          (MediaQuery.of(context).size.width > 900))) {
    return PreferredSize(
        preferredSize: Size.fromHeight(compact ? 32.0 : 80),
        child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: LdTheme.of(context).isDark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: MoveWindow(
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: compact ? 0.0 : 32.0),
                    decoration: BoxDecoration(
                        color: LdTheme.of(context).surface,
                        border: Border(
                            bottom: BorderSide(
                          color: LdTheme.of(context).border,
                          width: LdTheme.of(context).borderWidth,
                        ))),
                    child: SafeArea(
                      minimum: LdTheme.of(context).pad(),
                      child: DefaultTextStyle(
                          textAlign: TextAlign.center,
                          style: ldBuildTextStyle(
                              LdTheme.of(context), LdTextType.label, LdSize.l),
                          child: title),
                    ))).animate().fadeIn().moveY(begin: -100)));
  }
  return AppBar(title: title);
}
