import 'package:flutter/material.dart';
import 'package:liquid_flutter/src/theme/theme.dart';
import 'package:liquid_flutter/src/tokens.dart';
import 'package:liquid_flutter/src/typography.dart';

extension PaddingSize on LdThemeSize {
  double paddingSize(LdSize size) {
    switch (this) {
      case LdThemeSize.s:
        switch (size) {
          case LdSize.xs:
            return 4;
          case LdSize.s:
            return 8;
          case LdSize.m:
            return 10;
          case LdSize.l:
            return 12;
        }
      case LdThemeSize.m:
        switch (size) {
          case LdSize.xs:
            return 8;
          case LdSize.s:
            return 12;
          case LdSize.m:
            return 14;
          case LdSize.l:
            return 24;
        }
      case LdThemeSize.l:
        switch (size) {
          case LdSize.xs:
            return 8;
          case LdSize.s:
            return 16;
          case LdSize.m:
            return 24;
          case LdSize.l:
            return 32;
        }
    }
  }
}

extension LsPaddings on Widget {
  Widget padXS() {
    return _LdPadding(size: LdSize.xs, child: this);
  }

  Widget padS() {
    return _LdPadding(size: LdSize.s, child: this);
  }

  Widget padM() {
    return _LdPadding(size: LdSize.m, child: this);
  }

  Widget padL() {
    return _LdPadding(size: LdSize.l, child: this);
  }

  Widget pad(LdSize size) {
    return _LdPadding(size: size, child: this);
  }

  Widget padBalXs() {
    return _LdPadding(size: LdSize.xs, child: this, balanced: true);
  }

  Widget padBalS() {
    return _LdPadding(size: LdSize.s, child: this, balanced: true);
  }

  Widget padBalM() {
    return _LdPadding(size: LdSize.m, child: this, balanced: true);
  }

  Widget padBalL() {
    return _LdPadding(size: LdSize.l, child: this, balanced: true);
  }

  Widget padBal(LdSize size) {
    return _LdPadding(size: size, child: this, balanced: true);
  }
}

class _LdPadding extends StatelessWidget {
  final LdSize size;
  final Widget child;
  final bool balanced;

  const _LdPadding(
      {Key? key,
      required this.size,
      required this.child,
      this.balanced = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return Padding(
      padding: theme.pad(size: size),
      child: child,
    );
  }
}
