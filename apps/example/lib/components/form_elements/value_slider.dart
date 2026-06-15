import 'package:flutter/material.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import '../component_page.dart';

class LdValueSliderDemo extends StatefulWidget {
  const LdValueSliderDemo({super.key});

  @override
  State<LdValueSliderDemo> createState() => _LdValueSliderDemoState();
}

class _LdValueSliderDemoState extends State<LdValueSliderDemo> {
  // Single-mode state
  double _singleValue = 50.0;

  // Range-mode state
  double _lowValue = 25.0;
  double _highValue = 75.0;

  // Shared controls
  bool _disabled = false;
  bool _isRange = false;
  LdSize _size = LdSize.m;
  Axis _direction = Axis.horizontal;
  bool _allowRangeDrag = false;
  double _step = 0.0;

  @override
  Widget build(BuildContext context) {
    final String valueText = _isRange
        ? 'Low: ${_lowValue.toStringAsFixed(1)}  |  High: ${_highValue.toStringAsFixed(1)}'
        : 'Value: ${_singleValue.toStringAsFixed(1)}';

    final Widget slider = _isRange
        ? SizedBox(
            height: _direction == Axis.vertical ? 200 : null,
            child: LdSlider.range(
              lowValue: _lowValue,
              highValue: _highValue,
              min: 0.0,
              max: 100.0,
              step: _step,
              size: _size,
              direction: _direction,
              disabled: _disabled,
              allowRangeDrag: _allowRangeDrag,
              onRangeChanged: (low, high) {
                setState(() {
                  _lowValue = low;
                  _highValue = high;
                });
              },
            ),
          )
        : SizedBox(
            height: _direction == Axis.vertical ? 200 : null,
            child: LdSlider(
              value: _singleValue,
              min: 0.0,
              max: 100.0,
              step: _step,
              size: _size,
              direction: _direction,
              disabled: _disabled,
              onChanged: (v) {
                setState(() => _singleValue = v);
              },
            ),
          );

    return ComponentPage(
      path: "lib/components/form_elements/value_slider.dart",
      title: "LdSlider",
      apiComponents: const ["LdSlider"],
      demo: LdAutoSpace(
        children: [
          // ---- Live demo ----
          ComponentWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LdText(valueText),
                ldSpacerM,
                if (_direction == Axis.vertical)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [slider],
                  )
                else
                  slider,
              ],
            ),
          ),

          // ---- Controls ----

          // Mode toggle (single vs range)
          LdToggle(
            label: "Range mode",
            checked: _isRange,
            onChanged: (v) => setState(() => _isRange = v),
          ),

          // Disabled toggle
          LdToggle(
            label: "Disabled",
            checked: _disabled,
            onChanged: (v) => setState(() => _disabled = v),
          ),

          // allowRangeDrag toggle (only relevant in range mode)
          LdToggle(
            label: "Allow range drag (range mode only)",
            checked: _allowRangeDrag,
            onChanged: (v) => setState(() => _allowRangeDrag = v),
          ),

          // Direction toggle
          LdToggle(
            label: "Vertical orientation",
            checked: _direction == Axis.vertical,
            onChanged: (v) =>
                setState(() => _direction = v ? Axis.vertical : Axis.horizontal),
          ),

          // Size selector
          LdText("Size"),
          LdSelect<LdSize>(
            value: _size,
            items: const [
              LdSelectItem(child: Text("XS"), value: LdSize.xs),
              LdSelectItem(child: Text("S"), value: LdSize.s),
              LdSelectItem(child: Text("M"), value: LdSize.m),
              LdSelectItem(child: Text("L"), value: LdSize.l),
            ],
            onChanged: (v) => setState(() => _size = v),
          ),

          // Step input
          LdText("Step (0 = continuous)"),
          LdSelect<double>(
            value: _step,
            items: const [
              LdSelectItem(child: Text("Continuous (0)"), value: 0.0),
              LdSelectItem(child: Text("Step 1"), value: 1.0),
              LdSelectItem(child: Text("Step 5"), value: 5.0),
              LdSelectItem(child: Text("Step 10"), value: 10.0),
              LdSelectItem(child: Text("Step 25"), value: 25.0),
            ],
            onChanged: (v) => setState(() => _step = v),
          ),
        ],
      ),
    );
  }
}
