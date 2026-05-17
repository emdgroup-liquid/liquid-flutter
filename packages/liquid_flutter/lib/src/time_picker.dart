import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/touchable/input_color.dart';

class LdTimePicker extends StatelessWidget {
  final bool useRootNavigator;
  final bool disabled;
  final String? label;
  final TimeOfDay? value;
  final void Function(TimeOfDay) onChanged;
  final int minutePrecision;
  final LdButtonMode buttonMode;
  final FocusNode? focusNode;

  const LdTimePicker({
    super.key,
    this.useRootNavigator = false,
    required this.onChanged,
    this.disabled = false,
    this.label,
    this.buttonMode = LdButtonMode.filled,
    this.value,
    this.minutePrecision = 15,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final locale = LiquidLocalizations.of(context);
    final theme = LdTheme.of(context);

    var initialTimeString = locale.selectTime;

    if (value != null) {
      initialTimeString = '${value!.hour}:${value!.minute.toString().padLeft(2, '0')}';
    }

    return LdBundle(
      children: [
        if (label != null) LdText.l(label!),
        LdTouchableSurface(
          allowTapOutside: true,
          disabled: disabled,
          focusNode: focusNode,
          key: const Key("time_picker_button"),
          onPressed: () async {
            final navigator = useRootNavigator ? Navigator.of(context, rootNavigator: true) : Navigator.of(context);
            final newTime = await navigator.push(LdModalRoute(
              context: context,
              pageBuilder: (context) => LdTimePickerModal(initialTime: value, minutePrecision: minutePrecision),
            )) as TimeOfDay?;

            if (newTime != null) {
              onChanged(newTime);
            }
          },
          builder: (context, status, _) => Builder(builder: (context) {
            final colorBundle = inputColor(theme, status, isValid: true);
            return Container(
              clipBehavior: Clip.hardEdge,
              padding: theme.pad(size: LdSize.s),
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorBundle.surface,
                borderRadius: theme.radius(LdSize.s),
                border: Border.all(
                  color: colorBundle.border,
                  width: theme.borderWidth,
                ),
              ),
              child: LdText.l(initialTimeString),
            );
          }),
        ),
      ],
    );
  }
}

class LdTimePickerModal extends StatefulWidget {
  const LdTimePickerModal({
    super.key,
    this.initialTime,
    this.minutePrecision = 15,
  });

  final TimeOfDay? initialTime;
  final int minutePrecision;

  @override
  State<LdTimePickerModal> createState() => _LdTimePickerModalState();
}

