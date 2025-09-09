// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get autoLabel => 'Automatique';

  @override
  String get pausedLabel => 'En pause';

  @override
  String nextAutoDecrementIn(int s) {
    return 'Prochaine diminution automatique dans : ${s}s';
  }

  @override
  String get autoDecrementPaused => 'Diminution automatique en pause';

  @override
  String get lastChangedLabel => 'Dernière modification :';

  @override
  String get appTitle => 'Flutter Démo';

  @override
  String get homeTitle => 'Page d\'accueil Flutter Démo';

  @override
  String get pushCountLabel =>
      'Vous avez appuyé sur le bouton autant de fois :';

  @override
  String get incrementTooltip => 'Incrémenter';

  @override
  String get decrementTooltip => 'Décrémenter';

  @override
  String get loadErrorMessage => 'Impossible de charger le compteur enregistré';

  @override
  String get startAutoHint =>
      'Quand le compteur est 0, appuyez sur + pour démarrer';

  @override
  String get cannotGoBelowZero => 'Le compteur ne peut pas être inférieur à 0';
}
