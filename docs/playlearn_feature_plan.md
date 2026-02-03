# Kids English Playlearn Feature – Uygulama Planı (Demo)

Bu belge, Kids English Playlearn demo feature planının kopyasıdır. Başka bir AI agent (örn. Codex) veya ekip tarafından okunup analiz edilebilir.

---

## Amaç ve Kapsam

- **Hedef kitle:** 4 yaş (Eşrefhan); okuma yok, sadece dinleme ve dokunma.
- **Demo kapsamı:** Sadece **tek özellik** – Tap-to-hear kelime listesi (Lingokids tarzı kulak dolgunluğu). Tema seçimi ve kelime listesi **ayrı sayfalarda**.
- **Kısıt:** Tek bir kod dosyası **500 satırı geçmeyecek**; büyük sayfalar widget'lara bölünecek.

## Seçilen Demo Özelliği: Tap-to-Hear Kelime Listesi

Demo için yapılacak tek feature:

- **Sayfa 1 – Tema seçimi:** Ana giriş (`/playlearn`): büyük kartlarla tek tema (örn. Animals). Tıklanınca kelime listesi sayfasına gider.
- **Sayfa 2 – Kelime listesi:** (`/playlearn/vocabulary/:topicId`): Seçilen temadaki kelimeler; büyük resim + büyük alan; dokununca TTS ile İngilizce kelime söylenir.

İleride eklenebilecekler (her biri **ayrı sayfa**, ayrı route): Quiz ("Which one is X?"), ek temalar, ilerleme/ödül. Bu planda yapılmayacak.

## Sayfa ve Route Yapısı

- **Route 1:** `/playlearn` → Tema seçimi sayfası (PlaylearnPage).
- **Route 2:** `/playlearn/vocabulary/:topicId` → Kelime listesi sayfası (VocabularyListPage). Topic ID path'ten okunur.

Her feature/oyun farklı sayfada; tek sayfada tek iş.

## Mimari Uyum

- **Domain (Flutter-free):** `VocabularyItem`, `TopicItem`, `VocabularyRepository`, `AudioPlaybackService` interface.
- **Data:** Sabit/asset kelime-tema verisi, `VocabularyRepository` impl, TTS ile `AudioPlaybackService` impl; DI'da kayıt.
- **Presentation:** Cubit sadece tema listesi + seçili tema + kelime listesi (quiz yok). İki ayrı sayfa: tema seçimi, kelime listesi; her sayfa kendi route'unda.
- **Dosya boyutu:** Tüm dosyalar **max 500 satır**. Sayfa/cubit büyürse parçala (sayfa body ayrı widget dosyasına taşı).
- **DI:** `lib/core/di/injector_registrations.dart` içinde `VocabularyRepository` ve `AudioPlaybackService` kaydı; `registerLazySingletonIfAbsent` kullan.
- **Routing:** `lib/core/router/app_routes.dart`, `lib/app/router/routes.dart`; app bar veya overflow'a "Playlearn" linki.
- **Type-safe erişim:** UI'da `context.cubit<T>()`, `context.state<T, S>()`, `TypeSafeBlocSelector<T, S, R>` kullan; raw `context.read` yok.
- **State modeli:** Basit state için Freezed; async emit'lerde `if (isClosed) return;` guard.

## Teknik Tercihler

- **Ses:** İlk aşamada **flutter_tts** ile kelime telaffuzu (kurulum kolay, ağ gerektirmez). İleride pre-recorded ses isterseniz `just_audio` veya `audioplayers` ile asset ses eklenebilir.
- **Görseller:** `assets/playlearn/files/`: tema ve kelime kartları için resimler (PNG/SVG). Local asset kullanımı; pubspec’te bu dizin tek girişle tanımlı.
- **Renk / tema:** `Theme.of(context).colorScheme` kullanımı; çocuk dostu parlak renkler.
- **Erişilebilirlik / 4 yaş:** Minimum dokunma alanı 44x48, büyük ikonlar ve resimler, tek adımlı geri butonu.
- **UI bileşenleri:** `CommonPageLayout`, `CommonLoadingWidget`, `PlatformAdaptive.*`, `showAdaptiveDialog()` kullan; raw Material button/dialog yok.
- **Responsive:** `context.responsive*`, `context.page*Padding`, safe area + klavye inset uyumu; text scale 1.3+.

