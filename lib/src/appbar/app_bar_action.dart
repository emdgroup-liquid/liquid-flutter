import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart' hide LdLabeledAction, LdLabeledActionSubmitType;
import 'package:provider/single_child_widget.dart';
import 'action_trigger_button.dart';
import 'labeled_action.dart';

class LdAppBarAction extends StatelessWidget {
  final LdLabeledAction action;
  final bool bigToolbar;
  final List<SingleChildWidget> Function(BuildContext context)? menuProviders;
  final bool inMenu;

  const LdAppBarAction({
    super.key,
    required this.action,
    required this.bigToolbar,
    required this.inMenu,
    this.menuProviders,
  });

  @override
  Widget build(BuildContext context) {
    switch (action.submitType) {
      case LdLabeledActionSubmitType.contextMenu:
        return LdContextMenu(
          menuProviders: menuProviders,
          blurMode: LdContextMenuBlurMode.never,
          zoomMode: LdContextZoomMode.never,
          builder: (context, isOpen, open, child) => ActionTriggerButton(
            action: action,
            bigToolbar: bigToolbar,
            loadingText: action.loadingText(context),
            inMenu: inMenu,
            onPressed: () => open(),
            disabled: false,
          ),
          menuBuilder: (context, close) => action.contextMenu.call(context) ?? const SizedBox(),
        );
      case LdLabeledActionSubmitType.none:
        return ActionTriggerButton(
          action: action,
          bigToolbar: bigToolbar,
          loadingText: action.loadingText(context),
          inMenu: inMenu,
          onPressed: () => action.onPressed(context),
          disabled: false,
        );
      case LdLabeledActionSubmitType.notification:
      case LdLabeledActionSubmitType.dialog:
        final builder = action.submitType == LdLabeledActionSubmitType.notification
            ? LdSubmitNotificationBuilder<void, BuildContext>.new
            : LdSubmitDialogBuilder<void, BuildContext>.new;

        return LdSubmit<void, BuildContext>(
          arg: context,
          key: ValueKey(action.label(context)),
          config: LdSubmitConfig(
            loadingText: action.loadingText(context),
            action: (context) async => action.onPressed(context!),
          ),
          builder: builder(
            submitButtonBuilder: (submitButtonBuilder, controller) {
              return ActionTriggerButton(
                action: action,
                bigToolbar: bigToolbar,
                inMenu: inMenu,
                onPressed: controller.trigger,
                loading: controller.state.type == LdSubmitStateType.loading,
                loadingText: action.loadingText(context),
                disabled: !controller.canTrigger,
              );
            },
          ),
        );
    }
  }
}
