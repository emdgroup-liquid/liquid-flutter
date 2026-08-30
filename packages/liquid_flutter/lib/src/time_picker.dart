import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdTimePicker extends StatelessWidget {
  final bool useRootNavigator;
  final bool disabled;
  final String? label;
  final LdSize size;
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
    this.size = LdSize.m,
    this.buttonMode = LdButtonMode.filled,
    this.value,
    this.minutePrecision = 15,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final locale = LiquidLocalizations.of(context);
    final theme = LdTheme.of(context, listen: true);
    final lineBoxHeight = theme.labelSize(size) * ldLineHeight(LdTextType.label, size: size);
    final fieldPadding = theme.controlContentPadding(size) - EdgeInsets.all(theme.borderWidth);

    var initialTimeString = locale.selectTime;

    if (value != null) {
      initialTimeString = '${value!.hour}:${value!.minute.toString().padLeft(2, '0')}';
    }

    return LdBundle(
      children: [
        if (label != null)
          LdText.l(
            label!,
            size: size,
          ),
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
              padding: fieldPadding,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorBundle.surface,
                borderRadius: theme.radius(LdSize.s),
                border: Border.all(
                  color: colorBundle.border,
                  width: theme.borderWidth,
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: lineBoxHeight,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LdText.l(
                    initialTimeString,
                    size: size,
                    color: colorBundle.text,
                  ),
                ),
              ),
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
            shrinkWrap: true,
            children: [
              LdTimePickerWidget(
                initialTime: _time,
                onTimeSelected: (time) {
                  _time = time;
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
  late final FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  final _hourControllerText = TextEditingController();
  final _minuteControllerText = TextEditingController();

  final _hourFocusNode = FocusNode();
  final _minuteFocusNode = FocusNode();

  late TimeOfDay _time;
  bool _syncingWheels = false;

  int get _minuteIndex => (_time.minute ~/ widget.minutePrecision).clamp(
        0,
        (60 ~/ widget.minutePrecision) - 1,
      );

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime ?? TimeOfDay.now();
    _hourController = FixedExtentScrollController(initialItem: _time.hour);
    _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);
    _applyText();
  }

  @override
  void didUpdateWidget(covariant LdTimePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.minutePrecision != oldWidget.minutePrecision) {
      _minuteController.dispose();
      _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);
    }
    final incoming = widget.initialTime;
    if (incoming != null && incoming != _time) {
      _time = incoming;
      _applyText();
      _jumpWheels();
    }
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

  void _applyText() {
    final hour = _time.hour.toString();
    final minute = _time.minute.toString();
    if (!_hourFocusNode.hasFocus && _hourControllerText.text != hour) {
      _hourControllerText.text = hour;
    }
    if (!_minuteFocusNode.hasFocus && _minuteControllerText.text != minute) {
      _minuteControllerText.text = minute;
    }
  }

  void _jumpWheels({bool hour = true, bool minute = true}) {
    _syncingWheels = true;
    if (hour && _hourController.hasClients && _hourController.selectedItem != _time.hour) {
      _hourController.jumpToItem(_time.hour);
    }
    if (minute && _minuteController.hasClients && _minuteController.selectedItem != _minuteIndex) {
      _minuteController.jumpToItem(_minuteIndex);
    }
    _syncingWheels = false;
  }

  void _hourTextChanged(String newHour) {
    final hour = int.tryParse(newHour);
    if (hour != null && hour >= 0 && hour <= 23) {
      _time = TimeOfDay(hour: hour, minute: _time.minute);
      _jumpWheels();
      widget.onTimeSelected(_time);
    }
  }

  void _minuteTextChanged(String newMinute) {
    final minute = int.tryParse(newMinute);
    if (minute != null && minute >= 0 && minute <= 59) {
      _time = TimeOfDay(
        hour: _time.hour,
        minute: ((minute / widget.minutePrecision).round() * widget.minutePrecision).clamp(0, 59),
      );
      _jumpWheels();
      widget.onTimeSelected(_time);
    }
  }

  void _onHourWheelChanged(int value) {
    if (_syncingWheels || _hourFocusNode.hasFocus) {
      return;
    }
    _time = TimeOfDay(
      hour: value,
      minute: _time.minute,
    );
    _applyText();
    widget.onTimeSelected(_time);
  }

  void _onMinuteWheelChanged(int value) {
    if (_syncingWheels || _minuteFocusNode.hasFocus) {
      return;
    }
    _time = TimeOfDay(
      hour: _time.hour,
      minute: value * widget.minutePrecision,
    );
    _applyText();
    widget.onTimeSelected(_time);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LiquidLocalizations.of(context);
    final theme = LdTheme.of(context);
    final hourHint = l10n.durationHintHours;
    final minuteHint = l10n.durationHintMinutes;

    return LdAutoSpace(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (_) => true,
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) => true,
            child: Row(
              children: [
                Expanded(
                  child: _wheelFrame(
                    theme: theme,
                    child: CupertinoPicker(
                      scrollController: _hourController,
                      selectionOverlay: Container(),
                      squeeze: 1.4,
                      itemExtent: 32,
                      useMagnifier: true,
                      onSelectedItemChanged: _onHourWheelChanged,
                      children: List.generate(24, (index) {
                        return _wheelItem(
                          theme: theme,
                          value: index.toString().padLeft(2, '0'),
                          unit: hourHint,
                        );
                      }),
                    ),
                  ),
                ),
                ldSpacerM,
                LdText.l(':'),
                ldSpacerM,
                Expanded(
                  child: _wheelFrame(
                    theme: theme,
                    child: CupertinoPicker(
                      scrollController: _minuteController,
                      selectionOverlay: Container(),
                      squeeze: 1.4,
                      itemExtent: 32,
                      useMagnifier: true,
                      onSelectedItemChanged: _onMinuteWheelChanged,
                      children: List.generate(60 ~/ widget.minutePrecision, (index) {
                        return _wheelItem(
                          theme: theme,
                          value: (index * widget.minutePrecision).toString().padLeft(2, '0'),
                          unit: minuteHint,
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                onChanged: _hourTextChanged,
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
                onChanged: _minuteTextChanged,
                size: LdSize.l,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _wheelFrame({
    required LdTheme theme,
    required Widget child,
  }) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.border,
          width: theme.borderWidth,
        ),
        borderRadius: theme.radius(LdSize.s),
      ),
      child: child,
    );
  }

  Widget _wheelItem({
    required LdTheme theme,
    required String value,
    required String unit,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.all(4),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
            ldHSpacerXS,
            LdText.lxs(
              unit,
              color: theme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
