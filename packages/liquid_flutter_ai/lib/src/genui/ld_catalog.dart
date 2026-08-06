import 'package:genui/genui.dart';
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

Catalog buildLdCatalog() {
  return Catalog(
    [
      ldMultipleChoice,
      ldConfirm,
      ldCallout,
      ldCardGallery,
      ldWeatherCard,
      ldCalendarEvent,
      ldTimeline,
      ldDetailList,
    ],
    catalogId: kLdGenuiCatalogId,
    systemPromptFragments: kLdGenuiSystemPromptFragments,
  );
}
