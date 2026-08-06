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
  List<Widget> finalChildren = [];
  int index = 0;
  for (var child in children) {
    var next = index == children.length - 1 ? null : children[index + 1];
    index++;

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

    if (next is LdMute) {
      next = next.child;
    }

    _LdSizeItem spacer = switch ((child, next)) {
      (LdListItem _, LdListItem _) => _LdSizeItem(LdSize.s, 0),
      (LdText childText, LdText nextText) => switch ((childText.type, nextText.type)) {
          (LdTextType.headline, LdTextType.label) => _LdSizeItem(LdSize.xs, 1),
          (LdTextType.headline, _) => _LdSizeItem(LdSize.l, 1),
          (LdTextType.paragraph, LdTextType.headline) => _LdSizeItem(LdSize.l, 2),
          (LdTextType.paragraph, LdTextType.paragraph) => _LdSizeItem(LdSize.m, 1),
          (_, LdTextType.label) => _LdSizeItem(LdSize.s, 1),
          (LdTextType.label, _) => _LdSizeItem(LdSize.s, 1),
          (_, _) => _LdSizeItem(defaultSpacing, 1)
        },
      (LdText _, _) => _LdSizeItem(LdSize.m, 1),
      (LdButton _, LdButton _) => _LdSizeItem(LdSize.s, 1),
      (LdRadio _, LdRadio _) => _LdSizeItem(LdSize.xs, 1),
      (LdCheckbox _, LdCheckbox _) => _LdSizeItem(LdSize.xs, 1),
      (LdToggle _, LdToggle _) => _LdSizeItem(LdSize.xs, 1),
      (LdDivider _, _) => _LdSizeItem(LdSize.l, 1),
      (LdCard _, LdCard _) => _LdSizeItem(LdSize.l, 2),
      (LdDrawerItemSection _, LdDrawerItemSection _) => _LdSizeItem(LdSize.xs, 1),
      (LdSectionHeader _, LdSectionHeader _) => _LdSizeItem(LdSize.l, 1),
      (LdBundle _, LdBundle _) => _LdSizeItem(LdSize.l, 2),
      (_, LdBundle _) => _LdSizeItem(LdSize.l, 1),
      (_, LdText nextText) => switch (nextText.type) {
          LdTextType.headline => _LdSizeItem(LdSize.l, 2),
          _ => _LdSizeItem(defaultSpacing, 1)
        },
      (_, LdDivider _) => _LdSizeItem(LdSize.m, 1),
      (_, _) => _LdSizeItem(defaultSpacing, 1),
    };

    if (next is LdSpacer || child is LdSpacer) {
      spacer = _LdSizeItem(defaultSpacing, 0);
    }

    if (_isInputLike(child) && _isInputLike(next)) {
      spacer = _LdSizeItem(LdSize.l, 1);
    }

    if (spacer.multiplier != 0) {
      for (int i = 0; i < spacer.multiplier; i++) {
        finalChildren.add(
          LdSpacer(
            size: spacer.size,
          ),
        );
      }
    }
  }

  return finalChildren;
}

bool _isInputLike(Widget child) {
  return child is LdInput ||
      child is LdChoose ||
      child is LdDatePicker ||
      child is LdTimePicker ||
      child is LdSelect ||
      child is LdSwitch;
}

class _LdSizeItem {
  final LdSize size;
  final int multiplier;

  const _LdSizeItem(this.size, this.multiplier);
}

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
