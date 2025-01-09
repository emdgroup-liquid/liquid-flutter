import 'package:flutter/widgets.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class DatePickerDemo extends StatelessWidget {
  const DatePickerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'LdDatePicker',
      demo: LdAutoSpace(
        children: [
          LdDatePicker(
              label: 'Date Picker',
              onChanged: (date) {},
              maxDate: DateTime.now().add(const Duration(days: 10)),
              minDate: DateTime.now().subtract(const Duration(days: 1))),
        ],
      ),
    );
  }
}
