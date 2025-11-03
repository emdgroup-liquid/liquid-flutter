import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart' hide LdLabeledAction, LdLabeledActionType, LdAppBarActionWidget;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/single_child_widget.dart';

class LdAppbarActionOverflowMenu extends StatelessWidget {
  final List<Widget> actions;

  final List<SingleChildWidget> Function(BuildContext context)? menuProviders;

  final bool inMenu;
  final LdScaffoldLayoutState layoutState;

  const LdAppbarActionOverflowMenu({
    super.key,
    required this.actions,
    required this.inMenu,
    this.menuProviders,
    required this.layoutState,
  });

  @override
  Widget build(BuildContext context) {
    return LdContextMenu(
      menuProviders: menuProviders,
      scaleFromTrigger: true,
      blurMode: LdContextMenuBlurMode.never,
      zoomMode: LdContextZoomMode.never,
      builder: (context, isOpen, open, child) => LdButton.ghost(
        onPressed: open,
        child: const Icon(LucideIcons.ellipsisVertical),
      ),
      menuBuilder: (context, close) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: LdButtonConfigProvider(
          const LdButtonConfig(
            mode: LdButtonMode.ghost,
            disableSqueeze: true,
            width: double.infinity,
            borderRadius: BorderRadius.zero,
          ),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}
