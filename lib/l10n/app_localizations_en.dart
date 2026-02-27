// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get autoLabel => 'Auto';

  @override
  String get pausedLabel => 'Paused';

  @override
  String nextAutoDecrementIn(int s) {
    return 'Next auto-decrement in: ${s}s';
  }

  @override
  String get autoDecrementPaused => 'Auto-decrement paused !!!';

  @override
  String get lastChangedLabel => 'Last changed:';

  @override
  String get appTitle => 'Flutter Demo';

  @override
  String get homeTitle => 'Home Page';

  @override
  String get pushCountLabel => 'You have pushed the button this many times:';

  @override
  String get incrementTooltip => 'Increment';

  @override
  String get decrementTooltip => 'Decrement';

  @override
  String get loadErrorMessage => 'Failed to load saved counter';

  @override
  String get startAutoHint => 'Tap + to start auto-decrement';

  @override
  String get cannotGoBelowZero => 'Count cannot go below 0';

  @override
  String get openExampleTooltip => 'Open example page';

  @override
  String get openCalculatorTooltip => 'Open payment calculator';

  @override
  String get examplePageTitle => 'Example Page';

  @override
  String get examplePageDescription =>
      'This page demonstrates navigation with GoRouter.';

  @override
  String get exampleBackButtonLabel => 'Back to counter';

  @override
  String get exampleNativeInfoButton => 'Fetch native info';

  @override
  String get exampleNativeInfoTitle => 'Platform info';

  @override
  String get exampleNativeInfoError => 'Unable to fetch native platform info.';

  @override
  String get exampleNativeInfoDialogTitle => 'Platform details';

  @override
  String get exampleNativeInfoDialogPlatformLabel => 'Platform';

  @override
  String get exampleNativeInfoDialogVersionLabel => 'Version';

  @override
  String get exampleNativeInfoDialogManufacturerLabel => 'Manufacturer';

  @override
  String get exampleNativeInfoDialogModelLabel => 'Model';

  @override
  String get exampleNativeInfoDialogBatteryLabel => 'Battery level';

  @override
  String get exampleDialogCloseButton => 'Close';

  @override
  String get exampleRunIsolatesButton => 'Run isolate samples';

  @override
  String get exampleIsolateParallelPending => 'Running parallel tasks...';

  @override
  String exampleIsolateFibonacciLabel(int input, int value) {
    return 'Fibonacci($input) = $value';
  }

  @override
  String exampleIsolateParallelComplete(String values, int milliseconds) {
    return 'Parallel doubled values: $values (completed in $milliseconds ms)';
  }

  @override
  String get calculatorTitle => 'Payment calculator';

  @override
  String get calculatorSummaryHeader => 'Payment summary';

  @override
  String get calculatorResultLabel => 'Result';

  @override
  String get calculatorSubtotalLabel => 'Subtotal';

  @override
  String calculatorTaxLabel(String rate) {
    return 'Tax ($rate)';
  }

  @override
  String calculatorTipLabel(String rate) {
    return 'Tip ($rate)';
  }

  @override
  String get calculatorTotalLabel => 'Amount to collect';

  @override
  String get calculatorTaxPresetsLabel => 'Tax presets';

  @override
  String get calculatorCustomTaxLabel => 'Custom tax';

  @override
  String get calculatorCustomTaxDialogTitle => 'Custom tax';

  @override
  String get calculatorCustomTaxFieldLabel => 'Tax percentage';

  @override
  String get calculatorResetTax => 'Reset tax';

  @override
  String get calculatorTipRateLabel => 'Tip presets';

  @override
  String get calculatorCustomTipLabel => 'Custom tip';

  @override
  String get calculatorResetTip => 'Clear tip';

  @override
  String get calculatorCustomTipDialogTitle => 'Custom tip';

  @override
  String get calculatorCustomTipFieldLabel => 'Tip percentage';

  @override
  String get calculatorCancel => 'Cancel';

  @override
  String get calculatorApply => 'Apply';

  @override
  String get calculatorKeypadHeader => 'Keypad';

  @override
  String get calculatorClearLabel => 'Clear';

  @override
  String get calculatorBackspace => 'Backspace';

  @override
  String get calculatorPercentCommand => 'Percent';

  @override
  String get calculatorToggleSign => 'Toggle sign';

  @override
  String get calculatorDecimalPointLabel => 'Decimal point';

  @override
  String get calculatorErrorTitle => 'Error';

  @override
  String get calculatorErrorDivisionByZero => 'Cannot divide by zero';

  @override
  String get calculatorErrorInvalidResult => 'Result is not a valid number';

  @override
  String get calculatorErrorNonPositiveTotal =>
      'Total must be greater than zero';

  @override
  String get calculatorEquals => 'Charge total';

  @override
  String get calculatorPaymentTitle => 'Payment summary';

  @override
  String get calculatorNewCalculation => 'New calculation';

  @override
  String get settingsBiometricPrompt => 'Authenticate to open Settings';

  @override
  String get settingsBiometricFailed => 'Couldn\'t verify your identity.';

  @override
  String get openChartsTooltip => 'Open charts';

  @override
  String get openGraphqlTooltip => 'Explore GraphQL sample';

  @override
  String get openSettingsTooltip => 'Open settings';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get accountSectionTitle => 'Account';

  @override
  String accountSignedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get accountSignedOutLabel => 'Not signed in.';

  @override
  String get accountSignInButton => 'Sign in';

  @override
  String get accountManageButton => 'Manage account';

  @override
  String get accountGuestLabel => 'Using guest account';

  @override
  String get accountGuestDescription =>
      'You are signed in anonymously. Create an account to sync your data across devices.';

  @override
  String get accountUpgradeButton => 'Create or link account';

  @override
  String get themeSectionTitle => 'Appearance';

  @override
  String get themeModeSystem => 'System default';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageSystemDefault => 'Use device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get appInfoSectionTitle => 'App info';

  @override
  String get settingsRemoteConfigSectionTitle => 'Remote config';

  @override
  String get settingsRemoteConfigStatusIdle => 'Waiting for first fetch';

  @override
  String get settingsRemoteConfigStatusLoading => 'Loading latest values...';

  @override
  String get settingsRemoteConfigStatusLoaded => 'Latest values loaded';

  @override
  String get settingsRemoteConfigStatusError => 'Failed to load remote config';

  @override
  String get settingsRemoteConfigErrorLabel => 'Last error';

  @override
  String get settingsRemoteConfigFlagLabel => 'Awesome feature flag';

  @override
  String get settingsRemoteConfigFlagEnabled => 'Enabled';

  @override
  String get settingsRemoteConfigFlagDisabled => 'Disabled';

  @override
  String get settingsRemoteConfigTestValueLabel => 'Test value';

  @override
  String get settingsRemoteConfigTestValueEmpty => 'Not set';

  @override
  String get settingsRemoteConfigRetryButton => 'Retry fetch';

  @override
  String get settingsRemoteConfigClearCacheButton => 'Clear config cache';

  @override
  String get settingsSyncDiagnosticsTitle => 'Sync diagnostics';

  @override
  String get settingsSyncDiagnosticsEmpty => 'No sync runs recorded yet.';

  @override
  String settingsSyncLastRunLabel(String timestamp) {
    return 'Last run: $timestamp';
  }

  @override
  String settingsSyncOperationsLabel(int processed, int failed) {
    return 'Ops: $processed processed, $failed failed';
  }

  @override
  String settingsSyncPendingLabel(int count) {
    return 'Pending at start: $count';
  }

  @override
  String settingsSyncPrunedLabel(int count) {
    return 'Pruned: $count';
  }

  @override
  String settingsSyncDurationLabel(int ms) {
    return 'Duration: ${ms}ms';
  }

  @override
  String get settingsSyncHistoryTitle => 'Recent sync runs';

  @override
  String get settingsGraphqlCacheSectionTitle => 'GraphQL cache';

  @override
  String get settingsGraphqlCacheDescription =>
      'Clear the cached countries/continents used by the GraphQL demo. Fresh data will be fetched on next load.';

  @override
  String get settingsGraphqlCacheClearButton => 'Clear GraphQL cache';

  @override
  String get settingsGraphqlCacheClearedMessage => 'GraphQL cache cleared';

  @override
  String get settingsGraphqlCacheErrorMessage =>
      'Couldn\'t clear GraphQL cache';

  @override
  String get settingsProfileCacheSectionTitle => 'Profile cache';

  @override
  String get settingsProfileCacheDescription =>
      'Clear the locally cached profile snapshot used to render the profile screen offline.';

  @override
  String get settingsProfileCacheClearButton => 'Clear profile cache';

  @override
  String get settingsProfileCacheClearedMessage => 'Profile cache cleared';

  @override
  String get settingsProfileCacheErrorMessage =>
      'Couldn\'t clear profile cache';

  @override
  String get networkRetryingSnackBarMessage => 'Retrying…';

  @override
  String get appInfoVersionLabel => 'Version';

  @override
  String get appInfoBuildNumberLabel => 'Build number';

  @override
  String get appInfoLoadingLabel => 'Loading app info...';

  @override
  String get appInfoLoadErrorLabel => 'Failed to load app info.';

  @override
  String get appInfoRetryButtonLabel => 'Retry';

  @override
  String get openChatTooltip => 'Chat with AI';

  @override
  String get openGenuiDemoTooltip => 'GenUI Demo';

  @override
  String get openGoogleMapsTooltip => 'Open Google/Apple Maps demo';

  @override
  String get openWhiteboardTooltip => 'Open Whiteboard';

  @override
  String get openMarkdownEditorTooltip => 'Open Markdown Editor';

  @override
  String get openTodoTooltip => 'Open Todo List';

  @override
  String get openWalletconnectAuthTooltip => 'Connect Wallet';

  @override
  String get chatPageTitle => 'AI Chat';

  @override
  String get chatInputHint => 'Ask the assistant anything...';

  @override
  String get searchHint => 'Search...';

  @override
  String get retryButtonLabel => 'TRY AGAIN';

  @override
  String get featureLoadError =>
      'Unable to load this feature. Please try again.';

  @override
  String get chatSendButton => 'Send message';

  @override
  String get chatEmptyState => 'Start the conversation by sending a message.';

  @override
  String get chatModelLabel => 'Model';

  @override
  String get chatModelGptOss20b => 'GPT-OSS-20B';

  @override
  String get chatModelGptOss120b => 'GPT-OSS-120B';

  @override
  String get chatHistoryShowTooltip => 'Show history';

  @override
  String get chatHistoryHideTooltip => 'Hide history';

  @override
  String get chatHistoryPanelTitle => 'Conversation history';

  @override
  String get chatHistoryStartNew => 'Start new conversation';

  @override
  String get chatHistoryClearAll => 'Delete history';

  @override
  String get chatHistoryDeleteConversation => 'Delete conversation';

  @override
  String get chatHistoryClearAllWarning =>
      'This will permanently delete all stored conversations.';

  @override
  String get chatMessageStatusPending => 'Pending sync';

  @override
  String get chatMessageStatusSyncing => 'Syncing…';

  @override
  String get chatMessageStatusOffline => 'Offline — will send when connected';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerFullNameLabel => 'Full name';

  @override
  String get registerFullNameHint => 'Jane Doe';

  @override
  String get registerEmailLabel => 'Email address';

  @override
  String get registerEmailHint => 'jane.doe@example.com';

  @override
  String get registerPhoneLabel => 'Phone number';

  @override
  String get registerPhoneHint => '5551234567';

  @override
  String get registerCountryPickerTitle => 'Choose your country code';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => 'Create password';

  @override
  String get registerConfirmPasswordLabel => 'Confirm password';

  @override
  String get registerConfirmPasswordHint => 'Re-enter password';

  @override
  String get registerSubmitButton => 'Next';

  @override
  String get registerDialogTitle => 'Registration complete';

  @override
  String registerDialogMessage(String name) {
    return 'Welcome aboard, $name!';
  }

  @override
  String get registerDialogOk => 'OK';

  @override
  String get registerFullNameEmptyError => 'Please enter your full name';

  @override
  String get registerFullNameTooShortError =>
      'Name must be at least 2 characters';

  @override
  String get registerEmailEmptyError => 'Please enter your email';

  @override
  String get registerEmailInvalidError => 'Please enter a valid email';

  @override
  String get registerPasswordEmptyError => 'Please enter your password';

  @override
  String get registerPasswordTooShortError =>
      'Password must be at least 8 characters';

  @override
  String get registerPasswordLettersAndNumbersError =>
      'Use letters and numbers';

  @override
  String get registerPasswordWhitespaceError => 'Password can’t contain spaces';

  @override
  String get registerTermsCheckboxPrefix => 'I have read and agree to the ';

  @override
  String get registerTermsCheckboxSuffix => '.';

  @override
  String get registerTermsLinkLabel => 'Terms & Conditions';

  @override
  String get registerTermsError => 'Please accept the terms to continue';

  @override
  String get registerTermsDialogTitle => 'Terms & Conditions';

  @override
  String get registerTermsDialogBody =>
      'By creating an account, you agree to use this app responsibly, respect other users, and comply with all applicable laws. You consent to our privacy policy, acknowledge that service availability may change, and accept that your account may be suspended for misuse or violations of these terms.';

  @override
  String get registerTermsAcceptButton => 'Accept';

  @override
  String get registerTermsRejectButton => 'Cancel';

  @override
  String get registerTermsPrompt =>
      'Please review and accept the terms before continuing.';

  @override
  String get registerTermsButtonLabel => 'Read terms & conditions';

  @override
  String get registerTermsSheetTitle => 'Terms & Conditions';

  @override
  String get registerTermsSheetBody =>
      'These terms outline the acceptable use of this demo application. By continuing, you agree to handle your account responsibly, protect your credentials, and comply with any applicable laws. The content provided is illustrative only and may change without notice. If you do not agree to these terms, please discontinue the registration process.';

  @override
  String get registerTermsDialogAcknowledge => 'I have read the terms';

  @override
  String get registerTermsCheckboxLabel => 'I accept the Terms & Conditions';

  @override
  String get registerTermsCheckboxDisabledHint =>
      'Read the terms before accepting them.';

  @override
  String get registerTermsNotAcceptedError =>
      'You must accept the terms to continue.';

  @override
  String get registerConfirmPasswordEmptyError =>
      'Please confirm your password';

  @override
  String get registerConfirmPasswordMismatchError => 'Passwords do not match';

  @override
  String get registerPhoneEmptyError => 'Please enter your phone number';

  @override
  String get registerPhoneInvalidError => 'Enter 6-15 digits';

  @override
  String get profilePageTitle => 'Profile';

  @override
  String get anonymousSignInButton => 'Continue as guest';

  @override
  String get anonymousSignInDescription =>
      'You can explore the app without creating an account. You can upgrade later from Settings.';

  @override
  String get anonymousSignInFailed =>
      'Couldn\'t start guest session. Please try again.';

  @override
  String get anonymousUpgradeHint =>
      'You\'re currently using a guest session. Sign in to keep your data across installs and devices.';

  @override
  String get authErrorInvalidEmail =>
      'The email address appears to be malformed.';

  @override
  String get authErrorUserDisabled =>
      'This account has been disabled. Contact support for help.';

  @override
  String get authErrorUserNotFound =>
      'We couldn\'t find an account with those details.';

  @override
  String get authErrorWrongPassword =>
      'The password is incorrect. Check it and try again.';

  @override
  String get authErrorEmailInUse =>
      'That email is already linked to another account.';

  @override
  String get authErrorOperationNotAllowed =>
      'This sign-in method is currently disabled. Please try a different option.';

  @override
  String get authErrorWeakPassword =>
      'Choose a stronger password before continuing.';

  @override
  String get authErrorRequiresRecentLogin =>
      'Please sign in again to complete this action.';

  @override
  String get authErrorCredentialInUse =>
      'Those credentials are already associated with another account.';

  @override
  String get authErrorInvalidCredential =>
      'The provided credentials are invalid or expired.';

  @override
  String get authErrorGeneric =>
      'We couldn\'t complete the request. Please try again.';

  @override
  String get authErrorNetworkRequestFailed =>
      'Check your connection and try again.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Please wait before trying again.';

  @override
  String chatHistoryDeleteConversationWarning(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get deleteButtonLabel => 'Delete';

  @override
  String get chatHistoryEmpty => 'No past conversations yet.';

  @override
  String chatHistoryConversationTitle(int index) {
    return 'Conversation $index';
  }

  @override
  String chatHistoryUpdatedAt(String timestamp) {
    return 'Updated $timestamp';
  }

  @override
  String get chartPageTitle => 'Bitcoin Price (USD)';

  @override
  String get chartPageDescription =>
      'Closing price over the past 7 days (powered by CoinGecko)';

  @override
  String get chartPageError => 'Unable to load chart data.';

  @override
  String get chartPageEmpty => 'No chart data available yet.';

  @override
  String get chartZoomToggleLabel => 'Enable pinch zoom';

  @override
  String get graphqlSampleTitle => 'GraphQL Countries';

  @override
  String get graphqlSampleFilterLabel => 'Filter by continent';

  @override
  String get graphqlSampleAllContinents => 'All continents';

  @override
  String get graphqlSampleErrorTitle => 'Something went wrong';

  @override
  String get graphqlSampleGenericError =>
      'We couldn\'t load countries right now.';

  @override
  String get graphqlSampleRetryButton => 'Try again';

  @override
  String get graphqlSampleEmpty => 'No countries matched the selected filters.';

  @override
  String get graphqlSampleCapitalLabel => 'Capital';

  @override
  String get graphqlSampleCurrencyLabel => 'Currency';

  @override
  String get graphqlSampleNetworkError =>
      'Network error. Check your connection and try again.';

  @override
  String get graphqlSampleInvalidRequestError =>
      'The request was rejected. Try a different filter.';

  @override
  String get graphqlSampleServerError =>
      'The service is unavailable right now. Please try again later.';

  @override
  String get graphqlSampleDataError =>
      'We received an unexpected response. Please try again.';

  @override
  String get graphqlSampleDataSourceCache => 'Cache';

  @override
  String get graphqlSampleDataSourceRemote => 'Remote';

  @override
  String get exampleWebsocketButton => 'Open WebSocket demo';

  @override
  String get exampleGoogleMapsButton => 'Open Google/Apple Maps demo';

  @override
  String exampleNativeBatteryLabel(int percent) {
    return 'Battery level: $percent%';
  }

  @override
  String get websocketDemoTitle => 'WebSocket demo';

  @override
  String get websocketDemoWebUnsupported =>
      'The WebSocket demo isn\'t available on web builds yet.';

  @override
  String get websocketReconnectTooltip => 'Reconnect';

  @override
  String get websocketEmptyState =>
      'No messages yet. Send a message to get started.';

  @override
  String get websocketMessageHint => 'Type a message';

  @override
  String get websocketSendButton => 'Send';

  @override
  String websocketStatusConnected(String endpoint) {
    return 'Connected to $endpoint';
  }

  @override
  String websocketStatusConnecting(String endpoint) {
    return 'Connecting to $endpoint...';
  }

  @override
  String websocketErrorLabel(String error) {
    return 'WebSocket error: $error';
  }

  @override
  String get googleMapsPageTitle => 'Maps demo';

  @override
  String get googleMapsPageGenericError =>
      'We couldn\'t load map data right now.';

  @override
  String get googleMapsPageControlsHeading => 'Map controls';

  @override
  String get googleMapsPageMapTypeNormal => 'Show standard map';

  @override
  String get googleMapsPageMapTypeHybrid => 'Show hybrid map';

  @override
  String get googleMapsPageTrafficToggle => 'Show real-time traffic';

  @override
  String get googleMapsPageApiKeyHelp =>
      'Add your Google Maps API keys to the native projects to see live tiles.';

  @override
  String get googleMapsPageEmptyLocations => 'No locations to display yet.';

  @override
  String get googleMapsPageLocationsHeading => 'Featured locations';

  @override
  String get googleMapsPageFocusButton => 'Focus';

  @override
  String get googleMapsPageSelectedBadge => 'Selected';

  @override
  String get googleMapsPageMissingKeyTitle => 'Add a Google Maps API key';

  @override
  String get googleMapsPageMissingKeyDescription =>
      'Update the platform projects with valid Google Maps API keys to use this demo.';

  @override
  String get googleMapsPageUnsupportedDescription =>
      'The Google Maps demo is only available on Android and iOS builds.';

  @override
  String get syncStatusOfflineTitle => 'You\'re offline';

  @override
  String syncStatusOfflineMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# changes',
      one: '# change',
      zero: 'your changes',
    );
    return 'We will sync $_temp0 once you\'re back online.';
  }

  @override
  String get syncStatusSyncingTitle => 'Syncing changes';

  @override
  String syncStatusSyncingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: 'Syncing # changes…',
      one: 'Syncing # change…',
      zero: 'Wrapping up your latest updates.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusPendingTitle => 'Changes queued';

  @override
  String syncStatusPendingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# changes waiting to sync.',
      one: '# change waiting to sync.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusSyncNowButton => 'Sync now';

  @override
  String counterLastSynced(Object timestamp) {
    return 'Last synced: $timestamp';
  }

  @override
  String counterChangeId(Object changeId) {
    return 'Change ID: $changeId';
  }

  @override
  String get syncQueueInspectorButton => 'View sync queue';

  @override
  String get syncQueueInspectorEmpty => 'No pending operations.';

  @override
  String get syncQueueInspectorTitle => 'Pending Sync Operations';

  @override
  String syncQueueInspectorOperation(String entity, int attempts) {
    return 'Entity: $entity, attempts: $attempts';
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
  String get todoListEditAction => 'Edit';

  @override
  String get todoListCompleteAction => 'Complete';

  @override
  String get todoListUndoAction => 'Mark active';

  @override
  String get todoListDeleteDialogTitle => 'Delete todo?';

  @override
  String todoListDeleteDialogMessage(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get todoListSearchHint => 'Search todos...';

  @override
  String get todoListDeleteUndone => 'Todo deleted';

  @override
  String get todoListSortAction => 'Sort';

  @override
  String get todoListSortDateDesc => 'Date (newest first)';

  @override
  String get todoListSortDateAsc => 'Date (oldest first)';

  @override
  String get todoListSortTitleAsc => 'Title (A-Z)';

  @override
  String get todoListSortTitleDesc => 'Title (Z-A)';

  @override
  String get todoListSortManual => 'Manual (drag to reorder)';

  @override
  String get todoListSortPriorityDesc => 'Priority (high to low)';

  @override
  String get todoListSortPriorityAsc => 'Priority (low to high)';

  @override
  String get todoListSortDueDateAsc => 'Due date (earliest first)';

  @override
  String get todoListSortDueDateDesc => 'Due date (latest first)';

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
  String get todoListNoDueDate => 'No due date';

  @override
  String get todoListClearDueDate => 'Clear due date';

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
  String get exampleCameraGalleryButton => 'Camera & Gallery Demo';

  @override
  String get cameraGalleryPageTitle => 'Camera & Gallery';

  @override
  String get cameraGalleryTakePhoto => 'Take photo';

  @override
  String get cameraGalleryPickFromGallery => 'Pick from gallery';

  @override
  String get cameraGalleryNoImage => 'No image selected';

  @override
  String get cameraGalleryPermissionDenied =>
      'Camera or photo library access was denied.';

  @override
  String get cameraGalleryCancelled => 'Selection was cancelled.';

  @override
  String get cameraGalleryGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get cameraGalleryCameraUnavailable =>
      'Camera is not available. Use a real device or pick from gallery.';

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
  String get noWalletConnected =>
      'No wallet connected. Please connect a wallet first.';

  @override
  String get noWalletLinked => 'No wallet linked. Connect and link first.';

  @override
  String get couldNotPlayAudio => 'Could not play audio';

  @override
  String get scapesErrorOccurred => 'An error occurred';

  @override
  String get noScapesAvailable => 'No scapes available';

  @override
  String get genuiDemoPageTitle => 'GenUI Demo';

  @override
  String get genuiDemoHintText => 'Enter a message to generate UI...';

  @override
  String get genuiDemoSendButton => 'Send';

  @override
  String get genuiDemoErrorTitle => 'Error';

  @override
  String get genuiDemoNoApiKey =>
      'GEMINI_API_KEY not configured. Please add it to secrets.json or use --dart-define=GEMINI_API_KEY=...';

  @override
  String get walletconnectAuthTitle => 'Connect Wallet';

  @override
  String get connectWalletButton => 'Connect Wallet';

  @override
  String get walletAddress => 'Wallet Address';

  @override
  String get linkToFirebase => 'Link to Account';

  @override
  String get relinkToAccount => 'Re-link to Account';

  @override
  String get disconnectWallet => 'Disconnect';

  @override
  String get walletConnected => 'Wallet Connected';

  @override
  String get walletLinked => 'Wallet Linked to Account';

  @override
  String get walletConnectError => 'Failed to connect wallet';

  @override
  String get walletLinkError => 'Failed to link wallet to account';

  @override
  String get walletProfileSection => 'Profile';

  @override
  String get balanceOffChain => 'Balance (off-chain)';

  @override
  String get balanceOnChain => 'Balance (on-chain)';

  @override
  String get rewards => 'Rewards';

  @override
  String get lastClaim => 'Last claim';

  @override
  String get lastClaimNever => 'Never';

  @override
  String get nfts => 'NFTs';

  @override
  String nftsCount(int count) {
    return '$count NFT(s)';
  }

  @override
  String get playlearnTitle => 'Playlearn';

  @override
  String get playlearnTopicAnimals => 'Animals';

  @override
  String get playlearnListen => 'Listen';

  @override
  String get playlearnTapToListen => 'Tap to hear';

  @override
  String get playlearnBack => 'Back';

  @override
  String get openPlaylearnTooltip => 'Open Playlearn';

  @override
  String get whiteboardChoosePenColor => 'Choose pen color';

  @override
  String get whiteboardPickColor => 'Pick a color';

  @override
  String get whiteboardUndo => 'Undo';

  @override
  String get whiteboardUndoLastStroke => 'Undo last stroke';

  @override
  String get whiteboardRedo => 'Redo';

  @override
  String get whiteboardRedoLastStroke => 'Redo last undone stroke';

  @override
  String get whiteboardClear => 'Clear';

  @override
  String get whiteboardClearAllStrokes => 'Clear all strokes';

  @override
  String get whiteboardPenColor => 'Pen color';

  @override
  String get whiteboardStrokeWidth => 'Stroke width';

  @override
  String get errorUnknown => 'An unknown error occurred';

  @override
  String get errorNetwork =>
      'Network connection error. Please check your internet connection.';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get errorUnauthorized =>
      'Authentication required. Please sign in again.';

  @override
  String get errorForbidden =>
      'Access denied. You don\'t have permission for this action.';

  @override
  String get errorNotFound => 'The requested resource was not found.';

  @override
  String get errorServer => 'Server error. Please try again later.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorClient =>
      'Client error. Please check your request and try again.';

  @override
  String get errorTooManyRequests =>
      'Too many requests. Please wait before trying again.';

  @override
  String get errorServiceUnavailable =>
      'Service temporarily unavailable. Please try again in a minute.';
}
