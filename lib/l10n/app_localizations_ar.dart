// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get autoLabel => 'آلي';

  @override
  String get pausedLabel => 'متوقف مؤقتًا';

  @override
  String nextAutoDecrementIn(int s) {
    return 'التخفيض التلقائي التالي في: ${s}s';
  }

  @override
  String get autoDecrementPaused => 'تم إيقاف التخفيض التلقائي مؤقتًا !!!';

  @override
  String get lastChangedLabel => 'آخر تغيير:';

  @override
  String get appTitle => 'تطبيق BLoC';

  @override
  String get homeTitle => 'الصفحة الرئيسية';

  @override
  String get pushCountLabel => 'لقد ضغطت على الزر عدة مرات:';

  @override
  String get incrementTooltip => 'زيادة';

  @override
  String get decrementTooltip => 'إنقاص';

  @override
  String get loadErrorMessage => 'فشل تحميل العداد المحفوظ';

  @override
  String get saveErrorMessage => 'فشل حفظ العداد';

  @override
  String get startAutoHint => 'انقر فوق + لبدء التخفيض التلقائي';

  @override
  String get cannotGoBelowZero => 'لا يمكن أن يقل العدد عن 0';

  @override
  String get openExampleTooltip => 'افتح صفحة المثال';

  @override
  String get openCaseStudyDemoTooltip =>
      'افتح العرض التوضيحي لدراسة حالة طبيب الأسنان';

  @override
  String get openCalculatorTooltip => 'فتح حاسبة الدفع';

  @override
  String get examplePageTitle => 'صفحة المثال';

  @override
  String get examplePageDescription =>
      'توضح هذه الصفحة التنقل باستخدام GoRouter.';

  @override
  String get exampleBackButtonLabel => 'العودة إلى العداد';

  @override
  String get exampleNativeInfoButton => 'جلب المعلومات الأصلية';

  @override
  String get exampleNativeInfoTitle => 'معلومات المنصة';

  @override
  String get exampleNativeInfoError =>
      'غير قادر على جلب معلومات النظام الأساسي الأصلي.';

  @override
  String get exampleNativeInfoDialogTitle => 'تفاصيل المنصة';

  @override
  String get exampleNativeInfoDialogPlatformLabel => 'منصة';

  @override
  String get exampleNativeInfoDialogVersionLabel => 'إصدار';

  @override
  String get exampleNativeInfoDialogManufacturerLabel => 'الشركة المصنعة';

  @override
  String get exampleNativeInfoDialogModelLabel => 'نموذج';

  @override
  String get exampleNativeInfoDialogBatteryLabel => 'مستوى البطارية';

  @override
  String get exampleDialogCloseButton => 'يغلق';

  @override
  String get exampleRunIsolatesButton => 'تشغيل عينات معزولة';

  @override
  String get exampleIsolateParallelPending => 'تشغيل المهام المتوازية...';

  @override
  String exampleIsolateFibonacciLabel(int input, int value) {
    return 'فيبوناتشي ($input) = $value';
  }

  @override
  String exampleIsolateParallelComplete(String values, int milliseconds) {
    return 'القيم المضاعفة المتوازية: $values (اكتملت في $milliseconds مللي ثانية)';
  }

  @override
  String get calculatorTitle => 'حاسبة الدفع';

  @override
  String get calculatorSummaryHeader => 'ملخص الدفع';

  @override
  String get calculatorResultLabel => 'نتيجة';

  @override
  String get calculatorSubtotalLabel => 'المجموع الفرعي';

  @override
  String calculatorTaxLabel(String rate) {
    return 'الضريبة ($rate)';
  }

  @override
  String calculatorTipLabel(String rate) {
    return 'نصيحة ($rate)';
  }

  @override
  String get calculatorTotalLabel => 'المبلغ المراد تحصيله';

  @override
  String get calculatorTaxPresetsLabel => 'الإعدادات المسبقة للضرائب';

  @override
  String get calculatorCustomTaxLabel => 'ضريبة مخصصة';

  @override
  String get calculatorCustomTaxDialogTitle => 'ضريبة مخصصة';

  @override
  String get calculatorCustomTaxFieldLabel => 'نسبة الضريبة';

  @override
  String get calculatorResetTax => 'إعادة تعيين الضريبة';

  @override
  String get calculatorTipRateLabel => 'تلميح الإعدادات المسبقة';

  @override
  String get calculatorCustomTipLabel => 'نصيحة مخصصة';

  @override
  String get calculatorResetTip => 'نصيحة واضحة';

  @override
  String get calculatorCustomTipDialogTitle => 'نصيحة مخصصة';

  @override
  String get calculatorCustomTipFieldLabel => 'نسبة النصيحة';

  @override
  String get calculatorCancel => 'يلغي';

  @override
  String get calculatorApply => 'يتقدم';

  @override
  String get calculatorKeypadHeader => 'لوحة المفاتيح';

  @override
  String get calculatorClearLabel => 'واضح';

  @override
  String get calculatorBackspace => 'مسافة للخلف';

  @override
  String get calculatorPercentCommand => 'نسبة مئوية';

  @override
  String get calculatorToggleSign => 'تبديل الإشارة';

  @override
  String get calculatorDecimalPointLabel => 'النقطة العشرية';

  @override
  String get calculatorErrorTitle => 'خطأ';

  @override
  String get calculatorErrorDivisionByZero => 'لا يمكن القسمة على صفر';

  @override
  String get calculatorErrorInvalidResult => 'النتيجة ليست رقمًا صالحًا';

  @override
  String get calculatorErrorNonPositiveTotal =>
      'يجب أن يكون الإجمالي أكبر من الصفر';

  @override
  String get calculatorEquals => 'إجمالي الرسوم';

  @override
  String get calculatorPaymentTitle => 'ملخص الدفع';

  @override
  String get calculatorNewCalculation => 'عملية حسابية جديدة';

  @override
  String get settingsBiometricPrompt => 'قم بالمصادقة لفتح الإعدادات';

  @override
  String get settingsBiometricFailed => 'تعذر التحقق من هويتك.';

  @override
  String get settingsBiometricUnavailable =>
      'المصادقة البيومترية غير متوفرة على الويب. فتح الإعدادات على أي حال.';

  @override
  String get openChartsTooltip => 'فتح الرسوم البيانية';

  @override
  String get openGraphqlTooltip => 'استكشف نموذج GraphQL';

  @override
  String get openSettingsTooltip => 'افتح الإعدادات';

  @override
  String get settingsPageTitle => 'إعدادات';

  @override
  String get settingsThrowTestException => 'رمي استثناء الاختبار';

  @override
  String get accountSectionTitle => 'حساب';

  @override
  String accountSignedInAs(String name) {
    return 'تم تسجيل الدخول باسم $name';
  }

  @override
  String get accountSignedOutLabel => 'لم يتم تسجيل الدخول.';

  @override
  String get accountSignInButton => 'تسجيل الدخول';

  @override
  String get accountManageButton => 'إدارة الحساب';

  @override
  String get accountGuestLabel => 'باستخدام حساب الضيف';

  @override
  String get accountGuestDescription =>
      'لقد قمت بتسجيل الدخول بشكل مجهول. قم بإنشاء حساب لمزامنة بياناتك عبر الأجهزة.';

  @override
  String get accountUpgradeButton => 'إنشاء أو ربط الحساب';

  @override
  String get themeSectionTitle => 'مظهر';

  @override
  String get themeModeSystem => 'الافتراضي للنظام';

  @override
  String get themeModeLight => 'ضوء';

  @override
  String get themeModeDark => 'مظلم';

  @override
  String get languageSectionTitle => 'اللغة';

  @override
  String get languageSystemDefault => 'استخدام لغة الجهاز';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageTurkish => 'التركية';

  @override
  String get languageGerman => 'الألمانية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get appInfoSectionTitle => 'معلومات التطبيق';

  @override
  String get settingsRemoteConfigSectionTitle => 'التكوين عن بعد';

  @override
  String get settingsRemoteConfigStatusIdle => 'في انتظار الجلب الأول';

  @override
  String get settingsRemoteConfigStatusLoading => 'جارٍ تحميل أحدث القيم...';

  @override
  String get settingsRemoteConfigStatusLoaded => 'تم تحميل أحدث القيم';

  @override
  String get settingsRemoteConfigStatusError => 'فشل تحميل التكوين عن بعد';

  @override
  String get settingsRemoteConfigErrorLabel => 'الخطأ الأخير';

  @override
  String get remoteConfigAwesomeFeatureEnabled => 'تم تمكين الميزة الرائعة';

  @override
  String get settingsRemoteConfigFlagLabel => 'علم ميزة رهيبة';

  @override
  String get settingsRemoteConfigFlagEnabled => 'ممكّن';

  @override
  String get settingsRemoteConfigFlagDisabled => 'عاجز';

  @override
  String get settingsRemoteConfigTestValueLabel => 'قيمة الاختبار';

  @override
  String get settingsRemoteConfigTestValueEmpty => 'لم يتم ضبطه';

  @override
  String get settingsRemoteConfigRetryButton => 'أعد محاولة الجلب';

  @override
  String get settingsRemoteConfigClearCacheButton =>
      'مسح ذاكرة التخزين المؤقت للتكوين';

  @override
  String get settingsSyncDiagnosticsTitle => 'تشخيص المزامنة';

  @override
  String get settingsSyncDiagnosticsEmpty =>
      'لم يتم تسجيل أي عمليات مزامنة حتى الآن.';

  @override
  String settingsSyncLastRunLabel(String timestamp) {
    return 'آخر تشغيل: $timestamp';
  }

  @override
  String settingsSyncOperationsLabel(int processed, int failed) {
    return 'العمليات: تمت معالجة $processed، وفشلت $failed';
  }

  @override
  String settingsSyncPendingLabel(int count) {
    return 'معلق عند البداية: $count';
  }

  @override
  String settingsSyncPrunedLabel(int count) {
    return 'مشذب: $count';
  }

  @override
  String settingsSyncDurationLabel(int ms) {
    return 'المدة: ${ms}ms';
  }

  @override
  String get settingsSyncHistoryTitle => 'عمليات المزامنة الأخيرة';

  @override
  String get settingsGraphqlCacheSectionTitle => 'ذاكرة التخزين المؤقت GraphQL';

  @override
  String get settingsGraphqlCacheDescription =>
      'امسح البلدان/القارات المخزنة مؤقتًا التي يستخدمها العرض التوضيحي لـ GraphQL. سيتم جلب البيانات الجديدة عند التحميل التالي.';

  @override
  String get settingsGraphqlCacheClearButton =>
      'مسح ذاكرة التخزين المؤقت GraphQL';

  @override
  String get settingsGraphqlCacheClearedMessage =>
      'تم مسح ذاكرة التخزين المؤقت لـ GraphQL';

  @override
  String get settingsGraphqlCacheErrorMessage =>
      'تعذر مسح ذاكرة التخزين المؤقت لـ GraphQL';

  @override
  String get settingsProfileCacheSectionTitle =>
      'ذاكرة التخزين المؤقت للملف الشخصي';

  @override
  String get settingsProfileCacheDescription =>
      'امسح لقطة الملف الشخصي المخزنة مؤقتًا محليًا والمستخدمة لعرض شاشة الملف الشخصي في وضع عدم الاتصال.';

  @override
  String get settingsProfileCacheClearButton =>
      'مسح ذاكرة التخزين المؤقت للملف الشخصي';

  @override
  String get settingsProfileCacheClearedMessage =>
      'تم مسح ذاكرة التخزين المؤقت للملف الشخصي';

  @override
  String get settingsProfileCacheErrorMessage =>
      'تعذر مسح ذاكرة التخزين المؤقت للملف الشخصي';

  @override
  String settingsDiagnosticsLastSyncedAt(
    String formattedDate,
    String formattedTime,
  ) {
    return 'آخر مزامنة: $formattedDate $formattedTime';
  }

  @override
  String settingsDiagnosticsCacheSizeKb(int kilobytes) {
    return 'حجم ذاكرة التخزين المؤقت: $kilobytes كيلو بايت';
  }

  @override
  String settingsDiagnosticsDataSource(String name) {
    return 'المصدر: $name';
  }

  @override
  String get networkRetryingSnackBarMessage => 'جارٍ إعادة المحاولة...';

  @override
  String get appInfoVersionLabel => 'إصدار';

  @override
  String get appInfoBuildNumberLabel => 'رقم البناء';

  @override
  String get appInfoLoadingLabel => 'جارٍ تحميل معلومات التطبيق...';

  @override
  String get appInfoLoadErrorLabel => 'فشل في تحميل معلومات التطبيق.';

  @override
  String get appInfoRetryButtonLabel => 'أعد المحاولة';

  @override
  String get openChatTooltip => 'الدردشة مع منظمة العفو الدولية';

  @override
  String get openGenuiDemoTooltip => 'عرض GenUI';

  @override
  String get openGoogleMapsTooltip => 'افتح العرض التوضيحي لخرائط Google/Apple';

  @override
  String get openWhiteboardTooltip => 'افتح السبورة';

  @override
  String get openMarkdownEditorTooltip => 'افتح محرر تخفيض السعر';

  @override
  String get openTodoTooltip => 'افتح قائمة المهام';

  @override
  String get openWalletconnectAuthTooltip => 'ربط المحفظة';

  @override
  String get chatPageTitle => 'دردشة الذكاء الاصطناعي';

  @override
  String get chatTransportSupabase => 'سوباباس';

  @override
  String get chatTransportDirect => 'مباشر';

  @override
  String get chatTransportSupabaseSemanticsLabel =>
      'سوباباس. تستخدم ردود الدردشة وكيل Supabase Edge؛ معانقة الوجه يعمل على الخادم.';

  @override
  String get chatTransportDirectSemanticsLabel =>
      'مباشر. يقوم هذا التطبيق باستدعاء Hugging Face مباشرة للردود على الدردشة.';

  @override
  String get chatTransportRenderOrchestration => 'التنسيق';

  @override
  String get chatTransportRenderOrchestrationSemanticsLabel =>
      'التنسيق. تستخدم ردود الدردشة خدمة FastAPI Cloud الخاصة بك، والتي توجه إلى Hugging Face.';

  @override
  String get chatFastApiCloudBadgeLabel => 'سحابة FastAPI';

  @override
  String get chatFastApiCloudBadgeSemanticsLabel =>
      'سحابة FastAPI. يتم تشغيل التزامن على FastAPI Cloud.';

  @override
  String get chatModelAuto => 'آلي';

  @override
  String get chatRenderStrictMode =>
      'الوضع الصارم التجريبي لـ FastAPI Cloud قيد التشغيل؛ تم تعطيل السقوط.';

  @override
  String get chatAuthRefreshRequired =>
      'قم بتسجيل الدخول مرة أخرى لمواصلة استخدام العرض التوضيحي للدردشة FastAPI Cloud.';

  @override
  String get chatSessionEnded =>
      'انتهت جلستك. ابدأ محادثة جديدة بعد تسجيل الدخول.';

  @override
  String get chatSwitchAccount =>
      'قم بتبديل الحساب لتحديث بيانات الاعتماد للعرض التوضيحي للدردشة FastAPI Cloud.';

  @override
  String get chatTokenMissing =>
      'رمز وجه المعانقة مفقود. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get chatOrchestrationTooltip =>
      'يستخدم التوجيه من جانب الخادم بين النماذج عند تحديد تلقائي.';

  @override
  String get chatOfflineBadgeLabel => 'غير متصل';

  @override
  String get chatOfflineBadgeSemanticsLabel =>
      'غير متصل. ستتم مزامنة الرسائل عند معاودة الاتصال بالإنترنت.';

  @override
  String get chatInputHint => 'اسأل المساعد أي شيء...';

  @override
  String get searchHint => 'يبحث...';

  @override
  String get retryButtonLabel => 'حاول ثانية';

  @override
  String get featureLoadError =>
      'غير قادر على تحميل هذه الميزة. يرجى المحاولة مرة أخرى.';

  @override
  String get chatSendButton => 'أرسل رسالة';

  @override
  String get chatEmptyState => 'ابدأ المحادثة بإرسال رسالة.';

  @override
  String get chatModelLabel => 'نموذج';

  @override
  String get chatModelGptOss20b => 'جي بي تي-OSS-20B';

  @override
  String get chatModelGptOss120b => 'جي بي تي-OSS-120B';

  @override
  String get chatHistoryShowTooltip => 'عرض التاريخ';

  @override
  String get chatHistoryHideTooltip => 'إخفاء التاريخ';

  @override
  String get chatHistoryPanelTitle => 'تاريخ المحادثة';

  @override
  String get chatHistoryStartNew => 'ابدأ محادثة جديدة';

  @override
  String get chatHistoryClearAll => 'حذف التاريخ';

  @override
  String get chatHistoryDeleteConversation => 'حذف المحادثة';

  @override
  String get chatHistoryClearAllWarning =>
      'سيؤدي هذا إلى حذف جميع المحادثات المخزنة نهائيًا.';

  @override
  String get chatMessageStatusPending => 'في انتظار المزامنة';

  @override
  String get chatMessageStatusSyncing => 'جارٍ المزامنة…';

  @override
  String get chatMessageStatusOffline => 'غير متصل - سيتم الإرسال عند الاتصال';

  @override
  String get registerTitle => 'يسجل';

  @override
  String get registerFullNameLabel => 'الاسم الكامل';

  @override
  String get registerFullNameHint => 'جين دو';

  @override
  String get registerEmailLabel => 'عنوان البريد الإلكتروني';

  @override
  String get registerEmailHint => 'jane.doe@example.com';

  @override
  String get registerPhoneLabel => 'رقم التليفون';

  @override
  String get registerPhoneHint => '5551234567';

  @override
  String get registerCountryPickerTitle => 'اختر رمز بلدك';

  @override
  String get registerPasswordLabel => 'كلمة المرور';

  @override
  String get registerPasswordHint => 'إنشاء كلمة المرور';

  @override
  String get registerConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get registerConfirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get registerSubmitButton => 'التالي';

  @override
  String get registerDialogTitle => 'اكتمل التسجيل';

  @override
  String registerDialogMessage(String name) {
    return 'مرحبًا بك على متن الطائرة، $name!';
  }

  @override
  String get registerDialogOk => 'نعم';

  @override
  String get registerFullNameEmptyError => 'الرجاء إدخال اسمك الكامل';

  @override
  String get registerFullNameTooShortError =>
      'يجب أن يتكون الاسم من حرفين على الأقل';

  @override
  String get registerEmailEmptyError =>
      'الرجاء إدخال البريد الإلكتروني الخاص بك';

  @override
  String get registerEmailInvalidError => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get registerPasswordEmptyError => 'الرجاء إدخال كلمة المرور الخاصة بك';

  @override
  String get registerPasswordTooShortError =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get registerPasswordLettersAndNumbersError => 'استخدم الحروف والأرقام';

  @override
  String get registerPasswordWhitespaceError =>
      'لا يمكن أن تحتوي كلمة المرور على مسافات';

  @override
  String get registerTermsCheckboxPrefix => 'لقد قرأت ووافقت على';

  @override
  String get registerTermsCheckboxSuffix => '.';

  @override
  String get registerTermsLinkLabel => 'الشروط والأحكام';

  @override
  String get registerTermsError => 'يرجى قبول الشروط للمتابعة';

  @override
  String get registerTermsDialogTitle => 'الشروط والأحكام';

  @override
  String get registerTermsDialogBody =>
      'من خلال إنشاء حساب، فإنك توافق على استخدام هذا التطبيق بشكل مسؤول، واحترام المستخدمين الآخرين، والامتثال لجميع القوانين المعمول بها. أنت توافق على سياسة الخصوصية الخاصة بنا، وتقر بأن توفر الخدمة قد يتغير، وتقبل أنه قد يتم تعليق حسابك بسبب سوء الاستخدام أو انتهاك هذه الشروط.';

  @override
  String get registerTermsAcceptButton => 'يقبل';

  @override
  String get registerTermsRejectButton => 'يلغي';

  @override
  String get registerTermsPrompt => 'يرجى مراجعة الشروط وقبولها قبل المتابعة.';

  @override
  String get registerTermsButtonLabel => 'اقرأ الشروط والأحكام';

  @override
  String get registerTermsSheetTitle => 'الشروط والأحكام';

  @override
  String get registerTermsSheetBody =>
      'توضح هذه الشروط الاستخدام المقبول لهذا التطبيق التجريبي. من خلال المتابعة، فإنك توافق على التعامل مع حسابك بمسؤولية، وحماية بيانات الاعتماد الخاصة بك، والامتثال لأية قوانين معمول بها. المحتوى المقدم توضيحي فقط وقد يتغير دون إشعار. إذا كنت لا توافق على هذه الشروط، يرجى التوقف عن عملية التسجيل.';

  @override
  String get registerTermsDialogAcknowledge => 'لقد قرأت الشروط';

  @override
  String get registerTermsCheckboxLabel => 'أوافق على الشروط والأحكام';

  @override
  String get registerTermsCheckboxDisabledHint => 'اقرأ الشروط قبل قبولها.';

  @override
  String get registerTermsNotAcceptedError => 'يجب عليك قبول الشروط للمتابعة.';

  @override
  String get registerConfirmPasswordEmptyError =>
      'يرجى تأكيد كلمة المرور الخاصة بك';

  @override
  String get registerConfirmPasswordMismatchError => 'كلمات المرور غير متطابقة';

  @override
  String get registerPhoneEmptyError => 'الرجاء إدخال رقم هاتفك';

  @override
  String get registerPhoneInvalidError => 'أدخل 6-15 رقمًا';

  @override
  String get profilePageTitle => 'حساب تعريفي';

  @override
  String get anonymousSignInButton => 'استمر كضيف';

  @override
  String get anonymousSignInDescription =>
      'يمكنك استكشاف التطبيق دون إنشاء حساب. يمكنك الترقية لاحقًا من الإعدادات.';

  @override
  String get anonymousSignInFailed =>
      'تعذر بدء جلسة الضيف. يرجى المحاولة مرة أخرى.';

  @override
  String get anonymousUpgradeHint =>
      'أنت تستخدم حاليًا جلسة ضيف. قم بتسجيل الدخول للاحتفاظ ببياناتك عبر عمليات التثبيت والأجهزة.';

  @override
  String get authErrorInvalidEmail => 'يبدو أن عنوان البريد الإلكتروني مشوه.';

  @override
  String get authErrorUserDisabled =>
      'لقد تم تعطيل هذا الحساب. اتصل بالدعم للحصول على المساعدة.';

  @override
  String get authErrorUserNotFound =>
      'لم نتمكن من العثور على حساب بهذه التفاصيل.';

  @override
  String get authErrorWrongPassword =>
      'كلمة المرور غير صحيحة. التحقق من ذلك وحاول مرة أخرى.';

  @override
  String get authErrorEmailInUse =>
      'هذا البريد الإلكتروني مرتبط بالفعل بحساب آخر.';

  @override
  String get authErrorOperationNotAllowed =>
      'طريقة تسجيل الدخول هذه معطلة حاليًا. يرجى تجربة خيار مختلف.';

  @override
  String get authErrorWeakPassword => 'اختر كلمة مرور أقوى قبل المتابعة.';

  @override
  String get authErrorRequiresRecentLogin =>
      'الرجاء تسجيل الدخول مرة أخرى لإكمال هذا الإجراء.';

  @override
  String get authErrorCredentialInUse =>
      'بيانات الاعتماد هذه مرتبطة بالفعل بحساب آخر.';

  @override
  String get authErrorInvalidCredential =>
      'بيانات الاعتماد المقدمة غير صالحة أو منتهية الصلاحية.';

  @override
  String get authErrorGeneric =>
      'لم نتمكن من إكمال الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get authErrorNetworkRequestFailed => 'تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get authErrorTooManyRequests =>
      'محاولات كثيرة جدًا. يرجى الانتظار قبل المحاولة مرة أخرى.';

  @override
  String chatHistoryDeleteConversationWarning(String title) {
    return 'هل تريد حذف \"$title\"؟';
  }

  @override
  String get cancelButtonLabel => 'يلغي';

  @override
  String get deleteButtonLabel => 'يمسح';

  @override
  String get chatHistoryEmpty => 'لا توجد محادثات سابقة حتى الآن.';

  @override
  String chatHistoryConversationTitle(int index) {
    return 'المحادثة $index';
  }

  @override
  String chatHistoryUpdatedAt(String timestamp) {
    return 'تم التحديث $timestamp';
  }

  @override
  String get chartPageTitle => 'سعر البيتكوين (دولار أمريكي)';

  @override
  String get chartPageDescription =>
      'سعر الإغلاق خلال الأيام السبعة الماضية (مدعوم من CoinGecko)';

  @override
  String get chartPageError => 'غير قادر على تحميل بيانات المخطط.';

  @override
  String get chartPageEmpty => 'لا توجد بيانات الرسم البياني المتاحة حتى الآن.';

  @override
  String get chartZoomToggleLabel => 'تمكين قرصة التكبير';

  @override
  String get chartDataSourceCache => 'مخبأ';

  @override
  String get chartDataSourceSupabaseEdge => 'سوباباس (الحافة)';

  @override
  String get chartDataSourceSupabaseTables => 'سوباباس (الجداول)';

  @override
  String get chartDataSourceFirebaseCloud => 'Firebase (السحابة)';

  @override
  String get chartDataSourceFirebaseFirestore => 'فاير بيس (فاير ستور)';

  @override
  String get chartDataSourceRemote => 'بعيد';

  @override
  String get graphqlSampleTitle => 'دول الرسم البياني QL';

  @override
  String get graphqlSampleFilterLabel => 'تصفية حسب القارة';

  @override
  String get graphqlSampleAllContinents => 'جميع القارات';

  @override
  String get graphqlSampleErrorTitle => 'حدث خطأ ما';

  @override
  String get graphqlSampleGenericError => 'لا يمكننا تحميل البلدان الآن.';

  @override
  String get graphqlSampleRetryButton => 'حاول ثانية';

  @override
  String get graphqlSampleEmpty =>
      'لم تتطابق أي دولة مع عوامل التصفية المحددة.';

  @override
  String get graphqlSampleCapitalLabel => 'عاصمة';

  @override
  String get graphqlSampleCurrencyLabel => 'عملة';

  @override
  String get graphqlSampleNetworkError =>
      'خطأ في الشبكة. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get graphqlSampleInvalidRequestError =>
      'تم رفض الطلب. جرب مرشحًا مختلفًا.';

  @override
  String get graphqlSampleServerError =>
      'الخدمة غير متوفرة حاليا. يرجى المحاولة مرة أخرى في وقت لاحق.';

  @override
  String get graphqlSampleDataError =>
      'لقد تلقينا ردا غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get graphqlSampleDataSourceCache => 'مخبأ';

  @override
  String get graphqlSampleDataSourceSupabaseEdge => 'سوباباس (الحافة)';

  @override
  String get graphqlSampleDataSourceSupabaseTables => 'سوباباس (الجداول)';

  @override
  String get graphqlSampleDataSourceRemote => 'بعيد';

  @override
  String get exampleWebsocketButton => 'افتح العرض التوضيحي لـ WebSocket';

  @override
  String get exampleGoogleMapsButton =>
      'افتح العرض التوضيحي لخرائط Google/Apple';

  @override
  String exampleNativeBatteryLabel(int percent) {
    return 'مستوى البطارية: $percent%';
  }

  @override
  String get websocketDemoTitle => 'عرض WebSocket';

  @override
  String get websocketDemoWebUnsupported =>
      'العرض التوضيحي لـ WebSocket غير متوفر على إصدارات الويب حتى الآن.';

  @override
  String get websocketReconnectTooltip => 'أعد الاتصال';

  @override
  String get websocketEmptyState => 'لا توجد رسائل حتى الآن. أرسل رسالة للبدء.';

  @override
  String get websocketMessageHint => 'اكتب رسالة';

  @override
  String get websocketSendButton => 'إرسال';

  @override
  String websocketStatusConnected(String endpoint) {
    return 'متصل بـ $endpoint';
  }

  @override
  String websocketStatusConnecting(String endpoint) {
    return 'جارٍ الاتصال بـ $endpoint...';
  }

  @override
  String websocketErrorLabel(String error) {
    return 'خطأ WebSocket: $error';
  }

  @override
  String get googleMapsPageTitle => 'عرض الخرائط';

  @override
  String get googleMapsPageGenericError =>
      'لم نتمكن من تحميل بيانات الخريطة الآن.';

  @override
  String get googleMapsPageControlsHeading => 'ضوابط الخريطة';

  @override
  String get googleMapsPageMapTypeNormal => 'عرض الخريطة القياسية';

  @override
  String get googleMapsPageMapTypeHybrid => 'عرض الخريطة الهجينة';

  @override
  String get googleMapsPageTrafficToggle => 'عرض حركة المرور في الوقت الحقيقي';

  @override
  String get googleMapsPageApiKeyHelp =>
      'أضف مفاتيح Google Maps API إلى المشاريع الأصلية لرؤية المربعات الحية.';

  @override
  String get googleMapsPageEmptyLocations => 'لا توجد مواقع لعرضها بعد.';

  @override
  String get googleMapsPageLocationsHeading => 'مواقع مميزة';

  @override
  String get googleMapsPageFocusButton => 'ركز';

  @override
  String get googleMapsPageSelectedBadge => 'مختارة';

  @override
  String get googleMapsPageMissingKeyTitle => 'أضف مفتاح API لخرائط Google';

  @override
  String get googleMapsPageMissingKeyDescription =>
      'قم بتحديث مشاريع النظام الأساسي باستخدام مفاتيح Google Maps API الصالحة لاستخدام هذا العرض التوضيحي.';

  @override
  String get googleMapsPageUnsupportedDescription =>
      'يتوفر الإصدار التجريبي من خرائط Google فقط على إصدارات Android وiOS.';

  @override
  String get syncStatusOfflineTitle => 'أنت غير متصل بالإنترنت';

  @override
  String syncStatusOfflineMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# تغيير',
      many: '# تغييرًا',
      few: '# تغييرات',
      two: 'تغييرين',
      one: 'تغيير واحد',
      zero: 'تغييراتك',
    );
    return 'سنقوم بمزامنة $_temp0 عندما تعود متصلاً بالإنترنت.';
  }

  @override
  String get syncStatusSyncingTitle => 'مزامنة التغييرات';

  @override
  String syncStatusSyncingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: 'جارٍ مزامنة # تغيير…',
      many: 'جارٍ مزامنة # تغييرًا…',
      few: 'جارٍ مزامنة # تغييرات…',
      two: 'جارٍ مزامنة تغييرين…',
      one: 'جارٍ مزامنة تغيير واحد…',
      zero: 'جارٍ إنهاء آخر تحديثاتك.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusPendingTitle => 'التغييرات في قائمة الانتظار';

  @override
  String syncStatusPendingMessage(int pendingCount) {
    String _temp0 = intl.Intl.pluralLogic(
      pendingCount,
      locale: localeName,
      other: '# تغيير بانتظار المزامنة.',
      many: '# تغييرًا بانتظار المزامنة.',
      few: '# تغييرات بانتظار المزامنة.',
      two: 'تغييرين بانتظار المزامنة.',
      one: 'تغيير واحد بانتظار المزامنة.',
      zero: 'لا توجد تغييرات بانتظار المزامنة.',
    );
    return '$_temp0';
  }

  @override
  String get syncStatusDegradedTitle => 'تم اكتشاف مشكلات في المزامنة';

  @override
  String get syncStatusDegradedMessage =>
      'قد لا تتم مزامنة بعض البيانات. انقر فوق إعادة المحاولة لمحاولة المزامنة.';

  @override
  String get syncStatusSyncNowButton => 'مزامنة الآن';

  @override
  String counterLastSynced(Object timestamp) {
    return 'آخر مزامنة: $timestamp';
  }

  @override
  String counterChangeId(Object changeId) {
    return 'معرف التغيير: $changeId';
  }

  @override
  String get syncQueueInspectorButton => 'عرض قائمة انتظار المزامنة';

  @override
  String get syncQueueInspectorEmpty => 'لا توجد عمليات معلقة.';

  @override
  String get syncQueueInspectorTitle => 'عمليات المزامنة المعلقة';

  @override
  String syncQueueInspectorOperation(String entity, int attempts) {
    return 'الكيان: $entity، المحاولات: $attempts';
  }

  @override
  String get exampleTodoListButton => 'قائمة تودو التجريبي';

  @override
  String get exampleChatListButton => 'عرض قائمة الدردشة';

  @override
  String get exampleSearchDemoButton => 'بحث تجريبي';

  @override
  String get exampleProfileButton => 'العرض التوضيحي للملف الشخصي';

  @override
  String get exampleRegisterButton => 'سجل تجريبي';

  @override
  String get exampleLoggedOutButton => 'تسجيل الخروج التجريبي';

  @override
  String get exampleLibraryDemoButton => 'عرض المكتبة';

  @override
  String get libraryDemoPageTitle => 'عرض المكتبة';

  @override
  String get libraryDemoBrandName => 'عصر';

  @override
  String get libraryDemoPanelTitle => 'مكتبة';

  @override
  String get libraryDemoSearchHint => 'ابحث في مكتبتك';

  @override
  String get libraryDemoCategoryScapes => 'المناظر';

  @override
  String get libraryDemoCategoryPacks => 'حزم';

  @override
  String get libraryDemoAssetsTitle => 'جميع الأصول';

  @override
  String get libraryDemoAssetName => 'اسم الأصول';

  @override
  String get libraryDemoAssetTypeObject => 'هدف';

  @override
  String get libraryDemoAssetTypeImage => 'صورة';

  @override
  String get libraryDemoAssetTypeSound => 'صوت';

  @override
  String get libraryDemoAssetTypeFootage => 'لقطات';

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
  String get libraryDemoBackButtonLabel => 'خلف';

  @override
  String get libraryDemoFilterButtonLabel => 'فلتر';

  @override
  String get todoListTitle => 'قائمة المهام';

  @override
  String get todoListLoadError => 'غير قادر على تحميل المهام';

  @override
  String get todoListAddAction => 'إضافة ما يجب القيام به';

  @override
  String get todoListSaveAction => 'حفظ';

  @override
  String get todoListCancelAction => 'يلغي';

  @override
  String get todoListDeleteAction => 'يمسح';

  @override
  String get todoListEditAction => 'يحرر';

  @override
  String get todoListCompleteAction => 'مكتمل';

  @override
  String get todoListUndoAction => 'وضع علامة نشط';

  @override
  String get todoListDeleteDialogTitle => 'هل تريد حذف كل ما عليك فعله؟';

  @override
  String todoListDeleteDialogMessage(String title) {
    return 'هل تريد حذف \"$title\"؟ لا يمكن التراجع عن هذا.';
  }

  @override
  String get todoListSearchHint => 'بحث في كل شيء...';

  @override
  String get todoListDeleteUndone => 'تم حذف ما يجب القيام به';

  @override
  String get todoListSortAction => 'نوع';

  @override
  String get todoListSortDateDesc => 'التاريخ (الأحدث أولاً)';

  @override
  String get todoListSortDateAsc => 'التاريخ (الأقدم أولاً)';

  @override
  String get todoListSortTitleAsc => 'العنوان (أ-ي)';

  @override
  String get todoListSortTitleDesc => 'العنوان (ي-أ)';

  @override
  String get todoListSortManual => 'يدوي (اسحب لإعادة الترتيب)';

  @override
  String get todoListSortPriorityDesc => 'الأولوية (من الأعلى إلى الأدنى)';

  @override
  String get todoListSortPriorityAsc => 'الأولوية (من الأقل إلى الأعلى)';

  @override
  String get todoListSortDueDateAsc => 'تاريخ الاستحقاق (الأقرب أولاً)';

  @override
  String get todoListSortDueDateDesc => 'تاريخ الاستحقاق (الأحدث أولاً)';

  @override
  String get todoListPriorityNone => 'لا أحد';

  @override
  String get todoListPriorityLow => 'قليل';

  @override
  String get todoListPriorityMedium => 'واسطة';

  @override
  String get todoListPriorityHigh => 'عالي';

  @override
  String get todoListDueDateLabel => 'تاريخ الاستحقاق';

  @override
  String get todoListNoDueDate => 'لا يوجد تاريخ استحقاق';

  @override
  String get todoListClearDueDate => 'مسح تاريخ الاستحقاق';

  @override
  String get todoListPriorityLabel => 'أولوية';

  @override
  String get todoListSelectAll => 'حدد الكل';

  @override
  String get todoListClearSelection => 'مسح التحديد';

  @override
  String get todoListBatchDelete => 'حذف المحدد';

  @override
  String get todoListBatchDeleteDialogTitle => 'هل تريد حذف المهام المحددة؟';

  @override
  String todoListBatchDeleteDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      many: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: 'لا توجد مهام',
    );
    return 'حذف $_temp0؟ لا يمكن التراجع عن ذلك.';
  }

  @override
  String get todoListBatchComplete => 'أكمل التحديد';

  @override
  String get todoListBatchUncomplete => 'تم التحديد غير مكتمل';

  @override
  String todoListItemsSelected(int count) {
    return '$count تم التحديد';
  }

  @override
  String get todoListAddDialogTitle => 'ما يجب القيام به جديد';

  @override
  String get todoListEditDialogTitle => 'تحرير ما يجب القيام به';

  @override
  String get todoListTitlePlaceholder => 'عنوان';

  @override
  String get todoListDescriptionPlaceholder => 'الوصف (اختياري)';

  @override
  String get todoListEmptyTitle => 'لا يوجد كل شيء حتى الآن';

  @override
  String get todoListEmptyMessage => 'أضف مهمتك الأولى للبدء.';

  @override
  String get todoListFilterAll => 'الجميع';

  @override
  String get todoListFilterActive => 'نشيط';

  @override
  String get todoListFilterCompleted => 'مكتمل';

  @override
  String get todoListClearCompletedAction => 'اكتمل المسح';

  @override
  String get todoListClearCompletedDialogTitle =>
      'هل تريد مسح المهام المكتملة؟';

  @override
  String todoListClearCompletedDialogMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة مكتملة',
      many: '$count مهمة مكتملة',
      few: '$count مهام مكتملة',
      two: 'مهمتان مكتملتان',
      one: 'مهمة مكتملة واحدة',
      zero: 'لا توجد مهام مكتملة',
    );
    return 'حذف $_temp0؟ لا يمكن التراجع عن ذلك.';
  }

  @override
  String get exampleScapesButton => 'عرض سكيبس';

  @override
  String get exampleWalletconnectAuthButton => 'مصادقة WalletConnect (تجريبي)';

  @override
  String get exampleCameraGalleryButton => 'عرض الكاميرا والمعرض';

  @override
  String get cameraGalleryPageTitle => 'الكاميرا والمعرض';

  @override
  String get cameraGalleryTakePhoto => 'التقط صورة';

  @override
  String get cameraGalleryPickFromGallery => 'اختر من المعرض';

  @override
  String get cameraGalleryNoImage => 'لم يتم تحديد أي صورة';

  @override
  String get cameraGalleryPermissionDenied =>
      'تم رفض الوصول إلى الكاميرا أو مكتبة الصور.';

  @override
  String get cameraGalleryCancelled => 'تم إلغاء الاختيار.';

  @override
  String get cameraGalleryGenericError => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get cameraGalleryCameraUnavailable =>
      'الكاميرا غير متوفرة. استخدم جهازًا حقيقيًا أو اختر من المعرض.';

  @override
  String get scapesPageTitle => 'المكتبة / المناظر';

  @override
  String get scapeNameLabel => 'اسم سكيب';

  @override
  String scapeMetadataFormat(String duration, int assetCount) {
    String _temp0 = intl.Intl.pluralLogic(
      assetCount,
      locale: localeName,
      other: '$assetCount عنصر',
      many: '$assetCount عنصرًا',
      few: '$assetCount عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا عناصر',
    );
    return '$duration • $_temp0';
  }

  @override
  String get scapeFavoriteAddTooltip => 'أضف المفضلة';

  @override
  String get scapeFavoriteRemoveTooltip => 'إزالة المفضلة';

  @override
  String get scapeMoreOptionsTooltip => 'المزيد من الخيارات';

  @override
  String get scapesGridViewTooltip => 'عرض الشبكة';

  @override
  String get scapesListViewTooltip => 'عرض القائمة';

  @override
  String get noWalletConnected =>
      'لا توجد محفظة متصلة. يرجى توصيل المحفظة أولاً.';

  @override
  String get noWalletLinked => 'لا توجد محفظة مرتبطة. الاتصال والربط أولا.';

  @override
  String get couldNotPlayAudio => 'تعذر تشغيل الصوت';

  @override
  String get scapesErrorOccurred => 'حدث خطأ';

  @override
  String get noScapesAvailable => 'لا يوجد سكيبس المتاحة';

  @override
  String get genuiDemoPageTitle => 'عرض GenUI';

  @override
  String get genuiDemoHintText => 'أدخل رسالة لإنشاء واجهة المستخدم...';

  @override
  String get genuiDemoSendButton => 'إرسال';

  @override
  String get genuiDemoErrorTitle => 'خطأ';

  @override
  String get genuiDemoNoApiKey =>
      'GEMINI_API_KEY لم يتم تكوينه. الرجاء إضافته إلى Secrets.json أو استخدم --dart-define=GEMINI_API_KEY=...';

  @override
  String get walletconnectAuthTitle => 'ربط المحفظة';

  @override
  String get connectWalletButton => 'ربط المحفظة';

  @override
  String get walletAddress => 'عنوان المحفظة';

  @override
  String get linkToFirebase => 'رابط إلى الحساب';

  @override
  String get relinkToAccount => 'إعادة الارتباط بالحساب';

  @override
  String get disconnectWallet => 'قطع الاتصال';

  @override
  String get walletConnected => 'المحفظة متصلة';

  @override
  String get walletLinked => 'المحفظة مرتبطة بالحساب';

  @override
  String get walletConnectError => 'فشل في ربط المحفظة';

  @override
  String get walletLinkError => 'فشل ربط المحفظة بالحساب';

  @override
  String get walletProfileSection => 'حساب تعريفي';

  @override
  String get balanceOffChain => 'الرصيد (خارج السلسلة)';

  @override
  String get balanceOnChain => 'الرصيد (على السلسلة)';

  @override
  String get rewards => 'المكافآت';

  @override
  String get lastClaim => 'المطالبة الأخيرة';

  @override
  String get lastClaimNever => 'أبداً';

  @override
  String get nfts => 'NFTs';

  @override
  String nftsCount(int count) {
    return '$count NFT(s)';
  }

  @override
  String get playlearnTitle => 'تعلم اللعب';

  @override
  String get playlearnTopicAnimals => 'الحيوانات';

  @override
  String get playlearnListen => 'يستمع';

  @override
  String get playlearnTapToListen => 'انقر للاستماع';

  @override
  String get playlearnBack => 'خلف';

  @override
  String get openPlaylearnTooltip => 'افتح بلاي ليرن';

  @override
  String get openIgamingDemoTooltip => 'عرض iGaming';

  @override
  String get whiteboardChoosePenColor => 'اختيار لون القلم';

  @override
  String get whiteboardPickColor => 'اختر لونًا';

  @override
  String get whiteboardUndo => 'تراجع';

  @override
  String get whiteboardUndoLastStroke => 'التراجع عن السكتة الدماغية الأخيرة';

  @override
  String get whiteboardRedo => 'إعادة';

  @override
  String get whiteboardRedoLastStroke => 'إعادة آخر ضربة تم التراجع عنها';

  @override
  String get whiteboardClear => 'واضح';

  @override
  String get whiteboardClearAllStrokes => 'مسح كافة السكتات الدماغية';

  @override
  String get whiteboardPenColor => 'لون القلم';

  @override
  String get whiteboardStrokeWidth => 'عرض السكتة الدماغية';

  @override
  String get whiteboardStrokeWidthThin => 'رفيع';

  @override
  String get whiteboardStrokeWidthMedium => 'واسطة';

  @override
  String get whiteboardStrokeWidthThick => 'سميك';

  @override
  String get whiteboardStrokeWidthExtra => 'إضافي';

  @override
  String get errorUnknown => 'حدث خطأ غير معروف';

  @override
  String get errorNetwork =>
      'خطأ في الاتصال بالشبكة. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get errorTimeout => 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى.';

  @override
  String get errorUnauthorized =>
      'المصادقة مطلوبة. الرجاء تسجيل الدخول مرة أخرى.';

  @override
  String get errorForbidden => 'تم الرفض. ليس لديك إذن بهذا الإجراء.';

  @override
  String get errorNotFound => 'لم يتم العثور على المورد المطلوب.';

  @override
  String get errorServer =>
      'خطأ في الخادم. يرجى المحاولة مرة أخرى في وقت لاحق.';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get errorClient =>
      'خطأ العميل. Please check your request and try again.';

  @override
  String get errorTooManyRequests =>
      'طلبات كثيرة جدًا. يرجى الانتظار قبل المحاولة مرة أخرى.';

  @override
  String get errorServiceUnavailable =>
      'الخدمة غير متاحة مؤقتا. يرجى المحاولة مرة أخرى خلال دقيقة.';

  @override
  String get igamingDemoLobbyTitle => 'عرض iGaming';

  @override
  String get igamingDemoBalanceLabel => 'التوازن الظاهري';

  @override
  String get igamingDemoPlayGame => 'لعب لاكي سبين';

  @override
  String get igamingDemoGameTitle => 'لاكي سبين';

  @override
  String get igamingDemoStakeLabel => 'حصة';

  @override
  String get igamingDemoPlayButton => 'يلف';

  @override
  String get igamingDemoResultWin => 'لقد فزت!';

  @override
  String get igamingDemoResultLoss => 'لا يوجد فوز هذه المرة.';

  @override
  String get igamingDemoPlayAgain => 'العب مرة أخرى';

  @override
  String get igamingDemoBackToLobby => 'العودة إلى الردهة';

  @override
  String get igamingDemoErrorInsufficientBalance => 'رصيد غير كاف';

  @override
  String get igamingDemoErrorLoadBalance => 'فشل في تحميل الرصيد';

  @override
  String get igamingDemoSymbolLegendTitle => 'الرموز';

  @override
  String get igamingDemoSymbolWinHint =>
      'ثلاثة رموز متطابقة = فوز. رموز مختلفة = لا فوز.';

  @override
  String get igamingDemoSymbol7 => 'سبعة';

  @override
  String get igamingDemoSymbolStar => 'نجم';

  @override
  String get igamingDemoSymbolDiamond => 'الماس';

  @override
  String get igamingDemoSymbolCircle => 'دائرة';

  @override
  String get igamingDemoSymbolTriangle => 'مثلث';

  @override
  String get igamingDemoSymbolGem => 'جوهرة';

  @override
  String get exampleIgamingDemoButton => 'عرض iGaming';

  @override
  String get exampleFcmDemoButton => 'عرض FCM';

  @override
  String get exampleFirebaseFunctionsButton => 'اختبار وظائف Firebase';

  @override
  String get firebaseFunctionsTestTitle => 'وظائف Firebase';

  @override
  String get firebaseFunctionsCallButton => 'اتصل بـ helloWorld';

  @override
  String get firebaseFunctionsResultLabel => 'نتيجة';

  @override
  String get firebaseUnavailableMessage => 'لم تتم تهيئة Firebase.';

  @override
  String get fcmDemoPageTitle => 'عرض FCM';

  @override
  String get fcmDemoPermissionLabel => 'إذن';

  @override
  String get fcmDemoPermissionNotDetermined => 'لم يتم تحديدها';

  @override
  String get fcmDemoPermissionAuthorized => 'ممنوح';

  @override
  String get fcmDemoPermissionDenied => 'رفض';

  @override
  String get fcmDemoPermissionProvisional => 'مؤقت';

  @override
  String get fcmDemoFcmTokenLabel => 'رمز FCM';

  @override
  String get fcmDemoApnsTokenLabel => 'رمز APNs';

  @override
  String get fcmDemoTokenNotAvailable => 'غير متوفر';

  @override
  String get fcmDemoCopyToken => 'ينسخ';

  @override
  String get fcmDemoCopySuccess => 'تم النسخ إلى الحافظة';

  @override
  String get fcmDemoCopyFailure => 'فشل النسخ';

  @override
  String get fcmDemoLastMessageLabel => 'الرسالة الأخيرة';

  @override
  String get fcmDemoLastMessageNone => 'لا شيء حتى الآن';

  @override
  String get fcmDemoLastMessageReceived => 'تم استلام الرسالة';

  @override
  String get fcmDemoScopeNoteIos =>
      'على نظام التشغيل iOS، يتطلب التسليم في الخلفية/الإنهاء وجود مفتاح APNs في Firebase Console.';

  @override
  String get fcmDemoScopeNoteSimulator =>
      'في iOS Simulator، استخدم ملف .apns (اسحب إلى جهاز محاكاة أو دفع xcrun simctl).';

  @override
  String get iotDemoPageTitle => 'عرض إنترنت الأشياء';

  @override
  String get iotDemoDeviceListEmpty => 'لم يتم العثور على أي أجهزة';

  @override
  String get iotDemoConnect => 'يتصل';

  @override
  String get iotDemoDisconnect => 'قطع الاتصال';

  @override
  String get iotDemoToggle => 'تبديل';

  @override
  String get iotDemoSetValue => 'تعيين القيمة';

  @override
  String get iotDemoSetValueHint => 'قيمة';

  @override
  String get iotDemoStatusDisconnected => 'غير متصل';

  @override
  String get iotDemoStatusConnecting => 'الاتصال';

  @override
  String get iotDemoStatusConnected => 'متصل';

  @override
  String get iotDemoDeviceTypeLight => 'ضوء';

  @override
  String get iotDemoDeviceTypeThermostat => 'ترموستات';

  @override
  String get iotDemoDeviceTypePlug => 'سدادة';

  @override
  String get iotDemoDeviceTypeSensor => 'الاستشعار';

  @override
  String get iotDemoDeviceTypeSwitch => 'يُحوّل';

  @override
  String get iotDemoErrorLoad => 'فشل في تحميل الأجهزة';

  @override
  String get iotDemoErrorConnect => 'فشل الاتصال';

  @override
  String get iotDemoErrorDisconnect => 'فشل في قطع الاتصال';

  @override
  String get iotDemoErrorCommand => 'فشل في إرسال الأمر';

  @override
  String get iotDemoStateOn => 'على';

  @override
  String get iotDemoStateOff => 'عن';

  @override
  String iotDemoCurrentValue(String value) {
    return 'القيمة الحالية: $value';
  }

  @override
  String iotDemoSetValueOutOfRange(String min, String max) {
    return 'يجب أن تكون القيمة بين $min و$max';
  }

  @override
  String get iotDemoSetValueInvalidNumber => 'أدخل رقمًا صالحًا';

  @override
  String get iotDemoAddDevice => 'إضافة جهاز';

  @override
  String get iotDemoAddDeviceNameHint => 'اسم الجهاز';

  @override
  String get iotDemoAddDeviceNameRequired => 'الاسم مطلوب';

  @override
  String iotDemoAddDeviceNameTooLong(String max) {
    return 'يجب أن يتكون الاسم من $max حرفًا على الأكثر';
  }

  @override
  String get iotDemoAddDeviceTypeHint => 'نوع الجهاز';

  @override
  String iotDemoAddDeviceInitialValue(String value) {
    return 'القيمة الأولية: $value';
  }

  @override
  String get iotDemoAddDeviceTooltip => 'إضافة جهاز';

  @override
  String get iotDemoErrorAdd => 'فشلت إضافة الجهاز';

  @override
  String get iotDemoFilterAll => 'الجميع';

  @override
  String get iotDemoFilterOnOnly => 'على فقط';

  @override
  String get iotDemoFilterOffOnly => 'إيقاف فقط';

  @override
  String get openIotDemoTooltip => 'افتح العرض التجريبي لإنترنت الأشياء';

  @override
  String get searchAllResultsSectionTitle => 'جميع النتائج';

  @override
  String get searchErrorLoadingResults => 'حدث خطأ أثناء تحميل النتائج';

  @override
  String get searchNoResultsFound => 'لم يتم العثور على نتائج';

  @override
  String get profileSeeMore => 'شاهد المزيد';

  @override
  String get moreTooltip => 'أكثر';

  @override
  String get whiteboardPageTitle => 'السبورة';

  @override
  String get playlearnNoWords => 'لا توجد كلمات';

  @override
  String get playlearnNoTopics => 'لا توجد مواضيع';

  @override
  String get commonEmptyStateTryAgain => 'حاول ثانية';

  @override
  String get profileNoCachedProfile => 'لا يوجد ملف تعريف مخبأ';

  @override
  String get profileCachedProfileDetailsUnavailable =>
      'الملف الشخصي المخبأ (التفاصيل غير متوفرة)';

  @override
  String get loggedOutPhotoLabel => 'صورة';

  @override
  String get supabaseAuthTitle => 'مصادقة سوباباس';

  @override
  String get supabaseAuthSignIn => 'تسجيل الدخول';

  @override
  String get supabaseAuthSignUp => 'اشتراك';

  @override
  String get supabaseAuthSignOut => 'تسجيل الخروج';

  @override
  String get supabaseAuthEmailLabel => 'بريد إلكتروني';

  @override
  String get supabaseAuthPasswordLabel => 'كلمة المرور';

  @override
  String get supabaseAuthPasswordMinLength => 'ما لا يقل عن 6 أحرف';

  @override
  String get supabaseAuthDisplayNameLabel => 'اسم العرض (اختياري)';

  @override
  String get supabaseAuthNotConfigured =>
      'لم يتم تكوين Supabase. أضف SUPABASE_URL وSUPABASE_ANON_KEY إلى الأسرار أو البيئة.';

  @override
  String get supabaseAuthErrorInvalidCredentials =>
      'البريد الإلكتروني أو كلمة المرور غير صالحة';

  @override
  String get supabaseAuthErrorInvalidEmail =>
      'يرجى إدخال عنوان بريد إلكتروني صالح.';

  @override
  String get supabaseAuthErrorNetwork => 'خطأ في الشبكة. تحقق من اتصالك.';

  @override
  String get supabaseAuthErrorWeakPassword =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.';

  @override
  String get supabaseAuthErrorUserAlreadyExists =>
      'يوجد حساب بهذا البريد الإلكتروني بالفعل. حاول تسجيل الدخول.';

  @override
  String supabaseAuthSignedInAs(String email) {
    return 'تم تسجيل الدخول باسم $email';
  }

  @override
  String get settingsIntegrationsSection => 'التكامل';

  @override
  String get settingsSupabaseAuth => 'مصادقة سوباباس';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get exampleIapDemoButton =>
      'العرض التوضيحي لعمليات الشراء داخل التطبيق (IAP).';

  @override
  String get iapDemoPageTitle => 'عمليات الشراء داخل التطبيق';

  @override
  String get iapDemoDisclaimer =>
      'عرض تجريبي لمتجر IAP. تتطلب عمليات الشراء الحقيقية اختبار وضع الحماية في App Store/Play. بالنسبة للمحاكي/المحاكي، استخدم التدفق المحاكى.';

  @override
  String get iapDemoUseFakeRepoLabel => 'استخدم عمليات الشراء المحاكاة';

  @override
  String get iapDemoForceOutcomeLabel => 'نتيجة القوة';

  @override
  String get iapDemoEntitlementsTitle => 'الاستحقاقات';

  @override
  String get iapDemoCreditsLabel => 'الاعتمادات';

  @override
  String get iapDemoPremiumLabel => 'قسط المملوكة';

  @override
  String get iapDemoSubscriptionLabel => 'الاشتراك نشط';

  @override
  String get iapDemoSubscriptionExpiryLabel => 'انتهاء الاشتراك';

  @override
  String get iapDemoRestoreButton => 'استعادة المشتريات';

  @override
  String get iapDemoProductsTitle => 'منتجات';

  @override
  String get iapDemoConsumablesTitle => 'المواد الاستهلاكية';

  @override
  String get iapDemoNonConsumablesTitle => 'غير المواد الاستهلاكية';

  @override
  String get iapDemoSubscriptionsTitle => 'الاشتراكات';

  @override
  String get iapDemoLastResultLabel => 'النتيجة الأخيرة';

  @override
  String get iapDemoBuyButton => 'يشتري';

  @override
  String get iapDemoNoProductsFound => 'لم يتم العثور على منتجات.';

  @override
  String get exampleCaseStudyDemoButton => 'عرض دراسة حالة (طبيب أسنان)';

  @override
  String get caseStudyDemoTitle => 'عرض دراسة الحالة';

  @override
  String get caseStudyDemoNewCase => 'حالة جديدة';

  @override
  String get caseStudyDemoHistory => 'تاريخ';

  @override
  String get caseStudyDemoSettings => 'إعدادات';

  @override
  String get caseStudyDemoMetadataTitle => 'تفاصيل القضية';

  @override
  String get caseStudyDoctorNameLabel => 'اسم الطبيب';

  @override
  String get caseStudyCaseTypeLabel => 'نوع القضية';

  @override
  String get caseStudyNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get caseStudyContinue => 'يكمل';

  @override
  String get caseStudyCaseTypeImplant => 'زرع';

  @override
  String get caseStudyCaseTypeOrtho => 'تقويم الأسنان';

  @override
  String get caseStudyCaseTypeCosmetic => 'مستحضرات التجميل';

  @override
  String get caseStudyCaseTypeGeneral => 'عام';

  @override
  String get caseStudyRecordTitle => 'سجل الردود';

  @override
  String caseStudyQuestionProgress(int current, int total) {
    return 'السؤال $current من $total';
  }

  @override
  String get caseStudyPickVideoCamera => 'سجل الفيديو';

  @override
  String get caseStudyPickVideoGallery => 'اختر من المعرض';

  @override
  String get caseStudyNext => 'التالي';

  @override
  String get caseStudyGoToReview => 'مواصلة المراجعة';

  @override
  String get caseStudyBack => 'خلف';

  @override
  String get caseStudyReviewTitle => 'مراجعة وتقديم';

  @override
  String get caseStudySubmit => 'مرسل';

  @override
  String get caseStudyAbandon => 'ترك القضية';

  @override
  String get caseStudyAbandonConfirmBody =>
      'هل تريد تجاهل هذه الحالة وحذف أي مقاطع مسجلة لها؟';

  @override
  String get caseStudyDeleteDialogTitle => 'هل تريد حذف الحالة؟';

  @override
  String get caseStudyDeleteDialogBody =>
      'هل تريد حذف هذه الحالة نهائيًا؟ لا يمكن التراجع عن هذا.';

  @override
  String get caseStudyUploading => 'جارٍ التحميل…';

  @override
  String get caseStudyDataModeLocalOnly => 'محلي فقط';

  @override
  String get caseStudyDataModeSupabase => 'سوباباس';

  @override
  String get caseStudyHistoryTitle => 'الحالات المقدمة';

  @override
  String get caseStudyHistoryEmpty => 'لم يتم تقديم أي حالات حتى الآن.';

  @override
  String get caseStudyHistoryDetailTitle => 'تفاصيل القضية';

  @override
  String get caseStudySubmittedAt => 'مُقَدَّم';

  @override
  String get caseStudyVideoMissing => 'ملف الفيديو مفقود';

  @override
  String get caseStudyErrorGeneric => 'حدث خطأ ما. حاول ثانية.';

  @override
  String get caseStudyHistoryDetailNotFound =>
      'لم يتم العثور على هذه الحالة. ربما تمت إزالته أو ربما لا يمكنك الوصول إليه.';

  @override
  String get caseStudyHistoryDetailUnavailable =>
      'تعذر تحميل هذه الحالة. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get caseStudySubmitLocalHistoryFailed =>
      'تم حفظ حالتك في السحابة، ولكن لم يتمكن هذا الجهاز من تحديث السجل المحلي. استخدم \"إعادة محاولة الحفظ على هذا الجهاز\" أدناه، أو افتح السجل لرؤية عمليات الإرسال السحابية.';

  @override
  String get caseStudyRetryLocalSave => 'أعد محاولة الحفظ على هذا الجهاز';

  @override
  String get caseStudyRefreshDetailTooltip => 'ينعش';

  @override
  String get caseStudySignedUrlsRefreshHint =>
      'يستخدم تشغيل المقطع روابط مؤقتة (حوالي 24 ساعة). اسحب لأسفل أو اضغط على \"تحديث\" إذا توقف الفيديو عن العمل.';

  @override
  String get caseStudyQuestion1 => 'تقديم المريض والشكوى الرئيسية.';

  @override
  String get caseStudyQuestion2 => 'وصف التاريخ الطبي ذي الصلة.';

  @override
  String get caseStudyQuestion3 => 'عرض نتائج الفحص خارج الفم.';

  @override
  String get caseStudyQuestion4 => 'عرض نتائج الفحص داخل الفم.';

  @override
  String get caseStudyQuestion5 => 'شرح نتائج التصوير الشعاعي.';

  @override
  String get caseStudyQuestion6 => 'انتقل من خلال التشخيص وقائمة المشاكل.';

  @override
  String get caseStudyQuestion7 => 'وصف خيارات العلاج التي تمت مناقشتها.';

  @override
  String get caseStudyQuestion8 => 'تفاصيل خطة العلاج المختارة.';

  @override
  String get caseStudyQuestion9 => 'إظهار الحالة الفورية بعد العملية الجراحية.';

  @override
  String get caseStudyQuestion10 => 'تلخيص المتابعة والتشخيص.';

  @override
  String staffDemoAdminFlagged(int count) {
    return 'تم وضع علامة ($count)';
  }

  @override
  String get staffDemoAdminNoFlagged =>
      'لم يتم العثور على إدخالات تم وضع علامة عليها.';

  @override
  String staffDemoAdminRecentEntries(int count) {
    return 'إدخالات الوقت الأخيرة ($count)';
  }

  @override
  String get staffDemoAdminSeedingReminder =>
      'تذكيرات البذر: قم بإنشاء مستندات StaffDemoProfiles (معرف مستخدم المستخدم)، و StaffDemoSites (معرف الموقع)، و StaffDemoShifts (معرف التحول) في Firestore للحصول على تغطية تجريبية كاملة.';

  @override
  String get staffDemoAdminTitle => 'مسؤل';

  @override
  String get staffDemoAssignToStaffLabel => 'تكليف الموظفين';

  @override
  String get staffDemoComposeDefaultShiftBody =>
      'تبدأ مناوبتك في الساعة 10:00. يرجى الاجتماع في المستودع.';

  @override
  String get staffDemoComposeRecipientUserId => 'معرف المستخدم المستلم';

  @override
  String get staffDemoComposeSendShiftAssignment => 'إرسال مهمة التحول';

  @override
  String get staffDemoComposeStaffListFailed => 'فشل تحميل قائمة الموظفين.';

  @override
  String staffDemoComposeStaffListFailedWithDetails(String details) {
    return 'فشل تحميل قائمة الموظفين.\n$details';
  }

  @override
  String get staffDemoComposeTitle => 'إرسال مهمة التحول';

  @override
  String get staffDemoContentCouldNotLoadUrl => 'تعذر تحميل عنوان URL للملف.';

  @override
  String get staffDemoContentEmpty => 'لا يوجد محتوى بعد.';

  @override
  String get staffDemoContentFailedToOpenItem => 'فشل في تحميل المحتوى.';

  @override
  String get staffDemoContentTitle => 'محتوى';

  @override
  String staffDemoDashboardHello(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String get staffDemoDashboardInactiveProfile =>
      'هذا الملف التجريبي للموظفين غير نشط.';

  @override
  String get staffDemoDashboardIntro =>
      'استخدم علامات التبويب السفلية للتنقل في العرض التوضيحي. يبدأ التدفق المحاسبي بـ Timeclock.';

  @override
  String get staffDemoDashboardLoading => 'تحميل…';

  @override
  String get staffDemoDashboardNoProfile =>
      'لم يتم العثور على ملف تعريف تجريبي للموظفين لهذا المستخدم. قم بتزويد مستند StaffDemoProfiles بمفتاح بواسطة Firebase Auth uid لهذا المستخدم في Firestore.';

  @override
  String get staffDemoDashboardTitle => 'عرض الموظفين';

  @override
  String get staffDemoFormsErrorSiteRequired => 'معرف الموقع مطلوب.';

  @override
  String get staffDemoFormsManagerReport => 'تقرير مدير';

  @override
  String get staffDemoFormsNotesLabel => 'ملحوظات';

  @override
  String get staffDemoFormsSubmitAvailability => 'إرسال التوفر';

  @override
  String get staffDemoFormsSubmitReport => 'إرسال التقرير';

  @override
  String get staffDemoFormsSubmitted => 'مُقَدَّم.';

  @override
  String get staffDemoFormsSuccessAvailability => 'تم تقديم التوفر';

  @override
  String get staffDemoFormsSuccessManagerReport => 'تم تقديم تقرير المدير';

  @override
  String get staffDemoFormsTitle => 'النماذج';

  @override
  String get staffDemoFormsWeeklyAvailability => 'التوفر الأسبوعي';

  @override
  String get staffDemoMessagesEmpty => 'لا توجد رسائل حتى الآن.';

  @override
  String get staffDemoMessagesErrorInboxLoadFailed =>
      'فشل تحميل تحديثات البريد الوارد.';

  @override
  String get staffDemoMessagesTitle => 'رسائل';

  @override
  String get staffDemoNavAdmin => 'مسؤل';

  @override
  String get staffDemoNavContent => 'محتوى';

  @override
  String get staffDemoNavForms => 'النماذج';

  @override
  String get staffDemoNavHome => 'بيت';

  @override
  String get staffDemoNavMsgs => 'الرسائل';

  @override
  String get staffDemoNavProof => 'دليل';

  @override
  String get staffDemoNavTime => 'وقت';

  @override
  String get staffDemoNotSignedIn => 'لم يتم تسجيل الدخول.';

  @override
  String get staffDemoProofFailed => 'فشل.';

  @override
  String get staffDemoProofOfflineQueued =>
      'غير متصل: في قائمة الانتظار للمزامنة عند الاتصال بالإنترنت.';

  @override
  String get staffDemoProofPhotos => 'صور';

  @override
  String get staffDemoProofPickPhoto => 'يختار';

  @override
  String get staffDemoProofShiftIdOptional => 'معرف التحول (اختياري)';

  @override
  String get staffDemoProofSignatureClear => 'واضح';

  @override
  String get staffDemoProofSignatureLabel => 'إمضاء';

  @override
  String get staffDemoProofSignatureNotSaved => 'لم يتم حفظها';

  @override
  String get staffDemoProofSignatureSave => 'حفظ التوقيع';

  @override
  String get staffDemoProofSignatureSaved => 'أنقذ';

  @override
  String get staffDemoProofSignatureSaveBefore => 'الرجاء التوقيع قبل الحفظ.';

  @override
  String get staffDemoProofSignatureSaveSuccess => 'تم حفظ التوقيع.';

  @override
  String get staffDemoProofSubmit => 'يُقدِّم';

  @override
  String get staffDemoProofSubmitProof => 'تقديم إثبات';

  @override
  String get staffDemoProofSubmittedEmpty => 'إثبات مقدم';

  @override
  String staffDemoProofSubmittedWithId(String proofId) {
    return 'تم تقديم الدليل $proofId';
  }

  @override
  String get staffDemoProofTakePhoto => 'التقط صورة';

  @override
  String get staffDemoProofTitle => 'دليل';

  @override
  String get staffDemoSitePickerEmpty =>
      'لم يتم العثور على مواقع في StaffDemoSites.';

  @override
  String get staffDemoSitePickerFailed => 'فشل في تحميل المواقع.';

  @override
  String get staffDemoSitePickerLoading => 'جارٍ تحميل المواقع...';

  @override
  String get staffDemoSitePickerLabel => 'موقع';

  @override
  String get staffDemoSubmitting => 'تقديم…';

  @override
  String get staffDemoTimeclockClockIn => 'الساعة في';

  @override
  String get staffDemoTimeclockClockOut => 'خارج الساعة';

  @override
  String staffDemoTimeclockClockedInStatus(String entryId) {
    return 'الحالة: تم تسجيل الساعة ($entryId)';
  }

  @override
  String get staffDemoTimeclockClockedOutStatus => 'الحالة: انتهت الساعة';

  @override
  String staffDemoTimeclockDistanceMeters(String distanceM, String radiusM) {
    return 'المسافة: ${distanceM}m (نصف القطر ${radiusM}m)';
  }

  @override
  String get staffDemoTimeclockLastResultFlags => 'علامات النتيجة الأخيرة:';

  @override
  String get staffDemoTimeclockTitle => 'الساعة الزمنية';

  @override
  String get staffDemoVideoPlayerError => 'تعذر تحميل هذا الفيديو.';

  @override
  String get staffDemoActionSend => 'إرسال';

  @override
  String get staffDemoComposeMessageBodyLabel => 'نص الرسالة';

  @override
  String get staffDemoComposeRecipientUserIdHelper =>
      'أدخل معرف Firebase Auth.';

  @override
  String get staffDemoInboxMessageFallback => 'رسالة';

  @override
  String get staffDemoShiftConfirmAction => 'يتأكد';

  @override
  String get staffDemoShiftConfirmed => 'مؤكد';
}