## Dosya Yapısı (Demo – quiz yok, max 500 satır/dosya)

```text
lib/features/playlearn/
  domain/
    playlearn_domain.dart
    vocabulary_repository.dart
    vocabulary_item.dart
    topic_item.dart
    audio_playback_service.dart
  data/
    asset_vocabulary_repository.dart
    tts_audio_service.dart
  presentation/
    playlearn_cubit.dart
    playlearn_state.dart
    pages/
      playlearn_page.dart           # tema seçimi (ayrı sayfa)
      vocabulary_list_page.dart     # kelime listesi tap-to-hear (ayrı sayfa)
    widgets/
      topic_card.dart
      word_card.dart
      listen_button.dart
  playlearn.dart
```

- Quiz ve quiz widget'ları (quiz_page, quiz_options_grid, celebration_overlay) bu planda yapılmayacak; ileride ayrı sayfa olarak eklenebilir.
- Her dosya 500 satırı geçmeyecek; gerekirse body ayrı widget dosyasına taşınacak.

## Lokalizasyon

- `lib/l10n/app_en.arb` (ve diğer diller): `playlearnTitle`, `playlearnTopicAnimals`, `playlearnListen`, `playlearnTapToListen`, `playlearnBack` vb. Çocuğa gösterilen İngilizce kelimeler (cat, dog…) uygulama verisinde kalır.
- UI'da hardcoded string yok; tüm metinler `context.l10n.*`.

## Test Stratejisi

- **Domain/Data:** Repository ve TTS mock ile ses servisi unit testi.
- **Cubit:** `bloc_test` ile tema seçimi, kelime listesi yükleme.
- **Widget:** Tema seçimi ve kelime listesi sayfaları için widget testleri; ses butonu tıklaması.
- `./bin/checklist` ile doğrulama.

## Yaşam Döngüsü Notları

- `build()` içinde yan etki yok; TTS init ve veri yükleme `initState()` veya Cubit tarafında.
- `await` sonrası `context.mounted` kontrolü; `setState`/navigation öncesi `mounted` check.

## Bağımlılıklar

- **pubspec.yaml:** `flutter_tts`. Asset: `assets/playlearn/files/` (tüm dosyalar bu dizine eklenir).
- **Asset kaynakları:** Ücretsiz görsel/ses linkleri ve Flutter kullanımı için bkz. [Playlearn Asset Kaynakları](playlearn_asset_sources.md).

## Uygulama Sırası (Özet)

1. **Domain:** `VocabularyItem`, `TopicItem`, `VocabularyRepository`, `AudioPlaybackService`.
2. **Data:** Kelime/tema verisi (const veya asset), `AssetVocabularyRepository`, `TtsAudioService`, DI kaydı.
3. **Presentation:** `PlaylearnCubit` + state, **PlaylearnPage** (tema seçimi – ayrı sayfa), **VocabularyListPage** (kelime listesi tap-to-hear – ayrı sayfa); widget'lar; max 500 satır/dosya.
4. **Routing:** `AppRoutes`, `routes.dart` (iki route: `/playlearn`, `/playlearn/vocabulary/:topicId`); app bar veya overflow'a "Playlearn" linki.
5. **L10n:** Arayüz metinleri için arb.
6. **Test:** Repository, cubit, kritik widget'lar; `./bin/checklist`.

Bu plan, demo olarak sadece Tap-to-hear kelime listesini, her feature/oyunun ayrı sayfada ve her dosyanın 500 satır sınırı içinde kalması koşuluyla tanımlar.
