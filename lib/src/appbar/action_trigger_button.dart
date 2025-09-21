import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart' hide LdLabeledAction;
import 'labeled_action.dart';

class ActionTriggerButton extends StatelessWidget {
  final LdLabeledAction action;
  final bool bigToolbar;
  final bool inMenu;
  final VoidCallback onPressed;
  final bool loading;
  final String? loadingText;
  final bool disabled;

  const ActionTriggerButton({
    super.key,
    required this.action,
    required this.bigToolbar,
    required this.inMenu,
    required this.onPressed,
    this.loading = false,
    this.loadingText,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final icon = action.icon(context);
    final label = action.label(context);
    if (inMenu) {
      return LdReveal.quick(
        revealed: action.isVisible(context),
        child: LdListItem(
          onPressed: () {
            LdContextMenuDissmissNotification().dispatch(context);
            onPressed();
          },
          disabled: disabled,
          leading: icon != null
              ? IconTheme(
                  data: IconThemeData(
                    size: LdTheme.of(context).labelSize(null),
                    color:
                        action.color(context)?.center(LdTheme.of(context).isDark) ?? LdTheme.of(context).primaryColor,
                  ),
                  child: icon,
                )
              : null,
          title: Text(label),
        ),
      );
    } else {
      return Tooltip(
        message: action.label(context),
        child: LdButtonGhost(
          color: action.color(context),
          leading: bigToolbar ? icon : null,
          onPressed: onPressed,
          loadingText: loadingText,
          loading: loading,
          disabled: disabled,
          child: bigToolbar || icon == null ? Text(label) : icon,
        ),
      );
    }
  }
}
