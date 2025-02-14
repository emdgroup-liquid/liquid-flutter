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
  String get close => 'Close';

  @override
  String get loading => 'Loading...';

  @override
  String get networkError => 'A network error occurred. Please make sure you are connected to the internet and try again.';

  @override
  String get timeoutError => 'The request timed out. Please try again.';

  @override
  String get formatError => 'An error occurred while processing the request. Please try again.';
}
