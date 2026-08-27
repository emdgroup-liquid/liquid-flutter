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
  String get errorDetails => 'Error details';

  @override
  String get close => 'Schließen';

  @override
  String get clearError => 'Clear error';

  @override
  String get loading => 'Laden...';

  @override
  String get loadingRouteDefinitions => 'Filter und Sortierung werden geladen...';

  @override
  String get detailItemLoading => 'Element wird geladen...';

  @override
  String get detailItemLoadError => 'Dieses Element konnte nicht geladen werden. Es wurde möglicherweise gelöscht oder Sie haben keinen Zugriff.';

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
  String deleteConfirmBody(num items) {
    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return 'Are you sure you want to delete $items $_temp0?';
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
  String nItemsSelected(num items) {
    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: 'items',
      one: 'item',
    );
    return '%value% $_temp0 selected';
  }

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get clearSelectionDialogHeader => 'Clear selection?';

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

  @override
  String get copy => 'Copy';

  @override
  String get showSelection => 'Show';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get discardUnsavedChanges => 'Ungespeicherte Änderungen verwerfen?';

  @override
  String get discard => 'Verwerfen';

  @override
  String get keepEditing => 'Weiter bearbeiten';

  @override
  String get fieldConflictTitle => 'Widersprüchliche Änderungen';

  @override
  String get fieldConflictDescription => 'Diese Felder wurden anderswo geändert, während Sie sie bearbeitet haben. Wählen Sie, welcher Wert übernommen werden soll.';

  @override
  String get fieldConflictKeepAllMine => 'Alle meine behalten';

  @override
  String get fieldConflictUseAllServer => 'Alle vom Server übernehmen';

  @override
  String get fieldConflictKeepMine => 'Keep mine';

  @override
  String get fieldConflictUseServer => 'Use server';

  @override
  String get noItemsMatchFilter => 'Keine Elemente entsprechen Ihren Filtern';

  @override
  String get clearFilters => 'Filter zurücksetzen';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving';

  @override
  String get create => 'Create';

  @override
  String get creating => 'Creating..';

  @override
  String get discardChanges => 'Dicard changes';

  @override
  String get selectRecurrence => 'Wiederholung auswählen';

  @override
  String get recurrenceFrequency => 'Häufigkeit';

  @override
  String get recurrenceSecondly => 'Sekündlich';

  @override
  String get recurrenceMinutely => 'Minütlich';

  @override
  String get recurrenceHourly => 'Stündlich';

  @override
  String get recurrenceDaily => 'Täglich';

  @override
  String get recurrenceWeekly => 'Wöchentlich';

  @override
  String get recurrenceMonthly => 'Monatlich';

  @override
  String get recurrenceYearly => 'Jährlich';

  @override
  String get recurrenceEvery => 'Alle';

  @override
  String recurrenceUnitSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sekunden',
      one: 'Sekunde',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUnitMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Minuten',
      one: 'Minute',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUnitHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Stunden',
      one: 'Stunde',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUnitDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tage',
      one: 'Tag',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUnitWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wochen',
      one: 'Woche',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUnitMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Monate',
      one: 'Monat',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUnitYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jahre',
      one: 'Jahr',
    );
    return '$_temp0';
  }

  @override
  String get recurrenceOnDay => 'Am Tag';

  @override
  String get recurrenceOnThe => 'Am';

  @override
  String get recurrenceLastDay => 'Letzter Tag';

  @override
  String get recurrenceNthFirst => 'Ersten';

  @override
  String get recurrenceNthSecond => 'Zweiten';

  @override
  String get recurrenceNthThird => 'Dritten';

  @override
  String get recurrenceNthFourth => 'Vierten';

  @override
  String get recurrenceNthLast => 'Letzten';

  @override
  String get recurrenceEnds => 'Endet';

  @override
  String get recurrenceEndsNever => 'Nie';

  @override
  String get recurrenceEndsOn => 'Am Datum';

  @override
  String get recurrenceEndsAfter => 'Nach';

  @override
  String recurrenceOccurrences(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wiederholungen',
      one: 'Wiederholung',
    );
    return '$_temp0';
  }

  @override
  String get recurrenceNextOccurrences => 'Nächste Termine';

  @override
  String get recurrenceUnsupportedHint => 'Diese Regel enthält Teile, die dieser Picker nicht bearbeiten kann. Speichern entfernt diese Teile.';

  @override
  String get recurrenceOn => 'am';

  @override
  String get recurrenceIn => 'in';

  @override
  String get recurrenceUntil => 'bis';

  @override
  String recurrenceTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal',
      one: 'einmal',
    );
    return '$_temp0';
  }

  @override
  String recurrenceNthOccurrence(String ordinal) {
    return '$ordinal Termin';
  }

  @override
  String recurrenceLastNthOccurrence(String ordinal) {
    return 'Letzter ($ordinal)';
  }

  @override
  String get recurrenceViewAllOccurrences => 'Alle Termine anzeigen';

  @override
  String get recurrenceAllOccurrences => 'Alle Termine';

  @override
  String recurrenceShowingFirstN(int count) {
    return 'Zeigt die ersten $count Termine';
  }

  @override
  String recurrenceNMore(int count) {
    return '$count weitere';
  }

  @override
  String get recurrenceAt => 'Um';

  @override
  String get recurrenceHours => 'Stunden';

  @override
  String get recurrenceMinutes => 'Minuten';

  @override
  String get recurrenceTimesMatrixHint => 'Jede gewählte Stunde kombiniert sich mit jeder gewählten Minute.';

  @override
  String recurrenceAtTimes(String times) {
    return 'um $times';
  }

  @override
  String get selectRecurrences => 'Wiederholungen auswählen';

  @override
  String get recurrenceAddRule => 'Regel hinzufügen';

  @override
  String recurrenceRulesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Regeln',
      one: '1 Regel',
      zero: 'Keine Regeln',
    );
    return '$_temp0';
  }
}
