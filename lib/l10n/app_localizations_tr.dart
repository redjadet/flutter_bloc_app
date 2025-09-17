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
  String get homeTitle => 'Flutter Demo Ana Sayfa';

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
  String get openChartsTooltip => 'Grafikleri aç';

  @override
  String get openSettingsTooltip => 'Ayarları aç';

  @override
  String get settingsPageTitle => 'Ayarlar';

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
}
