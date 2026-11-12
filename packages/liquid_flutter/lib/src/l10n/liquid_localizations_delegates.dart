import 'package:material_ui/material_ui.dart';

import 'generated/liquid_localizations.dart';

/// Localization delegates for apps built with Liquid Flutter.
///
/// `flutter gen-l10n` still wires `liquidLocalizationsDelegates`
/// to the deprecated `flutter_localizations` delegates, which a `material_ui`
/// app cannot resolve - Material strings would silently fall back to English.
/// Prefer this list:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: liquidLocalizationsDelegates,
///   supportedLocales: LiquidLocalizations.supportedLocales,
///   // ...
/// )
/// ```
///
/// [GlobalMaterialLocalizations.delegates] covers Material, Cupertino and
/// widget strings for every locale the app supports.
const List<LocalizationsDelegate<dynamic>> liquidLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  LiquidLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
