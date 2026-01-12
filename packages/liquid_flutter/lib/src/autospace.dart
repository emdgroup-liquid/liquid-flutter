import 'package:flutter/material.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

/// Generates auto-spaced widgets from a list of children based on spacing rules.
///
/// This function applies automatic spacing between widgets based on their types,
/// following the spacing matrix rules and special handling for text widgets.
///
/// Parameters:
/// - [children]: The list of widgets to be spaced
/// - [context]: The build context for theme access
/// - [defaultSpacing]: The default spacing to use when no specific rule applies
/// - [animate]: Whether to apply animation to the widgets
///
/// Returns a list of widgets with appropriate spacing inserted between them.
List<Widget> generateAutoSpacings({
  required List<Widget> children,
  required BuildContext context,
  LdSize defaultSpacing = LdSize.m,
  bool animate = false,
}) {
  final theme = LdTheme.of(context, listen: true);

  List<Widget> finalChildren = [];
  int index = 0;
  for (var child in children) {
    var next = index == children.length - 1 ? null : children[index + 1];
    index++;
    if (child is LdSpacer) {
      continue;
    }
    finalChildren.add(child);

    if (next == null) {
      break;
    }

    if (child is LdReveal) {
      child = child.child;
    }

    if (child is LdCollapse) {
      child = child.child;
    }

    if (child is LdMute) {
      child = child.child;
    }

    final element = _spacingMatrix[child.runtimeType];

    if (next is LdMute) {
      next = next.child;
    }

    if (child is LdText && next is LdText) {
      final types = (child.type, next.type);

      final (LdSize spacerSize, double multiplier) = switch (types) {
        (LdTextType.headline, LdTextType.headline) => (LdSize.l, 2),
        (LdTextType.headline, LdTextType.paragraph) => (LdSize.l, 1),
        (LdTextType.paragraph, LdTextType.headline) => (LdSize.l, 2),
        (LdTextType.paragraph, LdTextType.paragraph) => (LdSize.xs, 0.5),
        (_, LdTextType.label) => (LdSize.s, 1),
        (LdTextType.label, _) => (LdSize.s, 1),
        (_, _) => (LdSize.m, 1),
      };

      finalChildren.add(SizedBox(
        height: theme.paddingSize(size: spacerSize) * multiplier * 0.5,
      ));

      continue;
    }

    // Add an automatic spacer if the next widget is a reveal widget
    if (next is LdReveal) {
      finalChildren.add(
        LdCollapse(
          collapsed: !next.revealed,
          child: LdSpacer(size: defaultSpacing),
        ),
      );
      continue;
    }

    if (element != null) {
      if (element[next.runtimeType] != null) {
        for (int i = 0; i < element[next.runtimeType]!.multiplier; i++) {
          finalChildren.add(
            LdSpacer(size: element[next.runtimeType]!.size),
          );
        }

        continue;
      }
    }
    final defaultSpacings = _spacingMatrix[_Default]!;
    if (defaultSpacings[next.runtimeType] != null) {
      for (int i = 0; i < defaultSpacings[next.runtimeType]!.multiplier; i++) {
        finalChildren.add(
          LdSpacer(size: defaultSpacings[next.runtimeType]!.size),
        );
      }
      continue;
    }

    finalChildren.add(
      LdSpacer(size: defaultSpacing),
    );
  }

  return finalChildren;
}

abstract class _Default extends StatelessWidget {}

class _LdSizeItem {
  final LdSize size;
  final int multiplier;

  const _LdSizeItem(this.size, this.multiplier);
}

const Map<Type, Map<Type, _LdSizeItem>> _spacingMatrix = {
  LdButton: {
    LdButton: _LdSizeItem(LdSize.s, 1),
  },
  LdRadio: {
    LdRadio: _LdSizeItem(LdSize.s, 1),
  },
  LdCheckbox: {
    LdCheckbox: _LdSizeItem(LdSize.s, 1),
  },
  LdToggle: {
    LdToggle: _LdSizeItem(LdSize.s, 1),
  },
  LdBundle: {
    LdBundle: _LdSizeItem(LdSize.l, 2),
  },
  LdDivider: {
    _Default: _LdSizeItem(LdSize.l, 1),
  },
  LdCard: {
    LdCard: _LdSizeItem(LdSize.l, 2),
  },
  LdDrawerItemSection: {
    LdDrawerItemSection: _LdSizeItem(LdSize.xs, 1),
    LdSectionHeader: _LdSizeItem(LdSize.l, 1),
  },
  LdListItem: {
    LdListItem: _LdSizeItem(LdSize.s, 1),
  },
  _Default: {
    LdBundle: _LdSizeItem(LdSize.l, 1),
    LdCard: _LdSizeItem(LdSize.l, 1),
    LdDivider: _LdSizeItem(LdSize.l, 1),
    LdButton: _LdSizeItem(LdSize.l, 1),
  }
};

extension LdAutoSpaceExt on List<Widget> {
  List<Widget> autoSpace(BuildContext context, {LdSize defaultSpacing = LdSize.m, bool animate = false}) {
    return generateAutoSpacings(
      children: this,
      context: context,
      defaultSpacing: defaultSpacing,
      animate: animate,
    );
  }
}

class LdAutoSpace extends StatelessWidget {
  final List<Widget> children;
  final LdSize defaultSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final bool animate;

  const LdAutoSpace({
    required this.children,
    this.defaultSpacing = LdSize.m,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.animate = false,
    super.key,
  });

  List<Widget> _generateSpacings(BuildContext context) {
    return generateAutoSpacings(
      children: children,
      context: context,
      defaultSpacing: defaultSpacing,
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: _generateSpacings(context),
    );
  }
}

class LdBundle extends StatelessWidget {
  final List<Widget> children;

  const LdBundle({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: children,
    );
  }
}
