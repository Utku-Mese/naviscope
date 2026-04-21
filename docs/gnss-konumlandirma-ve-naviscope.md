# GNSS ve Konumlandırma Servisleri: Nasıl Çalışır? 

Bu doküman, GNSS (Global Navigation Satellite System) başta olmak üzere modern konumlandırma servislerinin (GNSS, hücresel, Wi‑Fi, IMU/sensör füzyonu) uçtan uca nasıl çalıştığını anlatır. Anlatım, uygulamadaki akış ve ekranlarla da (izin ekranı, dashboard metrikleri, harita, uydular listesi, skyplot) birebir ilişkilendirilmiştir.



## İçindekiler

- [1. Konumlandırma problemini doğru tanımlamak](#1-konumlandırma-problemini-doğru-tanımlamak)
- [2. GNSS temel kavramlar: uydu sinyali, ölçüm, çözüm](#2-gnss-temel-kavramlar-uydu-sinyali-ölçüm-çözüm)
- [3. GNSS nasıl konum üretir? (pseudorange, trilaterasyon, saat hatası)](#3-gnss-nasıl-konum-üretir-pseudorange-trilaterasyon-saat-hatası)
- [4. Çözüm kalitesi: 2D/3D fix, doğruluk, geometri (DOP)](#4-çözüm-kalitesi-2d3d-fix-doğruluk-geometri-dop)
- [5. Hata kaynakları ve “neden bazen sapar?”](#5-hata-kaynakları-ve-neden-bazen-sapar)
- [6. Telefonlarda konum: “Fused Location” ve sensör füzyonu](#6-telefonlarda-konum-fused-location-ve-sensör-füzyonu)
- [7. Naviscope’ta veri akışı ve ekranlar: uygulamada neyi gösteriyoruz?](#7-naviscopeta-veri-akışı-ve-ekranlar-uygulamada-neyi-gösteriyoruz)
- [8. Uygulamadaki metrikler nasıl yorumlanır?](#8-uygulamadaki-metrikler-nasıl-yorumlanır)
- [9. Tasarım/ürün önerileri: kullanıcıya doğru konum deneyimi](#9-tasarımürün-önerileri-kullanıcıya-doğru-konum-deneyimi)
- [10. Sık sorulan sorular](#10-sık-sorulan-sorular)
- [Ek: Terimler sözlüğü](#ek-terimler-sözlüğü)

---

## 1. Konumlandırma problemini doğru tanımlamak

“Konum bulma” aslında tek bir şey değildir. Uygulama ihtiyacına göre aşağıdaki çıktılardan bir veya birkaçını üretmeye çalışırız:

- **Enlem/boylam**: Harita üzerinde nokta.
- **Yükseklik**: GNSS’in yükseklik çözümü çoğu zaman yatay konuma göre daha gürültülüdür; uygulamalar bunu ayrıca ele alır.
- **Hız**: GNSS’ten (Doppler) veya ardışık konumlardan türetilebilir.
- **Yön/heading**: Telefonun pusulası (manyetometre) ya da hareket yönü (course over ground) ile tahmin edilir.
- **Doğruluk/uncertainty**: “Bu nokta ne kadar güvenilir?” sorusuna sayısal yanıt (ör. ±8 m).
- **Zaman**: GNSS zamanı UTC ile yakından ilişkilidir; sensör verilerini GNSS ile eşleştirmek için kritik.

Uygulamalar çoğu zaman bu çıktıları **tek bir sağlayıcıdan** değil, **birden fazla kaynaktan** birleştirerek üretir: GNSS + ağ + sensörler + filtreleme + OS servisleri.

![1](/Users/utku/Downloads/GNSS images/1.png)

---

## 2. GNSS temel kavramlar: uydu sinyali, ölçüm, çözüm

GNSS şemsiyesi altında birden fazla uydu takımyıldızı vardır:

- **GPS (ABD)**
- **GLONASS (Rusya)**
- **Galileo (AB)**
- **BeiDou (Çin)**
*(bazı cihazlarda QZSS, NavIC gibi bölgesel sistemler de görülebilir)*

Her uydu, çok hassas saatlerle zaman bilgisi ve yörünge bilgisi (ephemeris) içeren sinyaller yayınlar. Alıcı (telefon) bu sinyalleri alıp işleyerek konumunu hesaplar.

GNSS’in “mucizesi” şu fikre dayanır:

- Uydu sinyalinin ne zaman gönderildiğini ve size ne zaman ulaştığını bilirseniz (yaklaşık),
- **Sinyalin uçuş süresinden** uydu‑alıcı arasındaki mesafeyi (pseudorange) tahmin edersiniz,
- En az 4 uydu ile (x, y, z + alıcı saat hatası) çözüm üretirsiniz.

---

## 3. GNSS nasıl konum üretir? (pseudorange, trilaterasyon, saat hatası)

### 3.1 Pseudorange nedir?

İdeal dünyada:

$$
\text{mesafe} = c \cdot (t_\text{alım} - t_\text{gönderim})
$$
Burada \(c\) ışık hızıdır. Ancak telefonun saati, uydular kadar hassas değildir. Bu yüzden hesaplanan mesafe “gerçek mesafe” değil **pseudorange** olur; içinde alıcı saat hatası (clock bias) ve çeşitli gecikmeler bulunur.

Basitleştirilmiş ölçüm modeli:

$$
\rho_i = r_i + c \cdot \Delta t + d_\text{iono} + d_\text{tropo} + \epsilon
$$


- $$rho_i$$: i’inci uyduya pseudorange
- $$r_i$$: geometrik gerçek mesafe
- $$Delta_t$$: alıcı saat hatası
- $$d_\text{iono}$$, $$d_\text{tropo}$$: atmosferik gecikmeler
- $$epsilon$$: çok yollu (multipath), gürültü vb.

### 3.2 Neden 4 uydu?

Bilinmeyenler:

- **x, y, z** (3 boyutlu konum)
- **alıcı saat hatası** ($$Delta_t$$)

Toplam 4 bilinmeyen → en az 4 uydu ölçümü gerekir. 2D fix (yüksekliği sabitleme) gibi durumlarda 3 uyduyla “yaklaşık” çözümler de üretilir; uygulamada bu yüzden **2D / 3D fix** ayrımı görürsünüz.

### 3.3 Doppler ve hız

Konum “anlık” çözüm gibi görünse de, alıcı sinyal taşıyıcısındaki Doppler kaymasını ölçerek **hızı** çok iyi tahmin edebilir. Bu, düşük örneklemli konumdan türetilen hızdan genellikle daha stabildir.

![2](/Users/utku/Downloads/GNSS images/2.png)

---

## 4. Çözüm kalitesi: 2D/3D fix, doğruluk, geometri (DOP)

### 4.1 Fix türleri (Naviscope’ta görünen)

Uygulama tarafında fix türleri şu şekilde modelleniyor:

- **none**: Fix yok
- **searching**: Uydu aranıyor / çözüm kuruluyor
- **fix2D**: 2 boyutlu çözüm (yükseklik güvenilir değil ya da sabitlenmiş)
- **fix3D**: 3 boyutlu çözüm

Naviscope dashboard’unda bu durum bir rozetle gösteriliyor ve fix varsa kalite skoru da yanına ekleniyor.

### 4.2 DOP (Dilution of Precision) – geometri neden önemli?

Aynı sayıda uydu görseniz bile dağılımları (gökyüzündeki açıları) kötü ise çözüm kötüleşir. DOP, hatanın geometri nedeniyle büyümesini özetleyen bir çarpan gibi düşünülebilir:

- **GDOP**: genel (konum + zaman)
- **PDOP**: 3D konum
- **HDOP**: yatay
- **VDOP**: dikey

Telefon seviyesinde her zaman DOP’ları doğrudan görmek kolay değildir; ama **skyplot** ve “used in fix”/“visible” metrikleri geometri hakkında sezgisel ipucu verir.

### 4.3 Doğruluk (accuracy) neyi ifade eder?

Uygulamalarda “accuracy” çoğu zaman **1‑sigma yatay belirsizlik** gibi raporlanır (platforma göre değişir). Harita ekranında gördüğünüz **accuracy circle** (yarıçapı metre cinsinden) bu belirsizliğin görselleştirilmiş halidir.

> Pratik okuma: “±8 m” gibi bir değer, gerçek konumun yüksek olasılıkla bu çember içinde olduğunu ima eder; ama şehir içince bu tahminler fazla iyimser olabilir.

---

## 5. Hata kaynakları ve “neden bazen sapar?”

GNSS konumunun “sapması” çoğu zaman tek bir nedenden değil, birden fazla etkinin birleşiminden olur:

- **Çok yollu yansıma (multipath)**: Sinyal binalardan yansıyıp gecikmeli gelir. Şehir içinde en yaygın hatalardan.
- **NLOS (Non‑Line‑of‑Sight)**: Uydu görünmüyordur ama yansıma sinyali görünüyordur; alıcı bunu yanlışlıkla direkt sinyal gibi kullanabilir.
- **Atmosfer (iono/tropo)**: Özellikle düşük yükseklik açılarında gecikme artar.
- **Uydu geometri zayıflığı**: Uydular aynı tarafta kümelenmişse.
- **Alıcı/anten kısıtları**: Telefon anteni küçük; kullanıcı eli ile gölgelenme, oryantasyon etkileri.
- **Kısıtlı frekanslar**: Tek frekans (L1/E1) daha sınırlı düzeltme imkânı.
- **OS filtresi / güç tasarrufu**: Telefon GNSS’i “kapatıp açabilir”, örnekleme düşebilir.

### C/N0 (Carrier‑to‑Noise density) neden kritik?

Naviscope’ta uydular listesinde sinyal gücünü **C/N0 dB‑Hz** gibi bir metrikle görüyorsunuz. Basit okuma:

- **daha yüksek C/N0** → daha temiz/sağlıklı sinyal → ölçüm gürültüsü genelde daha düşük
- **çok düşük C/N0** → yansıma/engellenme ihtimali → çözüm kararsızlaşabilir

> Not: Tek başına C/N0 her şeyi açıklamaz; geometri ve NLOS/multipath etkisi belirleyicidir.

![3](/Users/utku/Downloads/GNSS images/3.png)

---

## 6. Telefonlarda konum: “Fused Location” ve sensör füzyonu

Telefon işletim sistemleri genellikle uygulamalara tek bir “konum” vermez; bunun yerine bir **konum servisi** çalıştırır. Bu servis şunları birleştirebilir:

- **GNSS** (uydu)
- **Wi‑Fi** (SSID/BSSID veritabanı eşleşmeleri)
- **Hücresel** (baz istasyonu/triangülasyon)
- **Bluetooth beacon** (bazı senaryolar)
- **IMU**: ivmeölçer/jiroskop ile hareket modelleme
- **Pusula**: heading tahmini

Bu yaklaşımın amacı:

- İç mekânda GNSS yokken yine de “yaklaşık konum” üretmek,
- GNSS varken bile kısa süreli kesintileri yumuşatmak,
- Pil tüketimi/latency/doğruluk arasında denge kurmak.

### Naviscope’un Android yaklaşımı (projedeki tasarım)

Uygulamada Android tarafında iki akışın birlikte kullanıldığını görüyoruz:

- **Native GNSS telemetri stream**: Uydu seviyesinde veriler + GNSS fix bilgisi (uygun cihaz/Android API seviyesinde).
- **Geolocator position stream**: OS’in sağladığı konum (çoğu zaman fused/network) — özellikle emülatörde veya iç mekânda “GPS idle” kalınca veri akışının tamamen durmaması için.

Bu yaklaşımın faydası:

- GNSS telemetrisi geldiğinde uydu/skyplot ekranları beslenir,
- GNSS telemetrisi yoksa bile harita ve temel metrikler (lat/lon, hız, heading, accuracy) akmaya devam eder,
- Son GNSS snapshot’ı bir süre “cache” edilip fused konuma eklenerek UI daha tutarlı kalır.

> Bu, kullanıcıya “konum var ama uydu yok” ya da “uydu var ama anlık konum fused” gibi durumları daha düzgün hissettiren pratik bir mühendislik tercihi.

### 6.1 Naviscope’un Android native GNSS katmanı: LocationManager + GnssStatus

Naviscope’ta Android tarafında native bir eklenti, Flutter’a iki kanal üzerinden veri taşır:

- **Method channel (`naviscope/gnss`)**: Başlat/durdur, yetenek (capability) tespiti gibi kontrol çağrıları
- **Event channel (`naviscope/telemetry_stream`)**: Canlı telemetri akışı (konum + GNSS snapshot)

Bu eklenti, Android’in `LocationManager` API’sini kullanarak üç farklı sağlayıcıdan konum güncellemeleri isteyebilir:

- **GPS provider**: “Saf” GNSS odaklı konum
- **Network provider**: Hücresel/Wi‑Fi ile türetilen yaklaşık konum
- **Passive provider**: Başka uygulamalar veya fused yığın bir konum aldığı zaman “pasif” şekilde fix’leri iletebilen akış (özellikle emülatör/indoor senaryolarda can kurtarıcı)

Bu tasarımın kritik noktaları:

- **İzin duyarlılığı**: Uydu seviyesinde veri (`GnssStatus.Callback`) Android’de pratikte **fine (precise) konum izni** gerektirir. Sadece coarse (approximate) izin varsa konum akabilir ama uydu verisi hiç gelmeyebilir.
- **Idempotent GNSS kayıt**: Kullanıcı sistem ayarlarından sonradan “precise location” açarsa, akış ayakta kalırken GNSS callback sonradan bağlanabilir. Bu sayede “uydu ekranı neden boş?” sorunu daha az yaşanır.
- **Soğuk başlangıç / GPS ısınma**: İlk fix gelmeden UI boş kalmasın diye “last known location” ile ekranlar primelenebilir.

### 6.2 “Used in fix” güvenilir değilse ne yapmalı? (pratik heuristik)

Bazı cihazlarda/ROM’larda `GnssStatus.usedInFix()` alanı gerçekte fix varken bile sürekli `false` gelebilir. Naviscope’un native katmanında buna karşı pratik bir yaklaşım var:

- Eğer OS konum doğruluğu makulse (ör. accuracy çok kötü değilse),
- Uydu sayısı yeterliyse,
- En güçlü C/N0’lara ve makul elevation değerlerine sahip uydulardan “muhtemelen PVT’de kullanılanlar” seçilerek **used‑in‑fix** tahmini yapılır.

Bu yaklaşımın amacı “bilimsel olarak kesin” olmak değil; kullanıcıya skyplot ve uydu listesinde **beklediği görsel tutarlılığı** vermektir. Pilot kullanımında (ve saha testlerinde) “sinyaller güçlü görünüyor ama used=0” gibi çelişkiler, ürün algısını gereksiz yere bozar.

> Denge: Heuristikler faydalıdır ama şeffaflık önemlidir. İleride istenirse “inferred” işaretini UI’da küçük bir not ile belirtmek iyi bir ürün iyileştirmesi olabilir.

---

## 7. Naviscope’ta veri akışı ve ekranlar: uygulamada neyi gösteriyoruz?

Bu bölüm, uygulamanın kullanıcıya gösterdiği şeyleri konumlandırma teorisiyle eşleştirir.

### 7.1 İzin ekranı (Permission)

Uygulamada konum izni, kullanıcıya “neden gerekli” olduğunu açıklayan bir ekranla isteniyor. Bu ekran:

- **Uydu (satellite)**
- **Konum (position)**
- **Hareket (motion)**
- **Harita (map)**

gibi yetenekleri kullanıcıya vaad ediyor ve “GPS fixed” ikonlu bir butonla izin talebini başlatıyor.

Android tarafında manifestte en azından şu izinler tanımlı:

- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `FOREGROUND_SERVICE` (Android 10+ geolocator foreground service senaryoları için)

> Pratik not: Android’de “precise (fine)” izin verilmezse bazı GNSS durum/satellite API’leri uydu verisini kısıtlayabilir. Uygulamada bu durum, uydu ekranlarında kullanıcıya açıkça anlatılıyor.

### 7.2 Dashboard: “tek bakışta GNSS sağlığı”

Dashboard, GNSS’i bir mühendislik aracı gibi değil, **anlaşılır bir sağlık paneli** gibi sunuyor:

- **Fix rozetleri**: none/searching/2D/3D
- **Quality score (0–100)**: Uydu sayısı + kullanılan uydu sayısı + ortalama C/N0 + fix türü gibi bileşenlerden türetilmiş birleşik skor
- **Konum kartı**: lat/lon
- **Altitude**: metre ve feet alt satır
- **Hız**: km/h ve knots
- **Heading**: derece ve N/NE/E… gibi yön etiketi
- **Accuracy**: yatay doğruluk ve dikey doğruluk alt satırı
- **Sparkline grafikleri**: zaman içinde accuracy, speed, C/N0 trendleri
- **Constellation donut**: uyduların takımyıldızlarına dağılımı

Bu ekranın amacı: “Konum geliyor mu?”dan öte, “Konum ne kadar iyi?” sorusuna cevap vermek.

### 7.3 Harita: konum + belirsizlik + yön

Harita ekranında:

- Nokta (marker) ile **konum**,
- Metre cinsinden yarıçapla **accuracy circle** (belirsizlik),
- Heading varsa marker’ın **dönmesi**,
- Üst HUD’da lat/lon, altitude, accuracy, speed, heading özetleri

görülüyor. Kullanıcı haritayı elle sürükleyince “follow” kapanıyor; tekrar butonla konuma merkezleniyor.

### 7.4 Satellites ekranı: “visible vs used” + C/N0

Uydu ekranı, GNSS’in gerçekten “uydularla” çalıştığını gösteren en somut yer:

- **Used / Visible** sayacı
- Takımyıldız filtreleme (GPS/Galileo/…)
- “Used in fix only” seçeneği
- Her uydu için **C/N0**, kullanılma durumu, (varsa) carrier frequency gibi detaylar

Android’de **fine permission** yoksa veya platform sınırlıysa, kullanıcıya neden uydu verisi göremediği anlaşılır şekilde iletiliyor.

### 7.5 Skyplot: gökyüzü geometrisi

Skyplot ekranı, uyduların gökyüzündeki dağılımını gösterir:

- Merkez zenit, dış çember ufuk gibi düşünülebilir
- Uydu noktaları: takımyıldız rengine göre
- “Used in fix” farklı stil ile ayrılır
- **Elevation mask**: ufka yakın (düşük elevation) uyduları gizleyip multipath riskini azaltmaya yönelik analiz aracı

iOS tarafında CoreLocation satelit düzeyi veriyi sağlamadığı için bu ekran platform kısıtını kullanıcıya açıkça bildirir.



![4](/Users/utku/Downloads/GNSS images/4.png)

---

## 8. Uygulamadaki metrikler nasıl yorumlanır?

Bu bölüm, uygulamadaki sayıları “saha kullanımı” perspektifiyle okumanız için pratik bir rehberdir.

### 8.1 Fix türü

- **searching**: Cihaz uydu sinyali arıyor; ilk fix birkaç saniye ile birkaç dakika arasında değişebilir (AGPS, çevre, cihaz).
- **2D fix**: Yatay konum var ama yükseklik güvenilir değil (veya çözüm 3D için yeterli değil).
- **3D fix**: En iyi senaryo; yine de şehir içinde multipath olabilir.

### 8.2 Used / Visible

- **Visible**: Cihazın “iz” sürdüğü uydular.
- **Used**: Çözümde gerçekten kullanılanlar.

“Visible yüksek, Used düşük” durumları:

- Sinyal zayıf / C/N0 düşük
- Uydular ufka yakın (yüksek multipath riski)
- Bazı takımyıldızlar/kodlar o an çözümde tercih edilmiyor

### 8.3 Quality score (0–100)

Naviscope’ta quality score, kullanıcıya tek bir sayı ile “GNSS sağlığı” hissi verir. Bu skor:

- Fix yoksa / searching ise **0**
- Fix varsa:
  - kullanılan uydu sayısı arttıkça yükselir
  - kullanılan uyduların ortalama C/N0’su yükseldikçe yükselir
  - 3D fix, 2D’ye göre daha iyi puan alır

> Önemli: Bu tür skorlarda amaç “mutlak doğruluk tahmini” değil, kullanıcının trendi ve sağlığı hızlı okumasıdır.

### 8.4 Accuracy (±m) ve harita çemberi

- Çember büyüdükçe belirsizlik artar.
- İç mekânda OS fused konum “iyi görünen” ama gerçekte yanlış olabilen bir accuracy verebilir.
- Dikey doğruluk (vertical accuracy) genelde yataydan daha kötü olur; özellikle barometre olmayan cihazlarda.

### 8.5 Heading: course mu compass mı?

Uygulamada heading iki yoldan gelebilir:

- **Course heading**: Cihaz yeterince hızlı hareket ediyorsa (ör. \(> 1\,m/s\)), konum türeviyle bulunan hareket yönü daha güvenilir olabilir.
- **Compass heading**: Düşük hızda GNSS heading gürültülü olacağından pusula tercih edilebilir (ancak manyetik parazitlere duyarlı).

Bu yüzden dururken heading “zıplayabilir”; hareket edince daha stabil hale gelmesi normaldir.

---

## 9. Tasarım/ürün önerileri: kullanıcıya doğru konum deneyimi

Bu kısım, makaleyi “uygulama geliştirme” açısından da tamamlar.

- **İzin metnini somut fayda ile bağlamak**: “Uydu görünümü ve fix kalitesi gösterebilmemiz için precise location gerekli” gibi net açıklama.
- **Platform farklarını açıkça anlatmak**: iOS’ta uydu verisi yok → kullanıcı “bozuk” sanmasın.
- **‘Live’ hissi**: Dashboard’daki live indicator ve sparkline’lar iyi; örnekleme aralığı düşerse kullanıcıya “low update rate” gibi durumlar ayrıca gösterilebilir.
- **Hata modları**: GPS kapalı, izin yok, indoor/multipath, arka plan kısıtları gibi durumlar ayrı ayrı mesajlanmalı.

![son](/Users/utku/Downloads/GNSS images/son.png)

---

## 10. Sık sorulan sorular

### 10.1 “Uydular görünür ama konum kötü, nasıl olur?”

Çünkü **multipath/NLOS** ile cihaz “yanlış mesafe” ölçebilir. Ayrıca uyduların çoğu ufka yakınsa geometri zayıflar.

### 10.2 “İç mekânda neden bazen konum varmış gibi görünüyor?”

OS fused konum, Wi‑Fi/hücresel eşleşmelerle “yaklaşık konum” üretebilir. Bu konum, GNSS kadar güvenilir olmayabilir ama kullanıcı deneyimi için tercih edilir.

### 10.3 “Neden iOS’ta uydu ekranları yok?”

CoreLocation, satelit düzeyi telemetriyi genel uygulama API’leriyle sağlamaz. Bu bir uygulama eksikliği değil, platform kısıtıdır; Naviscope da bunu UI’da belirtir.

---

## Ek: Terimler sözlüğü

- **GNSS**: Uydu tabanlı global navigasyon sistemleri ailesi (GPS/Galileo/…).
- **Fix**: Alıcının konum çözümü üretebildiği durum.
- **2D/3D fix**: Yatay (2D) / yatay + dikey (3D) çözüm.
- **Pseudorange**: Saat hatası ve gecikmeler içeren ölçülen mesafe.
- **C/N0 (dB‑Hz)**: Sinyal‑gürültü yoğunluğu oranı; sinyal kalitesi göstergesi.
- **DOP**: Uydu geometrisinin hatayı büyütme etkisi.
- **Multipath**: Yansıma nedeniyle gecikmeli sinyal; özellikle şehir içi hatası.
- **Fused Location**: OS’in GNSS + ağ + sensörleri birleştirerek verdiği konum.
- **Heading**: Yön; pusula (manyetik) veya course (hareket yönü) olabilir.

