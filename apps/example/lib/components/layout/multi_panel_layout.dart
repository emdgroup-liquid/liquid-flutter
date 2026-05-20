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
  LdMultiPanelLayoutMode _mode = LdMultiPanelLayoutMode.sideBySide;
  LdPanelPosition _panelPosition = LdPanelPosition.left;
  bool _allowResize = false;
  bool _panelVisible = true;

  Widget _buildChildInfo(BuildContext context, LdMultiPanelChildState state) {
    final theme = LdTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: state.role == LdPanelRole.panel
            ? theme.palette.primary.idle(theme.isDark).withAlpha(40)
            : theme.palette.secondary.idle(theme.isDark).withAlpha(40),
        border: Border.all(color: theme.border),
      ),
      child: Center(
        child: Padding(
          padding: theme.pad(size: LdSize.m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LdText.hs(
                state.role == LdPanelRole.panel ? "Panel" : "Body",
              ),
              ldSpacerS,
              LdText.p(
                "Role: ${state.role.name}",
                textAlign: TextAlign.center,
              ),
              LdText.p(
                "Left: ${state.left.toStringAsFixed(0)} px",
                textAlign: TextAlign.center,
              ),
              LdText.p(
                "Width: ${state.width.toStringAsFixed(0)} px",
                textAlign: TextAlign.center,
              ),
              LdText.p(
                "Dragging: ${state.isDragging}",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return Builder(
      builder: (context) {
        final state = LdMultiPanelChildState.watch(context);
        return _buildChildInfo(context, state);
      },
    );
  }

  Widget _buildBody() {
    return Builder(
      builder: (context) {
        final state = LdMultiPanelChildState.watch(context);
        return _buildChildInfo(context, state);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/layout/multi_panel_layout.dart",
      title: "LdMultiPanelLayout",
      apiComponents: const [
        "LdMultiPanelLayout",
        "LdMultiPanelLayoutMode",
        "LdPanelPosition",
        "LdPanelRole",
        "LdMultiPanelChildState",
      ],
      demo: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live preview
          LdCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 400,
              child: LdMultiPanelLayout(
                mode: _mode,
                panelPosition: _panelPosition,
                allowResize: _allowResize,
                panelVisible: _panelVisible,
                initialPanelWidth: 200,
                onPanelVisibilityChanged: (visible) {
                  setState(() {
                    _panelVisible = visible;
                  });
                },
                panel: _buildPanel(),
                body: _buildBody(),
              ),
            ),
          ),
          // Controls
          LdCard(
            child: LdAutoSpace(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LdText.hs("Controls"),
                LdSelect<LdMultiPanelLayoutMode>(
                  value: _mode,
                  label: "Mode",
                  items: const [
                    LdSelectItem(
                      value: LdMultiPanelLayoutMode.sideBySide,
                      child: Text("Side by Side"),
                    ),
                    LdSelectItem(
                      value: LdMultiPanelLayoutMode.stacked,
                      child: Text("Stacked"),
                    ),
                  ],
                  onChanged: (mode) => setState(() => _mode = mode),
                ),
                LdSelect<LdPanelPosition>(
                  value: _panelPosition,
                  label: "Panel Position",
                  items: const [
                    LdSelectItem(
                      value: LdPanelPosition.left,
                      child: Text("Left"),
                    ),
                    LdSelectItem(
                      value: LdPanelPosition.right,
                      child: Text("Right"),
                    ),
                  ],
                  onChanged: (pos) => setState(() => _panelPosition = pos),
                ),
                LdToggle(
                  label: "Allow Resize (side-by-side only)",
                  checked: _allowResize,
                  onChanged: (v) => setState(() => _allowResize = v),
                ),
                LdToggle(
                  label: "Panel Visible",
                  checked: _panelVisible,
                  onChanged: (v) => setState(() => _panelVisible = v),
                ),
                Row(
                  children: [
                    LdButton(
                      onPressed: () =>
                          setState(() => _panelVisible = !_panelVisible),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _panelVisible
                                ? LucideIcons.panelLeftClose
                                : LucideIcons.panelLeftOpen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _panelVisible ? "Hide Panel" : "Show Panel",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
