import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Hosts offstage [LdSubmit] widgets for submit actions and refreshes [LdMonkeyActionScope.appContext].
class LdMonkeyActionHost<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  const LdMonkeyActionHost({
    super.key,
    required this.actions,
    required this.child,
  });

  final List<LdMonkeyAction<T, IdType>> actions;
  final Widget child;

  @override
  State<LdMonkeyActionHost<T, IdType>> createState() => _LdMonkeyActionHostState<T, IdType>();
}

class _LdMonkeyActionHostState<T extends Identifiable<IdType>, IdType> extends State<LdMonkeyActionHost<T, IdType>> {
  @override
  void initState() {
    super.initState();
    _assertUniqueSubmitIds();
  }

  @override
  void didUpdateWidget(covariant LdMonkeyActionHost<T, IdType> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.actions, widget.actions)) {
      _assertUniqueSubmitIds();
    }
  }

  void _assertUniqueSubmitIds() {
    final ids = <Object>{};
    for (final action in widget.actions) {
      if (action is LdMonkeySubmitAction<T, IdType, dynamic>) {
        assert(
          ids.add(action.id),
          'Duplicate LdMonkeySubmitAction id: ${action.id}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = LdMonkeyActionScope.of<T, IdType>(context);
    if (context.mounted) {
      scope.appContext = context;
    }

    final submitHosts = widget.actions
        .whereType<LdMonkeySubmitAction<T, IdType, dynamic>>()
        .map((action) => Offstage(child: action.buildHost(context, scope)))
        .toList();

    if (submitHosts.isEmpty) {
      return widget.child;
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        ...submitHosts,
        widget.child,
      ],
    );
  }
}
