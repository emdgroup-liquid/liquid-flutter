import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/components/ld_calendar_event.dart';
import 'package:liquid_flutter_ai_shared/src/genui/components/ld_callout.dart';
import 'package:liquid_flutter_ai_shared/src/genui/components/ld_card_gallery.dart';
import 'package:liquid_flutter_ai_shared/src/genui/components/ld_confirm.dart';
import 'package:liquid_flutter_ai_shared/src/genui/components/ld_detail_list.dart';
import 'package:liquid_flutter_ai_shared/src/genui/components/ld_multiple_choice.dart';
import 'package:liquid_flutter_ai_shared/src/genui/components/ld_timeline.dart';
import 'package:liquid_flutter_ai_shared/src/genui/components/ld_weather_card.dart';

export 'components/ld_calendar_event.dart';
export 'components/ld_callout.dart';
export 'components/ld_card_gallery.dart';
export 'components/ld_confirm.dart';
export 'components/ld_detail_list.dart';
export 'components/ld_multiple_choice.dart';
export 'components/ld_timeline.dart';
export 'components/ld_weather_card.dart';
export 'ld_a2ui_refs.dart';
export 'ld_genui_action.dart';
export 'ld_genui_tone.dart';
export 'ld_json.dart';

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

  const LdGenuiComponentSchema({required this.name, required this.schema});
}

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
