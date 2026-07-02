// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'liquid_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LiquidLocalizationsEn extends LiquidLocalizations {
  LiquidLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchAgain => 'Search again';

  @override
  String get search => 'Search...';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get enterText => 'Enter text';

  @override
  String get refresh => 'Refresh';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get failed => 'Failed';

  @override
  String get retry => 'Retry';

  @override
  String retryIn(Object seconds) {
    return 'Retry in ${seconds}s...';
  }

  @override
  String get choose => 'Choose';

  @override
  String get submit => 'Submit';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select time';

  @override
  String get unknownError => 'An unknown error occurred';

  @override
  String get moreInfo => 'More info';

  @override
  String get errorDetails => 'Error details';

  @override
  String get close => 'Close';

  @override
  String get clearError => 'Clear error';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingRouteDefinitions => 'Loading filters and sort options...';

  @override
  String get detailItemLoading => 'Loading item...';

  @override
  String get detailItemLoadError => 'This item could not be loaded. It may have been deleted or you may not have access.';

  @override
  String get networkError => 'A network error occurred. Please make sure you are connected to the internet and try again.';

  @override
  String get timeoutError => 'The request timed out. Please try again.';

  @override
  String get formatError => 'An error occurred while processing the request. Please try again.';

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
  String get discardUnsavedChanges => 'Discard unsaved changes?';

  @override
  String get discard => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get fieldConflictTitle => 'Conflicting changes';

  @override
  String get fieldConflictDescription => 'These fields changed elsewhere while you were editing. Choose which value to keep.';

  @override
  String get fieldConflictKeepAllMine => 'Keep all mine';

  @override
  String get fieldConflictUseAllServer => 'Use all from server';

  @override
  String get fieldConflictYours => 'Your value';

  @override
  String get fieldConflictServer => 'Server value';

  @override
  String get noItemsMatchFilter => 'No items match your filters';

  @override
  String get clearFilters => 'Clear filters';
}
