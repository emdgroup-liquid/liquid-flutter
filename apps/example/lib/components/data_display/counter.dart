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

  Timer? _timer;
  Timer? _inlineTimer;

  @override
  void dispose() {
    _timer?.cancel();
    _inlineTimer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/data_display/counter.dart",
      title: "LdCounter",
      apiComponents: const ["LdCounter", "LdCounter.s", "LdCounter.l", "LdCounter.xs", "LdCounterText"],
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
                      LdCounter(value: _value, size: _size, type: _type, precision: _precision, minDigits: _minDigits),
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
              LdText.h("Size variants"),
              LdText.p("Use factory constructors for preset sizes."),
              ComponentWell(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    /*begin demo:LdCounterSizes*/
                    LdCounter.xs(value: 128),
                    LdCounter.s(value: 128),
                    LdCounter(value: 128),
                    LdCounter.l(value: 128),
                    /*end demo:LdCounterSizes*/
                  ],
                ),
              ),
            ],
          ),
          LdBundle(
            children: [
              LdText.h("Typography types"),
              ComponentWell(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    /*begin demo:LdCounterTypes*/
                    LdCounter(value: 256, type: LdTextType.headline),
                    LdCounter(value: 256, type: LdTextType.paragraph),
                    LdCounter(value: 256, type: LdTextType.label),
                    LdCounter(value: 256, type: LdTextType.caption),
                    /*end demo:LdCounterTypes*/
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
        ],
      ),
    );
  }
}
