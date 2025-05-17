import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class FormDemo extends StatefulWidget {
  const FormDemo({super.key});

  @override
  State<FormDemo> createState() => _FormDemoState();
}

class _FormDemoState extends State<FormDemo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _disabledFieldController =
      TextEditingController(text: "Disabled field");
  final Map<String, LdFormHint> _hints = {};
  bool _nameValid = true;
  bool _formDisabled = false;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/form.dart",
      title: "LdForm",
      demo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComponentWell(
            onSurface: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LdForm(
                    disabled: _formDisabled,
                    hints: _hints,
                    onSubmit: _submit,
                    key: _formKey,
                    fields: [
                      LdFormItem(
                        "firstName",
                        LdInput(
                          hint: "First Name",
                          label: "First Name",
                          valid: _nameValid,
                          textInputAction: TextInputAction.next,
                          controller: _nameController,
                        ),
                      ),
                      LdFormItem(
                        "lastName",
                        LdInput(
                          hint: "Last Name",
                          label: "Last Name",
                          controller: _lastNameController,
                        ),
                      ),
                      LdFormItem(
                          "selectField",
                          const LdSelect<String>(items: [
                            LdSelectItem(
                                value: "1", child: Text("First choice")),
                            LdSelectItem(
                                value: "2", child: Text("Second choice")),
                          ])),
                      LdFormItem(
                        "lastName",
                        LdChoose(
                            label: "Choose something",
                            placeholder: const Text("Select an option"),
                            multiple: true,
                            onChange: (value) {
                              //print(value);
                            },
                            items: const [
                              LdSelectItem(
                                  value: "1", child: Text("First choice")),
                              LdSelectItem(
                                  value: "2", child: Text("Second choice")),
                            ]),
                      ),
                      LdFormItem(
                        "disabledField",
                        LdInput(
                          hint: "Disabled Field",
                          label: "Disabled Field",
                          disabled: true,
                          controller: _disabledFieldController,
                        ),
                      ),
                      LdFormItem(
                        "bio",
                        LdInput(
                          hint: "About you",
                          label: "Biography",
                          minLines: 3,
                          maxLines: 5,
                          textInputAction: TextInputAction.done,
                          controller: _bioController,
                        ),
                      ),
                    ]),
              ],
            ),
          ),
          ldSpacerM,
          LdToggle(
            label: "Disable",
            checked: _formDisabled,
            onChanged: (enable) {
              setState(() {
                _formDisabled = enable;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _disabledFieldController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _hints.clear();
      if (_nameController.text.isEmpty) {
        _nameValid = false;
        _hints["firstName"] =
            LdFormHint("First name is required", LdHintType.error);
      } else {
        _nameValid = true;
      }
    });
  }
}
