import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_a2ui_refs.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_a2ui_schemas.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

enum LdMultipleChoiceLayout {
  radio,
  chips,
  list;

  static LdMultipleChoiceLayout parse(
    Object? raw, {
    LdMultipleChoiceLayout or = LdMultipleChoiceLayout.radio,
  }) {
    return switch (raw) {
      'chips' => LdMultipleChoiceLayout.chips,
      'list' => LdMultipleChoiceLayout.list,
      _ => or,
    };
  }

  static const schemaValues = ['radio', 'chips', 'list'];
}

final _labeledOptionSchema = S.object(
  properties: {
    'value': S.string(),
    'label': S.string(),
    'description': S.string(
      description:
          'Optional longer description. Used as list-item subtitle when '
          'LdMultipleChoice layout is list.',
    ),
  },
  required: ['value', 'label'],
);

final ldMultipleChoiceSchema = S.object(
  description:
      'Single-select multiple choice. '
      'Set allowCustom to show a free-text input below the options; a non-empty '
      'input becomes the selection. '
      'For layout list, options may include description as a subtitle.',
  properties: {
    'label': S.string(),
    'description': S.string(),
    'selected': LdA2uiSchemas.stringReference(),
    'options': S.list(items: _labeledOptionSchema),
    'layout': S.string(enumValues: LdMultipleChoiceLayout.schemaValues),
    'allowCustom': S.boolean(
      description:
          'When true, always shows a text input below the options. '
          'A non-empty value becomes selected and deselects the listed options.',
    ),
    'customLabel': S.string(
      description: 'Optional label for the custom text input.',
    ),
    'customHint': S.string(
      description:
          'Hint for the custom text input. Defaults to Enter your own…',
    ),
    'submitLabel': S.string(
      description:
          'Submit button label. Defaults to Submit. Dispatches action with the '
          'selection.',
    ),
  },
  required: ['selected', 'options'],
);

class LdLabeledOption {
  const LdLabeledOption({
    required this.value,
    required this.label,
    this.description,
  });

  final String value;
  final String label;
  final String? description;

  static LdLabeledOption? tryParse(Map<String, Object?> json) {
    final value = ldJsonString(json['value']);
    final label = ldJsonString(json['label']);
    if (value == null || label == null) return null;
    return LdLabeledOption(
      value: value,
      label: label,
      description: ldJsonString(json['description']),
    );
  }
}

class LdMultipleChoiceData {
  const LdMultipleChoiceData({
    this.label,
    this.description,
    this.selected,
    required this.options,
    this.layout = LdMultipleChoiceLayout.radio,
    this.allowCustom = false,
    this.customLabel,
    this.customHint = 'Enter your own…',
    this.submitLabel = 'Submit',
  });

  final String? label;
  final String? description;
  final LdStringRef? selected;
  final List<LdLabeledOption> options;
  final LdMultipleChoiceLayout layout;
  final bool allowCustom;
  final String? customLabel;
  final String customHint;
  final String submitLabel;

  factory LdMultipleChoiceData.fromJson(Object? json) {
    final map = ldRequireJsonMap(json, 'LdMultipleChoice');
    return LdMultipleChoiceData(
      label: ldJsonString(map['label']),
      description: ldJsonString(map['description']),
      selected: LdStringRef.tryParse(map['selected']),
      options: ldJsonObjectListWhere(map['options'], LdLabeledOption.tryParse),
      layout: LdMultipleChoiceLayout.parse(map['layout']),
      allowCustom: ldJsonBool(map['allowCustom']) ?? false,
      customLabel: ldJsonString(map['customLabel']),
      customHint: ldJsonString(map['customHint']) ?? 'Enter your own…',
      submitLabel: ldJsonString(map['submitLabel']) ?? 'Submit',
    );
  }
}
