import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
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
  LdDuration _inline = const LdDuration(hours: 1, minutes: 30);
  final _anchor = DateTime(2024, 1, 31);

  @override
  Widget build(BuildContext context) {
    final applied = _anchor.addLdDuration(_calendar);
    return ComponentPage(
      path: 'lib/components/form_elements/date_time_pickers.dart',
      title: 'Date and Time Pickers',
      apiComponents: const ['LdDatePicker', 'LdTimePicker', 'LdDurationPicker', 'LdDurationPickerWidget'],
      demo: LdAutoSpace(
        children: [
          LdText.p(
            'Labeled fields that open a modal to pick a date, a clock time, or a '
            'calendar-aware duration. Durations use LdDuration (not Dart Duration) '
            'so years and months stay as components, with ISO 8601 for the wire format.',
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs('Date picker'),
            description: LdText.p(
              'Opens a calendar in a modal. This example clamps the range to yesterday '
              'through ten days from now.',
            ),
            child: LdDatePicker(
              value: _date,
              label: 'Date',
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
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs('Time picker'),
            description: LdText.p('Hour and minute wheels plus text fields. The default minute step is 15.'),
            child: LdTimePicker(
              value: _time,
              useRootNavigator: true,
              label: 'Time',
              onChanged: (time) {
                LdNotificationsController.of(
                  context,
                ).success('Time selected: ${time.hour}:${time.minute.toString().padLeft(2, '0')}');
                setState(() {
                  _time = time;
                });
              },
            ),
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs('Duration picker'),
            description: LdText.p(
              'Default config shows hours and minutes (15-minute step). Confirming the '
              'modal writes an ISO 8601 string such as PT1H30M.',
            ),
            child: LdAutoSpace(
              children: [
                LdDurationPicker(
                  value: _duration,
                  useRootNavigator: true,
                  label: 'Duration',
                  onChanged: (duration) {
                    LdNotificationsController.of(context).success('Duration: ${duration.toIso8601String()}');
                    setState(() {
                      _duration = duration;
                    });
                  },
                ),
                LdText.l('ISO 8601: ${_duration.toIso8601String()}'),
              ],
            ),
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs('Timer'),
            description: LdText.p('LdDurationConfig.timer() adds a seconds wheel for countdown-style values.'),
            child: LdDurationPicker(
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
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs('Span'),
            description: LdText.p(
              'LdDurationConfig.span() uses days, hours, and minutes for elapsed ranges '
              'that are still clock-based (no months or years).',
            ),
            child: LdDurationPicker(
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
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs('Calendar'),
            description: LdText.p(
              'LdDurationConfig.calendar() picks years and months. Applying the value '
              'with DateTime.addLdDuration clamps month-ends (31 Jan + 1 month → 28/29 Feb).',
            ),
            child: LdAutoSpace(
              children: [
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
                LdText.l(
                  '31 Jan 2024 + ${_calendar.toIso8601String()} → ${applied.year}-${applied.month}-${applied.day}',
                ),
              ],
            ),
          ),
          ComponentWell(
            onSurface: true,
            title: LdText.hs('Inline widget'),
            description: LdText.p(
              'LdDurationPickerWidget is the editor without the field + modal shell. '
              'Use it when the picker should live on the page itself.',
            ),
            child: LdDurationPickerWidget(
              value: _inline,
              onChanged: (duration) {
                _inline = duration;
              },
            ),
          ),
        ],
      ),
    );
  }
}