class _LdTimePickerModalState extends State<LdTimePickerModal> {
  late TimeOfDay? _time = widget.initialTime;

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime ?? TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return LdScaffold(
      key: const Key('time_picker_sheet'),
      body: LdAppBar(
        title: Text(LiquidLocalizations.of(context).selectTime),
        child: LdAppBar.bottom(
          actions: [
            LdFlexibleChild(
              child: LdButton.vague(
                width: double.infinity,
                child: Text(LiquidLocalizations.of(context).done),
                onPressed: () => Navigator.pop(context, _time),
              ),
            )
          ],
          child: LdScaffoldBody(
            children: [
              LdTimePickerWidget(
                initialTime: _time,
                onTimeSelected: (time) {
                  setState(() {
                    _time = time;
                  });
                },
                minutePrecision: widget.minutePrecision,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LdTimePickerWidget extends StatefulWidget {
  const LdTimePickerWidget({
    required this.initialTime,
    required this.onTimeSelected,
    this.minutePrecision = 15,
    super.key,
  });
  final int minutePrecision;

  final TimeOfDay? initialTime;
  final void Function(TimeOfDay newTime) onTimeSelected;

  @override
  State<LdTimePickerWidget> createState() => _LdTimePickerWidgetState();
}

class _LdTimePickerWidgetState extends State<LdTimePickerWidget> {
  final _hourController = FixedExtentScrollController();
  final _minuteController = FixedExtentScrollController();

  final _hourControllerText = TextEditingController();
  final _minuteControllerText = TextEditingController();

  final _hourFocusNode = FocusNode();
  final _minuteFocusNode = FocusNode();

  late TimeOfDay? _time = widget.initialTime;

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime ?? TimeOfDay.now();
    _hourControllerText.text = _time!.hour.toString();
    _minuteControllerText.text = _time!.minute.toString();
    _applyWheels();
    _applyText();
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _hourControllerText.dispose();
    _minuteControllerText.dispose();
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _applyWheels() async {
    if (_time == null) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) {
      return;
    }
    unawaited(
      _hourController.animateTo(
        (_time!.hour) * 32,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      ),
    );
    unawaited(
      _minuteController.animateTo(
        (_time!.minute ~/ widget.minutePrecision) * 32,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
      ),
    );
  }

  void _applyText() {
    _hourControllerText.text = _time!.hour.toString();
    _minuteControllerText.text = _time!.minute.toString();
  }

  void _hourTextChanged(String newHour) {
    final hour = int.tryParse(newHour);
    if (hour != null && hour >= 0 && hour <= 23) {
      _time = TimeOfDay(hour: hour, minute: _time?.minute ?? 0);
      _applyWheels();
      widget.onTimeSelected(_time!);
    }
  }

  void _minuteTextChanged(String newMinute) {
    final minute = int.tryParse(newMinute);
    if (minute != null && minute >= 0 && minute <= 59) {
      _time = TimeOfDay(
        hour: _time?.hour ?? 0,
        minute: ((minute / widget.minutePrecision).round() * widget.minutePrecision).clamp(0, 59),
      );
      _applyWheels();
      widget.onTimeSelected(_time!);
    }
  }

  void _submit() {
    if (_time == null) return;

    _minuteTextChanged(_minuteControllerText.text);
    _hourTextChanged(_hourControllerText.text);

    widget.onTimeSelected(_time!);
  }

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 128,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: LdTheme.of(context).border,
                    width: LdTheme.of(context).borderWidth,
                  ),
                  borderRadius: LdTheme.of(context).radius(LdSize.s),
                  color: LdTheme.of(context).surface,
                ),
                child: CupertinoPicker(
                  scrollController: _hourController,
                  selectionOverlay: Container(),
                  squeeze: 1.4,
                  itemExtent: 32,
                  useMagnifier: true,
                  onSelectedItemChanged: (value) {
                    if (_hourFocusNode.hasFocus) {
                      return;
                    }
                    _time = TimeOfDay(
                      hour: value,
                      minute: _time?.minute ?? 0,
                    );
                    _applyText();
                    _applyWheels();
                    _submit();
                  },
                  children: List.generate(24, (index) {
                    return Container(
                      height: 32,
                      padding: const EdgeInsets.all(4),
                      color: LdTheme.of(context).surface,
                      child: Center(
                        child: Text(
                          index.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            ldSpacerM,
            LdText.l(':'),
            ldSpacerM,
            Expanded(
              child: Container(
                height: 128,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: LdTheme.of(context).border,
                    width: LdTheme.of(context).borderWidth,
                  ),
                  color: LdTheme.of(context).surface,
                  borderRadius: LdTheme.of(context).radius(LdSize.s),
                ),
                child: CupertinoPicker(
                  scrollController: _minuteController,
                  selectionOverlay: Container(),
                  squeeze: 1.4,
                  itemExtent: 32,
                  useMagnifier: true,
                  onSelectedItemChanged: (value) {
                    if (_minuteFocusNode.hasFocus) {
                      return;
                    }
                    _time = TimeOfDay(
                      hour: _time?.hour ?? 0,
                      minute: value * widget.minutePrecision,
                    );
                    _applyText();
                    _applyWheels();
                    _submit();
                  },
                  children: List.generate(60 ~/ widget.minutePrecision, (index) {
                    return Container(
                      height: 32,
                      padding: const EdgeInsets.all(4),
                      child: Center(
                        child: Text(
                          (index * widget.minutePrecision).toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: LdInput(
                hint: 'HH',
                autofocus: LdTheme.of(context).platform.isDesktop,
                focusNode: _hourFocusNode,
                controller: _hourControllerText,
                size: LdSize.l,
                keyboardType: TextInputType.number,
                onChanged: (p0) {
                  _hourTextChanged(p0);
                },
              ),
            ),
            ldSpacerM,
            LdText.l(':'),
            ldSpacerM,
            Expanded(
              child: LdInput(
                focusNode: _minuteFocusNode,
                hint: 'MM',
                controller: _minuteControllerText,
                keyboardType: TextInputType.number,
                onChanged: (p0) {
                  _minuteTextChanged(p0);
                },
                size: LdSize.l,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
