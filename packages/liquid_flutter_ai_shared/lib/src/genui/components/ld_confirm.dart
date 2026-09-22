import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_genui_action.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

enum LdConfirmTone {
  info,
  warning,
  danger;

  static LdConfirmTone parse(
    Object? raw, {
    LdConfirmTone or = LdConfirmTone.info,
  }) {
    return switch (raw) {
      'warning' => LdConfirmTone.warning,
      'danger' => LdConfirmTone.danger,
      _ => or,
    };
  }

  static const schemaValues = ['info', 'warning', 'danger'];
}

final ldConfirmSchema = S.object(
  description: 'Approve/deny or yes/no prompt as one unit.',
  properties: {
    'title': S.string(),
    'message': S.string(),
    'tone': S.string(enumValues: LdConfirmTone.schemaValues),
    'primary': LdLabeledAction.schema(),
    'secondary': LdLabeledAction.schema(),
  },
  required: ['title', 'primary'],
);

class LdConfirmData {
  const LdConfirmData({
    required this.title,
    this.message,
    this.tone = LdConfirmTone.info,
    required this.primary,
    this.secondary,
  });

  final String title;
  final String? message;
  final LdConfirmTone tone;
  final LdLabeledAction primary;
  final LdLabeledAction? secondary;

  factory LdConfirmData.fromJson(Object? json) {
    final map = ldRequireJsonMap(json, 'LdConfirm');
    return LdConfirmData(
      title: ldRequireString(map['title'], 'LdConfirm.title'),
      message: ldJsonString(map['message']),
      tone: LdConfirmTone.parse(map['tone']),
      primary: LdLabeledAction.parse(
        map['primary'],
        field: 'LdConfirm.primary',
      ),
      secondary: LdLabeledAction.tryParse(map['secondary']),
    );
  }
}
