import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_a2ui_schemas.dart';

/// Catalog id injected into createSurface messages.
const kLdGenuiCatalogId = 'com.liquid.catalog';

/// Markers embedded in [buildLdGenuiSystemPrompt] for DB catalog refresh.
const kLdGenuiCatalogPromptMarker = 'LD_GENUI_CATALOG_START';
const kLdGenuiCatalogPromptEndMarker = 'LD_GENUI_CATALOG_END';

/// High-level fragments also attached to the Flutter [Catalog].
const kLdGenuiSystemPromptFragments = <String>[
  'Use the Liquid Flutter GenUI catalog to render UI in response to user queries.',
  'Use precomposed composite components only — do not assemble low-level widgets.',
  'Set the root component to the composite that best matches the intent.',
  'Use LdConfirm for approve/deny or yes/no prompts.',
  'Use LdMultipleChoice for single-select questions; set allowCustom for a '
      'free-text input below the options.',
  'Use LdCallout for status banners.',
  'Use LdCardGallery for horizontally scrollable option cards '
      '(recipes, products, places).',
  'Use LdWeatherCard and LdCalendarEvent for weather and calendar summaries.',
  'Use LdTimeline for chronological event sequences.',
  'Use LdDetailList when items should open a markdown detail dialog with '
      'actions.',
];

/// Name + JSON schema for one GenUI catalog component (no Flutter builders).
class LdGenuiComponentSchema {
  final String name;
  final Schema schema;

  const LdGenuiComponentSchema({
    required this.name,
    required this.schema,
  });
}

Schema _actionSchema({String? description}) => S.object(
  description: description,
  properties: {
    'name': S.string(),
    'context': S.object(properties: {}, additionalProperties: true),
  },
  required: ['name'],
);

Schema _labeledOptionSchema() => S.object(
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

// ─── Component schemas (source of truth for client Catalog + server prompt) ─

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
    'options': S.list(items: _labeledOptionSchema()),
    'layout': S.string(enumValues: ['radio', 'chips', 'list']),
    'allowCustom': S.boolean(
      description:
          'When true, always shows a text input below the options. '
          'A non-empty value becomes selected and deselects the listed options.',
    ),
    'customLabel': S.string(
      description: 'Optional label for the custom text input.',
    ),
    'customHint': S.string(
      description: 'Hint for the custom text input. Defaults to Enter your own…',
    ),
    'submitLabel': S.string(
      description:
          'Submit button label. Defaults to Submit. Dispatches action with the selection.',
    ),
  },
  required: ['selected', 'options'],
);

final ldConfirmSchema = S.object(
  description: 'Approve/deny or yes/no prompt as one unit.',
  properties: {
    'title': S.string(),
    'message': S.string(),
    'tone': S.string(enumValues: ['info', 'warning', 'danger']),
    'primary': S.object(
      properties: {
        'label': S.string(),
        'action': _actionSchema(),
      },
      required: ['label', 'action'],
    ),
    'secondary': S.object(
      properties: {
        'label': S.string(),
        'action': _actionSchema(),
      },
      required: ['label', 'action'],
    ),
  },
  required: ['title', 'primary'],
);

final ldCalloutSchema = S.object(
  description: 'Status banner (info/warning/success/error).',
  properties: {
    'type': S.string(enumValues: ['info', 'warning', 'success', 'error']),
    'title': S.string(),
    'body': S.string(),
  },
  required: ['type', 'body'],
);

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
          'action': _actionSchema(),
        },
        required: ['id', 'title'],
      ),
    ),
  },
  required: ['cards'],
);

final ldWeatherCardSchema = S.object(
  description: 'Opinionated weather snapshot card.',
  properties: {
    'location': S.string(),
    'temperature': LdA2uiSchemas.numberReference(),
    'unit': S.string(enumValues: ['c', 'f']),
    'condition': S.string(
      description:
          'Condition key: sunny, cloudy, partlyCloudy, rainy, stormy, '
          'snowy, foggy, windy — rendered as a human-readable label — '
          'or a short free-text label.',
    ),
    'summary': S.string(),
    'high': S.number(),
    'low': S.number(),
    'humidity': S.number(description: 'Relative humidity percent.'),
    'wind': S.string(description: 'Wind summary, e.g. 12 km/h NW.'),
  },
  required: ['location', 'temperature', 'condition'],
);

final ldCalendarEventSchema = S.object(
  description: 'Single calendar event summary card.',
  properties: {
    'title': S.string(),
    'start': S.string(description: 'ISO-8601 start datetime.'),
    'end': S.string(description: 'ISO-8601 end datetime.'),
    'location': S.string(),
    'description': S.string(
      description: 'Plain text or markdown description.',
    ),
    'allDay': S.boolean(),
    'action': _actionSchema(),
  },
  required: ['title', 'start'],
);

final ldTimelineSchema = S.object(
  description: 'Vertical chronological timeline of events.',
  properties: {
    'title': S.string(),
    'items': S.list(
      items: S.object(
        properties: {
          'time': S.string(),
          'title': S.string(),
          'body': S.string(),
          'tone': S.string(enumValues: ['info', 'warning', 'success', 'error']),
        },
        required: ['title'],
      ),
    ),
  },
  required: ['items'],
);

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
                'action': _actionSchema(),
                'mode': S.string(
                  enumValues: ['filled', 'outline', 'ghost', 'vague'],
                ),
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

/// All catalog components in display/prompt order.
final List<LdGenuiComponentSchema> ldGenuiComponentSchemas = [
  LdGenuiComponentSchema(
    name: 'LdMultipleChoice',
    schema: ldMultipleChoiceSchema,
  ),
  LdGenuiComponentSchema(name: 'LdConfirm', schema: ldConfirmSchema),
  LdGenuiComponentSchema(name: 'LdCallout', schema: ldCalloutSchema),
  LdGenuiComponentSchema(name: 'LdCardGallery', schema: ldCardGallerySchema),
  LdGenuiComponentSchema(name: 'LdWeatherCard', schema: ldWeatherCardSchema),
  LdGenuiComponentSchema(
    name: 'LdCalendarEvent',
    schema: ldCalendarEventSchema,
  ),
  LdGenuiComponentSchema(name: 'LdTimeline', schema: ldTimelineSchema),
  LdGenuiComponentSchema(name: 'LdDetailList', schema: ldDetailListSchema),
];
