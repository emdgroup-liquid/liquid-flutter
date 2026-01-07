// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'liquid_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LiquidLocalizationsDe extends LiquidLocalizations {
  LiquidLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get searchAgain => 'Erneut suchen';

  @override
  String get search => 'Search...';

  @override
  String get noItemsFound => 'Keine Elemente gefunden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Fertig';

  @override
  String get enterText => 'Text eingeben';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get failed => 'Fehlgeschlagen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String retryIn(Object seconds) {
    return 'Erneuter Versuch in ${seconds}s...';
  }

  @override
  String get choose => 'Auswählen';

  @override
  String get submit => 'Absenden';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get selectTime => 'Select time';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get moreInfo => 'Weitere Informationen';

  @override
  String get close => 'Schließen';

  @override
  String get clearError => 'Clear error';

  @override
  String get loading => 'Laden...';

  @override
  String get networkError => 'Netzwerkfehler. Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind und versuchen Sie es erneut.';

  @override
  String get timeoutError => 'Zeitüberschreitung der Anfrage. Bitte versuchen Sie es erneut.';

  @override
  String get formatError => 'Ein Fehler beim Verarbeiten der Anfrage ist aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get createNew => 'Create new';

  @override
  String get delete => 'Delete';

  @override
  String get deleteSelected => 'Delete selected';

  @override
  String deleteNItems(num items) {
    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return 'Delete $items $_temp0';
  }

  @override
  String get edit => 'Edit';

  @override
  String get select => 'Select';

  @override
  String get filter => 'Filter';

  @override
  String get apply => 'Apply';

  @override
  String get activeFilters => 'Active Filters';

  @override
  String get sort => 'Sort';

  @override
  String get minimize => 'Minimize';

  @override
  String get maximize => 'Maximize';

  @override
  String get showDrawer => 'Show Sidebar';

  @override
  String get hideDrawer => 'Hide Sidebar';

  @override
  String get clearSelection => 'Clear selection?';

  @override
  String clearSelectionBody(Object n) {
    return 'Are you sure you want to discard your selection of $n items?';
  }

  @override
  String get openDrawer => 'Open Sidebar';

  @override
  String get closeDrawer => 'Close Sidebar';

  @override
  String get ctrlListExplanation => 'Select multiple items while holding cmd/ctrl';

  @override
  String get listHidden => 'The list was hidden';

  @override
  String get shiftListExplanation => 'Select a range of items while holding shift';
}
