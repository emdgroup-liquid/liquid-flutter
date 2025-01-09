import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

abstract class _Default extends StatelessWidget {}

class _LdSizeItem {
  final LdSize size;
  final int multiplier;

  const _LdSizeItem(this.size, this.multiplier);
}

const Map<Type, Map<Type, _LdSizeItem>> spacingMatrix = {
  LdButton: {
    _Default: _LdSizeItem(LdSize.m, 1),
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
    _Default: _LdSizeItem(LdSize.l, 1),
    LdBundle: _LdSizeItem(LdSize.l, 2),
  },
  LdDivider: {
    _Default: _LdSizeItem(LdSize.l, 1),
  },
  LdCard: {
    _Default: _LdSizeItem(LdSize.l, 1),
    LdCard: _LdSizeItem(LdSize.l, 2),
  },
  LdDrawerItemSection: {
    _Default: _LdSizeItem(LdSize.l, 1),
    LdDrawerItemSection: _LdSizeItem(LdSize.xs, 1),
    LdSectionHeader: _LdSizeItem(LdSize.l, 1)
  },
};

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
    final theme = LdTheme.of(context, listen: true);

    List<Widget> finalChildren = [];
    int index = 0;
    for (var child in children) {
      if (animate) {
        finalChildren.add(child
            .animate(delay: 50.ms * finalChildren.length)
            .fadeIn()
            .moveY(begin: 5));
      } else {
        finalChildren.add(child);
      }

      if (index == children.length - 1) {
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

      final element = spacingMatrix[child.runtimeType];

      var next = children[index + 1];

      if (next is LdMute) {
        next = next.child;
      }

      index++;

      if (child is LdSpacer || next is LdSpacer) {
        continue;
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
            child: LdSpacer(size: defaultSpacing),
            collapsed: !next.revealed,
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

        if (element[_Default] != null) {
          for (int i = 0; i < element[_Default]!.multiplier; i++) {
            finalChildren.add(
              LdSpacer(size: element[_Default]!.size),
            );
          }
          continue;
        }
      }

      finalChildren.add(
        LdSpacer(size: defaultSpacing),
      );
    }

    return finalChildren;
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
