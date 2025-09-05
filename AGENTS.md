# Repository Guidelines (MVP + SOLID + Clean Code)

Bu projede tüm yeni geliştirmeler, refaktörler ve katkılar aşağıdaki mimari ve prensiplere uymalıdır: MVP (Model–View–Presenter), SOLID ve Clean Code.

## Mimari: MVP
- View: Sadece UI. `Widget`/`Screen` bileşenleri kullanıcı etkileşimini presenter’a deleg eder; iş kuralı içermez.
- Presenter: UI iş mantığı. View arayüzüne konuşur, model/repoya delegasyon yapar. Test edilebilir saf Dart sınıflarıdır.
- Model: Durum + veri erişimi. Tercih edilen state management: Bloc/Cubit (`flutter_bloc`) veya Provider (`provider`/`ChangeNotifier`/`ValueNotifier`). Repo’lar ve veri modelleri bu katmanda konumlanır.

## Klasör Yapısı
- `lib/core/`:
  - `mvp/`: Presenter tabanı ve ortak MVP yardımcıları (`lib/core/mvp/presenter.dart`).
  - `theme/`, `ui/`, `l10n/`: Çapraz kesen UI/konfig.
- `lib/features/<feature>/`:
  - `screens/`: Route seviyesindeki View’lar (örn. `dashboard_screen.dart`).
  - `widgets/`: Parçalı UI bileşenleri (yalnızca görünüm).
  - `presentation/`: Presenter arayüzleri + uygulamaları (örn. `dashboard_presenter.dart`, `settings_presenter.dart`).
  - `state/` veya `data/`: Bloc/Cubit veya Provider tabanlı yöneticiler, repo’lar, modeller.

Örnek: Dashboard
- Presenter: `lib/features/dashboard/presentation/dashboard_presenter.dart`
- View: `lib/features/dashboard/screens/dashboard_screen.dart`
- Model/State: `lib/features/dashboard/state/*`

## SOLID Uygulaması
- Single Responsibility: View, Presenter ve Model katmanları tek sorumluluk taşır; sınırlar karıştırılmaz.
- Open/Closed: View’ları değiştirmeden yeni davranışlar presenter’a eklenir; arayüzler genişletilir.
- Liskov Substitution: Presenter arayüzü (`IDashboardPresenter` vs.) yerine tüm uygulamalar sorunsuz geçebilir.
- Interface Segregation: Her özelliğe özel küçük arayüzler (örn. `ISettingsPresenter`); şişkin interface yok.
- Dependency Inversion: View’lar somut sınıflara değil presenter arayüzlerine bağımlı olur; DI için `provider` (Provider<>) veya `flutter_bloc` (BlocProvider) tercih edilir.

## Clean Code Kuralları
- Adlandırma: Anlamlı, niyeti ifade eden isimler. Dosyalar `snake_case.dart`, tipler `UpperCamelCase`, değişken/metotlar `lowerCamelCase`, sabitler `const` + `lowerCamelCase`.
- Küçük bileşenler: UI bileşenlerini odaklı tutun; tekrar eden stilleri `core/` altında toplayın.
- Yan etki yönetimi: View içinden doğrudan state değiştirmeyin; presenter aracılığıyla çağırın. Presenter da repo/bloc/cubit/notify ediciye deleg eder.
- Açık bağımlılıklar: Presenter, ihtiyaç duyduğu servisleri DI ile alır (`Provider`/`BlocProvider`). Gizli global erişim yok.
- Test edilebilirlik: Presenter’lar saf Dart olarak yazılır; UI’dan bağımsız test edilir.

## Geliştirme Akışı
- View → Presenter: Widget, kullanıcı etkileşimlerinde sadece presenter arayüz metodlarını çağırır (örn. `presenter.refresh()`).
- Presenter → Model: Presenter, Bloc/Cubit aksiyonlarını tetikler veya Provider tabanlı yöneticilere/repo’lara deleg eder; gerektiğinde View’i bilgilendirmek için view arayüzünü (opsiyonel) kullanır.
- Durum okuma: UI, görsel durumu `context.watch<Bloc>()/context.select` veya `Provider.of<T>(context)/context.watch<T>()` ile okur; doğrudan mutable state tutmaz.
- Yaşam döngüsü: Presenter tek sefer okunur ve alan olarak saklanır; `dispose` içinde tekrar lookup yapılmaz (örn. `BlocProvider.of`/`Provider.of` çağrısından kaçının).

## Kod Örüntüleri
- Presenter tabanı: `lib/core/mvp/presenter.dart` içinde `attachView/detachView` barındıran temel sınıf.
- DI: `provider` ile `Provider<T>` veya `flutter_bloc` ile `BlocProvider` kullanın; presenter enjekte edin.
- View’larda arayüz: `implements <Feature>View` tercih edin; navigation/snackbar gibi UI etkileri view tarafından gerçekleştirilir, tetikleyici presenter’dan gelir.
- Şablonlar: Yeni özellik eklerken aşağıdaki şablonları baz alın:
  - `lib/core/mvp/templates/presenter_template.dart`
  - `lib/core/mvp/templates/view_widget_template.dart`

## Test
- Birim test: Presenter mantığı (senaryolar, hatalar, delegasyon). Repo/Notifer bağımlılıklarını sahtelemek.
- Widget test: Görünüm durum bağlama, etkileşimlerin presenter’a delegasyonu ve görsel çıktılar.
- Golden (varsa): Görsel regresyon için kritik widget’lar.

## Komutlar
- `flutter pub get`: Bağımlılıkları kurar.
- `flutter run -d chrome` veya `flutter run`: Uygulamayı çalıştırır.
- `flutter analyze`: Statik analiz ve linter.
- `dart format .`: Otomatik biçimlendirme.
- `flutter test`: Birim/widget testleri.
- `flutter build apk --release` / `flutter build ios --release`: Platforma özel sürüm derlemeleri.

## PR ve Commit Kuralları
- Conventional Commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`. Örn: `refactor(dashboard): move logic to presenter`.
- PR’lar: Açıklama, ekran görüntüsü/GIF (UI değiştiyse), test adımları ve ilgili issue bağlantıları. Analiz ve testler geçmeli.

## Güvenlik ve Yapılandırma
- SDK: `pubspec.yaml` içindeki `environment.sdk`’e uyun.
- Sırlar: İmzalama dosyaları/sırlar commitlenmez; `build/` ignore’dur.

---
Not: Mevcut projede hali hazırda farklı state management çözümleri bulunabilir. Yeni geliştirmelerde öncelik Bloc/Cubit veya Provider’dır. Kademeli geçiş yapılabilir; view içinde iş kuralı eklemeyin, presenter arayüzü ile genişletin.
