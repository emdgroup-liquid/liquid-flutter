import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/single_child_widget.dart';

class LdAppbarActionOverflowMenu extends StatelessWidget {
  final List<Widget> actions;

  final List<SingleChildWidget> Function(BuildContext context)? menuProviders;

  final bool inMenu;

  const LdAppbarActionOverflowMenu({
    super.key,
    required this.actions,
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
      builder: (context, isShuttle, open, isOpen, child) => LdButton.ghost(
        active: isOpen,
        onPressed: open,
        child: const Icon(LucideIcons.ellipsisVertical),
      ),
      menuBuilder: (context) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: LdButtonConfigProvider(
          config: const LdButtonConfig(
            mode: LdButtonMode.ghost,
            disableSqueeze: true,
            width: double.infinity,
            borderRadius: BorderRadius.zero,
          ),
          child: ListView(
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
