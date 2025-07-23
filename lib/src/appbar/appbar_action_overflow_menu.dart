import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart' hide LdLabeledAction, LdLabeledActionSubmitType, LdAppBarAction;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/single_child_widget.dart';
import 'app_bar_action.dart';
import 'labeled_action.dart';

class LdAppbarActionOverflowMenu extends StatelessWidget {
  final List<LdLabeledAction> actions;
  final bool bigToolbar;
  final List<SingleChildWidget> Function(BuildContext context)? menuProviders;

  final bool inMenu;

  const LdAppbarActionOverflowMenu({
    super.key,
    required this.actions,
    required this.bigToolbar,
    required this.inMenu,
    this.menuProviders,
  });

  @override
  Widget build(BuildContext context) {
    return LdContextMenu(
      menuProviders: menuProviders,
      scaleFromTrigger: true,
      blurMode: LdContextMenuBlurMode.never,
      zoomMode: LdContextZoomMode.never,
      builder: (context, isOpen, open, child) => LdButtonGhost(
        onPressed: open,
        child: const Icon(LucideIcons.ellipsisVertical),
      ),
      menuBuilder: (context, close) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            ...actions.map(
              (e) => LdAppBarAction(
                key: ValueKey(e.label(context)),
                action: e,
                menuProviders: menuProviders,
                bigToolbar: bigToolbar,
                inMenu: inMenu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
