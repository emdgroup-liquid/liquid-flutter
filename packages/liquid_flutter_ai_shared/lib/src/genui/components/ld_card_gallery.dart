import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_a2ui_refs.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_a2ui_schemas.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_genui_action.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

final ldCardGallerySchema = S.object(
  description:
      'Horizontally scrollable gallery of option cards '
      '(recipes, products, places).',
  properties: {
    'title': S.string(description: 'Optional gallery heading.'),
    'selected': LdA2uiSchemas.stringReference(
      description: 'Optional selected card id binding.',
    ),
    'cards': S.list(
      items: S.object(
        properties: {
          'id': S.string(),
          'title': S.string(),
          'subtitle': S.string(),
          'imageUrl': S.string(),
          'markdown': S.string(
            description: 'Optional markdown details shown on the card.',
          ),
          'tags': S.list(
            items: S.string(),
            description: 'Optional short labels shown as tags on the card.',
          ),
          'action': ldGenuiActionSchema,
        },
        required: ['id', 'title'],
      ),
    ),
  },
  required: ['cards'],
);

class LdGalleryCard {
  const LdGalleryCard({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.markdown,
    this.tags = const [],
    this.action,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? markdown;
  final List<String> tags;
  final LdGenuiAction? action;

  static LdGalleryCard? tryParse(Map<String, Object?> json) {
    final id = ldJsonString(json['id']);
    final title = ldJsonString(json['title']);
    if (id == null || id.isEmpty || title == null) return null;
    return LdGalleryCard(
      id: id,
      title: title,
      subtitle: ldJsonString(json['subtitle']),
      imageUrl: ldJsonString(json['imageUrl']),
      markdown: ldJsonString(json['markdown']),
      tags: ldJsonStringList(json['tags']),
      action: LdGenuiAction.tryParse(json['action']),
    );
  }
}

class LdCardGalleryData {
  const LdCardGalleryData({this.title, this.selected, required this.cards});

  final String? title;
  final LdStringRef? selected;
  final List<LdGalleryCard> cards;

  factory LdCardGalleryData.fromJson(Object? json) {
    final map = ldRequireJsonMap(json, 'LdCardGallery');
    final cards = ldJsonObjectListWhere(map['cards'], LdGalleryCard.tryParse);
    if (cards.isEmpty) {
      throw FormatException('LdCardGallery requires at least one card');
    }
    return LdCardGalleryData(
      title: ldJsonString(map['title']),
      selected: LdStringRef.tryParse(map['selected']),
      cards: cards,
    );
  }
}
