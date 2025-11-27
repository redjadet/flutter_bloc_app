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
  String get openCalculatorTooltip => 'Ouvrir la calculatrice de paiement';

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
  String get exampleNativeInfoDialogTitle => 'Détails de la plateforme';

  @override
  String get exampleNativeInfoDialogPlatformLabel => 'Plateforme';

  @override
  String get exampleNativeInfoDialogVersionLabel => 'Version';

  @override
  String get exampleNativeInfoDialogManufacturerLabel => 'Fabricant';

  @override
  String get exampleNativeInfoDialogModelLabel => 'Modèle';

  @override
  String get exampleNativeInfoDialogBatteryLabel => 'Niveau de batterie';

  @override
  String get exampleDialogCloseButton => 'Fermer';

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
  String get calculatorTitle => 'Calculatrice de paiement';

  @override
  String get calculatorSummaryHeader => 'Résumé de paiement';

  @override
  String get calculatorResultLabel => 'Résultat';

  @override
  String get calculatorSubtotalLabel => 'Sous-total';

  @override
  String calculatorTaxLabel(String rate) {
    return 'Taxe ($rate)';
  }

  @override
  String calculatorTipLabel(String rate) {
    return 'Pourboire ($rate)';
  }

  @override
  String get calculatorTotalLabel => 'Montant à encaisser';

  @override
  String get calculatorTaxPresetsLabel => 'Taxes suggérées';

  @override
  String get calculatorCustomTaxLabel => 'Taxe personnalisée';

  @override
  String get calculatorCustomTaxDialogTitle => 'Taxe personnalisée';

  @override
  String get calculatorCustomTaxFieldLabel => 'Pourcentage de taxe';

  @override
  String get calculatorResetTax => 'Réinitialiser la taxe';

  @override
  String get calculatorTipRateLabel => 'Pourboires suggérés';

  @override
  String get calculatorCustomTipLabel => 'Pourboire personnalisé';

  @override
  String get calculatorResetTip => 'Effacer le pourboire';

  @override
  String get calculatorCustomTipDialogTitle => 'Pourboire personnalisé';

  @override
  String get calculatorCustomTipFieldLabel => 'Pourcentage de pourboire';

  @override
  String get calculatorCancel => 'Annuler';

  @override
  String get calculatorApply => 'Appliquer';

  @override
  String get calculatorKeypadHeader => 'Clavier';

  @override
  String get calculatorClearLabel => 'Effacer';

  @override
  String get calculatorBackspace => 'Retour arrière';

  @override
  String get calculatorPercentCommand => 'Pourcentage';

  @override
  String get calculatorToggleSign => 'Changer de signe';

  @override
  String get calculatorDecimalPointLabel => 'Séparateur décimal';

  @override
  String get calculatorErrorTitle => 'Erreur';

  @override
  String get calculatorErrorDivisionByZero => 'Impossible de diviser par zéro';

  @override
  String get calculatorErrorInvalidResult =>
      'Le résultat n\'est pas un nombre valide';

  @override
  String get calculatorErrorNonPositiveTotal =>
      'Le total doit être supérieur à zéro';

  @override
  String get calculatorEquals => 'Calculer le total';

  @override
  String get calculatorPaymentTitle => 'Résumé de paiement';

  @override
  String get calculatorNewCalculation => 'Nouvelle opération';

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
  String get appInfoSectionTitle => 'Informations de l\'application';

  @override
  String get settingsRemoteConfigSectionTitle => 'Configuration distante';

  @override
  String get settingsRemoteConfigStatusIdle =>
      'En attente du premier chargement';

  @override
  String get settingsRemoteConfigStatusLoading =>
      'Chargement des dernières valeurs...';

  @override
  String get settingsRemoteConfigStatusLoaded => 'Dernières valeurs chargées';

  @override
  String get settingsRemoteConfigStatusError =>
      'Échec du chargement de la configuration distante';

  @override
  String get settingsRemoteConfigErrorLabel => 'Dernière erreur';

  @override
  String get settingsRemoteConfigFlagLabel =>
      'Indicateur de fonctionnalité Awesome';

  @override
  String get settingsRemoteConfigFlagEnabled => 'Activé';

  @override
  String get settingsRemoteConfigFlagDisabled => 'Désactivé';

  @override
  String get settingsRemoteConfigTestValueLabel => 'Valeur de test';

  @override
  String get settingsRemoteConfigTestValueEmpty => 'Non défini';

  @override
  String get settingsRemoteConfigRetryButton => 'Relancer la récupération';

  @override
  String get settingsRemoteConfigClearCacheButton => 'Vider le cache config';

  @override
  String get settingsSyncDiagnosticsTitle => 'Diagnostics de synchronisation';

  @override
  String get settingsSyncDiagnosticsEmpty =>
      'Aucune exécution de synchro pour le moment.';

  @override
  String settingsSyncLastRunLabel(String timestamp) {
    return 'Dernière exécution : $timestamp';
  }

  @override
  String settingsSyncOperationsLabel(int processed, int failed) {
    return 'Ops : $processed traitées, $failed échouées';
  }

  @override
  String settingsSyncPendingLabel(int count) {
    return 'En attente au départ : $count';
  }

  @override
  String settingsSyncPrunedLabel(int count) {
    return 'Nettoyés : $count';
  }

  @override
  String settingsSyncDurationLabel(int ms) {
    return 'Durée : $ms ms';
  }

  @override
  String get settingsSyncHistoryTitle => 'Exécutions de synchro récentes';

  @override
  String get settingsProfileCacheSectionTitle => 'Cache du profil';

  @override
  String get settingsProfileCacheDescription =>
      'Supprimez l\'instantané de profil stocké localement utilisé pour afficher l\'écran du profil hors ligne.';

  @override
  String get settingsProfileCacheClearButton => 'Vider le cache du profil';

  @override
  String get settingsProfileCacheClearedMessage => 'Cache du profil vidé';

  @override
  String get settingsProfileCacheErrorMessage =>
      'Impossible de vider le cache du profil';

  @override
  String get appInfoVersionLabel => 'Version';

  @override
  String get appInfoBuildNumberLabel => 'Numéro de build';

  @override
  String get appInfoLoadingLabel =>
      'Chargement des informations de l\'application...';

  @override
  String get appInfoLoadErrorLabel =>
      'Impossible de charger les informations de l\'application.';

  @override
  String get appInfoRetryButtonLabel => 'Réessayer';

  @override
  String get openChatTooltip => 'Discuter avec l\'IA';

  @override
  String get openGoogleMapsTooltip => 'Ouvrir la démo Google Maps';

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
  String get chatMessageStatusPending => 'Synchronisation en attente';

  @override
  String get chatMessageStatusSyncing => 'Synchronisation…';

  @override
  String get chatMessageStatusOffline =>
      'Hors ligne – sera envoyé une fois connecté';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get registerFullNameLabel => 'Nom complet';

  @override
  String get registerFullNameHint => 'Marie Dupont';

  @override
  String get registerEmailLabel => 'Adresse e-mail';

  @override
  String get registerEmailHint => 'marie.dupont@example.com';

  @override
  String get registerPhoneLabel => 'Numéro de téléphone';

  @override
  String get registerPhoneHint => '5551234567';

  @override
  String get registerCountryPickerTitle => 'Choisissez votre indicatif pays';

  @override
  String get registerPasswordLabel => 'Mot de passe';

  @override
  String get registerPasswordHint => 'Créer un mot de passe';

  @override
  String get registerConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get registerConfirmPasswordHint => 'Saisir à nouveau le mot de passe';

  @override
  String get registerSubmitButton => 'Suivant';

  @override
  String get registerDialogTitle => 'Inscription terminée';

  @override
  String registerDialogMessage(String name) {
    return 'Bienvenue à bord, $name !';
  }

  @override
  String get registerDialogOk => 'OK';

  @override
  String get registerFullNameEmptyError => 'Veuillez saisir votre nom complet';

  @override
  String get registerFullNameTooShortError =>
      'Le nom doit comporter au moins 2 caractères';

  @override
  String get registerEmailEmptyError => 'Veuillez saisir votre e-mail';

  @override
  String get registerEmailInvalidError => 'Veuillez saisir un e-mail valide';

  @override
  String get registerPasswordEmptyError => 'Veuillez saisir votre mot de passe';

  @override
  String get registerPasswordTooShortError =>
      'Le mot de passe doit comporter au moins 8 caractères';

  @override
  String get registerPasswordLettersAndNumbersError =>
      'Utilisez des lettres et des chiffres';

  @override
  String get registerPasswordWhitespaceError =>
      'Le mot de passe ne peut pas contenir d’espaces';

  @override
  String get registerTermsCheckboxPrefix => 'J’ai lu et j’accepte les ';

  @override
  String get registerTermsCheckboxSuffix => '.';

  @override
  String get registerTermsLinkLabel => 'conditions générales d’utilisation';

  @override
  String get registerTermsError =>
      'Veuillez accepter les conditions pour continuer';

  @override
  String get registerTermsDialogTitle => 'Conditions générales';

  @override
  String get registerTermsDialogBody =>
      'Cette application de démonstration doit être utilisée de manière responsable. En vous inscrivant, vous acceptez de protéger vos identifiants, de respecter les lois en vigueur et de reconnaître que le contenu est fourni à titre illustratif et peut être modifié sans préavis. Si vous n’acceptez pas ces conditions, interrompez l’inscription.';

  @override
  String get registerTermsAcceptButton => 'Accepter';

  @override
  String get registerTermsRejectButton => 'Annuler';

  @override
  String get registerTermsPrompt =>
      'Veuillez lire et accepter les conditions avant de continuer.';

  @override
  String get registerTermsButtonLabel => 'Lire les conditions générales';

  @override
  String get registerTermsDialogAcknowledge => 'J’ai lu les conditions';

  @override
  String get registerTermsCheckboxLabel => 'J’accepte les conditions générales';

  @override
  String get registerTermsCheckboxDisabledHint =>
      'Veuillez lire les conditions avant de les accepter.';

  @override
  String get registerTermsNotAcceptedError =>
      'Vous devez accepter les conditions pour continuer.';

  @override
  String get registerConfirmPasswordEmptyError =>
      'Veuillez confirmer votre mot de passe';

  @override
  String get registerConfirmPasswordMismatchError =>
      'Les mots de passe ne correspondent pas';

  @override
  String get registerPhoneEmptyError =>
      'Veuillez saisir votre numéro de téléphone';

  @override
  String get registerPhoneInvalidError => 'Saisissez entre 6 et 15 chiffres';

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
  String get exampleGoogleMapsButton => 'Ouvrir la démo Google Maps';

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

  @override
  String get googleMapsPageTitle => 'Démo Google Maps';

  @override
  String get googleMapsPageGenericError =>
      'Impossible de charger les données de la carte.';

  @override
  String get googleMapsPageControlsHeading => 'Commandes de la carte';

  @override
  String get googleMapsPageMapTypeNormal => 'Afficher la carte standard';

  @override
  String get googleMapsPageMapTypeHybrid => 'Afficher la carte hybride';

  @override
  String get googleMapsPageTrafficToggle => 'Afficher le trafic en temps réel';

  @override
  String get googleMapsPageApiKeyHelp =>
      'Ajoutez les clés d’API Google Maps aux projets natifs pour voir les tuiles en direct.';

  @override
  String get googleMapsPageEmptyLocations =>
      'Aucun lieu à afficher pour le moment.';

  @override
  String get googleMapsPageLocationsHeading => 'Lieux à découvrir';

  @override
  String get googleMapsPageFocusButton => 'Centrer';

  @override
  String get googleMapsPageSelectedBadge => 'Sélectionné';

  @override
  String get googleMapsPageMissingKeyTitle =>
      'Ajoutez une clé d’API Google Maps';

  @override
  String get googleMapsPageMissingKeyDescription =>
      'Configurez des clés Google Maps valides dans les projets natifs pour utiliser cette démo.';

  @override
  String get googleMapsPageUnsupportedDescription =>
      'La démo Google Maps est disponible uniquement sur Android et iOS.';

  @override
  String get syncStatusOfflineTitle => 'Vous êtes hors ligne';

  @override
  String syncStatusOfflineMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# changements',
      one: '# changement',
      zero: 'vos changements',
    );
    return 'Nous synchroniserons $_temp0 dès que vous serez reconnecté(e).';
  }

  @override
  String get syncStatusSyncingTitle => 'Synchronisation en cours';

  @override
  String syncStatusSyncingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: 'Synchronisation de # changements…',
      one: 'Synchronisation de # changement…',
      zero: 'Finalisation des dernières mises à jour.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusPendingTitle => 'Changements en attente';

  @override
  String syncStatusPendingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# changements en attente de synchronisation.',
      one: '# changement en attente de synchronisation.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusSyncNowButton => 'Synchroniser maintenant';

  @override
  String counterLastSynced(Object timestamp) {
    return 'Dernière synchro : $timestamp';
  }

  @override
  String counterChangeId(Object changeId) {
    return 'ID de changement : $changeId';
  }

  @override
  String get syncQueueInspectorButton => 'Voir la file de synchro';

  @override
  String get syncQueueInspectorEmpty => 'Aucune opération en attente.';

  @override
  String get syncQueueInspectorTitle => 'Opérations de synchronisation';

  @override
  String syncQueueInspectorOperation(String entity, int attempts) {
    return 'Entité : $entity, tentatives : $attempts';
  }
}
