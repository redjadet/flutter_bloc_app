import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

/// Localizations for `package:material_ui` [MaterialApp] plus app ARBs.
///
/// Generated [AppLocalizations.localizationsDelegates] still wires
/// `package:flutter_localizations` Material/Cupertino types. `material_ui`
/// widgets look up their own types, so tests and [MaterialApp] must use this
/// list instead. Golden tests must wrap with `materialUiAppWrapper`, not
/// golden_toolkit `materialAppWrapper`.
const List<LocalizationsDelegate<dynamic>> appLocalizationDelegates =
    <LocalizationsDelegate<dynamic>>[
      ...GlobalMaterialLocalizations.delegates,
      AppLocalizations.delegate,
    ];
