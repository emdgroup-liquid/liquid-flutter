import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class RecurrencePickerDemo extends StatefulWidget {
  const RecurrencePickerDemo({super.key});

  @override
  State<RecurrencePickerDemo> createState() => _RecurrencePickerDemoState();
}

class _RecurrencePickerDemoState extends State<RecurrencePickerDemo> {
  RecurrenceRule? _pickerRule;
  RecurrenceRule _formRule = RecurrenceRule(frequency: Frequency.weekly);
  RecurrenceRule _restrictedRule = RecurrenceRule(frequency: Frequency.weekly);
  RecurrenceRule _matrixRule = RecurrenceRule(frequency: Frequency.daily);
  List<RecurrenceRule> _multiRules = const [];
  DateTime _start = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/recurrence_picker.dart",
      title: 'Recurrence Picker',
      apiComponents: const [
        "LdRecurrencePicker",
        "LdRecurrenceMultiPicker",
        "LdRecurrenceForm",
      ],
      demo: LdAutoSpace(
        children: [
          LdText.l('Start'),
          LdDatePicker(
            value: _start,
            onChanged: (date) {
              setState(() {
                _start = DateTime(date.year, date.month, date.day, _start.hour, _start.minute);
              });
            },
          ),
          ComponentWell(
            title: Text("Picker"),
            child: LdRecurrencePicker(
              value: _pickerRule,
              start: _start,
              label: 'Recurrence',
              useRootNavigator: true,
              onChanged: (rule) {
                LdNotificationsController.of(context).success('Selected: ${rule.toString()}');
                setState(() {
                  _pickerRule = rule;
                });
              },
            ),
          ),

          ComponentWell(
            title: Text("Multi picker"),
            description: Text("Independent rules (e.g. separate clock times)."),
            child: LdRecurrenceMultiPicker(
              value: _multiRules,
              start: _start,
              label: 'Recurrences',
              useRootNavigator: true,
              config: const LdRecurrenceConfig(
                timesMode: LdRecurrenceTimesMode.single,
              ),
              onChanged: (rules) {
                setState(() {
                  _multiRules = rules;
                });
              },
            ),
          ),
          LdText.l(_multiRules.map((rule) => rule.toString()).join('\n')),

          ComponentWell(
            title: Text("Inline form"),
            child: LdRecurrenceForm(
              value: _formRule,
              start: _start,
              config: const LdRecurrenceConfig(
                timesMode: LdRecurrenceTimesMode.linear,
              ),
              onChanged: (rule) {
                setState(() {
                  _formRule = rule;
                });
              },
            ),
          ),
          LdText.l(_formRule.toString()),

          ComponentWell(
            title: Text("Restricted config"),
            description: Text("Daily–yearly only, no ending."),
            child: LdRecurrenceForm(
              value: _restrictedRule,
              start: _start,
              config: const LdRecurrenceConfig.calendar(endModes: {}),
              onChanged: (rule) {
                setState(() {
                  _restrictedRule = rule;
                });
              },
            ),
          ),

          ComponentWell(
            title: Text("Matrix times"),
            description: Text("Advanced: hours × minutes cartesian product."),
            child: LdRecurrenceForm(
              value: _matrixRule,
              start: _start,
              config: const LdRecurrenceConfig(
                timesMode: LdRecurrenceTimesMode.matrix,
                endModes: {},
                showPreview: true,
              ),
              onChanged: (rule) {
                setState(() {
                  _matrixRule = rule;
                });
              },
            ),
          ),
          LdText.l(_matrixRule.toString()),
        ],
      ),
    );
  }
}
