import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Groups app bar actions so they overflow as a single [LdOverflowView] child.
///
/// In the app bar this renders as a [Row], optionally with a vertical rule on
/// either side. In an overflow or context menu it renders as a [Column] of
/// [children] with no outer dividers — callers insert [LdDivider]s between
/// adjacent menu items via [ldAppBarActionGroupMenuChildren].
class LdAppBarActionGroup extends StatelessWidget {
  const LdAppBarActionGroup({
    super.key,
    required this.children,
    this.leadingDivider = false,
    this.trailingDivider = false,
  });

  final List<Widget> children;
  final bool leadingDivider;
  final bool trailingDivider;

  @override
  Widget build(BuildContext context) {
    final isInContextMenu = context.read<LdAppBarActionDisplayMode?>() == LdAppBarActionDisplayMode.contextMenu;

    if (isInContextMenu) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    final theme = LdTheme.of(context);
    final spacing = theme.paddingSize(size: LdSize.xs);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: spacing,
      children: [
        if (leadingDivider) const _LdAppBarActionGroupDivider(),
        ...children,
        if (trailingDivider) const _LdAppBarActionGroupDivider(),
      ],
    );
  }
}

/// Inserts [LdDivider]s between adjacent [actions] when either side is an
/// [LdAppBarActionGroup], and flattens each group into its children so menu
/// items stay full-width column children.
List<Widget> ldAppBarActionGroupMenuChildren(List<Widget> actions) {
  if (actions.isEmpty) {
    return actions;
  }

  final children = <Widget>[];
  for (var i = 0; i < actions.length; i++) {
    if (i > 0 && _isGroupMenuBoundary(actions[i - 1], actions[i])) {
      children.add(const LdDivider());
    }
    final action = actions[i];
    if (action is LdAppBarActionGroup) {
      children.addAll(action.children);
    } else {
      children.add(action);
    }
  }
  return children;
}

bool _isGroupMenuBoundary(Widget previous, Widget next) {
  return previous is LdAppBarActionGroup || next is LdAppBarActionGroup;
}

class _LdAppBarActionGroupDivider extends StatelessWidget {
  const _LdAppBarActionGroupDivider();

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);

    return SizedBox(
      height: theme.labelSize(LdSize.m) * 2,
      child: VerticalDivider(
        width: theme.borderWidth,
        thickness: theme.borderWidth,
        color: theme.border,
        indent: 0,
        endIndent: 0,
      ),
    );
  }
}
