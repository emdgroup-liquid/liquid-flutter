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

  Widget padVertical({LdSize size = LdSize.m}) {
    return _LdPadding(size: size, child: this, sides: const {_Side.top, _Side.bottom});
  }

  Widget padHorizontal({LdSize size = LdSize.m}) {
    return _LdPadding(size: size, child: this, sides: const {_Side.left, _Side.right});
  }

  Widget insetLeft({LdSize size = LdSize.m}) {
    return _LdPadding(size: size, child: this, sides: const {_Side.left});
  }

  Widget insetRight({LdSize size = LdSize.m}) {
    return _LdPadding(size: size, child: this, sides: const {_Side.right});
  }

  Widget insetTop({LdSize size = LdSize.m}) {
    return _LdPadding(size: size, child: this, sides: const {_Side.top});
  }

  Widget insetBottom({LdSize size = LdSize.m}) {
    return _LdPadding(size: size, child: this, sides: const {_Side.bottom});
  }
}

extension RowSpacing on Row {
  Widget spaceXS() {
    return Builder(builder: (context) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        textBaseline: textBaseline,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.xs),
        children: children,
      );
    });
  }

  Widget spaceS() {
    return Builder(builder: (context) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        textBaseline: textBaseline,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.s),
        children: children,
      );
    });
  }

  Widget spaceM() {
    return Builder(builder: (context) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        textBaseline: textBaseline,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.m),
        children: children,
      );
    });
  }

  Widget spaceL() {
    return Builder(builder: (context) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        textBaseline: textBaseline,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.l),
        children: children,
      );
    });
  }
}

extension WrapSpacing on Wrap {
  Widget spaceXS() {
    return Builder(builder: (context) {
      return Wrap(
        direction: direction,
        alignment: alignment,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.xs),
        runSpacing: LdTheme.of(context).paddingSize(size: LdSize.xs),
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        children: children,
      );
    });
  }

  Widget spaceS() {
    return Builder(builder: (context) {
      return Wrap(
        direction: direction,
        alignment: alignment,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.s),
        runSpacing: LdTheme.of(context).paddingSize(size: LdSize.s),
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        children: children,
      );
    });
  }

  Widget spaceM() {
    return Builder(builder: (context) {
      return Wrap(
        direction: direction,
        alignment: alignment,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.m),
        runSpacing: LdTheme.of(context).paddingSize(size: LdSize.m),
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        children: children,
      );
    });
  }

  Widget spaceL() {
    return Builder(builder: (context) {
      return Wrap(
        direction: direction,
        alignment: alignment,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.l),
        runSpacing: LdTheme.of(context).paddingSize(size: LdSize.l),
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        children: children,
      );
    });
  }
}

extension ColumnSpacing on Column {
  Widget spaceS() {
    return Builder(builder: (context) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        textBaseline: textBaseline,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.s),
        children: children,
      );
    });
  }

  Widget spaceM() {
    return Builder(builder: (context) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        textBaseline: textBaseline,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.m),
        children: children,
      );
    });
  }

  Widget spaceL() {
    return Builder(builder: (context) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        textBaseline: textBaseline,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        key: key,
        spacing: LdTheme.of(context).paddingSize(size: LdSize.l),
        children: children,
      );
    });
  }
}

enum _Side {
  left,
  right,
  top,
  bottom,
}

class _LdPadding extends StatelessWidget {
  final LdSize size;
  final Widget child;

  final Set<_Side>? sides;

  final bool balanced;

  const _LdPadding({Key? key, required this.size, required this.child, this.balanced = false, this.sides})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    var padding = theme.pad(size: size);

    if (sides != null) {
      padding = EdgeInsets.only(
        left: sides!.contains(_Side.left) ? padding.left : 0,
        right: sides!.contains(_Side.right) ? padding.right : 0,
        top: sides!.contains(_Side.top) ? padding.top : 0,
        bottom: sides!.contains(_Side.bottom) ? padding.bottom : 0,
      );
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}
