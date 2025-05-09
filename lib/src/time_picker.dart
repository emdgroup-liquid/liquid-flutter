import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdTimePicker extends StatelessWidget {
  final bool useRootNavigator;
  final bool disabled;
  final String? label;
  final TimeOfDay? value;
  final void Function(TimeOfDay?) onChanged;
  final int minutePrecision;
  final LdButtonMode buttonMode;

  const LdTimePicker({
    super.key,
    this.useRootNavigator = false,
    required this.onChanged,
    this.disabled = false,
    this.label,
    this.buttonMode = LdButtonMode.filled,
    this.value,
    this.minutePrecision = 15,
  });

  @override
  Widget build(BuildContext context) {
    final locale = LiquidLocalizations.of(context);

    var initialTimeString = locale.selectTime;

    if (value != null) {
      initialTimeString =
          '${value!.hour}:${value!.minute.toString().padLeft(2, '0')}';
    }

    return LdModalBuilder(
      useRootNavigator: useRootNavigator,
      builder: (context, open) => LdBundle(
        children: [
          if (label != null) LdTextL(label!),
          LdButton(
            child: Text(initialTimeString),
            key: const Key("time_picker_button"),
            onPressed: open,
            mode: buttonMode,
            disabled: disabled,
          )
        ],
      ),
      modal: LdModal(
        key: const Key('time_picker_sheet'),
        size: LdSize.m,
        fixedDialogSize: const Size(300, 300),
        title: label != null ? LdTextL(label!) : null,
        contentPadding: LdTheme.of(context).pad(size: LdSize.s),
        modalContent: (
          context,
        ) =>
            LdAutoSpace(
          children: [
            LdTimePickerWidget(
              initialTime: value,
              onTimeSelected: (time) {
                Navigator.pop(context);
                onChanged(time);
              },
              minutePrecision: minutePrecision,
            ),
          ],
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
  final _hourFocusNode = FocusNode();

  final _hourControllerText = TextEditingController();
  final _minuteControllerText = TextEditingController();

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
    }
  }

  void _minuteTextChanged(String newMinute) {
    final minute = int.tryParse(newMinute);
    if (minute != null && minute >= 0 && minute <= 59) {
      _time = TimeOfDay(
        hour: _time?.hour ?? 0,
        minute:
            ((minute / widget.minutePrecision).round() * widget.minutePrecision)
                .clamp(0, 59),
      );
      _applyWheels();
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
                    _time = TimeOfDay(
                      hour: value,
                      minute: _time?.minute ?? 0,
                    );
                    _applyText();
                    _applyWheels();
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
            const LdTextL(':'),
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
                    _time = TimeOfDay(
                      hour: _time?.hour ?? 0,
                      minute: value * widget.minutePrecision,
                    );
                    _applyText();
                    _applyWheels();
                  },
                  children:
                      List.generate(60 ~/ widget.minutePrecision, (index) {
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
                autofocus: kIsWeb ||
                    Platform.isMacOS ||
                    Platform.isLinux ||
                    Platform.isWindows,
                focusNode: _hourFocusNode,
                controller: _hourControllerText,
                size: LdSize.l,
                keyboardType: TextInputType.number,
                onSubmitted: (p0) {
                  _hourTextChanged(p0!);
                  _submit();
                },
                onBlur: (p0) => _hourTextChanged(p0!),
              ),
            ),
            ldSpacerM,
            const LdTextL(':'),
            ldSpacerM,
            Expanded(
              child: LdInput(
                hint: 'MM',
                controller: _minuteControllerText,
                keyboardType: TextInputType.number,
                onBlur: (p0) {
                  _minuteTextChanged(p0!);
                },
                onSubmitted: (p0) {
                  _minuteTextChanged(p0!);
                  _submit();
                },
                size: LdSize.l,
              ),
            ),
          ],
        ),
        Flexible(
          child: LdButton(
            width: double.infinity,
            onPressed: () {
              _submit();
            },
            child: const Text('Done'),
          ),
        ),
        ldSpacerL,
      ],
    );
  }
}
