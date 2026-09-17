import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

List<LdMonkeyAction<T, IdType>>
    ldMonkeyAppBarActionsForLocation<T extends Identifiable<IdType>, IdType>(
        BuildContext context, LdMonkeyActionLocation location) {
  final actions = context.read<LdMonkeyActions<T, IdType>>();

  final visibleActions =
      actions.where((e) => e.isVisible(context, location: location)).toList();

  return visibleActions;
}

List<Widget>
    ldMonkeyAppBarActionWidgets<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  List<LdMonkeyAction<T, IdType>> actions,
) {
  final scope = LdMonkeyActionScope.of<T, IdType>(context, listen: true);
  return [
    for (var i = 0; i < actions.length; i++)
      _wrapAppBarOverflowMode(
        actions[i].appBarOverflowMode,
        _buildAppBarTrigger(context, scope, actions, i),
      ),
  ];
}

Widget _buildAppBarTrigger<T extends Identifiable<IdType>, IdType>(
  BuildContext context,
  LdMonkeyActionScope<T, IdType> scope,
  List<LdMonkeyAction<T, IdType>> actions,
  int index,
) {
  final action = actions[index];
  if (action is LdMonkeyActionGroup<T, IdType>) {
    final nextIsGroup = index < actions.length - 1 &&
        actions[index + 1] is LdMonkeyActionGroup<T, IdType>;
    return action.buildGroupedTrigger(
      context,
      scope,
      leadingDivider: index > 0,
      trailingDivider: index < actions.length - 1 && !nextIsGroup,
    );
  }
  return action.buildTrigger(context, scope);
}

Widget _wrapAppBarOverflowMode(
  LdAppBarActionOverflowMode mode,
  Widget trigger,
) {
  return switch (mode) {
    LdAppBarActionOverflowMode.pinned => LdOverflowPinnedChild(child: trigger),
    LdAppBarActionOverflowMode.overflowable => trigger,
    LdAppBarActionOverflowMode.always => LdOverflowAlwaysChild(child: trigger),
  };
}
