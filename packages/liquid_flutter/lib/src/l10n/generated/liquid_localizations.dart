import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'liquid_localizations_de.dart';
import 'liquid_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of LiquidLocalizations
/// returned by `LiquidLocalizations.of(context)`.
///
/// Applications need to include `LiquidLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/liquid_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: LiquidLocalizations.localizationsDelegates,
///   supportedLocales: LiquidLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the LiquidLocalizations.supportedLocales
/// property.
abstract class LiquidLocalizations {
  LiquidLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static LiquidLocalizations of(BuildContext context) {
    return Localizations.of<LiquidLocalizations>(context, LiquidLocalizations)!;
  }

  static const LocalizationsDelegate<LiquidLocalizations> delegate = _LiquidLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('de')
  ];

  /// No description provided for @searchAgain.
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get searchAgain;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @enterText.
  ///
  /// In en, this message translates to:
  /// **'Enter text'**
  String get enterText;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retryIn.
  ///
  /// In en, this message translates to:
  /// **'Retry in {seconds}s...'**
  String retryIn(Object seconds);

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get selectTime;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get unknownError;

  /// No description provided for @moreInfo.
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get moreInfo;

  /// No description provided for @errorDetails.
  ///
  /// In en, this message translates to:
  /// **'Error details'**
  String get errorDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @clearError.
  ///
  /// In en, this message translates to:
  /// **'Clear error'**
  String get clearError;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingRouteDefinitions.
  ///
  /// In en, this message translates to:
  /// **'Loading filters and sort options...'**
  String get loadingRouteDefinitions;

  /// No description provided for @detailItemLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading item...'**
  String get detailItemLoading;

  /// No description provided for @detailItemLoadError.
  ///
  /// In en, this message translates to:
  /// **'This item could not be loaded. It may have been deleted or you may not have access.'**
  String get detailItemLoadError;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'A network error occurred. Please make sure you are connected to the internet and try again.'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In en, this message translates to:
  /// **'The request timed out. Please try again.'**
  String get timeoutError;

  /// No description provided for @formatError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing the request. Please try again.'**
  String get formatError;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get deleteSelected;

  /// No description provided for @deleteNItems.
  ///
  /// In en, this message translates to:
  /// **'Delete {items} {items,plural, =1{item}other{items}}'**
  String deleteNItems(num items);

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {items} {items,plural, =1{item}other{items}}?'**
  String deleteConfirmBody(num items);

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @activeFilters.
  ///
  /// In en, this message translates to:
  /// **'Active Filters'**
  String get activeFilters;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @maximize.
  ///
  /// In en, this message translates to:
  /// **'Maximize'**
  String get maximize;

  /// No description provided for @showDrawer.
  ///
  /// In en, this message translates to:
  /// **'Show Sidebar'**
  String get showDrawer;

  /// No description provided for @hideDrawer.
  ///
  /// In en, this message translates to:
  /// **'Hide Sidebar'**
  String get hideDrawer;

  /// No description provided for @nItemsSelected.
  ///
  /// In en, this message translates to:
  /// **'%value% {items,plural, =1{item}other{items}} selected'**
  String nItemsSelected(num items);

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @clearSelectionDialogHeader.
  ///
  /// In en, this message translates to:
  /// **'Clear selection?'**
  String get clearSelectionDialogHeader;

  /// No description provided for @clearSelectionBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard your selection of {n} items?'**
  String clearSelectionBody(Object n);

  /// No description provided for @openDrawer.
  ///
  /// In en, this message translates to:
  /// **'Open Sidebar'**
  String get openDrawer;

  /// No description provided for @closeDrawer.
  ///
  /// In en, this message translates to:
  /// **'Close Sidebar'**
  String get closeDrawer;

  /// No description provided for @ctrlListExplanation.
  ///
  /// In en, this message translates to:
  /// **'Select multiple items while holding cmd/ctrl'**
  String get ctrlListExplanation;

  /// No description provided for @listHidden.
  ///
  /// In en, this message translates to:
  /// **'The list was hidden'**
  String get listHidden;

  /// No description provided for @shiftListExplanation.
  ///
  /// In en, this message translates to:
  /// **'Select a range of items while holding shift'**
  String get shiftListExplanation;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @showSelection.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showSelection;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @discardUnsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard unsaved changes?'**
  String get discardUnsavedChanges;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @fieldConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflicting changes'**
  String get fieldConflictTitle;

  /// No description provided for @fieldConflictDescription.
  ///
  /// In en, this message translates to:
  /// **'These fields changed elsewhere while you were editing. Choose which value to keep.'**
  String get fieldConflictDescription;

  /// No description provided for @fieldConflictKeepAllMine.
  ///
  /// In en, this message translates to:
  /// **'Keep all mine'**
  String get fieldConflictKeepAllMine;

  /// No description provided for @fieldConflictUseAllServer.
  ///
  /// In en, this message translates to:
  /// **'Use all from server'**
  String get fieldConflictUseAllServer;

  /// No description provided for @fieldConflictKeepMine.
  ///
  /// In en, this message translates to:
  /// **'Keep mine'**
  String get fieldConflictKeepMine;

  /// No description provided for @fieldConflictUseServer.
  ///
  /// In en, this message translates to:
  /// **'Use server'**
  String get fieldConflictUseServer;

  /// No description provided for @noItemsMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No items match your filters'**
  String get noItemsMatchFilter;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating..'**
  String get creating;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Dicard changes'**
  String get discardChanges;

  /// No description provided for @selectRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Select recurrence'**
  String get selectRecurrence;

  /// No description provided for @recurrenceFrequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurrenceFrequency;

  /// No description provided for @recurrenceSecondly.
  ///
  /// In en, this message translates to:
  /// **'Secondly'**
  String get recurrenceSecondly;

  /// No description provided for @recurrenceMinutely.
  ///
  /// In en, this message translates to:
  /// **'Minutely'**
  String get recurrenceMinutely;

  /// No description provided for @recurrenceHourly.
  ///
  /// In en, this message translates to:
  /// **'Hourly'**
  String get recurrenceHourly;

  /// No description provided for @recurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurrenceDaily;

  /// No description provided for @recurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurrenceWeekly;

  /// No description provided for @recurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurrenceMonthly;

  /// No description provided for @recurrenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurrenceYearly;

  /// No description provided for @recurrenceEvery.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get recurrenceEvery;

  /// No description provided for @recurrenceUnitSeconds.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{second}other{seconds}}'**
  String recurrenceUnitSeconds(int count);

  /// No description provided for @recurrenceUnitMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{minute}other{minutes}}'**
  String recurrenceUnitMinutes(int count);

  /// No description provided for @recurrenceUnitHours.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{hour}other{hours}}'**
  String recurrenceUnitHours(int count);

  /// No description provided for @recurrenceUnitDays.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{day}other{days}}'**
  String recurrenceUnitDays(int count);

  /// No description provided for @recurrenceUnitWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{week}other{weeks}}'**
  String recurrenceUnitWeeks(int count);

  /// No description provided for @recurrenceUnitMonths.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{month}other{months}}'**
  String recurrenceUnitMonths(int count);

  /// No description provided for @recurrenceUnitYears.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{year}other{years}}'**
  String recurrenceUnitYears(int count);

  /// No description provided for @recurrenceOnDay.
  ///
  /// In en, this message translates to:
  /// **'On day'**
  String get recurrenceOnDay;

  /// No description provided for @recurrenceOnThe.
  ///
  /// In en, this message translates to:
  /// **'On the'**
  String get recurrenceOnThe;

  /// No description provided for @recurrenceLastDay.
  ///
  /// In en, this message translates to:
  /// **'Last day'**
  String get recurrenceLastDay;

  /// No description provided for @recurrenceNthFirst.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get recurrenceNthFirst;

  /// No description provided for @recurrenceNthSecond.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get recurrenceNthSecond;

  /// No description provided for @recurrenceNthThird.
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get recurrenceNthThird;

  /// No description provided for @recurrenceNthFourth.
  ///
  /// In en, this message translates to:
  /// **'Fourth'**
  String get recurrenceNthFourth;

  /// No description provided for @recurrenceNthLast.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get recurrenceNthLast;

  /// No description provided for @recurrenceEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get recurrenceEnds;

  /// No description provided for @recurrenceEndsNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get recurrenceEndsNever;

  /// No description provided for @recurrenceEndsOn.
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get recurrenceEndsOn;

  /// No description provided for @recurrenceEndsAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get recurrenceEndsAfter;

  /// No description provided for @recurrenceOccurrences.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{occurrence}other{occurrences}}'**
  String recurrenceOccurrences(int count);

  /// No description provided for @recurrenceNextOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Next occurrences'**
  String get recurrenceNextOccurrences;

  /// No description provided for @recurrenceUnsupportedHint.
  ///
  /// In en, this message translates to:
  /// **'This rule has parts this picker cannot edit. Saving will drop those parts.'**
  String get recurrenceUnsupportedHint;

  /// No description provided for @recurrenceOn.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get recurrenceOn;

  /// No description provided for @recurrenceIn.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get recurrenceIn;

  /// No description provided for @recurrenceUntil.
  ///
  /// In en, this message translates to:
  /// **'until'**
  String get recurrenceUntil;

  /// No description provided for @recurrenceTimes.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{once}other{{count} times}}'**
  String recurrenceTimes(int count);

  /// No description provided for @recurrenceLastOccurrence.
  ///
  /// In en, this message translates to:
  /// **'Last occurrence'**
  String get recurrenceLastOccurrence;

  /// No description provided for @recurrenceViewAllOccurrences.
  ///
  /// In en, this message translates to:
  /// **'View all occurrences'**
  String get recurrenceViewAllOccurrences;

  /// No description provided for @recurrenceAllOccurrences.
  ///
  /// In en, this message translates to:
  /// **'All occurrences'**
  String get recurrenceAllOccurrences;

  /// No description provided for @recurrenceShowingFirstN.
  ///
  /// In en, this message translates to:
  /// **'Showing the first {count} occurrences'**
  String recurrenceShowingFirstN(int count);
}

class _LiquidLocalizationsDelegate extends LocalizationsDelegate<LiquidLocalizations> {
  const _LiquidLocalizationsDelegate();

  @override
  Future<LiquidLocalizations> load(Locale locale) {
    return SynchronousFuture<LiquidLocalizations>(lookupLiquidLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LiquidLocalizationsDelegate old) => false;
}

LiquidLocalizations lookupLiquidLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return LiquidLocalizationsDe();
    case 'en': return LiquidLocalizationsEn();
  }

  throw FlutterError(
    'LiquidLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
