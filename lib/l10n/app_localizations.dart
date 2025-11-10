import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('tr'),
  ];

  /// Label for choosing automatic behaviour, such as using the system theme
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoLabel;

  /// Label displayed when an automatic process is temporarily stopped
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedLabel;

  /// Countdown message that shows how many seconds remain before the counter auto-decrements
  ///
  /// In en, this message translates to:
  /// **'Next auto-decrement in: {s}s'**
  String nextAutoDecrementIn(int s);

  /// Warning text shown when the automatic decrement routine is paused
  ///
  /// In en, this message translates to:
  /// **'Auto-decrement paused !!!'**
  String get autoDecrementPaused;

  /// Caption shown before the timestamp of the last counter update
  ///
  /// In en, this message translates to:
  /// **'Last changed:'**
  String get lastChangedLabel;

  /// Application title shown on the launcher and app switcher
  ///
  /// In en, this message translates to:
  /// **'Flutter Demo'**
  String get appTitle;

  /// Title for the home screen in the demo application
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get homeTitle;

  /// Label preceding the current count value
  ///
  /// In en, this message translates to:
  /// **'You have pushed the button this many times:'**
  String get pushCountLabel;

  /// Tooltip for the button that increases the counter
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get incrementTooltip;

  /// Tooltip for the button that decreases the counter
  ///
  /// In en, this message translates to:
  /// **'Decrement'**
  String get decrementTooltip;

  /// Error message shown when counter data cannot be loaded from storage
  ///
  /// In en, this message translates to:
  /// **'Failed to load saved counter'**
  String get loadErrorMessage;

  /// Hint explaining how to start the automatic decrement feature
  ///
  /// In en, this message translates to:
  /// **'Tap + to start auto-decrement'**
  String get startAutoHint;

  /// Error message displayed when the user tries to decrement past zero
  ///
  /// In en, this message translates to:
  /// **'Count cannot go below 0'**
  String get cannotGoBelowZero;

  /// Tooltip for navigating to the example feature page
  ///
  /// In en, this message translates to:
  /// **'Open example page'**
  String get openExampleTooltip;

  /// Tooltip for navigating to the payment calculator page
  ///
  /// In en, this message translates to:
  /// **'Open payment calculator'**
  String get openCalculatorTooltip;

  /// Title of the example feature page
  ///
  /// In en, this message translates to:
  /// **'Example Page'**
  String get examplePageTitle;

  /// Description shown on the example page summarising its purpose
  ///
  /// In en, this message translates to:
  /// **'This page demonstrates navigation with GoRouter.'**
  String get examplePageDescription;

  /// Label for the button that returns from the example page to the counter
  ///
  /// In en, this message translates to:
  /// **'Back to counter'**
  String get exampleBackButtonLabel;

  /// Button label that triggers fetching platform information via MethodChannel
  ///
  /// In en, this message translates to:
  /// **'Fetch native info'**
  String get exampleNativeInfoButton;

  /// Title displayed above the platform information section
  ///
  /// In en, this message translates to:
  /// **'Platform info'**
  String get exampleNativeInfoTitle;

  /// Error message shown when fetching native platform information fails
  ///
  /// In en, this message translates to:
  /// **'Unable to fetch native platform info.'**
  String get exampleNativeInfoError;

  /// Button label to execute isolate demo functions
  ///
  /// In en, this message translates to:
  /// **'Run isolate samples'**
  String get exampleRunIsolatesButton;

  /// Status text shown while isolate tasks are in progress
  ///
  /// In en, this message translates to:
  /// **'Running parallel tasks...'**
  String get exampleIsolateParallelPending;

  /// Displays the fibonacci result returned from an isolate
  ///
  /// In en, this message translates to:
  /// **'Fibonacci({input}) = {value}'**
  String exampleIsolateFibonacciLabel(int input, int value);

  /// Shows the doubled list and elapsed time of the isolate demo
  ///
  /// In en, this message translates to:
  /// **'Parallel doubled values: {values} (completed in {milliseconds} ms)'**
  String exampleIsolateParallelComplete(String values, int milliseconds);

  /// Title for the payment calculator screen
  ///
  /// In en, this message translates to:
  /// **'Payment calculator'**
  String get calculatorTitle;

  /// Heading for the payment summary card
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get calculatorSummaryHeader;

  /// Label for the committed calculation result
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get calculatorResultLabel;

  /// Label for the subtotal amount
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get calculatorSubtotalLabel;

  /// Label for the tax amount row
  ///
  /// In en, this message translates to:
  /// **'Tax ({rate})'**
  String calculatorTaxLabel(String rate);

  /// Label for the tip amount row
  ///
  /// In en, this message translates to:
  /// **'Tip ({rate})'**
  String calculatorTipLabel(String rate);

  /// Label for the final total amount
  ///
  /// In en, this message translates to:
  /// **'Amount to collect'**
  String get calculatorTotalLabel;

  /// Caption for the tax preset chips
  ///
  /// In en, this message translates to:
  /// **'Tax presets'**
  String get calculatorTaxPresetsLabel;

  /// Label for opening the custom tax dialog
  ///
  /// In en, this message translates to:
  /// **'Custom tax'**
  String get calculatorCustomTaxLabel;

  /// Dialog title asking for a custom tax percentage
  ///
  /// In en, this message translates to:
  /// **'Custom tax'**
  String get calculatorCustomTaxDialogTitle;

  /// Label for the custom tax text field
  ///
  /// In en, this message translates to:
  /// **'Tax percentage'**
  String get calculatorCustomTaxFieldLabel;

  /// Action label for clearing the configured tax
  ///
  /// In en, this message translates to:
  /// **'Reset tax'**
  String get calculatorResetTax;

  /// Caption for the tip preset chips
  ///
  /// In en, this message translates to:
  /// **'Tip presets'**
  String get calculatorTipRateLabel;

  /// Label for opening the custom tip dialog
  ///
  /// In en, this message translates to:
  /// **'Custom tip'**
  String get calculatorCustomTipLabel;

  /// Action label for clearing the selected tip
  ///
  /// In en, this message translates to:
  /// **'Clear tip'**
  String get calculatorResetTip;

  /// Dialog title asking for a custom tip percentage
  ///
  /// In en, this message translates to:
  /// **'Custom tip'**
  String get calculatorCustomTipDialogTitle;

  /// Label for the text field requesting a custom tip
  ///
  /// In en, this message translates to:
  /// **'Tip percentage'**
  String get calculatorCustomTipFieldLabel;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get calculatorCancel;

  /// Label for applying a custom configuration
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get calculatorApply;

  /// Heading for the calculator keypad card
  ///
  /// In en, this message translates to:
  /// **'Keypad'**
  String get calculatorKeypadHeader;

  /// Button label that clears the calculator state
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get calculatorClearLabel;

  /// Button label that removes the last character
  ///
  /// In en, this message translates to:
  /// **'Backspace'**
  String get calculatorBackspace;

  /// Button label that applies the percentage operation
  ///
  /// In en, this message translates to:
  /// **'Percent'**
  String get calculatorPercentCommand;

  /// Button label that toggles the sign of the current value
  ///
  /// In en, this message translates to:
  /// **'Toggle sign'**
  String get calculatorToggleSign;

  /// Button label that inserts a decimal separator
  ///
  /// In en, this message translates to:
  /// **'Decimal point'**
  String get calculatorDecimalPointLabel;

  /// Title displayed when the calculator encounters an error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get calculatorErrorTitle;

  /// Error message shown when attempting to divide by zero
  ///
  /// In en, this message translates to:
  /// **'Cannot divide by zero'**
  String get calculatorErrorDivisionByZero;

  /// Error message shown when an operation results in NaN or infinity
  ///
  /// In en, this message translates to:
  /// **'Result is not a valid number'**
  String get calculatorErrorInvalidResult;

  /// Error message shown when attempting to settle a payment with zero or negative amount
  ///
  /// In en, this message translates to:
  /// **'Total must be greater than zero'**
  String get calculatorErrorNonPositiveTotal;

  /// Label for the button finalising the calculation
  ///
  /// In en, this message translates to:
  /// **'Charge total'**
  String get calculatorEquals;

  /// Title for the payment breakdown screen
  ///
  /// In en, this message translates to:
  /// **'Payment summary'**
  String get calculatorPaymentTitle;

  /// Button label to return to the calculator
  ///
  /// In en, this message translates to:
  /// **'New calculation'**
  String get calculatorNewCalculation;

  /// Biometric prompt displayed before navigating to settings
  ///
  /// In en, this message translates to:
  /// **'Authenticate to open Settings'**
  String get settingsBiometricPrompt;

  /// Shown when biometric authentication fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify your identity.'**
  String get settingsBiometricFailed;

  /// Tooltip for the action that opens the charts feature
  ///
  /// In en, this message translates to:
  /// **'Open charts'**
  String get openChartsTooltip;

  /// Tooltip for navigating to the GraphQL demo page
  ///
  /// In en, this message translates to:
  /// **'Explore GraphQL sample'**
  String get openGraphqlTooltip;

  /// Tooltip for navigating to the settings page
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettingsTooltip;

  /// Title for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsPageTitle;

  /// Heading for the account and authentication section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSectionTitle;

  /// Label showing the current authenticated user
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String accountSignedInAs(String name);

  /// Label shown when the user has not authenticated
  ///
  /// In en, this message translates to:
  /// **'Not signed in.'**
  String get accountSignedOutLabel;

  /// Button label that navigates to the sign-in flow
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get accountSignInButton;

  /// Button label that opens the profile management page
  ///
  /// In en, this message translates to:
  /// **'Manage account'**
  String get accountManageButton;

  /// Label shown when the current user is anonymous
  ///
  /// In en, this message translates to:
  /// **'Using guest account'**
  String get accountGuestLabel;

  /// Helper text encouraging guest users to upgrade
  ///
  /// In en, this message translates to:
  /// **'You are signed in anonymously. Create an account to sync your data across devices.'**
  String get accountGuestDescription;

  /// Button label inviting anonymous users to upgrade
  ///
  /// In en, this message translates to:
  /// **'Create or link account'**
  String get accountUpgradeButton;

  /// Heading for the appearance/theme selection section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeSectionTitle;

  /// Option label for matching the system theme
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeModeSystem;

  /// Option label for forcing light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Option label for forcing dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// Heading for the language selection section
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSectionTitle;

  /// Option label that follows the device language setting
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get languageSystemDefault;

  /// Language option for English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option for Turkish
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// Language option for German
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// Language option for French
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Language option for Spanish
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Heading for the section that displays application metadata
  ///
  /// In en, this message translates to:
  /// **'App info'**
  String get appInfoSectionTitle;

  /// Label shown before the application version string
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appInfoVersionLabel;

  /// Label shown before the build number string
  ///
  /// In en, this message translates to:
  /// **'Build number'**
  String get appInfoBuildNumberLabel;

  /// Status text shown while the app info is loading
  ///
  /// In en, this message translates to:
  /// **'Loading app info...'**
  String get appInfoLoadingLabel;

  /// Error message shown when app info fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load app info.'**
  String get appInfoLoadErrorLabel;

  /// Button label to retry loading the app info
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get appInfoRetryButtonLabel;

  /// Tooltip for navigating to the AI chat feature
  ///
  /// In en, this message translates to:
  /// **'Chat with AI'**
  String get openChatTooltip;

  /// Tooltip for navigating to the Google/Apple Maps sample page
  ///
  /// In en, this message translates to:
  /// **'Open Google/Apple Maps demo'**
  String get openGoogleMapsTooltip;

  /// Title for the AI chat page
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get chatPageTitle;

  /// Placeholder text shown in the chat input field
  ///
  /// In en, this message translates to:
  /// **'Ask the assistant anything...'**
  String get chatInputHint;

  /// Tooltip and accessibility label for the button that sends a chat message
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chatSendButton;

  /// Empty-state message displayed before any chat messages exist
  ///
  /// In en, this message translates to:
  /// **'Start the conversation by sending a message.'**
  String get chatEmptyState;

  /// Label shown before the chat model dropdown
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get chatModelLabel;

  /// Display name for the GPT-OSS-20B chat model
  ///
  /// In en, this message translates to:
  /// **'GPT-OSS-20B'**
  String get chatModelGptOss20b;

  /// Display name for the GPT-OSS-120B chat model
  ///
  /// In en, this message translates to:
  /// **'GPT-OSS-120B'**
  String get chatModelGptOss120b;

  /// Tooltip for the action that opens the chat history
  ///
  /// In en, this message translates to:
  /// **'Show history'**
  String get chatHistoryShowTooltip;

  /// Tooltip for the action that closes the chat history
  ///
  /// In en, this message translates to:
  /// **'Hide history'**
  String get chatHistoryHideTooltip;

  /// Heading for the chat history panel
  ///
  /// In en, this message translates to:
  /// **'Conversation history'**
  String get chatHistoryPanelTitle;

  /// Button label for creating a new chat conversation
  ///
  /// In en, this message translates to:
  /// **'Start new conversation'**
  String get chatHistoryStartNew;

  /// Button label for clearing all stored chat conversations
  ///
  /// In en, this message translates to:
  /// **'Delete history'**
  String get chatHistoryClearAll;

  /// Tooltip for removing a single conversation from history
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get chatHistoryDeleteConversation;

  /// Warning message shown before clearing all chat history
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all stored conversations.'**
  String get chatHistoryClearAllWarning;

  /// Title for the account profile management page
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profilePageTitle;

  /// Button label for anonymous sign-in
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get anonymousSignInButton;

  /// Helper text explaining anonymous sign-in
  ///
  /// In en, this message translates to:
  /// **'You can explore the app without creating an account. You can upgrade later from Settings.'**
  String get anonymousSignInDescription;

  /// Snackbar message shown if anonymous sign-in fails
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start guest session. Please try again.'**
  String get anonymousSignInFailed;

  /// Informational text for anonymous users upgrading
  ///
  /// In en, this message translates to:
  /// **'You\'re currently using a guest session. Sign in to keep your data across installs and devices.'**
  String get anonymousUpgradeHint;

  /// Error shown when the email is invalid
  ///
  /// In en, this message translates to:
  /// **'The email address appears to be malformed.'**
  String get authErrorInvalidEmail;

  /// Error when the Firebase user is disabled
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Contact support for help.'**
  String get authErrorUserDisabled;

  /// Error when the user does not exist
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find an account with those details.'**
  String get authErrorUserNotFound;

  /// Error when password is wrong
  ///
  /// In en, this message translates to:
  /// **'The password is incorrect. Check it and try again.'**
  String get authErrorWrongPassword;

  /// Error when email already in use
  ///
  /// In en, this message translates to:
  /// **'That email is already linked to another account.'**
  String get authErrorEmailInUse;

  /// Error when provider is not enabled
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is currently disabled. Please try a different option.'**
  String get authErrorOperationNotAllowed;

  /// Error for weak password
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password before continuing.'**
  String get authErrorWeakPassword;

  /// Error when recent login is required
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to complete this action.'**
  String get authErrorRequiresRecentLogin;

  /// Error when credential already in use
  ///
  /// In en, this message translates to:
  /// **'Those credentials are already associated with another account.'**
  String get authErrorCredentialInUse;

  /// Error when credential invalid
  ///
  /// In en, this message translates to:
  /// **'The provided credentials are invalid or expired.'**
  String get authErrorInvalidCredential;

  /// Fallback error message for authentication
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t complete the request. Please try again.'**
  String get authErrorGeneric;

  /// Warning displayed before deleting a specific conversation
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String chatHistoryDeleteConversationWarning(String title);

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// Generic delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButtonLabel;

  /// Message shown when no stored chat history is available
  ///
  /// In en, this message translates to:
  /// **'No past conversations yet.'**
  String get chatHistoryEmpty;

  /// Generated title for a conversation in the history list
  ///
  /// In en, this message translates to:
  /// **'Conversation {index}'**
  String chatHistoryConversationTitle(int index);

  /// Indicates when a conversation in the history was last updated
  ///
  /// In en, this message translates to:
  /// **'Updated {timestamp}'**
  String chatHistoryUpdatedAt(String timestamp);

  /// Title for the cryptocurrency chart page
  ///
  /// In en, this message translates to:
  /// **'Bitcoin Price (USD)'**
  String get chartPageTitle;

  /// Description text explaining what data the chart represents
  ///
  /// In en, this message translates to:
  /// **'Closing price over the past 7 days (powered by CoinGecko)'**
  String get chartPageDescription;

  /// Error message shown when fetching chart data fails
  ///
  /// In en, this message translates to:
  /// **'Unable to load chart data.'**
  String get chartPageError;

  /// Message displayed when there is no chart data to show
  ///
  /// In en, this message translates to:
  /// **'No chart data available yet.'**
  String get chartPageEmpty;

  /// Toggle label for enabling pinch-to-zoom on the chart
  ///
  /// In en, this message translates to:
  /// **'Enable pinch zoom'**
  String get chartZoomToggleLabel;

  /// App bar title for the GraphQL demo page
  ///
  /// In en, this message translates to:
  /// **'GraphQL Countries'**
  String get graphqlSampleTitle;

  /// Label shown above the continent filter control
  ///
  /// In en, this message translates to:
  /// **'Filter by continent'**
  String get graphqlSampleFilterLabel;

  /// Dropdown option that clears the continent filter
  ///
  /// In en, this message translates to:
  /// **'All continents'**
  String get graphqlSampleAllContinents;

  /// Headline shown when the GraphQL request fails
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get graphqlSampleErrorTitle;

  /// Fallback error text used when no specific message is available
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load countries right now.'**
  String get graphqlSampleGenericError;

  /// Button label for retrying the GraphQL request
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get graphqlSampleRetryButton;

  /// Message shown when the query returns zero countries
  ///
  /// In en, this message translates to:
  /// **'No countries matched the selected filters.'**
  String get graphqlSampleEmpty;

  /// Label used before the capital city name
  ///
  /// In en, this message translates to:
  /// **'Capital'**
  String get graphqlSampleCapitalLabel;

  /// Label used before the currency code
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get graphqlSampleCurrencyLabel;

  /// Shown when the GraphQL call fails due to connectivity
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get graphqlSampleNetworkError;

  /// Shown when the GraphQL endpoint rejects the query
  ///
  /// In en, this message translates to:
  /// **'The request was rejected. Try a different filter.'**
  String get graphqlSampleInvalidRequestError;

  /// Shown when the GraphQL endpoint returns a server error
  ///
  /// In en, this message translates to:
  /// **'The service is unavailable right now. Please try again later.'**
  String get graphqlSampleServerError;

  /// Shown when the GraphQL response is malformed or missing data
  ///
  /// In en, this message translates to:
  /// **'We received an unexpected response. Please try again.'**
  String get graphqlSampleDataError;

  /// Button label that navigates to the WebSocket demo page
  ///
  /// In en, this message translates to:
  /// **'Open WebSocket demo'**
  String get exampleWebsocketButton;

  /// Button label that navigates to the Google/Apple Maps sample page
  ///
  /// In en, this message translates to:
  /// **'Open Google/Apple Maps demo'**
  String get exampleGoogleMapsButton;

  /// Label showing the battery level returned from the native platform
  ///
  /// In en, this message translates to:
  /// **'Battery level: {percent}%'**
  String exampleNativeBatteryLabel(int percent);

  /// Title for the WebSocket demonstration page
  ///
  /// In en, this message translates to:
  /// **'WebSocket demo'**
  String get websocketDemoTitle;

  /// Message shown when the WebSocket demo is opened on the web platform
  ///
  /// In en, this message translates to:
  /// **'The WebSocket demo isn\'t available on web builds yet.'**
  String get websocketDemoWebUnsupported;

  /// Tooltip for the reconnect icon button in the WebSocket demo
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get websocketReconnectTooltip;

  /// Empty state text when no WebSocket messages have been exchanged
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Send a message to get started.'**
  String get websocketEmptyState;

  /// Placeholder text for the WebSocket message input
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get websocketMessageHint;

  /// Label for the button that sends a WebSocket message
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get websocketSendButton;

  /// Status label shown when the WebSocket connection is established
  ///
  /// In en, this message translates to:
  /// **'Connected to {endpoint}'**
  String websocketStatusConnected(String endpoint);

  /// Status label shown while establishing the WebSocket connection
  ///
  /// In en, this message translates to:
  /// **'Connecting to {endpoint}...'**
  String websocketStatusConnecting(String endpoint);

  /// Error message shown when the WebSocket connection fails
  ///
  /// In en, this message translates to:
  /// **'WebSocket error: {error}'**
  String websocketErrorLabel(String error);

  /// Title for the Google Maps sample page
  ///
  /// In en, this message translates to:
  /// **'Maps demo'**
  String get googleMapsPageTitle;

  /// Fallback error message shown when the Google Maps sample fails to load
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load map data right now.'**
  String get googleMapsPageGenericError;

  /// Section title for the map interaction controls
  ///
  /// In en, this message translates to:
  /// **'Map controls'**
  String get googleMapsPageControlsHeading;

  /// Button label that switches the map back to the normal style
  ///
  /// In en, this message translates to:
  /// **'Show standard map'**
  String get googleMapsPageMapTypeNormal;

  /// Button label that switches the map to the hybrid style
  ///
  /// In en, this message translates to:
  /// **'Show hybrid map'**
  String get googleMapsPageMapTypeHybrid;

  /// Toggle label for enabling traffic overlays on the map
  ///
  /// In en, this message translates to:
  /// **'Show real-time traffic'**
  String get googleMapsPageTrafficToggle;

  /// Helper text reminding developers to configure API keys for the Google Maps demo
  ///
  /// In en, this message translates to:
  /// **'Add your Google Maps API keys to the native projects to see live tiles.'**
  String get googleMapsPageApiKeyHelp;

  /// Message shown when there are no sample map locations
  ///
  /// In en, this message translates to:
  /// **'No locations to display yet.'**
  String get googleMapsPageEmptyLocations;

  /// Heading displayed above the list of sample map locations
  ///
  /// In en, this message translates to:
  /// **'Featured locations'**
  String get googleMapsPageLocationsHeading;

  /// Button label that re-centres the map on a selected location
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get googleMapsPageFocusButton;

  /// Badge text shown next to the currently selected location
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get googleMapsPageSelectedBadge;

  /// Headline shown when no Google Maps API key is configured
  ///
  /// In en, this message translates to:
  /// **'Add a Google Maps API key'**
  String get googleMapsPageMissingKeyTitle;

  /// Helper text prompting developers to configure Google Maps keys
  ///
  /// In en, this message translates to:
  /// **'Update the platform projects with valid Google Maps API keys to use this demo.'**
  String get googleMapsPageMissingKeyDescription;

  /// Message shown when the Google Maps demo is opened on an unsupported platform
  ///
  /// In en, this message translates to:
  /// **'The Google Maps demo is only available on Android and iOS builds.'**
  String get googleMapsPageUnsupportedDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
