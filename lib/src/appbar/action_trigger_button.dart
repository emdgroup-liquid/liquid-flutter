import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart' hide LdLabeledAction;
import 'package:liquid_flutter/src/scaffold_layout_state.dart';
import 'labeled_action.dart';

class ActionTriggerButton extends StatelessWidget {
  final LdLabeledAction action;

  final bool inMenu;
  final VoidCallback onPressed;
  final bool loading;
  final String? loadingText;
  final bool disabled;
  final LdScaffoldLayoutState layoutState;

  const ActionTriggerButton({
    super.key,
    required this.action,
    required this.inMenu,
    required this.onPressed,
    required this.layoutState,
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
      late Widget child;

      if (icon == null) {
        child = Text(label);
      } else {
        // Show label for bottom app bars if alwaysShowLabel is true
        // This check can be enhanced to detect bottom position from context if needed
        if (action.alwaysShowLabel) {
          child = Column(
            children: [icon, ldSpacerXS, Text(label)],
          );
        } else {
          child = icon;
        }
      }

      return Tooltip(
        message: action.label(context),
        child: LdButton.ghost(
          color: action.color(context),
          active: action.isActive(context),
          onPressed: onPressed,
          loadingText: loadingText,
          loading: loading,
          disabled: disabled,
          child: child,
        ),
      );
    }
  }
}
