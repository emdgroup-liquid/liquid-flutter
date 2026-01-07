import 'dart:math';

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
  int _visibleStartIndex = 0;
  int _visibleEndIndex = 2;
  bool _gesturesEnabled = true;
  double _spacing = 0;

  final List<PanelWidth> _panelWidths = [];

  @override
  void initState() {
    super.initState();
    _initializePanels();
  }

  void _initializePanels() {
    _panelWidths.clear();

    _panelWidths.addAll([
      const PanelWidth.fixed(200),
      const PanelWidth.fixed(100),
      const PanelWidth.fill(),
      const PanelWidth.fill(fillFlex: 2),
      const PanelWidth.quarter(),
    ]);
  }

  Widget _buildPanel(int index, String title, Color color) {
    return Builder(builder: (context) {
      final state = LdMultiPanelChildState.watch(context);
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: LdTheme.of(context).border),

          color: color.withAlpha(switch (_mode) {
            LdMultiPanelLayoutMode.sideBySide => state.isDragging ? 102 : 51,
            LdMultiPanelLayoutMode.stacked => 255,
          }), // ~20% opacity
        ),
        child: Placeholder(
          child: Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LdText.hs(title),
              Column(
                children: [
                  LdText.p(
                    "Left: ${state.left.toStringAsFixed(2)}, Width: ${state.width.toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                  ),
                  LdText.p(
                    "On Screen: ${state.onScreen}, Dragging: ${state.isDragging}",
                    textAlign: TextAlign.center,
                  ),
                  LdText.p(
                    "Drag Offset: ${state.dragOffset.toStringAsFixed(2)}",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (index == _visibleStartIndex || index == _visibleEndIndex) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LdButton(
                        disabled: index == _panelWidths.length - 1,
                        onPressed: () {
                          setState(() {
                            if (index == _visibleStartIndex) {
                              _visibleStartIndex = min(_visibleStartIndex + 1, _visibleEndIndex);
                            } else {
                              _visibleEndIndex = min(_visibleEndIndex + 1, _panelWidths.length - 1);
                            }
                          });
                        },
                        child: Icon(LucideIcons.moveLeft)),
                    LdButton(
                        disabled: index == 0,
                        onPressed: () {
                          setState(() {
                            if (index == _visibleEndIndex) {
                              _visibleEndIndex = max(_visibleEndIndex - 1, _visibleStartIndex);
                            } else {
                              _visibleStartIndex = max(_visibleStartIndex - 1, 0);
                            }
                          });
                        },
                        child: Icon(LucideIcons.moveRight)),
                  ],
                ),
              ]
            ],
          )),
        ),
      );
    });
  }

  void _changeMode(LdMultiPanelLayoutMode? mode) {
    setState(() {
      _mode = mode ?? LdMultiPanelLayoutMode.sideBySide;
    });
  }

  void _changeVisibleStart(int? value) {
    if (value == null) return;
    setState(() {
      _visibleStartIndex = value.clamp(0, _visibleEndIndex);
    });
  }

  void _changeVisibleEnd(int? value) {
    if (value == null) return;
    setState(() {
      _visibleEndIndex = value.clamp(_visibleStartIndex, _panelWidths.length);
    });
  }

  void _changeGesturesEnabled(bool? enabled) {
    setState(() {
      _gesturesEnabled = enabled ?? true;
    });
  }

  void _handleVisibleRangeChanged(int startIndex, int endIndex) {
    setState(() {
      _visibleStartIndex = startIndex;
      _visibleEndIndex = endIndex;
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
        "PanelWidth",
        "LdMultiPanelLayoutMode",
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
                  child: /*begin demo:LdMultiPanelLayout*/
                      LdMultiPanelLayout(
                    mode: _mode,
                    visibleStartIndex: _visibleStartIndex,
                    visibleEndIndex: _visibleEndIndex,
                    spacing: _spacing,
                    widths: _panelWidths,
                    onVisibleRangeChanged: _gesturesEnabled ? _handleVisibleRangeChanged : null,
                    children: [
                      _buildPanel(0, "Panel 0 (fixed 200px)", theme.palette.error.idle(isDark)),
                      _buildPanel(1, "Panel 1 (fixed 100px)", theme.palette.primary.idle(isDark)),
                      _buildPanel(2, "Panel 2 (fill 1x)", theme.palette.secondary.idle(isDark)),
                      _buildPanel(3, "Panel 3 (fill 2x)", theme.palette.success.idle(isDark)),
                      _buildPanel(4, "Panel 4 (quarter)", theme.palette.warning.idle(isDark)),
                    ],
                  ),
                  /*end demo:LdMultiPanelLayout*/
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
                    onChanged: _changeMode,
                  ),
                ],
              ),
              LdSwitch(
                value: _spacing,
                children: {
                  0.0: Text("0"),
                  12.0: Text("12"),
                  16.0: Text("16"),
                },
                onChanged: (value) {
                  setState(() {
                    _spacing = value;
                  });
                },
              ),
              Text("Visible Start Index: $_visibleStartIndex, ${_panelWidths.length}"),
              LdBundle(
                children: [
                  LdSelect<int>(
                    value: _visibleStartIndex,
                    label: "Visible Start Index",
                    items: List.generate(
                      _panelWidths.length,
                      (index) => LdSelectItem(
                        child: Text("$index"),
                        value: index,
                      ),
                    ),
                    onChanged: _changeVisibleStart,
                  ),
                ],
              ),
              Text("Visible End Index: $_visibleEndIndex"),
              LdBundle(
                children: [
                  LdSelect<int>(
                    value: _visibleEndIndex,
                    label: "Visible End Index",
                    items: List.generate(
                      _panelWidths.length,
                      (index) => LdSelectItem(
                        child: Text("$index"),
                        value: index,
                      ),
                    ).where((item) => item.value >= _visibleStartIndex).toList(),
                    onChanged: _changeVisibleEnd,
                  ),
                ],
              ),
              LdToggle(
                checked: _gesturesEnabled,
                onChanged: _changeGesturesEnabled,
                label: "Enable Gestures",
              ),
            ],
          ),
          /* LdBundle(
            children: [
              LdText.h("Side-by-Side Mode"),
              LdText.p(
                "In side-by-side mode, children are placed horizontally next to each other. "
                "Children outside the visible range are positioned off-screen and can be animated in by changing the visible range.",
              ),
              ComponentWell(
                child: SizedBox(
                  height: 300,
                  child: LdMultiPanelLayout(
                    mode: LdMultiPanelLayoutMode.sideBySide,
                    visibleStartIndex: 0,
                    visibleEndIndex: 3,
                    children: [
                      _buildSimplePanel(0, "Fixed 200px", Colors.blue),
                      _buildSimplePanel(1, "Third", Colors.green),
                      _buildSimplePanel(2, "Fill", Colors.orange),
                    ],
                    widths: const [
                      PanelWidth.fixed(200),
                      PanelWidth.third(),
                      PanelWidth.fill(),
                    ],
                  ),
                ),
              ),
            ],
          ), */
          /* LdBundle(
            children: [
              LdText.h("Stacked Mode"),
              LdText.p(
                "In stacked mode, children are overlaid on top of each other. "
                "Children outside the visible range are hidden. Higher index children appear on top.",
              ),
              ComponentWell(
                child: SizedBox(
                  height: 300,
                  child: LdMultiPanelLayout(
                    mode: LdMultiPanelLayoutMode.stacked,
                    visibleStartIndex: 0,
                    visibleEndIndex: 2,
                    children: [
                      _buildSimplePanel(0, "Panel 1 (bottom)", Colors.blue),
                      _buildSimplePanel(1, "Panel 2 (top)", Colors.green),
                    ],
                    widths: const [
                      PanelWidth.fill(),
                      PanelWidth.fill(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          LdBundle(
            children: [
              LdText.h("Width Utilities"),
              LdText.p(
                "PanelWidth provides several utilities for configuring panel widths:",
              ),
              LdText.p("• Fixed width: PanelWidth.fixed(200)"),
              LdText.p("• Fractions: PanelWidth.half(), PanelWidth.third(), PanelWidth.twoThirds(), etc."),
              LdText.p("• Fill remaining: PanelWidth.fill()"),
              ComponentWell(
                child: SizedBox(
                  height: 200,
                  child: LdMultiPanelLayout(
                    mode: LdMultiPanelLayoutMode.sideBySide,
                    visibleStartIndex: 0,
                    visibleEndIndex: 4,
                    children: [
                      _buildSimplePanel(0, "Half", Colors.red),
                      _buildSimplePanel(1, "Quarter", Colors.blue),
                      _buildSimplePanel(2, "Quarter", Colors.green),
                      _buildSimplePanel(3, "Fill", Colors.orange),
                    ],
                    widths: const [
                      PanelWidth.half(),
                      PanelWidth.quarter(),
                      PanelWidth.quarter(),
                      PanelWidth.fill(),
                    ],
                  ),
                ),
              ),
            ],
          ), */
          LdBundle(
            children: [
              LdText.h("Push Animations"),
              LdText.p(
                "When gestures are enabled, you can drag panels left or right to push them. "
                "The onPushLeft and onPushRight callbacks are triggered based on drag velocity.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
