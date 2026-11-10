import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:liquid_flutter_ai/src/genui/ld_catalog_composites.dart';
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

export 'ld_catalog_composites.dart'
    show
        ldMultipleChoice,
        ldConfirm,
        ldCallout,
        ldCardGallery,
        ldWeatherCard,
        ldCalendarEvent,
        ldTimeline,
        ldDetailList;

CatalogImplementation buildLdCatalog() {
  return CatalogImplementation(
    id: kLdGenuiCatalogId,
    components: [
      ldMultipleChoice,
      ldConfirm,
      ldCallout,
      ldCardGallery,
      ldWeatherCard,
      ldCalendarEvent,
      ldTimeline,
      ldDetailList,
    ],
    instructions: kLdGenuiSystemPromptFragments.join('\n'),
  );
}
