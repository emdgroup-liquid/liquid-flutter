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

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/date_time_pickers.dart",
      title: 'Date and Time Pickers',
      apiComponents: const ["LdDatePicker", "LdTimePicker"],
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
        ],
      ),
    );
  }
}
