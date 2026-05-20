import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MultiPanelLayoutDemo extends StatefulWidget {
  const MultiPanelLayoutDemo({super.key});

  @override
  State<MultiPanelLayoutDemo> createState() => _MultiPanelLayoutDemoState();
}

class _MultiPanelLayoutDemoState extends State<MultiPanelLayoutDemo> {
  LdMultiPanelLayoutMode _mode = LdMultiPanelLayoutMode.stacked;
  bool _panelVisible = true;
  LdPanelPosition _panelPosition = LdPanelPosition.left;
  bool _allowResize = false;

  Widget _buildPanel(String title, Color color, LdPanelRole role) {
    return Builder(builder: (context) {
      final state = LdMultiPanelChildState.watch(context);
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: LdTheme.of(context).border),
          color: color.withAlpha(51),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LdText.hs(title),
              LdText.p(
                "Role: ${state.role.name}, On Screen: ${state.onScreen}",
                textAlign: TextAlign.center,
              ),
              LdText.p(
                "Width: ${state.width.toStringAsFixed(0)}px",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final isDark = theme.isDark;
    return ComponentPage(
      path: "lib/components/layout/multi_panel_layout.dart",
      title: "LdMultiPanelLayout",
      apiComponents: const [
        "LdMultiPanelLayout",
        "LdMultiPanelLayoutMode",
        "LdPanelPosition",
        "LdPanelRole",
      ],
      demo: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdBundle(
            children: [
              LdCard(
                padding: EdgeInsets.zero,
                child: SizedBox(
                  height: 250,
                  child: LdMultiPanelLayout(
                    mode: _mode,
                    panelVisible: _panelVisible,
                    panelPosition: _panelPosition,
                    allowResize: _allowResize,
                    initialPanelWidth: 200,
                    onPanelVisibilityChanged: (visible) {
                      setState(() {
                        _panelVisible = visible;
                      });
                    },
                    panel: _buildPanel(
                      "Panel",
                      theme.palette.primary.idle(isDark),
                      LdPanelRole.panel,
                    ),
                    body: _buildPanel(
                      "Body",
                      theme.palette.secondary.idle(isDark),
                      LdPanelRole.body,
                    ),
                  ),
                ),
              ),
              LdBundle(
                children: [
                  LdSelect<LdMultiPanelLayoutMode>(
                    value: _mode,
                    label: "Layout Mode",
                    items: const [
                      LdSelectItem(
                        child: Text("Side by Side"),
                        value: LdMultiPanelLayoutMode.sideBySide,
                      ),
                      LdSelectItem(
                        child: Text("Stacked"),
                        value: LdMultiPanelLayoutMode.stacked,
                      ),
                    ],
                    onChanged: (mode) {
                      setState(() {
                        _mode = mode;
                      });
                    },
                  ),
                  LdSelect<LdPanelPosition>(
                    value: _panelPosition,
                    label: "Panel Position",
                    items: const [
                      LdSelectItem(
                        child: Text("Left"),
                        value: LdPanelPosition.left,
                      ),
                      LdSelectItem(
                        child: Text("Right"),
                        value: LdPanelPosition.right,
                      ),
                    ],
                    onChanged: (pos) {
                      setState(() {
                        _panelPosition = pos;
                      });
                    },
                  ),
                ],
              ),
              LdToggle(
                checked: _panelVisible,
                onChanged: (v) => setState(() => _panelVisible = v),
                label: "Panel Visible",
              ),
              LdToggle(
                checked: _allowResize,
                onChanged: (v) => setState(() => _allowResize = v),
                label: "Allow Resize (side-by-side only)",
              ),
              Row(
                children: [
                  LdButton(
                    onPressed: () => setState(() => _panelVisible = !_panelVisible),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_panelVisible ? LucideIcons.panelLeftClose : LucideIcons.panelLeftOpen),
                        const SizedBox(width: 8),
                        Text(_panelVisible ? "Hide Panel" : "Show Panel"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
