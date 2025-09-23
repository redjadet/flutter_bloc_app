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

  @override
  String get openExampleTooltip => 'Ouvrir la page d\'exemple';

  @override
  String get examplePageTitle => 'Page d\'exemple';

  @override
  String get examplePageDescription =>
      'Cette page montre la navigation avec GoRouter.';

  @override
  String get exampleBackButtonLabel => 'Retour au compteur';

  @override
  String get exampleNativeInfoButton => 'Récupérer les infos natives';

  @override
  String get exampleNativeInfoTitle => 'Informations sur la plateforme';

  @override
  String get exampleNativeInfoError =>
      'Impossible de récupérer les informations natives de la plateforme.';

  @override
  String get openChartsTooltip => 'Ouvrir les graphiques';

  @override
  String get openSettingsTooltip => 'Ouvrir les paramètres';

  @override
  String get settingsPageTitle => 'Paramètres';

  @override
  String get themeSectionTitle => 'Apparence';

  @override
  String get themeModeSystem => 'Valeur par défaut du système';

  @override
  String get themeModeLight => 'Clair';

  @override
  String get themeModeDark => 'Sombre';

  @override
  String get languageSectionTitle => 'Langue';

  @override
  String get languageSystemDefault => 'Utiliser la langue de l\'appareil';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageTurkish => 'Turc';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get openChatTooltip => 'Discuter avec l\'IA';

  @override
  String get chatPageTitle => 'Discussion IA';

  @override
  String get chatInputHint => 'Posez votre question à l\'assistant...';

  @override
  String get chatSendButton => 'Envoyer le message';

  @override
  String get chatEmptyState =>
      'Commencez la conversation en envoyant un message.';

  @override
  String get chatModelLabel => 'Modèle';

  @override
  String get chatModelGptOss20b => 'GPT-OSS-20B';

  @override
  String get chatModelGptOss120b => 'GPT-OSS-120B';

  @override
  String get chatHistoryShowTooltip => 'Afficher l\'historique';

  @override
  String get chatHistoryHideTooltip => 'Masquer l\'historique';

  @override
  String get chatHistoryPanelTitle => 'Historique des conversations';

  @override
  String get chatHistoryStartNew => 'Commencer une nouvelle conversation';

  @override
  String get chatHistoryClearAll => 'Supprimer l\'historique';

  @override
  String get chatHistoryDeleteConversation => 'Supprimer la conversation';

  @override
  String get chatHistoryClearAllWarning =>
      'Cela supprimera définitivement toutes les conversations enregistrées.';

  @override
  String chatHistoryDeleteConversationWarning(String title) {
    return 'Supprimer \"$title\" ?';
  }

  @override
  String get cancelButtonLabel => 'Annuler';

  @override
  String get deleteButtonLabel => 'Supprimer';

  @override
  String get chatHistoryEmpty =>
      'Aucune conversation enregistrée pour le moment.';

  @override
  String chatHistoryConversationTitle(int index) {
    return 'Conversation $index';
  }

  @override
  String chatHistoryUpdatedAt(String timestamp) {
    return 'Mis à jour $timestamp';
  }

  @override
  String get chartPageTitle => 'Prix du Bitcoin (USD)';

  @override
  String get chartPageDescription =>
      'Cours de clôture sur les 7 derniers jours (source : CoinGecko)';

  @override
  String get chartPageError =>
      'Impossible de charger les données du graphique.';

  @override
  String get chartPageEmpty => 'Aucune donnée de graphique pour le moment.';

  @override
  String get chartZoomToggleLabel => 'Activer le zoom par pincement';
}
