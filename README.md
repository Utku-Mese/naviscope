# Naviscope

Ilgili Makale: https://medium.com/@mutkumese/gnss-ve-konum-servisleri-ger%C3%A7ekte-nas%C4%B1l-%C3%A7al%C4%B1%C5%9F%C4%B1r-7c9ac4ed998b

Naviscope, telefonunuzun konumunu “tek bir nokta” olarak değil; **GNSS fix kalitesi, uydu sinyalleri, doğruluk ve stabilite** gibi metriklerle birlikte görmenizi sağlayan bir mobil uygulamadır.

<img src="doc%20images/naviscope poster.png" alt="Naviscope Poster" width="1280" />

---

### Naviscope ne yapar?

- **Konum (Position)**: Enlem/boylam, hız, heading, yükseklik gibi temel metrikler.
- **Doğruluk (Accuracy)**: Konumun belirsizliğini (±m) görünür kılma.
- **Fix durumu**: Searching / 2D / 3D gibi durumları anlaşılır biçimde gösterme.
- **Uydu telemetrisi**: Uyduları, sinyal gücünü (C/N0) ve “used/visible” gibi ayrımları izleme.
- **Skyplot**: Uyduların gökyüzündeki dağılımını (geometri) görerek kaliteyi sezgisel okuma.

---

### GNSS’i (kısaca) nasıl düşünmeli?

GNSS (GPS/Galileo/GLONASS/BeiDou…), cihazın uydulardan gelen zaman bilgili sinyalleri kullanarak konumunu hesapladığı sistemler ailesidir.

Pratikte kullanıcı deneyimini en çok etkileyen şeyler şunlardır:

- **Uydu geometrisi**: Uydular gökyüzüne iyi yayılmamışsa hata büyüyebilir (DOP etkisi).
- **Sinyal kalitesi (C/N0)**: Zayıf sinyaller ve yansımalar (multipath/NLOS) konumu “zıplatabilir”.
- **Fix türü (2D/3D)**: 3D fix genelde daha sağlıklıdır; 2D fix yükseklik/dikey bileşenlerde kısıtlı olabilir.

Daha detaylı teknik anlatım için:

- `docs/gnss-konumlandirma-ve-naviscope.md`

---

### Görseller

<img src="doc%20images/1.png" alt="Naviscope screenshot 1" width="620" />

<img src="doc%20images/2.png" alt="Naviscope screenshot 2" width="620" />

<img src="doc%20images/3.png" alt="Naviscope screenshot 3" width="620" />

<img src="doc%20images/4.png" alt="Naviscope screenshot 4" width="620" />

<img src="doc%20images/5.png" alt="Naviscope screenshot 5" width="620" />

---

### Teknik

#### Gereksinimler

- Flutter SDK: **3.27.0** (Dart `>=3.6.0 <4.0.0`)
- Android Studio ve/veya Xcode (platforma göre)
- Android cihaz veya emulator (uydu telemetrisi gerçek cihazda daha anlamlıdır)

#### Kurulum

```bash
flutter pub get
```

#### Çalıştırma

Android:

```bash
flutter run
```

iOS (macOS gerekli):

```bash
cd ios && pod install && cd ..
flutter run
```

#### Notlar

- Android’de **precise (fine) location** izni verilmezse bazı GNSS/uydu API’leri sınırlı kalabilir.
- iOS tarafında CoreLocation, genel uygulama API’leriyle **uydu (satellite) düzeyi GNSS telemetrisi** sağlamaz. Bu nedenle uydu listesi / skyplot gibi ekranlar platformda **kısıtlı veya devre dışı** olabilir.
- Emülatörde GNSS uydu telemetrisi her zaman gerçekçi olmayabilir; saha testi için gerçek cihaz önerilir.
