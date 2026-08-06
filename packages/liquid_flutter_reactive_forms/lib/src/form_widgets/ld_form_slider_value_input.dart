import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Compact numeric [LdInput] used beside [LdFormSlider] / [LdFormRangeSlider].
///
/// Commits on blur and submit. Syncs from [value] only while unfocused so
/// typing is not interrupted by slider rebuilds.
class LdFormSliderValueInput extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final bool isInteger;
  final bool disabled;
  final LdSize size;
  final ValueChanged<double> onChanged;
  final VoidCallback? onCommitted;

  const LdFormSliderValueInput({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.isInteger = false,
    this.disabled = false,
    this.size = LdSize.s,
    this.onCommitted,
  });

  @override
  State<LdFormSliderValueInput> createState() => _LdFormSliderValueInputState();
}

class _LdFormSliderValueInputState extends State<LdFormSliderValueInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant LdFormSliderValueInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode.hasFocus) return;
    final next = _format(widget.value);
    if (_controller.text != next) {
      _controller.text = next;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && mounted) {
      _commit();
    }
  }

  String _format(double value) {
    if (widget.isInteger) {
      return value.round().toString();
    }
    final places = _decimalPlaces(widget.step);
    final fixed = value.toStringAsFixed(places);
    if (places == 0) return fixed;
    // Trim trailing zeros while keeping at least one digit after the point
    // when the value is non-integer.
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  int _decimalPlaces(double step) {
    if (widget.isInteger || step <= 0) {
      return widget.isInteger ? 0 : 2;
    }
    var s = step;
    var places = 0;
    while (s < 1 && places < 6) {
      s *= 10;
      places++;
    }
    // Handle floating-point noise (e.g. 0.1 * 10 = 0.999...)
    if ((s - s.round()).abs() > 1e-9) {
      places = (places + 1).clamp(0, 6);
    }
    return places;
  }

  double _snap(double value) {
    final clamped = value.clamp(widget.min, widget.max);
    if (widget.step <= 0) return clamped;
    final snapped = (clamped / widget.step).round() * widget.step;
    return snapped.clamp(widget.min, widget.max);
  }

  void _commit() {
    final parsed = double.tryParse(
      _controller.text.trim().replaceAll(',', '.'),
    );
    if (parsed == null) {
      _controller.text = _format(widget.value);
      return;
    }
    final next = widget.isInteger ? _snap(parsed).roundToDouble() : _snap(parsed);
    _controller.text = _format(next);
    if (next != widget.value) {
      widget.onChanged(next);
    }
    widget.onCommitted?.call();
  }

  double get _width {
    final samples = [
      widget.min,
      widget.max,
      widget.value,
    ];
    var longest = 1;
    for (final sample in samples) {
      final length = _format(sample).length;
      if (length > longest) longest = length;
    }
    // Extra character for typing + padding for the input chrome.
    return ((longest + 1) * 10.0 + 28.0).clamp(56.0, 120.0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: LdInput(
        hint: '',
        controller: _controller,
        focusNode: _focusNode,
        size: widget.size,
        disabled: widget.disabled,
        showClear: false,
        selectAllOnFocus: true,
        keyboardType: TextInputType.numberWithOptions(
          decimal: !widget.isInteger,
          signed: widget.min < 0,
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _commit(),
      ),
    );
  }
}
