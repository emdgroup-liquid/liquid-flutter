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
  LdContextPositionMode _positionMode = LdContextPositionMode.relativeTrigger;

  _buildMenu(BuildContext context, VoidCallback onDismiss) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LdListItem(
          width: double.infinity,
          trailing: const Icon(LucideIcons.arrowRight),
          onTap: () {
            onDismiss();
          },
          title: const Text("Button 1"),
        ),
        LdListItem(
          width: double.infinity,
          trailing: const Icon(LucideIcons.arrowRight),
          onTap: () async {
            await Future.delayed(const Duration(seconds: 1));
            onDismiss();
          },
          title: const Text("Button 2"),
        ),
        LdListItem(
          width: double.infinity,
          trailing: const Icon(LucideIcons.trash),
          onTap: () {
            onDismiss();
          },
          title: const Text("Button 2"),
        ),
      ]);
  @override
  Widget build(BuildContext context) {
    return ComponentPage(
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
                builder: (context, shuttle) => LdListItem(
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
                    builder: (context, shuttle) => LdButton(
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
