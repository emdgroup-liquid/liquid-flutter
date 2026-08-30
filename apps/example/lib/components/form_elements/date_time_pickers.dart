import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class DateTimePickerDemo extends StatefulWidget {
  const DateTimePickerDemo({super.key});

  @override
  State<DateTimePickerDemo> createState() => _DateTimePickerDemoState();
}

class _DateTimePickerDemoState extends State<DateTimePickerDemo> {
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay(hour: 9, minute: 0);
  LdDuration _duration = const LdDuration(hours: 1, minutes: 30);
  LdDuration _timer = const LdDuration(minutes: 5, seconds: 0);
  LdDuration _span = const LdDuration(days: 2, hours: 4);
  LdDuration _calendar = const LdDuration(years: 1, months: 3);
  final _anchor = DateTime(2024, 1, 31);

  @override
  Widget build(BuildContext context) {
    final applied = _anchor.addLdDuration(_calendar);
    return ComponentPage(
      path: "lib/components/form_elements/date_time_pickers.dart",
      title: 'Date and Time Pickers',
      apiComponents: const ["LdDatePicker", "LdTimePicker", "LdDurationPicker"],
      demo: LdAutoSpace(
        children: [
          LdDatePicker(
            value: _date,
            label: 'Date Picker',
            useRootNavigator: true,
            onChanged: (date) {
              LdNotificationsController.of(context).success('Date selected: ${date.year}-${date.month}-${date.day}');
              setState(() {
                _date = date;
              });
            },
            maxDate: DateTime.now().add(const Duration(days: 10)),
            minDate: DateTime.now().subtract(const Duration(days: 1)),
          ),
          LdTimePicker(
            value: _time,
            useRootNavigator: true,
            label: 'Time Picker',
            onChanged: (time) {
              LdNotificationsController.of(context).success('Time selected: ${time.hour}:${time.minute}');
              setState(() {
                _time = time;
              });
            },
          ),
          LdDurationPicker(
            value: _duration,
            useRootNavigator: true,
            label: 'Duration Picker',
            onChanged: (duration) {
              LdNotificationsController.of(context).success('Duration: ${duration.toIso8601String()}');
              setState(() {
                _duration = duration;
              });
            },
          ),
          LdText.l('ISO 8601: ${_duration.toIso8601String()}'),
          LdDurationPicker(
            value: _timer,
            useRootNavigator: true,
            label: 'Timer',
            config: const LdDurationConfig.timer(),
            onChanged: (duration) {
              setState(() {
                _timer = duration;
              });
            },
          ),
          LdDurationPicker(
            value: _span,
            useRootNavigator: true,
            label: 'Span',
            config: const LdDurationConfig.span(),
            onChanged: (duration) {
              setState(() {
                _span = duration;
              });
            },
          ),
          LdDurationPicker(
            value: _calendar,
            useRootNavigator: true,
            label: 'Calendar',
            config: const LdDurationConfig.calendar(),
            onChanged: (duration) {
              setState(() {
                _calendar = duration;
              });
            },
          ),
          LdText.l('31 Jan 2024 + ${_calendar.toIso8601String()} → ${applied.year}-${applied.month}-${applied.day}'),
          LdText.l('Inline'),
          LdDurationPickerWidget(
            value: _duration,
            onChanged: (duration) {
              _duration = duration;
            },
          ),
        ],
      ),
    );
  }
}
