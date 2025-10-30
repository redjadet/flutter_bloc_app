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
  String get openGoogleMapsTooltip => 'Open Google Maps demo';

  @override
  String get chatPageTitle => 'AI Chat';

  @override
  String get chatInputHint => 'Ask the assistant anything...';

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
  String get exampleWebsocketButton => 'Open WebSocket demo';

  @override
  String get exampleGoogleMapsButton => 'Open Google Maps demo';

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
  String get googleMapsPageTitle => 'Google Maps demo';

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
}
