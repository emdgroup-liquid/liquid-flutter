import 'package:flutter/widgets.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class DateTimePickerDemo extends StatelessWidget {
  const DateTimePickerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Date and Time Pickers',
      apiComponents: const [
        "LdDatePicker",
        "LdTimePicker",
      ],
      demo: LdAutoSpace(
        children: [
          LdDatePicker(
              label: 'Date Picker',
              useRootNavigator: true,
              onChanged: (date) {},
              maxDate: DateTime.now().add(const Duration(days: 10)),
              minDate: DateTime.now().subtract(const Duration(days: 1))),
          LdTimePicker(
            useRootNavigator: true,
            label: 'Time Picker',
            onChanged: (time) {},
          ),
        ],
      ),
    );
  }
}
