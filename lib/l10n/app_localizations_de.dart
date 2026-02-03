// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get autoLabel => 'Automatisch';

  @override
  String get pausedLabel => 'Pausiert';

  @override
  String nextAutoDecrementIn(int s) {
    return 'Nächste automatische Verringerung in: ${s}s';
  }

  @override
  String get autoDecrementPaused => 'Automatische Verringerung pausiert';

  @override
  String get lastChangedLabel => 'Zuletzt geändert:';

  @override
  String get appTitle => 'Flutter Demo';

  @override
  String get homeTitle => 'Flutter Demo Startseite';

  @override
  String get pushCountLabel => 'Sie haben so oft auf die Taste gedrückt:';

  @override
  String get incrementTooltip => 'Erhöhen';

  @override
  String get decrementTooltip => 'Verringern';

  @override
  String get loadErrorMessage =>
      'Gespeicherter Zähler konnte nicht geladen werden';

  @override
  String get startAutoHint =>
      'Bei Zähler 0: Tippen Sie auf + für Auto-Verringerung';

  @override
  String get cannotGoBelowZero => 'Der Zähler kann nicht unter 0 gehen';

  @override
  String get openExampleTooltip => 'Beispielseite öffnen';

  @override
  String get openCalculatorTooltip => 'Zahlungsrechner öffnen';

  @override
  String get examplePageTitle => 'Beispielseite';

  @override
  String get examplePageDescription =>
      'Diese Seite demonstriert die Navigation mit GoRouter.';

  @override
  String get exampleBackButtonLabel => 'Zurück zum Zähler';

  @override
  String get exampleNativeInfoButton => 'Native Infos abrufen';

  @override
  String get exampleNativeInfoTitle => 'Plattforminformationen';

  @override
  String get exampleNativeInfoError =>
      'Native Plattforminformationen konnten nicht abgerufen werden.';

  @override
  String get exampleNativeInfoDialogTitle => 'Plattformdetails';

  @override
  String get exampleNativeInfoDialogPlatformLabel => 'Plattform';

  @override
  String get exampleNativeInfoDialogVersionLabel => 'Version';

  @override
  String get exampleNativeInfoDialogManufacturerLabel => 'Hersteller';

  @override
  String get exampleNativeInfoDialogModelLabel => 'Modell';

  @override
  String get exampleNativeInfoDialogBatteryLabel => 'Akkustand';

  @override
  String get exampleDialogCloseButton => 'Schließen';

  @override
  String get exampleRunIsolatesButton => 'Isolat-Beispiele ausführen';

  @override
  String get exampleIsolateParallelPending =>
      'Parallele Aufgaben werden ausgeführt...';

  @override
  String exampleIsolateFibonacciLabel(int input, int value) {
    return 'Fibonacci($input) = $value';
  }

  @override
  String exampleIsolateParallelComplete(String values, int milliseconds) {
    return 'Parallel verdoppelte Werte: $values (abgeschlossen in $milliseconds ms)';
  }

  @override
  String get calculatorTitle => 'Zahlungsrechner';

  @override
  String get calculatorSummaryHeader => 'Zahlungsübersicht';

  @override
  String get calculatorResultLabel => 'Ergebnis';

  @override
  String get calculatorSubtotalLabel => 'Zwischensumme';

  @override
  String calculatorTaxLabel(String rate) {
    return 'Steuer ($rate)';
  }

  @override
  String calculatorTipLabel(String rate) {
    return 'Trinkgeld ($rate)';
  }

  @override
  String get calculatorTotalLabel => 'Zu kassierender Betrag';

  @override
  String get calculatorTaxPresetsLabel => 'Steuervorgaben';

  @override
  String get calculatorCustomTaxLabel => 'Individueller Steuersatz';

  @override
  String get calculatorCustomTaxDialogTitle => 'Individueller Steuersatz';

  @override
  String get calculatorCustomTaxFieldLabel => 'Steuersatz in Prozent';

  @override
  String get calculatorResetTax => 'Steuer zurücksetzen';

  @override
  String get calculatorTipRateLabel => 'Trinkgeld-Voreinstellungen';

  @override
  String get calculatorCustomTipLabel => 'Individuelles Trinkgeld';

  @override
  String get calculatorResetTip => 'Trinkgeld löschen';

  @override
  String get calculatorCustomTipDialogTitle => 'Individuelles Trinkgeld';

  @override
  String get calculatorCustomTipFieldLabel => 'Trinkgeld in Prozent';

  @override
  String get calculatorCancel => 'Abbrechen';

  @override
  String get calculatorApply => 'Übernehmen';

  @override
  String get calculatorKeypadHeader => 'Tastatur';

  @override
  String get calculatorClearLabel => 'Zurücksetzen';

  @override
  String get calculatorBackspace => 'Rücktaste';

  @override
  String get calculatorPercentCommand => 'Prozent';

  @override
  String get calculatorToggleSign => 'Vorzeichen wechseln';

  @override
  String get calculatorDecimalPointLabel => 'Dezimaltrennzeichen';

  @override
  String get calculatorErrorTitle => 'Fehler';

  @override
  String get calculatorErrorDivisionByZero =>
      'Division durch Null ist nicht möglich';

  @override
  String get calculatorErrorInvalidResult =>
      'Das Ergebnis ist keine gültige Zahl';

  @override
  String get calculatorErrorNonPositiveTotal =>
      'Der Gesamtbetrag muss größer als null sein';

  @override
  String get calculatorEquals => 'Betrag berechnen';

  @override
  String get calculatorPaymentTitle => 'Zahlungsübersicht';

  @override
  String get calculatorNewCalculation => 'Neue Berechnung';

  @override
  String get settingsBiometricPrompt =>
      'Authentifiziere dich, um die Einstellungen zu öffnen';

  @override
  String get settingsBiometricFailed =>
      'Identität konnte nicht bestätigt werden.';

  @override
  String get openChartsTooltip => 'Diagramme öffnen';

  @override
  String get openGraphqlTooltip => 'GraphQL-Demo anzeigen';

  @override
  String get openSettingsTooltip => 'Einstellungen öffnen';

  @override
  String get settingsPageTitle => 'Einstellungen';

  @override
  String get accountSectionTitle => 'Konto';

  @override
  String accountSignedInAs(String name) {
    return 'Angemeldet als $name';
  }

  @override
  String get accountSignedOutLabel => 'Nicht angemeldet.';

  @override
  String get accountSignInButton => 'Anmelden';

  @override
  String get accountManageButton => 'Konto verwalten';

  @override
  String get accountGuestLabel => 'Gastkonto wird verwendet';

  @override
  String get accountGuestDescription =>
      'Du bist anonym angemeldet. Erstelle ein Konto, um deine Daten zwischen Geräten zu synchronisieren.';

  @override
  String get accountUpgradeButton => 'Konto erstellen oder verknüpfen';

  @override
  String get themeSectionTitle => 'Erscheinungsbild';

  @override
  String get themeModeSystem => 'Systemstandard';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get languageSectionTitle => 'Sprache';

  @override
  String get languageSystemDefault => 'Gerätesprache verwenden';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageTurkish => 'Türkisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get appInfoSectionTitle => 'App-Informationen';

  @override
  String get settingsRemoteConfigSectionTitle => 'Remote Config';

  @override
  String get settingsRemoteConfigStatusIdle => 'Warte auf ersten Abruf';

  @override
  String get settingsRemoteConfigStatusLoading => 'Lade aktuelle Werte...';

  @override
  String get settingsRemoteConfigStatusLoaded => 'Aktuelle Werte geladen';

  @override
  String get settingsRemoteConfigStatusError =>
      'Remote Config konnte nicht geladen werden';

  @override
  String get settingsRemoteConfigErrorLabel => 'Letzter Fehler';

  @override
  String get settingsRemoteConfigFlagLabel => 'Awesome-Feature-Flag';

  @override
  String get settingsRemoteConfigFlagEnabled => 'Aktiviert';

  @override
  String get settingsRemoteConfigFlagDisabled => 'Deaktiviert';

  @override
  String get settingsRemoteConfigTestValueLabel => 'Testwert';

  @override
  String get settingsRemoteConfigTestValueEmpty => 'Nicht gesetzt';

  @override
  String get settingsRemoteConfigRetryButton => 'Erneut abrufen';

  @override
  String get settingsRemoteConfigClearCacheButton => 'Konfig-Cache löschen';

  @override
  String get settingsSyncDiagnosticsTitle => 'Sync-Diagnostik';

  @override
  String get settingsSyncDiagnosticsEmpty =>
      'Noch keine Sync-Durchläufe aufgezeichnet.';

  @override
  String settingsSyncLastRunLabel(String timestamp) {
    return 'Letzter Lauf: $timestamp';
  }

  @override
  String settingsSyncOperationsLabel(int processed, int failed) {
    return 'Vorgänge: $processed verarbeitet, $failed fehlgeschlagen';
  }

  @override
  String settingsSyncPendingLabel(int count) {
    return 'Zu Beginn offen: $count';
  }

  @override
  String settingsSyncPrunedLabel(int count) {
    return 'Bereinigt: $count';
  }

  @override
  String settingsSyncDurationLabel(int ms) {
    return 'Dauer: ${ms}ms';
  }

  @override
  String get settingsSyncHistoryTitle => 'Aktuelle Sync-Läufe';

  @override
  String get settingsGraphqlCacheSectionTitle => 'GraphQL-Cache';

  @override
  String get settingsGraphqlCacheDescription =>
      'Lösche den zwischengespeicherten Länder/Kontinente-Datensatz der GraphQL-Demo. Daten werden beim nächsten Laden erneuert.';

  @override
  String get settingsGraphqlCacheClearButton => 'GraphQL-Cache leeren';

  @override
  String get settingsGraphqlCacheClearedMessage => 'GraphQL-Cache geleert';

  @override
  String get settingsGraphqlCacheErrorMessage =>
      'GraphQL-Cache konnte nicht geleert werden';

  @override
  String get settingsProfileCacheSectionTitle => 'Profil-Cache';

  @override
  String get settingsProfileCacheDescription =>
      'Lösche den lokal gespeicherten Profil-Snapshot, der die Profilseite offline rendert.';

  @override
  String get settingsProfileCacheClearButton => 'Profil-Cache löschen';

  @override
  String get settingsProfileCacheClearedMessage => 'Profil-Cache gelöscht';

  @override
  String get settingsProfileCacheErrorMessage =>
      'Profil-Cache konnte nicht gelöscht werden';

  @override
  String get networkRetryingSnackBarMessage => 'Wird erneut versucht…';

  @override
  String get appInfoVersionLabel => 'Version';

  @override
  String get appInfoBuildNumberLabel => 'Build-Nummer';

  @override
  String get appInfoLoadingLabel => 'App-Informationen werden geladen...';

  @override
  String get appInfoLoadErrorLabel =>
      'App-Informationen konnten nicht geladen werden.';

  @override
  String get appInfoRetryButtonLabel => 'Erneut versuchen';

  @override
  String get openChatTooltip => 'Mit KI chatten';

  @override
  String get openGenuiDemoTooltip => 'GenUI Demo';

  @override
  String get openGoogleMapsTooltip => 'Google-Maps-Demo öffnen';

  @override
  String get openWhiteboardTooltip => 'Whiteboard öffnen';

  @override
  String get openMarkdownEditorTooltip => 'Markdown-Editor öffnen';

  @override
  String get openTodoTooltip => 'Todo-Liste öffnen';

  @override
  String get openWalletconnectAuthTooltip => 'Wallet verbinden';

  @override
  String get chatPageTitle => 'KI-Chat';

  @override
  String get chatInputHint => 'Frag den Assistenten etwas...';

  @override
  String get searchHint => 'Suchen...';

  @override
  String get retryButtonLabel => 'ERNEUT VERSUCHEN';

  @override
  String get featureLoadError =>
      'Diese Funktion konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get chatSendButton => 'Nachricht senden';

  @override
  String get chatEmptyState => 'Beginne das Gespräch mit einer Nachricht.';

  @override
  String get chatModelLabel => 'Modell';

  @override
  String get chatModelGptOss20b => 'GPT-OSS-20B';

  @override
  String get chatModelGptOss120b => 'GPT-OSS-120B';

  @override
  String get chatHistoryShowTooltip => 'Verlauf anzeigen';

  @override
  String get chatHistoryHideTooltip => 'Verlauf ausblenden';

  @override
  String get chatHistoryPanelTitle => 'Konversationsverlauf';

  @override
  String get chatHistoryStartNew => 'Neue Unterhaltung starten';

  @override
  String get chatHistoryClearAll => 'Verlauf löschen';

  @override
  String get chatHistoryDeleteConversation => 'Unterhaltung löschen';

  @override
  String get chatHistoryClearAllWarning =>
      'Dadurch werden alle gespeicherten Unterhaltungen dauerhaft gelöscht.';

  @override
  String get chatMessageStatusPending => 'Synchronisation ausstehend';

  @override
  String get chatMessageStatusSyncing => 'Wird synchronisiert…';

  @override
  String get chatMessageStatusOffline =>
      'Offline – wird bei Verbindung gesendet';

  @override
  String get registerTitle => 'Registrieren';

  @override
  String get registerFullNameLabel => 'Vollständiger Name';

  @override
  String get registerFullNameHint => 'Max Mustermann';

  @override
  String get registerEmailLabel => 'E-Mail-Adresse';

  @override
  String get registerEmailHint => 'max.mustermann@example.com';

  @override
  String get registerPhoneLabel => 'Telefonnummer';

  @override
  String get registerPhoneHint => '5551234567';

  @override
  String get registerCountryPickerTitle => 'Wähle deine Ländervorwahl';

  @override
  String get registerPasswordLabel => 'Passwort';

  @override
  String get registerPasswordHint => 'Passwort erstellen';

  @override
  String get registerConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get registerConfirmPasswordHint => 'Passwort erneut eingeben';

  @override
  String get registerSubmitButton => 'Weiter';

  @override
  String get registerDialogTitle => 'Registrierung abgeschlossen';

  @override
  String registerDialogMessage(String name) {
    return 'Willkommen an Bord, $name!';
  }

  @override
  String get registerDialogOk => 'OK';

  @override
  String get registerFullNameEmptyError =>
      'Bitte geben Sie Ihren vollständigen Namen ein';

  @override
  String get registerFullNameTooShortError =>
      'Der Name muss mindestens 2 Zeichen lang sein';

  @override
  String get registerEmailEmptyError =>
      'Bitte geben Sie Ihre E-Mail-Adresse ein';

  @override
  String get registerEmailInvalidError =>
      'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get registerPasswordEmptyError => 'Bitte geben Sie Ihr Passwort ein';

  @override
  String get registerPasswordTooShortError =>
      'Das Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get registerPasswordLettersAndNumbersError =>
      'Verwenden Sie Buchstaben und Zahlen';

  @override
  String get registerPasswordWhitespaceError =>
      'Das Passwort darf keine Leerzeichen enthalten';

  @override
  String get registerTermsCheckboxPrefix => 'Ich habe die ';

  @override
  String get registerTermsCheckboxSuffix => ' gelesen und akzeptiere sie.';

  @override
  String get registerTermsLinkLabel => 'Allgemeinen Geschäftsbedingungen';

  @override
  String get registerTermsError =>
      'Bitte akzeptieren Sie die Bedingungen, um fortzufahren';

  @override
  String get registerTermsDialogTitle => 'Allgemeine Geschäftsbedingungen';

  @override
  String get registerTermsDialogBody =>
      'Mit der Kontoerstellung verpflichten Sie sich, die App verantwortungsvoll zu nutzen, andere Nutzer zu respektieren und alle geltenden Gesetze einzuhalten. Sie stimmen unserer Datenschutzrichtlinie zu, erkennen an, dass sich die Verfügbarkeit des Dienstes ändern kann, und akzeptieren, dass Ihr Konto bei Missbrauch oder Verstößen gesperrt werden kann.';

  @override
  String get registerTermsAcceptButton => 'Akzeptieren';

  @override
  String get registerTermsRejectButton => 'Abbrechen';

  @override
  String get registerTermsPrompt =>
      'Bitte lesen und akzeptieren Sie die Bedingungen, bevor Sie fortfahren.';

  @override
  String get registerTermsButtonLabel =>
      'Allgemeine Geschäftsbedingungen lesen';

  @override
  String get registerTermsSheetTitle => 'Allgemeine Geschäftsbedingungen';

  @override
  String get registerTermsSheetBody =>
      'Diese Demo-Anwendung darf nur verantwortungsvoll genutzt werden. Durch die Registrierung verpflichten Sie sich, Ihre Zugangsdaten zu schützen, geltende Gesetze einzuhalten und zu akzeptieren, dass Inhalte ausschließlich illustrativen Charakter haben und ohne Ankündigung geändert werden können. Wenn Sie nicht zustimmen, brechen Sie die Registrierung ab.';

  @override
  String get registerTermsDialogAcknowledge =>
      'Ich habe die Bedingungen gelesen';

  @override
  String get registerTermsCheckboxLabel =>
      'Ich akzeptiere die Allgemeinen Geschäftsbedingungen';

  @override
  String get registerTermsCheckboxDisabledHint =>
      'Bitte lesen Sie zuerst die Bedingungen.';

  @override
  String get registerTermsNotAcceptedError =>
      'Sie müssen die Bedingungen akzeptieren, um fortzufahren.';

  @override
  String get registerConfirmPasswordEmptyError =>
      'Bitte bestätigen Sie Ihr Passwort';

  @override
  String get registerConfirmPasswordMismatchError =>
      'Passwörter stimmen nicht überein';

  @override
  String get registerPhoneEmptyError =>
      'Bitte geben Sie Ihre Telefonnummer ein';

  @override
  String get registerPhoneInvalidError => 'Geben Sie 6 bis 15 Ziffern ein';

  @override
  String get profilePageTitle => 'Profil';

  @override
  String get anonymousSignInButton => 'Als Gast fortfahren';

  @override
  String get anonymousSignInDescription =>
      'Du kannst die App ohne Konto ausprobieren. Später kannst du in den Einstellungen upgraden.';

  @override
  String get anonymousSignInFailed =>
      'Gast-Sitzung konnte nicht gestartet werden. Bitte versuche es erneut.';

  @override
  String get anonymousUpgradeHint =>
      'Du nutzt derzeit eine Gast-Sitzung. Melde dich an, um deine Daten dauerhaft zu sichern.';

  @override
  String get authErrorInvalidEmail =>
      'Die E-Mail-Adresse scheint ungültig zu sein.';

  @override
  String get authErrorUserDisabled =>
      'Dieses Konto wurde deaktiviert. Bitte wende dich an den Support.';

  @override
  String get authErrorUserNotFound =>
      'Wir konnten kein Konto mit diesen Angaben finden.';

  @override
  String get authErrorWrongPassword =>
      'Das Passwort ist falsch. Bitte überprüfe es und versuche es erneut.';

  @override
  String get authErrorEmailInUse =>
      'Diese E-Mail ist bereits mit einem anderen Konto verknüpft.';

  @override
  String get authErrorOperationNotAllowed =>
      'Diese Anmeldemethode ist derzeit deaktiviert. Bitte wähle eine andere Option.';

  @override
  String get authErrorWeakPassword => 'Bitte wähle ein stärkeres Passwort.';

  @override
  String get authErrorRequiresRecentLogin =>
      'Bitte melde dich erneut an, um diesen Vorgang abzuschließen.';

  @override
  String get authErrorCredentialInUse =>
      'Diese Anmeldedaten sind bereits einem anderen Konto zugeordnet.';

  @override
  String get authErrorInvalidCredential =>
      'Die angegebenen Anmeldedaten sind ungültig oder abgelaufen.';

  @override
  String get authErrorGeneric =>
      'Die Anfrage konnte nicht abgeschlossen werden. Bitte versuche es erneut.';

  @override
  String chatHistoryDeleteConversationWarning(String title) {
    return '\"$title\" löschen?';
  }

  @override
  String get cancelButtonLabel => 'Abbrechen';

  @override
  String get deleteButtonLabel => 'Löschen';

  @override
  String get chatHistoryEmpty => 'Noch keine gespeicherten Unterhaltungen.';

  @override
  String chatHistoryConversationTitle(int index) {
    return 'Unterhaltung $index';
  }

  @override
  String chatHistoryUpdatedAt(String timestamp) {
    return 'Aktualisiert $timestamp';
  }

  @override
  String get chartPageTitle => 'Bitcoin-Preis (USD)';

  @override
  String get chartPageDescription =>
      'Schlusskurs der letzten 7 Tage (Quelle: CoinGecko)';

  @override
  String get chartPageError => 'Diagrammdaten konnten nicht geladen werden.';

  @override
  String get chartPageEmpty => 'Noch keine Diagrammdaten verfügbar.';

  @override
  String get chartZoomToggleLabel => 'Pinch-Zoom aktivieren';

  @override
  String get graphqlSampleTitle => 'GraphQL-Länder';

  @override
  String get graphqlSampleFilterLabel => 'Nach Kontinent filtern';

  @override
  String get graphqlSampleAllContinents => 'Alle Kontinente';

  @override
  String get graphqlSampleErrorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get graphqlSampleGenericError =>
      'Länder konnten derzeit nicht geladen werden.';

  @override
  String get graphqlSampleRetryButton => 'Erneut versuchen';

  @override
  String get graphqlSampleEmpty => 'Keine Länder entsprechen der Auswahl.';

  @override
  String get graphqlSampleCapitalLabel => 'Hauptstadt';

  @override
  String get graphqlSampleCurrencyLabel => 'Währung';

  @override
  String get graphqlSampleNetworkError =>
      'Netzwerkfehler. Bitte Verbindung prüfen und erneut versuchen.';

  @override
  String get graphqlSampleInvalidRequestError =>
      'Die Anfrage wurde abgelehnt. Bitte wähle einen anderen Filter.';

  @override
  String get graphqlSampleServerError =>
      'Der Dienst ist derzeit nicht verfügbar. Versuche es später erneut.';

  @override
  String get graphqlSampleDataError =>
      'Unerwartete Antwort empfangen. Bitte versuche es erneut.';

  @override
  String get exampleWebsocketButton => 'WebSocket-Demo öffnen';

  @override
  String get exampleGoogleMapsButton => 'Google-Maps-Demo öffnen';

  @override
  String exampleNativeBatteryLabel(int percent) {
    return 'Batteriestand: $percent%';
  }

  @override
  String get websocketDemoTitle => 'WebSocket-Demo';

  @override
  String get websocketDemoWebUnsupported =>
      'Die WebSocket-Demo ist in Web-Builds noch nicht verfügbar.';

  @override
  String get websocketReconnectTooltip => 'Neu verbinden';

  @override
  String get websocketEmptyState =>
      'Noch keine Nachrichten. Senden Sie eine Nachricht, um zu beginnen.';

  @override
  String get websocketMessageHint => 'Nachricht eingeben';

  @override
  String get websocketSendButton => 'Senden';

  @override
  String websocketStatusConnected(String endpoint) {
    return 'Verbunden mit $endpoint';
  }

  @override
  String websocketStatusConnecting(String endpoint) {
    return 'Verbinde mit $endpoint...';
  }

  @override
  String websocketErrorLabel(String error) {
    return 'WebSocket-Fehler: $error';
  }

  @override
  String get googleMapsPageTitle => 'Maps Demo';

  @override
  String get googleMapsPageGenericError =>
      'Kartendaten konnten nicht geladen werden.';

  @override
  String get googleMapsPageControlsHeading => 'Kartensteuerung';

  @override
  String get googleMapsPageMapTypeNormal => 'Standardkarte anzeigen';

  @override
  String get googleMapsPageMapTypeHybrid => 'Hybridkarte anzeigen';

  @override
  String get googleMapsPageTrafficToggle => 'Verkehr in Echtzeit anzeigen';

  @override
  String get googleMapsPageApiKeyHelp =>
      'Füge die Google-Maps-API-Schlüssel zu den nativen Projekten hinzu, um Live-Kacheln zu sehen.';

  @override
  String get googleMapsPageEmptyLocations => 'Noch keine Orte vorhanden.';

  @override
  String get googleMapsPageLocationsHeading => 'Ausgewählte Orte';

  @override
  String get googleMapsPageFocusButton => 'Fokussieren';

  @override
  String get googleMapsPageSelectedBadge => 'Ausgewählt';

  @override
  String get googleMapsPageMissingKeyTitle =>
      'Google-Maps-API-Schlüssel hinzufügen';

  @override
  String get googleMapsPageMissingKeyDescription =>
      'Hinterlege gültige Google-Maps-API-Schlüssel in den Plattformprojekten, um diese Demo zu verwenden.';

  @override
  String get googleMapsPageUnsupportedDescription =>
      'Die Google-Maps-Demo ist nur auf Android- und iOS-Builds verfügbar.';

  @override
  String get syncStatusOfflineTitle => 'Du bist offline';

  @override
  String syncStatusOfflineMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# Änderungen',
      one: '# Änderung',
      zero: 'deine Änderungen',
    );
    return 'Wir synchronisieren $_temp0, sobald du wieder online bist.';
  }

  @override
  String get syncStatusSyncingTitle => 'Änderungen werden synchronisiert';

  @override
  String syncStatusSyncingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: 'Synchronisiere # Änderungen…',
      one: 'Synchronisiere # Änderung…',
      zero: 'Aktualisiere letzte Änderungen.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusPendingTitle => 'Änderungen in Warteschlange';

  @override
  String syncStatusPendingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# Änderungen warten auf Synchronisierung.',
      one: '# Änderung wartet auf Synchronisierung.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusSyncNowButton => 'Jetzt synchronisieren';

  @override
  String counterLastSynced(Object timestamp) {
    return 'Zuletzt synchronisiert: $timestamp';
  }

  @override
  String counterChangeId(Object changeId) {
    return 'Änderungs-ID: $changeId';
  }

  @override
  String get syncQueueInspectorButton => 'Sync-Warteschlange anzeigen';

  @override
  String get syncQueueInspectorEmpty => 'Keine ausstehenden Vorgänge.';

  @override
  String get syncQueueInspectorTitle => 'Ausstehende Synchronisationen';

  @override
  String syncQueueInspectorOperation(String entity, int attempts) {
    return 'Eintrag: $entity, Versuche: $attempts';
  }

  @override
  String get exampleTodoListButton => 'Todo List Demo';

  @override
  String get exampleChatListButton => 'Chat List Demo';

  @override
  String get exampleSearchDemoButton => 'Search Demo';

  @override
  String get exampleProfileButton => 'Profile Demo';

  @override
  String get exampleRegisterButton => 'Register Demo';

  @override
  String get exampleLoggedOutButton => 'Logged Out Demo';

  @override
  String get exampleLibraryDemoButton => 'Library Demo';

  @override
  String get libraryDemoPageTitle => 'Library Demo';

  @override
  String get libraryDemoBrandName => 'Epoch';

  @override
  String get libraryDemoPanelTitle => 'Library';

  @override
  String get libraryDemoSearchHint => 'Search your library';

  @override
  String get libraryDemoCategoryScapes => 'Scapes';

  @override
  String get libraryDemoCategoryPacks => 'Packs';

  @override
  String get libraryDemoAssetsTitle => 'All Assets';

  @override
  String get libraryDemoAssetName => 'Asset Name';

  @override
  String get libraryDemoAssetTypeObject => 'Object';

  @override
  String get libraryDemoAssetTypeImage => 'Image';

  @override
  String get libraryDemoAssetTypeSound => 'Sound';

  @override
  String get libraryDemoAssetTypeFootage => 'Footage';

  @override
  String get libraryDemoAssetDuration => '00:00';

  @override
  String get libraryDemoFormatObj => 'OBJ';

  @override
  String get libraryDemoFormatJpg => 'JPG';

  @override
  String get libraryDemoFormatMp4 => 'MP4';

  @override
  String get libraryDemoFormatMp3 => 'MP3';

  @override
  String get libraryDemoBackButtonLabel => 'Back';

  @override
  String get libraryDemoFilterButtonLabel => 'Filter';

  @override
  String get todoListTitle => 'Todo List';

  @override
  String get todoListLoadError => 'Unable to load todos';

  @override
  String get todoListAddAction => 'Add todo';

  @override
  String get todoListSaveAction => 'Save';

  @override
  String get todoListCancelAction => 'Cancel';

  @override
  String get todoListDeleteAction => 'Delete';

  @override
  String get todoListEditAction => 'Bearbeiten';

  @override
  String get todoListCompleteAction => 'Abschließen';

  @override
  String get todoListUndoAction => 'Als aktiv markieren';

  @override
  String get todoListDeleteDialogTitle => 'Delete todo?';

  @override
  String todoListDeleteDialogMessage(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get todoListSearchHint => 'Todos suchen...';

  @override
  String get todoListDeleteUndone => 'Todo gelöscht';

  @override
  String get todoListSortAction => 'Sortieren';

  @override
  String get todoListSortDateDesc => 'Datum (neueste zuerst)';

  @override
  String get todoListSortDateAsc => 'Datum (älteste zuerst)';

  @override
  String get todoListSortTitleAsc => 'Titel (A bis Z)';

  @override
  String get todoListSortTitleDesc => 'Titel (Z bis A)';

  @override
  String get todoListSortManual => 'Manuell (zum Sortieren ziehen)';

  @override
  String get todoListSortPriorityDesc => 'Priorität (hoch bis niedrig)';

  @override
  String get todoListSortPriorityAsc => 'Priorität (niedrig bis hoch)';

  @override
  String get todoListSortDueDateAsc => 'Fälligkeitsdatum (frühestes zuerst)';

  @override
  String get todoListSortDueDateDesc => 'Fälligkeitsdatum (spätestes zuerst)';

  @override
  String get todoListPriorityNone => 'None';

  @override
  String get todoListPriorityLow => 'Low';

  @override
  String get todoListPriorityMedium => 'Medium';

  @override
  String get todoListPriorityHigh => 'High';

  @override
  String get todoListDueDateLabel => 'Due date';

  @override
  String get todoListNoDueDate => 'Kein Fälligkeitsdatum';

  @override
  String get todoListClearDueDate => 'Fälligkeitsdatum entfernen';

  @override
  String get todoListPriorityLabel => 'Priority';

  @override
  String get todoListSelectAll => 'Select all';

  @override
  String get todoListClearSelection => 'Clear selection';

  @override
  String get todoListBatchDelete => 'Delete selected';

  @override
  String get todoListBatchDeleteDialogTitle => 'Delete selected todos?';

  @override
  String todoListBatchDeleteDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count todos',
      one: '1 todo',
    );
    return 'Delete $_temp0? This cannot be undone.';
  }

  @override
  String get todoListBatchComplete => 'Complete selected';

  @override
  String get todoListBatchUncomplete => 'Uncomplete selected';

  @override
  String todoListItemsSelected(int count) {
    return '$count selected';
  }

  @override
  String get todoListAddDialogTitle => 'New todo';

  @override
  String get todoListEditDialogTitle => 'Edit todo';

  @override
  String get todoListTitlePlaceholder => 'Title';

  @override
  String get todoListDescriptionPlaceholder => 'Description (optional)';

  @override
  String get todoListEmptyTitle => 'No todos yet';

  @override
  String get todoListEmptyMessage => 'Add your first task to get started.';

  @override
  String get todoListFilterAll => 'All';

  @override
  String get todoListFilterActive => 'Active';

  @override
  String get todoListFilterCompleted => 'Completed';

  @override
  String get todoListClearCompletedAction => 'Clear completed';

  @override
  String get todoListClearCompletedDialogTitle => 'Clear completed todos?';

  @override
  String todoListClearCompletedDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed todos',
      one: '1 completed todo',
    );
    return 'Delete $_temp0? This cannot be undone.';
  }

  @override
  String get exampleScapesButton => 'Scapes Demo';

  @override
  String get exampleWalletconnectAuthButton => 'WalletConnect Auth (Demo)';

  @override
  String get scapesPageTitle => 'Library / Scapes';

  @override
  String get scapeNameLabel => 'Scape Name';

  @override
  String scapeMetadataFormat(String duration, int assetCount) {
    String _temp0 = intl.Intl.pluralLogic(
      assetCount,
      locale: localeName,
      other: '$assetCount ASSETS',
      one: '1 ASSET',
    );
    return '$duration • $_temp0';
  }

  @override
  String get scapeFavoriteAddTooltip => 'Add favorite';

  @override
  String get scapeFavoriteRemoveTooltip => 'Remove favorite';

  @override
  String get scapeMoreOptionsTooltip => 'More options';

  @override
  String get scapesGridViewTooltip => 'Grid view';

  @override
  String get scapesListViewTooltip => 'List view';

  @override
  String get genuiDemoPageTitle => 'GenUI Demo';

  @override
  String get genuiDemoHintText =>
      'Geben Sie eine Nachricht ein, um UI zu generieren...';

  @override
  String get genuiDemoSendButton => 'Senden';

  @override
  String get genuiDemoErrorTitle => 'Fehler';

  @override
  String get genuiDemoNoApiKey =>
      'GEMINI_API_KEY nicht konfiguriert. Bitte fügen Sie es zu secrets.json hinzu oder verwenden Sie --dart-define=GEMINI_API_KEY=...';

  @override
  String get walletconnectAuthTitle => 'Wallet verbinden';

  @override
  String get connectWalletButton => 'Wallet verbinden';

  @override
  String get walletAddress => 'Wallet-Adresse';

  @override
  String get linkToFirebase => 'Mit Konto verknüpfen';

  @override
  String get relinkToAccount => 'Erneut mit Konto verknüpfen';

  @override
  String get disconnectWallet => 'Trennen';

  @override
  String get walletConnected => 'Wallet verbunden';

  @override
  String get walletLinked => 'Wallet mit Konto verknüpft';

  @override
  String get walletConnectError => 'Wallet-Verbindung fehlgeschlagen';

  @override
  String get walletLinkError =>
      'Wallet konnte nicht mit Konto verknüpft werden';

  @override
  String get walletProfileSection => 'Profil';

  @override
  String get balanceOffChain => 'Saldo (Off-Chain)';

  @override
  String get balanceOnChain => 'Saldo (On-Chain)';

  @override
  String get rewards => 'Belohnungen';

  @override
  String get lastClaim => 'Letzte Auszahlung';

  @override
  String get lastClaimNever => 'Nie';

  @override
  String get nfts => 'NFTs';

  @override
  String nftsCount(int count) {
    return '$count NFT(s)';
  }

  @override
  String get playlearnTitle => 'Playlearn';

  @override
  String get playlearnTopicAnimals => 'Tiere';

  @override
  String get playlearnListen => 'Hören';

  @override
  String get playlearnTapToListen => 'Tippen zum Hören';

  @override
  String get playlearnBack => 'Zurück';

  @override
  String get openPlaylearnTooltip => 'Playlearn öffnen';
}
