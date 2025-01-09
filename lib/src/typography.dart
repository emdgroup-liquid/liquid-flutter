import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

enum LdThemeSize { s, m, l }

extension FontSize on LdThemeSize {
  double labelSize(LdSize size) {
    switch (this) {
      case LdThemeSize.s:
        switch (size) {
          case LdSize.xs:
            return 8;
          case LdSize.s:
            return 10;
          case LdSize.m:
            return 12;
          case LdSize.l:
            return 16;
        }
      case LdThemeSize.m:
        switch (size) {
          case LdSize.xs:
            return 10;
          case LdSize.s:
            return 12;
          case LdSize.m:
            return 16;
          case LdSize.l:
            return 18;
        }
      case LdThemeSize.l:
        switch (size) {
          case LdSize.xs:
            return 14;
          case LdSize.s:
            return 16;
          case LdSize.m:
            return 18;
          case LdSize.l:
            return 24;
        }
    }
  }

  double paragraphSize(LdSize size) {
    switch (this) {
      case LdThemeSize.s:
        switch (size) {
          case LdSize.xs:
            return 10;
          case LdSize.s:
            return 12;
          case LdSize.m:
            return 14;
          case LdSize.l:
            return 16;
        }
      case LdThemeSize.m:
        switch (size) {
          case LdSize.xs:
            return 12;
          case LdSize.s:
            return 14;
          case LdSize.m:
            return 16;
          case LdSize.l:
            return 18;
        }
      case LdThemeSize.l:
        switch (size) {
          case LdSize.xs:
            return 12;
          case LdSize.s:
            return 14;
          case LdSize.m:
            return 16;
          case LdSize.l:
            return 18;
        }
    }
  }

  double headlineSize(LdSize size) {
    switch (this) {
      case LdThemeSize.s:
        switch (size) {
          case LdSize.xs:
            return 14;
          case LdSize.s:
            return 16;
          case LdSize.m:
            return 24;
          case LdSize.l:
            return 28;
        }
      case LdThemeSize.m:
        switch (size) {
          case LdSize.xs:
            return 16;
          case LdSize.s:
            return 20;
          case LdSize.m:
            return 24;
          case LdSize.l:
            return 32;
        }
      case LdThemeSize.l:
        switch (size) {
          case LdSize.xs:
            return 20;
          case LdSize.s:
            return 22;
          case LdSize.m:
            return 24;
          case LdSize.l:
            return 28;
        }
    }
  }
}

/// LdMute allows you to use the LdTheme to make a muted text
class LdMute extends StatelessWidget {
  final Widget child;

  const LdMute({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return IconTheme(
      data: IconThemeData(color: theme.textMuted),
      child: DefaultTextStyle(
        style: TextStyle(
          color: theme.textMuted,
          fontFamily: theme.fontFamily,
        ),
        child: child,
      ),
    );
  }
}
