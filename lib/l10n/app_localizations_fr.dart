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
  String get exampleRunIsolatesButton => 'Exécuter les exemples d\'isolats';

  @override
  String get exampleIsolateParallelPending =>
      'Exécution des tâches parallèles...';

  @override
  String exampleIsolateFibonacciLabel(int input, int value) {
    return 'Fibonacci($input) = $value';
  }

  @override
  String exampleIsolateParallelComplete(String values, int milliseconds) {
    return 'Valeurs doublées en parallèle : $values (terminé en $milliseconds ms)';
  }

  @override
  String get settingsBiometricPrompt =>
      'Authentifiez-vous pour ouvrir les paramètres';

  @override
  String get settingsBiometricFailed =>
      'Impossible de vérifier votre identité.';

  @override
  String get openChartsTooltip => 'Ouvrir les graphiques';

  @override
  String get openGraphqlTooltip => 'Explorer la démo GraphQL';

  @override
  String get openSettingsTooltip => 'Ouvrir les paramètres';

  @override
  String get settingsPageTitle => 'Paramètres';

  @override
  String get accountSectionTitle => 'Compte';

  @override
  String accountSignedInAs(String name) {
    return 'Connecté en tant que $name';
  }

  @override
  String get accountSignedOutLabel => 'Non connecté.';

  @override
  String get accountSignInButton => 'Se connecter';

  @override
  String get accountManageButton => 'Gérer le compte';

  @override
  String get accountGuestLabel => 'Compte invité utilisé';

  @override
  String get accountGuestDescription =>
      'Vous êtes connecté anonymement. Créez un compte pour synchroniser vos données entre vos appareils.';

  @override
  String get accountUpgradeButton => 'Créer ou lier un compte';

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
  String get profilePageTitle => 'Profil';

  @override
  String get anonymousSignInButton => 'Continuer en invité';

  @override
  String get anonymousSignInDescription =>
      'Vous pouvez explorer l\'application sans créer de compte. Vous pourrez mettre à niveau plus tard depuis les paramètres.';

  @override
  String get anonymousSignInFailed =>
      'Impossible de démarrer la session invité. Veuillez réessayer.';

  @override
  String get anonymousUpgradeHint =>
      'Vous utilisez actuellement une session invitée. Connectez-vous pour conserver vos données durablement.';

  @override
  String get authErrorInvalidEmail => 'L\'adresse e-mail semble invalide.';

  @override
  String get authErrorUserDisabled =>
      'Ce compte est désactivé. Contactez le support pour obtenir de l\'aide.';

  @override
  String get authErrorUserNotFound =>
      'Aucun compte ne correspond à ces informations.';

  @override
  String get authErrorWrongPassword =>
      'Le mot de passe est incorrect. Vérifiez et réessayez.';

  @override
  String get authErrorEmailInUse =>
      'Cette adresse e-mail est déjà liée à un autre compte.';

  @override
  String get authErrorOperationNotAllowed =>
      'Ce mode de connexion est actuellement désactivé. Choisissez une autre option.';

  @override
  String get authErrorWeakPassword =>
      'Choisissez un mot de passe plus robuste avant de continuer.';

  @override
  String get authErrorRequiresRecentLogin =>
      'Veuillez vous reconnecter pour terminer cette action.';

  @override
  String get authErrorCredentialInUse =>
      'Ces identifiants sont déjà associés à un autre compte.';

  @override
  String get authErrorInvalidCredential =>
      'Les identifiants fournis sont invalides ou ont expiré.';

  @override
  String get authErrorGeneric =>
      'La requête n\'a pas abouti. Veuillez réessayer.';

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

  @override
  String get graphqlSampleTitle => 'Pays GraphQL';

  @override
  String get graphqlSampleFilterLabel => 'Filtrer par continent';

  @override
  String get graphqlSampleAllContinents => 'Tous les continents';

  @override
  String get graphqlSampleErrorTitle => 'Un problème est survenu';

  @override
  String get graphqlSampleGenericError =>
      'Impossible de charger les pays pour le moment.';

  @override
  String get graphqlSampleRetryButton => 'Réessayer';

  @override
  String get graphqlSampleEmpty =>
      'Aucun pays ne correspond aux filtres sélectionnés.';

  @override
  String get graphqlSampleCapitalLabel => 'Capitale';

  @override
  String get graphqlSampleCurrencyLabel => 'Devise';

  @override
  String get graphqlSampleNetworkError =>
      'Erreur réseau. Vérifiez votre connexion et réessayez.';

  @override
  String get graphqlSampleInvalidRequestError =>
      'La requête a été refusée. Essayez un autre filtre.';

  @override
  String get graphqlSampleServerError =>
      'Le service est momentanément indisponible. Réessayez plus tard.';

  @override
  String get graphqlSampleDataError => 'Réponse inattendue reçue. Réessayez.';

  @override
  String get exampleWebsocketButton => 'Ouvrir la démo WebSocket';

  @override
  String exampleNativeBatteryLabel(int percent) {
    return 'Niveau de batterie : $percent %';
  }

  @override
  String get websocketDemoTitle => 'Démo WebSocket';

  @override
  String get websocketDemoWebUnsupported =>
      'La démo WebSocket n\'est pas encore disponible sur le Web.';

  @override
  String get websocketReconnectTooltip => 'Reconnexion';

  @override
  String get websocketEmptyState =>
      'Aucun message pour le moment. Envoyez un message pour commencer.';

  @override
  String get websocketMessageHint => 'Saisissez un message';

  @override
  String get websocketSendButton => 'Envoyer';

  @override
  String websocketStatusConnected(String endpoint) {
    return 'Connecté à $endpoint';
  }

  @override
  String websocketStatusConnecting(String endpoint) {
    return 'Connexion à $endpoint...';
  }

  @override
  String websocketErrorLabel(String error) {
    return 'Erreur WebSocket : $error';
  }
}
