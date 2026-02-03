# Playlearn – Ücretsiz Görsel ve Ses Kaynakları

<!-- markdownlint-disable MD060 -->

4 yaş İngilizce kelime uygulaması (Playlearn) için CC0 / ücretsiz, kolay indirilebilir asset kaynakları. Tüm dosyalar `assets/playlearn/files/` içine koyulur; pubspec'te tek giriş `assets/playlearn/files/` olduğu için yeni dosya eklemek için pubspec değişikliği gerekmez.

---

## 1) Görseller – CC0 / ücretsiz PNG (çocuk dostu)

| Kaynak | Açıklama | Link |
|--------|----------|------|
| **Pixabay – hayvan PNG** | Çizim/illüstrasyon, çok sayıda PNG | [animal png](https://pixabay.com/images/search/animal%20png/) |
| **Pixabay – kedi/köpek** | Cat/dog çizim, cartoon tarzı | [cat dog](https://pixabay.com/images/search/cat%20dog/) |
| **Vecteezy – cute pets** | Evcil hayvan vektör seti (SVG indirilebilir) | [cute pets](https://www.vecteezy.com/free-vector/cute-pets) |

**Not:** Pixabay CC0. Vecteezy'de lisansı kontrol et (Free for personal/commercial / attribution).

---

## 2) Sesler – kısa hayvan ses efektleri (MP3/WAV)

| Kaynak | Açıklama | Link |
|--------|----------|------|
| **Pixabay – pets** | Kedi, köpek vb. evcil sesler | [pets](https://pixabay.com/sound-effects/search/pets/) |
| **Pixabay – cat meow** | Kedi miyavlaması | [cat meow](https://pixabay.com/sound-effects/search/cat%20meow/) |
| **Pixabay – dog bark** | Köpek havlaması | [dog barking](https://pixabay.com/sound-effects/search/dog%20barking/) |

İndirilen sesleri `assets/playlearn/files/` içine koy (örn. `cat_meow.mp3`, `dog_bark.mp3`).

---

## 3) Flutter'da kullanım

### Görseller

- **PNG:** `Image.asset('assets/playlearn/files/cat.png', width: 200, height: 200)`
- **SVG:** `flutter_svg` ile
  `SvgPicture.asset('assets/playlearn/files/cat.svg', width: 200, height: 200)`

### Ses

- Kısa efekt için `audioplayers` veya `just_audio`:

  ```dart
  final player = AudioPlayer();
  await player.play(AssetSource('playlearn/files/dog_bark.mp3'));
  ```

- Kelime telaffuzu şu an **flutter_tts** ile; ileride pre-recorded ses istersen aynı klasöre MP3 koyup yukarıdaki gibi çalabilirsin.

---

## 4) Önerilen dosya adları (Animals konusu)

| Kelime | Görsel | Ses (opsiyonel) |
|--------|--------|------------------|
| cat | `cat.png` veya `cat.svg` | `cat_meow.mp3` |
| dog | `dog.png` / `dog.svg` | `dog_bark.mp3` |
| bird | `bird.png` / `bird.jpg` | `bird.mp3` |
| fish | `fish.png` / `fish.svg` | — |
| rabbit | `rabbit.png` / `rabbit.svg` | — |

Yeni konu eklerken aynı `files/` klasörüne ekleyebilir veya ileride `files/animals/`, `files/colors/` gibi alt klasörler + pubspec'e ek giriş kullanabilirsin.

---

## 5) Projede kullanılan asset'ler (referans)

Animals konusu için **tüm hayvanlar SVG** kullanıyor (her ekran ve cihazda net, ölçeklenebilir):

- **cat.svg:** [Black Cat Vector](https://commons.wikimedia.org/wiki/File:Black_Cat_Vector.svg) – Wikimedia Commons, CC0.
- **dog.svg:** [Dog.svg](https://commons.wikimedia.org/wiki/File:Dog.svg) – Wikimedia Commons, public domain (USDOT).
- **fish.svg:** [Fish icon](https://commons.wikimedia.org/wiki/File:Fish_icon.svg) – Wikimedia Commons, public domain (Vägverket).
- **rabbit.svg:** [Rabbit clipart](https://commons.wikimedia.org/wiki/File:Rabbit_clipart.svg) – Wikimedia Commons, CC0.
- **bird-vector.svg:** Kullanıcı tarafından eklenen vektör görsel.

**Görüntüleme:** `WordCard` tüm görselleri `BoxFit.contain` ile gösterir (kesme veya ezme yok); hizalama ortalanmış, kare hücre içinde. SVG’ler `SvgPicture.asset`, raster (PNG/JPEG) `Image.asset` ile; fallback `Icons.pets`.
