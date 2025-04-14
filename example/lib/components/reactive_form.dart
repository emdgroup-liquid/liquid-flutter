import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';

enum Pet { cats, dogs }

enum FriesTopping { ketchup, mayo }

class ReactiveFormDemo extends StatelessWidget {
  const ReactiveFormDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: "LdReactiveForm",
      demo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComponentWell(
            onSurface: true,
            child: LdReactiveForm(
              validators: [
                LdFormValidators.mustMatch('email', 'email2'),
              ],
              validationMessages: {
                'required': (field) => 'This field is required',
                'mustMatch': (field) => 'The emails must match'
              },
              onSubmit: (form) {
                return Future.delayed(
                  const Duration(seconds: 2),
                  () {
                    if (!context.mounted) return;
                    LdModal(
                      title: const Text('LdReactiveForm Demo'),
                      modalContent: (context) => Text(
                        'Form submitted with values: ${form.value}',
                      ),
                    ).show(context);
                  },
                );
              },
              submitConfig: LdFormSubmitConfig(
                submitText: 'Submit Form',
              ),
              items: [
                LdReactiveFormItem.input<String>(
                  key: 'name',
                  label: 'We already know your name, so you cannot change it:',
                  inputFieldHint: 'Name',
                  initialValue: 'John Doe',
                  validators: [LdFormValidators.required],
                  disabled: true,
                ),
                LdReactiveFormItem.input<String>(
                  key: 'email',
                  label: 'Enter your Email:',
                  inputFieldHint: 'john.doe@example.com',
                  validators: [
                    LdFormValidators.required,
                    LdFormValidators.email
                  ],
                  validationMessages: {
                    'email': (field) => 'This is not a valid email'
                  },
                ),
                LdReactiveFormItem.input<String>(
                  key: 'email2',
                  label: 'Confirm Email',
                  inputFieldHint: 'john.doe@example.com',
                ),
                LdReactiveFormItem.input<int>(
                  key: 'age',
                  inputFieldHint: 'Age',
                  validators: [LdFormValidators.required],
                ),
                LdReactiveFormItem.select<Pet>(
                  key: 'catsOrDogs',
                  items: Pet.values
                      .map(
                        (e) => LdSelectItem(
                          value: e,
                          child: Text(e.name.capitalize()),
                        ),
                      )
                      .toList(),
                  label: 'Cats or Dogs?',
                  hintBuilder: (_) => const LdHint(
                    type: LdHintType.info,
                    child: Text('There is only one correct answer...'),
                  ),
                  validators: [
                    LdFormValidators.equals(Pet.cats),
                  ],
                  validationMessages: {
                    'requiredEquals': (field) =>
                        'Cats are the only correct answer'
                  },
                ),
                LdReactiveFormItem.multiSelect<FriesTopping>(
                  key: 'friesTopping',
                  items: [
                    const LdSelectItem(
                      value: FriesTopping.ketchup,
                      child: Text('Ketchup'),
                    ),
                    const LdSelectItem(
                      value: FriesTopping.mayo,
                      child: Text('Mayo'),
                    ),
                  ],
                  label: 'Ketchup, Mayo? (Both?)',
                ),
                LdReactiveFormItem.slider(
                  key: 'slider',
                  label: 'How awesome is Liquid Flutter?',
                  min: 0,
                  max: 10,
                  valueFormatter: (value) => value == null
                      ? ''
                      : value.toStringAsFixed(0) + ' out of 10',
                  hintBuilder: (state) {
                    final value = state.control.value;
                    if (value == null) {
                      return null;
                    } else if (value < 3) {
                      return const LdHint(
                        type: LdHintType.warning,
                        child: Text('That is not enough!'),
                      );
                    } else if (value < 7) {
                      return const LdHint(
                        type: LdHintType.info,
                        child: Text('You can do better!'),
                      );
                    } else {
                      return const LdHint(
                        type: LdHintType.success,
                        child: Text('Now we are talking!'),
                      );
                    }
                  },
                ),
                LdReactiveFormItem.checkbox(
                  key: 'terms',
                  label: 'I accept the terms of service',
                  initialValue: false,
                  validators: [LdFormValidators.requiredTrue],
                  validationMessages: {
                    'requiredTrue': (field) =>
                        'You have to accept the terms of service'
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
