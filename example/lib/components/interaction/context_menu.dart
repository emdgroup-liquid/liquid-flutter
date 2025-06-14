import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ContextMenuDemo extends StatefulWidget {
  const ContextMenuDemo({super.key});

  @override
  State<ContextMenuDemo> createState() => _ContextMenuDemoState();
}

class _ContextMenuDemoState extends State<ContextMenuDemo> {
  LdContextMenuBlurMode _blurMode = LdContextMenuBlurMode.mobileOnly;
  LdContextZoomMode _zoomMode = LdContextZoomMode.mobileOnly;
  LdContextPositionMode _positionMode = LdContextPositionMode.auto;

  _buildMenu(BuildContext context, VoidCallback onDismiss) =>
      SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LdListItem(
                width: double.infinity,
                leading: const Icon(LucideIcons.pen),
                subContent: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: LdSwitch(
                      value: false,
                      onChanged: (p0) {},
                      children: const {
                        true: Text("On"),
                        false: Text("Off"),
                      },
                    ),
                  ),
                ),
                title: const Text("Turbo mode"),
              ),
              LdListItem(
                width: double.infinity,
                leading: const Icon(LucideIcons.pen),
                onTap: () {
                  onDismiss();
                },
                title: const Text("Edit"),
              ),
              LdListItem(
                width: double.infinity,
                leading: const Icon(LucideIcons.copy),
                onTap: () {
                  onDismiss();
                },
                title: const Text("Copy"),
              ),
              LdListItem(
                width: double.infinity,
                leading: const Icon(LucideIcons.share2),
                onTap: () {
                  onDismiss();
                },
                title: const Text("Share"),
              ),
              LdListItem(
                width: double.infinity,
                leading: const Icon(LucideIcons.star),
                onTap: () {
                  onDismiss();
                },
                title: const Text("Favorite"),
              ),
              LdListItem(
                width: double.infinity,
                leading: const Icon(LucideIcons.archive),
                onTap: () {
                  onDismiss();
                },
                title: const Text("Archive"),
              ),
              const LdDivider(),
              LdListItem(
                width: double.infinity,
                leading: const Icon(LucideIcons.trash2, color: Colors.red),
                onTap: () {
                  onDismiss();
                },
                title:
                    const Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ]),
      );
  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        path: "lib/components/interaction/context_menu.dart",
        title: "LdContextMenu",
        demo: LdAutoSpace(
          children: [
            ComponentWell(
              onSurface: true,
              padding: EdgeInsets.zero,
              child: LdContextMenu(
                zoomMode: _zoomMode,
                blurMode: _blurMode,
                positionMode: _positionMode,
                menuBuilder: (context, onDismiss) {
                  return ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 150,
                      ),
                      child: _buildMenu(context, onDismiss));
                },
                builder: (
                  context,
                  shuttle,
                  trigger,
                ) =>
                    LdListItem(
                  borderRadius: LdTheme.of(context).radius(LdSize.m),
                  width: double.infinity,
                  leading: const LdAvatar(
                    child: Text("C"),
                  ),
                  title: const Text("Right click me"),
                ),
              ).padM(),
            ),
            ComponentWell(
              child: Row(
                children: [
                  LdContextMenu(
                    zoomMode: _zoomMode,
                    blurMode: _blurMode,
                    positionMode: _positionMode,
                    menuBuilder: (context, onDismiss) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: _buildMenu(context, onDismiss),
                      );
                    },
                    builder: (
                      context,
                      shuttle,
                      trigger,
                    ) =>
                        LdButton(
                      onPressed: () {},
                      child: const Text("Right click me"),
                    ),
                  ),
                ],
              ),
            ),
            LdSwitch(
              label: "Blur",
              children: const {
                LdContextMenuBlurMode.always: Text("Always"),
                LdContextMenuBlurMode.mobileOnly: Text("Mobile only"),
                LdContextMenuBlurMode.never: Text("Never"),
              },
              value: _blurMode,
              onChanged: (p0) {
                setState(() {
                  _blurMode = p0;
                });
              },
            ),
            LdSwitch(
                label: "Zoom",
                children: const {
                  LdContextZoomMode.always: Text("Always"),
                  LdContextZoomMode.mobileOnly: Text("Mobile only"),
                  LdContextZoomMode.never: Text("Never"),
                },
                value: _zoomMode,
                onChanged: (p0) {
                  setState(() {
                    _zoomMode = p0;
                  });
                }),
            LdSwitch(
                label: "Position",
                children: const {
                  LdContextPositionMode.auto: Text("Auto"),
                  LdContextPositionMode.relativeTrigger: Text("Trigger"),
                  LdContextPositionMode.relativeCursor: Text("Cursor"),
                },
                value: _positionMode,
                onChanged: (p0) {
                  setState(() {
                    _positionMode = p0;
                  });
                }),
          ],
        ));
  }
}
