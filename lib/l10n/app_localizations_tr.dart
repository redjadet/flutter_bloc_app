// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get autoLabel => 'Otomatik';

  @override
  String get pausedLabel => 'Duraklatıldı';

  @override
  String nextAutoDecrementIn(int s) {
    return 'Sonraki otomatik azaltım: ${s}s';
  }

  @override
  String get autoDecrementPaused => 'Otomatik azaltım duraklatıldı';

  @override
  String get lastChangedLabel => 'Son değişiklik:';

  @override
  String get appTitle => 'Flutter Demo';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get pushCountLabel => 'Butona bu kadar kez bastınız:';

  @override
  String get incrementTooltip => '+';

  @override
  String get decrementTooltip => '-';

  @override
  String get loadErrorMessage => 'Kaydedilmiş sayaç yüklenemedi';

  @override
  String get startAutoHint => 'Sayı 0 iken otomatik azalma için +\'ya dokunun';

  @override
  String get cannotGoBelowZero => 'Sayı 0\'ın altına inemez';

  @override
  String get openExampleTooltip => 'Örnek sayfayı aç';

  @override
  String get examplePageTitle => 'Örnek Sayfa';

  @override
  String get examplePageDescription =>
      'Bu sayfa GoRouter ile yönlendirmeyi gösterir.';

  @override
  String get exampleBackButtonLabel => 'Sayaca dön';

  @override
  String get exampleNativeInfoButton => 'Yerel bilgileri getir';

  @override
  String get exampleNativeInfoTitle => 'Platform bilgisi';

  @override
  String get exampleNativeInfoError => 'Yerel platform bilgisi alınamadı.';

  @override
  String get exampleRunIsolatesButton => 'İzole örneklerini çalıştır';

  @override
  String get exampleIsolateParallelPending =>
      'Paralel görevler çalıştırılıyor...';

  @override
  String exampleIsolateFibonacciLabel(int input, int value) {
    return 'Fibonacci($input) = $value';
  }

  @override
  String exampleIsolateParallelComplete(String values, int milliseconds) {
    return 'Paralel iki kat değerler: $values ($milliseconds ms içinde tamamlandı)';
  }

  @override
  String get settingsBiometricPrompt =>
      'Ayarları açmak için kimliğinizi doğrulayın';

  @override
  String get settingsBiometricFailed => 'Kimliğiniz doğrulanamadı.';

  @override
  String get openChartsTooltip => 'Grafikleri aç';

  @override
  String get openGraphqlTooltip => 'GraphQL örneğini aç';

  @override
  String get openSettingsTooltip => 'Ayarları aç';

  @override
  String get settingsPageTitle => 'Ayarlar';

  @override
  String get accountSectionTitle => 'Hesap';

  @override
  String accountSignedInAs(String name) {
    return '$name olarak oturum açıldı';
  }

  @override
  String get accountSignedOutLabel => 'Oturum açılmadı.';

  @override
  String get accountSignInButton => 'Oturum aç';

  @override
  String get accountManageButton => 'Hesabı yönet';

  @override
  String get accountGuestLabel => 'Misafir hesabı kullanılıyor';

  @override
  String get accountGuestDescription =>
      'Anonim olarak oturum açtınız. Verilerinizi cihazlar arasında senkronlamak için bir hesap oluşturun.';

  @override
  String get accountUpgradeButton => 'Hesap oluştur veya bağla';

  @override
  String get themeSectionTitle => 'Görünüm';

  @override
  String get themeModeSystem => 'Sistem varsayılanı';

  @override
  String get themeModeLight => 'Açık';

  @override
  String get themeModeDark => 'Koyu';

  @override
  String get languageSectionTitle => 'Dil';

  @override
  String get languageSystemDefault => 'Cihaz dilini kullan';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageGerman => 'Almanca';

  @override
  String get languageFrench => 'Fransızca';

  @override
  String get languageSpanish => 'İspanyolca';

  @override
  String get appInfoSectionTitle => 'Uygulama bilgileri';

  @override
  String get appInfoVersionLabel => 'Sürüm';

  @override
  String get appInfoBuildNumberLabel => 'Derleme numarası';

  @override
  String get appInfoLoadingLabel => 'Uygulama bilgileri yükleniyor...';

  @override
  String get appInfoLoadErrorLabel => 'Uygulama bilgileri yüklenemedi.';

  @override
  String get appInfoRetryButtonLabel => 'Tekrar dene';

  @override
  String get openChatTooltip => 'Yapay zekâ ile sohbet et';

  @override
  String get openGoogleMapsTooltip => 'Google Haritalar demosunu aç';

  @override
  String get chatPageTitle => 'Yapay Zekâ Sohbeti';

  @override
  String get chatInputHint => 'Asistana bir şey sor...';

  @override
  String get chatSendButton => 'Mesaj gönder';

  @override
  String get chatEmptyState => 'Sohbete bir mesaj göndererek başla.';

  @override
  String get chatModelLabel => 'Model';

  @override
  String get chatModelGptOss20b => 'GPT-OSS-20B';

  @override
  String get chatModelGptOss120b => 'GPT-OSS-120B';

  @override
  String get chatHistoryShowTooltip => 'Geçmişi göster';

  @override
  String get chatHistoryHideTooltip => 'Geçmişi gizle';

  @override
  String get chatHistoryPanelTitle => 'Sohbet geçmişi';

  @override
  String get chatHistoryStartNew => 'Yeni sohbet başlat';

  @override
  String get chatHistoryClearAll => 'Geçmişi sil';

  @override
  String get chatHistoryDeleteConversation => 'Sohbeti sil';

  @override
  String get chatHistoryClearAllWarning =>
      'Bu işlem tüm kayıtlı sohbetleri kalıcı olarak silecek.';

  @override
  String get profilePageTitle => 'Profil';

  @override
  String get anonymousSignInButton => 'Misafir olarak devam et';

  @override
  String get anonymousSignInDescription =>
      'Hesap oluşturmadan uygulamayı keşfedebilirsiniz. Daha sonra Ayarlar\'dan yükseltebilirsiniz.';

  @override
  String get anonymousSignInFailed =>
      'Misafir oturumu başlatılamadı. Lütfen tekrar deneyin.';

  @override
  String get anonymousUpgradeHint =>
      'Şu anda misafir oturumundasınız. Verilerinizi korumak için giriş yapın.';

  @override
  String get authErrorInvalidEmail => 'E-posta adresi geçerli görünmüyor.';

  @override
  String get authErrorUserDisabled =>
      'Bu hesap devre dışı bırakılmış. Lütfen destek ile iletişime geçin.';

  @override
  String get authErrorUserNotFound =>
      'Bu bilgilerle eşleşen bir hesap bulunamadı.';

  @override
  String get authErrorWrongPassword =>
      'Parola yanlış. Lütfen kontrol edip tekrar deneyin.';

  @override
  String get authErrorEmailInUse =>
      'Bu e-posta zaten başka bir hesapla ilişkili.';

  @override
  String get authErrorOperationNotAllowed =>
      'Bu giriş yöntemi şu anda devre dışı. Lütfen farklı bir seçenek deneyin.';

  @override
  String get authErrorWeakPassword =>
      'Devam etmeden önce daha güçlü bir parola seçin.';

  @override
  String get authErrorRequiresRecentLogin =>
      'Bu işlemi tamamlamak için lütfen yeniden oturum açın.';

  @override
  String get authErrorCredentialInUse =>
      'Bu kimlik bilgileri zaten başka bir hesapla ilişkili.';

  @override
  String get authErrorInvalidCredential =>
      'Sağlanan kimlik bilgileri geçersiz veya süresi dolmuş.';

  @override
  String get authErrorGeneric => 'İstek tamamlanamadı. Lütfen tekrar deneyin.';

  @override
  String chatHistoryDeleteConversationWarning(String title) {
    return '\"$title\" konuşmasını silmek istiyor musun?';
  }

  @override
  String get cancelButtonLabel => 'Vazgeç';

  @override
  String get deleteButtonLabel => 'Sil';

  @override
  String get chatHistoryEmpty => 'Henüz kayıtlı sohbet yok.';

  @override
  String chatHistoryConversationTitle(int index) {
    return 'Sohbet $index';
  }

  @override
  String chatHistoryUpdatedAt(String timestamp) {
    return '$timestamp tarihinde güncellendi';
  }

  @override
  String get chartPageTitle => 'Bitcoin Fiyatı (USD)';

  @override
  String get chartPageDescription =>
      'Son 7 günün kapanış fiyatı (CoinGecko verisi)';

  @override
  String get chartPageError => 'Grafik verileri yüklenemedi.';

  @override
  String get chartPageEmpty => 'Henüz grafik verisi yok.';

  @override
  String get chartZoomToggleLabel => 'Yakınlaştırmayı etkinleştir';

  @override
  String get graphqlSampleTitle => 'GraphQL Ülkeleri';

  @override
  String get graphqlSampleFilterLabel => 'Kıtaya göre filtrele';

  @override
  String get graphqlSampleAllContinents => 'Tüm kıtalar';

  @override
  String get graphqlSampleErrorTitle => 'Bir sorun oluştu';

  @override
  String get graphqlSampleGenericError => 'Şu anda ülkeler yüklenemedi.';

  @override
  String get graphqlSampleRetryButton => 'Tekrar dene';

  @override
  String get graphqlSampleEmpty => 'Seçilen filtrelerle ülke bulunamadı.';

  @override
  String get graphqlSampleCapitalLabel => 'Başkent';

  @override
  String get graphqlSampleCurrencyLabel => 'Para birimi';

  @override
  String get graphqlSampleNetworkError =>
      'Ağ hatası. Bağlantınızı kontrol edip yeniden deneyin.';

  @override
  String get graphqlSampleInvalidRequestError =>
      'İstek reddedildi. Farklı bir filtre deneyin.';

  @override
  String get graphqlSampleServerError =>
      'Hizmet şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.';

  @override
  String get graphqlSampleDataError =>
      'Beklenmedik bir yanıt alındı. Lütfen yeniden deneyin.';

  @override
  String get exampleWebsocketButton => 'WebSocket demosunu aç';

  @override
  String get exampleGoogleMapsButton => 'Google Haritalar demosunu aç';

  @override
  String exampleNativeBatteryLabel(int percent) {
    return 'Pil seviyesi: %$percent';
  }

  @override
  String get websocketDemoTitle => 'WebSocket demosu';

  @override
  String get websocketDemoWebUnsupported =>
      'WebSocket demosu web derlemelerinde henüz kullanılabilir değil.';

  @override
  String get websocketReconnectTooltip => 'Yeniden bağlan';

  @override
  String get websocketEmptyState =>
      'Henüz mesaj yok. Başlamak için bir mesaj gönderin.';

  @override
  String get websocketMessageHint => 'Bir mesaj yazın';

  @override
  String get websocketSendButton => 'Gönder';

  @override
  String websocketStatusConnected(String endpoint) {
    return '$endpoint adresine bağlandı';
  }

  @override
  String websocketStatusConnecting(String endpoint) {
    return '$endpoint adresine bağlanılıyor...';
  }

  @override
  String websocketErrorLabel(String error) {
    return 'WebSocket hatası: $error';
  }

  @override
  String get googleMapsPageTitle => 'Google Haritalar demosu';

  @override
  String get googleMapsPageGenericError => 'Harita verileri yüklenemedi.';

  @override
  String get googleMapsPageControlsHeading => 'Harita kontrolleri';

  @override
  String get googleMapsPageMapTypeNormal => 'Standart haritayı göster';

  @override
  String get googleMapsPageMapTypeHybrid => 'Hibrit haritayı göster';

  @override
  String get googleMapsPageTrafficToggle => 'Canlı trafiği göster';

  @override
  String get googleMapsPageApiKeyHelp =>
      'Canlı döşemeleri görebilmek için Google Haritalar API anahtarlarını yerel projelere ekleyin.';

  @override
  String get googleMapsPageEmptyLocations => 'Gösterilecek konum yok.';

  @override
  String get googleMapsPageLocationsHeading => 'Öne çıkan konumlar';

  @override
  String get googleMapsPageFocusButton => 'Odaklan';

  @override
  String get googleMapsPageSelectedBadge => 'Seçildi';

  @override
  String get googleMapsPageMissingKeyTitle =>
      'Google Haritalar API anahtarı ekle';

  @override
  String get googleMapsPageMissingKeyDescription =>
      'Bu demoyu kullanmak için yerel projelere geçerli Google Haritalar API anahtarlarını ekleyin.';

  @override
  String get googleMapsPageUnsupportedDescription =>
      'Google Haritalar demosu yalnızca Android ve iOS derlemelerinde kullanılabilir.';
}
