import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CounterDemo extends StatefulWidget {
  const CounterDemo({super.key});

  @override
  State<CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends State<CounterDemo> {
  double _value = 42;
  double _inlineValue = 7;
  LdSize _size = LdSize.m;
  LdTextType _type = LdTextType.headline;
  int _precision = 0;
  int? _minDigits;
  bool _autoIncrement = false;
  bool _inlineAutoIncrement = false;
  bool _durationRunning = false;
  bool _showTenths = false;
  Duration _elapsed = Duration.zero;

  Timer? _timer;
  Timer? _inlineTimer;
  Timer? _durationTimer;

  @override
  void dispose() {
    _timer?.cancel();
    _inlineTimer?.cancel();
    _durationTimer?.cancel();
    super.dispose();
  }

  void _setAutoIncrement(bool enabled) {
    setState(() {
      _autoIncrement = enabled;
    });

    _timer?.cancel();
    if (enabled) {
      _timer = Timer.periodic(const Duration(milliseconds: 800), (_) {
        setState(() {
          _value += 1;
        });
      });
    }
  }

  void _setInlineAutoIncrement(bool enabled) {
    setState(() {
      _inlineAutoIncrement = enabled;
    });

    _inlineTimer?.cancel();
    if (enabled) {
      _inlineTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
        setState(() {
          _inlineValue += 1;
        });
      });
    }
  }

  void _changeSize(LdSize? size) {
    setState(() {
      _size = size ?? LdSize.m;
    });
  }

  void _changeType(LdTextType? type) {
    setState(() {
      _type = type ?? LdTextType.headline;
    });
  }

  void _changePrecision(int? precision) {
    setState(() {
      _precision = precision ?? 0;
    });
  }

  void _changeMinDigits(int? minDigits) {
    setState(() {
      _minDigits = minDigits;
    });
  }

  void _syncDurationTimer() {
    _durationTimer?.cancel();
    if (!_durationRunning) {
      return;
    }
    final step = _showTenths
        ? const Duration(milliseconds: 100)
        : const Duration(seconds: 1);
    _durationTimer = Timer.periodic(step, (_) {
      setState(() {
        _elapsed += step;
      });
    });
  }

  void _setDurationRunning(bool enabled) {
    setState(() {
      _durationRunning = enabled;
    });
    _syncDurationTimer();
  }

  void _setShowTenths(bool enabled) {
    setState(() {
      _showTenths = enabled;
    });
    if (_durationRunning) {
      _syncDurationTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/data_display/counter.dart",
      title: "LdCounter",
      apiComponents: const ["LdCounter", "LdCounterText", "LdCounterDuration"],
      demo: LdAutoSpace(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdText.p(
            "LdCounter animates numeric values with a rolling digit effect. "
            "Use size and type to match Liquid Flutter typography, and minDigits to pad with leading zeros.",
          ),
          LdBundle(
            children: [
              ComponentWell(
                onSurface: true,
                child: Center(
                  child: Column(
                    children: [
                      /*begin demo:LdCounter*/
                      LdCounter(
                        value: _value,
                        precision: _precision,
                        minDigits: _minDigits,
                        size: _size,
                        type: _type,
                      ),
                      /*end demo:LdCounter*/
                      ldSpacerM,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LdButton(
                            mode: LdButtonMode.ghost,
                            child: const Icon(LucideIcons.minus),
                            onPressed: () => setState(() => _value -= 1),
                          ),
                          ldSpacerS,
                          LdButton(
                            mode: LdButtonMode.ghost,
                            child: const Icon(LucideIcons.plus),
                            onPressed: () => setState(() => _value += 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              LdSelect<LdTextType>(
                value: _type,
                label: "Type",
                items: const [
                  LdSelectItem(child: Text("Headline"), value: LdTextType.headline),
                  LdSelectItem(child: Text("Paragraph"), value: LdTextType.paragraph),
                  LdSelectItem(child: Text("Label"), value: LdTextType.label),
                  LdSelectItem(child: Text("Caption"), value: LdTextType.caption),
                ],
                onChanged: _changeType,
              ),
              LdSelect<LdSize>(
                value: _size,
                label: "Size",
                items: const [
                  LdSelectItem(child: Text("Extra Small (XS)"), value: LdSize.xs),
                  LdSelectItem(child: Text("Small (S)"), value: LdSize.s),
                  LdSelectItem(child: Text("Medium (M)"), value: LdSize.m),
                  LdSelectItem(child: Text("Large (L)"), value: LdSize.l),
                ],
                onChanged: _changeSize,
              ),
              LdSelect<int>(
                value: _precision,
                label: "Precision",
                items: const [
                  LdSelectItem(child: Text("0"), value: 0),
                  LdSelectItem(child: Text("1"), value: 1),
                  LdSelectItem(child: Text("2"), value: 2),
                ],
                onChanged: _changePrecision,
              ),
              LdSelect<int?>(
                value: _minDigits,
                label: "Min digits (leading zeros)",
                items: const [
                  LdSelectItem(child: Text("None"), value: null),
                  LdSelectItem(child: Text("2"), value: 2),
                  LdSelectItem(child: Text("3"), value: 3),
                  LdSelectItem(child: Text("4"), value: 4),
                  LdSelectItem(child: Text("5"), value: 5),
                ],
                onChanged: _changeMinDigits,
              ),
              LdToggle(
                checked: _autoIncrement,
                onChanged: (value) => _setAutoIncrement(value),
                label: "Auto increment",
              ),
            ],
          ),
          LdBundle(
            children: [
              LdText.h("Inline in text"),
              LdText.p(
                "Use LdCounterText to embed an animated counter in a sentence on a shared baseline. "
                "For custom RichText, pass inline: true to LdCounter inside a baseline WidgetSpan.",
              ),
              ComponentWell(
                child: LdAutoSpace(
                  children: [
                    /*begin demo:LdCounterText*/
                    LdCounterText.template('You changed %value% files', value: _inlineValue),
                    LdCounterText(
                      before: 'Temperature is ',
                      after: ' °C and rising',
                      value: _inlineValue,
                      type: LdTextType.label,
                    ),
                    /*end demo:LdCounterText*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LdButton(
                          mode: LdButtonMode.ghost,
                          child: const Icon(LucideIcons.minus),
                          onPressed: () => setState(() => _inlineValue -= 1),
                        ),
                        ldSpacerS,
                        LdButton(
                          mode: LdButtonMode.ghost,
                          child: const Icon(LucideIcons.plus),
                          onPressed: () => setState(() => _inlineValue += 1),
                        ),
                      ],
                    ),
                    LdToggle(
                      checked: _inlineAutoIncrement,
                      onChanged: _setInlineAutoIncrement,
                      label: "Auto increment",
                    ),
                  ],
                ),
              ),
            ],
          ),

          LdBundle(
            children: [
              LdText.h("Leading zeros"),
              LdText.p("Set minDigits to pad the integer part with leading zeros."),
              ComponentWell(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    /*begin demo:LdCounterLeadingZeros*/
                    LdCounter(value: 7, minDigits: 2),
                    LdCounter(value: 42, minDigits: 4),
                    LdCounter(value: 3.14, precision: 2, minDigits: 3),
                    /*end demo:LdCounterLeadingZeros*/
                  ],
                ),
              ),
            ],
          ),

          LdBundle(
            children: [
              LdText.h("Duration"),
              LdText.p(
                "LdCounterDuration formats a Duration as MM:SS under one hour, "
                "or H:MM:SS above. Enable tenths for a trailing .T digit.",
              ),
              ComponentWell(
                onSurface: true,
                child: LdAutoSpace(
                  children: [
                    /*begin demo:LdCounterDuration*/
                    Center(
                      child: LdCounterDuration(
                        duration: _elapsed,
                        size: _size,
                        type: _type,
                        showTenths: _showTenths,
                      ),
                    ),
                    Center(
                      child: LdCounterDuration(
                        duration: const Duration(hours: 1, minutes: 2, seconds: 3),
                        size: LdSize.s,
                        type: LdTextType.label,
                      ),
                    ),
                    /*end demo:LdCounterDuration*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LdButton(
                          mode: LdButtonMode.ghost,
                          child: const Icon(LucideIcons.rotateCcw),
                          onPressed: () => setState(() => _elapsed = Duration.zero),
                        ),
                        ldSpacerS,
                        LdButton(
                          mode: LdButtonMode.ghost,
                          child: Icon(
                            _durationRunning ? LucideIcons.pause : LucideIcons.play,
                          ),
                          onPressed: () => _setDurationRunning(!_durationRunning),
                        ),
                      ],
                    ),
                    LdToggle(
                      checked: _showTenths,
                      onChanged: _setShowTenths,
                      label: "Show tenths",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
