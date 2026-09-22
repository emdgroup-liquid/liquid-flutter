import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_genui_action.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

enum LdGenuiButtonMode {
  filled,
  outline,
  ghost,
  vague;

  static LdGenuiButtonMode parse(
    Object? raw, {
    LdGenuiButtonMode or = LdGenuiButtonMode.filled,
  }) {
    return switch (raw) {
      'outline' => LdGenuiButtonMode.outline,
      'ghost' => LdGenuiButtonMode.ghost,
      'vague' => LdGenuiButtonMode.vague,
      _ => or,
    };
  }

  static const schemaValues = ['filled', 'outline', 'ghost', 'vague'];
}

final ldDetailListSchema = S.object(
  description:
      'List of items that open a markdown detail dialog with optional actions.',
  properties: {
    'title': S.string(),
    'items': S.list(
      items: S.object(
        properties: {
          'id': S.string(),
          'title': S.string(),
          'subtitle': S.string(),
          'markdown': S.string(),
          'actions': S.list(
            items: S.object(
              properties: {
                'label': S.string(),
                'action': ldGenuiActionSchema,
                'mode': S.string(enumValues: LdGenuiButtonMode.schemaValues),
              },
              required: ['label', 'action'],
            ),
          ),
        },
        required: ['id', 'title', 'markdown'],
      ),
    ),
  },
  required: ['items'],
);

class LdDetailListAction {
  const LdDetailListAction({
    required this.label,
    required this.action,
    this.mode = LdGenuiButtonMode.filled,
  });

  final String label;
  final LdGenuiAction action;
  final LdGenuiButtonMode mode;

  static LdDetailListAction? tryParse(Map<String, Object?> json) {
    final labeled = LdLabeledAction.tryParse(json);
    if (labeled == null) return null;
    return LdDetailListAction(
      label: labeled.label,
      action: labeled.action,
      mode: LdGenuiButtonMode.parse(json['mode']),
    );
  }
}

class LdDetailListItem {
  const LdDetailListItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.markdown,
    this.actions = const [],
  });

  final String id;
  final String title;
  final String? subtitle;
  final String markdown;
  final List<LdDetailListAction> actions;

  static LdDetailListItem? tryParse(Map<String, Object?> json) {
    final id = ldJsonString(json['id']);
    final title = ldJsonString(json['title']);
    final markdown = ldJsonString(json['markdown']);
    if (id == null || title == null || markdown == null) return null;
    return LdDetailListItem(
      id: id,
      title: title,
      subtitle: ldJsonString(json['subtitle']),
      markdown: markdown,
      actions: ldJsonObjectListWhere(
        json['actions'],
        LdDetailListAction.tryParse,
      ),
    );
  }
}

class LdDetailListData {
  const LdDetailListData({this.title, required this.items});

  final String? title;
  final List<LdDetailListItem> items;

  factory LdDetailListData.fromJson(Object? json) {
    final map = ldRequireJsonMap(json, 'LdDetailList');
    final items = ldJsonObjectListWhere(
      map['items'],
      LdDetailListItem.tryParse,
    );
    if (items.isEmpty) {
      throw FormatException('LdDetailList requires at least one item');
    }
    return LdDetailListData(title: ldJsonString(map['title']), items: items);
  }
}
