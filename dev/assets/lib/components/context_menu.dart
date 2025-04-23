import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class ContextMenuDemo extends StatefulWidget {
  const ContextMenuDemo({super.key});

  @override
  State<ContextMenuDemo> createState() => _ContextMenuDemoState();
}

class _ContextMenuDemoState extends State<ContextMenuDemo> {
  LdContextMenuBlurMode _blurMode = LdContextMenuBlurMode.mobileOnly;
  LdContextZoomMode _zoomMode = LdContextZoomMode.mobileOnly;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
        title: "LdContextMenu",
        demo: LdAutoSpace(
          children: [
            ComponentWell(
              onSurface: true,
              child: LdContextMenu(
                zoomMode: _zoomMode,
                blurMode: _blurMode,
                menuBuilder: (context, onDismiss) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 150,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LdButtonGhost(
                            width: double.infinity,
                            trailing: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              onDismiss();
                            },
                            child: const Text("Button 1"),
                          ),
                          ldSpacerXS,
                          LdButtonGhost(
                            width: double.infinity,
                            trailing: const Icon(Icons.arrow_forward),
                            onPressed: () async {
                              await Future.delayed(const Duration(seconds: 1));
                              onDismiss();
                            },
                            child: const Text("Button 2"),
                          ),
                          ldSpacerXS,
                          const LdDivider(),
                          ldSpacerS,
                          LdButtonGhost(
                            width: double.infinity,
                            color: shadRed,
                            trailing: const Icon(Icons.remove),
                            onPressed: () {
                              onDismiss();
                            },
                            child: const Text("Button 2"),
                          ),
                        ]),
                  );
                },
                builder: (context, shuttle) => LdListItem(
                  width: double.infinity,
                  leading: const LdAvatar(
                    child: Text("C"),
                  ),
                  disabled: shuttle,
                  title: const Text("Right click me"),
                ),
              ),
            ),
            ComponentWell(
              child: Row(
                children: [
                  LdContextMenu(
                    zoomMode: _zoomMode,
                    blurMode: _blurMode,
                    menuBuilder: (context, onDismiss) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LdButtonGhost(
                                width: double.infinity,
                                size: LdSize.s,
                                trailing: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  onDismiss();
                                },
                                child: const Text("Button 1"),
                              ),
                              ldSpacerXS,
                              LdButtonGhost(
                                width: double.infinity,
                                size: LdSize.s,
                                trailing: const Icon(Icons.arrow_forward),
                                onPressed: () async {
                                  await Future.delayed(
                                      const Duration(seconds: 1));
                                  onDismiss();
                                },
                                child: const Text("Button 2"),
                              ),
                              ldSpacerXS,
                              const LdDivider(),
                              ldSpacerS,
                              LdButtonGhost(
                                width: double.infinity,
                                size: LdSize.s,
                                color: LdTheme.of(context).error,
                                trailing: const Icon(Icons.remove),
                                onPressed: () {
                                  onDismiss();
                                },
                                child: const Text("Button 2"),
                              ),
                            ]),
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
          ],
        ));
  }
}
