# Eatly – Kişisel Sağlık ve Beslenme Takip Uygulaması

[🇬🇧 English README](README.md)

Eatly, kullanıcıların daha sağlıklı alışkanlıklar oluşturmasına yardımcı olmak için geliştirilen bir mobil sağlık ve beslenme takip uygulamasıdır. Uygulama; öğün takibi, yemek fotoğrafı analizi, su tüketimi takibi, spor aktivitesi kaydı, kalori hesaplama ve kişiselleştirilmiş beslenme önerilerini tek bir Flutter mobil deneyiminde bir araya getirir.

Proje; Flutter ile geliştirilmiş mobil uygulama ve yemek görsellerini analiz edebilen FastAPI tabanlı ayrı bir vision backend servisinden oluşur.

## Proje Hakkında

Eatly’nin amacı, günlük sağlık takibini daha pratik hale getirmektir. Kullanıcılar öğünlerini kaydedebilir, kalori ve makro besin değerlerini takip edebilir, su tüketimini izleyebilir, spor aktivitelerini ekleyebilir ve günlük/haftalık ilerlemelerini görüntüleyebilir. Uygulama, Supabase entegrasyonu ve servis tabanlı mimarisi ile geliştirilmiştir.

Bu proje; mobil uygulama geliştirme, backend entegrasyonu, API kullanımı, görsel analiz, kullanıcı kimlik doğrulama ve sağlık verisi takibi gibi konuları göstermek için uygundur.

## Özellikler

- **Kullanıcı Girişi ve Kayıt**
  - Kayıt olma ve giriş yapma akışı
  - Şifre sıfırlama desteği
  - Onboarding ve başlangıç ekranları

- **Beslenme Takibi**
  - Porsiyon bilgisiyle yemek ekleme
  - Kalori, protein, karbonhidrat, yağ, lif, vitamin ve mineral takibi
  - Günlük beslenme özeti oluşturma
  - Günlük toplamları hedef kalori ve makro değerleri ile karşılaştırma

- **Yemek Fotoğrafı Analizi**
  - FastAPI vision backend ile yemek fotoğrafı analizi
  - `/api/vision/analyze` endpoint’i üzerinden resim bytes gönderme
  - `features=labels,objects` ve `threshold` gibi opsiyonel parametreler
  - Docker ve Hugging Face Spaces üzerinde çalıştırılabilme

- **Kalori ve Enerji Hesaplama**
  - Kullanıcı profiline göre BMR hesaplama
  - Aktivite seviyesine göre TDEE tahmini
  - Kilo verme, koruma ve kas kazanımı gibi hedeflere uygun hesaplama yapısı

- **Spor Aktivitesi Takibi**
  - Koşu, yürüyüş, bisiklet, yüzme, antrenman, yoga, HIIT ve diğer aktiviteleri kaydetme
  - Aktivite türü ve süresine göre yakılan kaloriyi tahmin etme
  - Günlük ve geçmiş aktiviteleri görüntüleme

- **Su Tüketimi Takibi**
  - Günlük su tüketimini mililitre cinsinden kaydetme
  - Günlük su hedefi belirleme ve güncelleme
  - Günlük ve haftalık su tüketim verilerini görüntüleme

- **Öneriler ve İstatistikler**
  - Beslenme önerileri ve sağlıklı alışkanlık tavsiyeleri
  - Günlük/haftalık özet ekranları
  - Başarım ve ilerleme takibi için geliştirilebilir altyapı

- **Modern Mobil Mimari**
  - Flutter ve Dart frontend
  - Supabase backend entegrasyonu
  - Servis tabanlı kod yapısı
  - Çevrimdışı/senkronizasyon odaklı servis mimarisi

## Kullanılan Teknolojiler

| Teknoloji | Kullanım Amacı |
|-----------|----------------|
| Flutter | Çapraz platform mobil uygulama geliştirme |
| Dart | Mobil uygulamanın ana programlama dili |
| Supabase | Kimlik doğrulama, veritabanı ve backend servisleri |
| PowerSync | Offline-first senkronizasyon desteği |
| FastAPI | Vision backend API servisi |
| Hugging Face Transformers | Görsel analiz ve yapay zekâ model desteği |
| FatSecret API | Yemek tanıma ve besin değeri entegrasyonu |
| Docker | Backend servisinin konteynerleştirilmesi |

## Proje Yapısı

```text
eatly/
├── backend/                 # FastAPI vision backend
│   ├── app/                 # Backend uygulama dosyaları
│   ├── Dockerfile           # Docker yapılandırması
│   ├── requirements.txt     # Python bağımlılıkları
│   └── README.md            # Backend dokümantasyonu
│
├── eatly/                   # Flutter mobil uygulama
│   ├── android/             # Android proje dosyaları
│   ├── ios/                 # iOS proje dosyaları
│   ├── lib/
│   │   ├── app/             # App setup, routing, dialogs, bottom sheets
│   │   ├── core/            # Models, services, config, theme, utilities
│   │   └── ui/              # View ve arayüz bileşenleri
│   └── pubspec.yaml         # Flutter bağımlılıkları
│
└── README.md
```

## Kurulum

### Gereksinimler

Mobil uygulamayı çalıştırmadan önce şunların kurulu olması gerekir:

- Flutter SDK
- Android Studio veya Xcode
- Supabase projesi
- Analiz özellikleri için Supabase, FatSecret ve/veya Hugging Face API bilgileri

### Mobil Uygulama Kurulumu

Depoyu klonlayın:

```bash
git clone https://github.com/dursunozer/eatly.git
cd eatly/eatly
```

Flutter bağımlılıklarını yükleyin:

```bash
flutter pub get
```

Supabase ve API bilgilerinizi ilgili config dosyalarına ekleyin.

Uygulamayı çalıştırın:

```bash
flutter run
```

Android build almak için:

```bash
flutter build apk
```

iOS build almak için:

```bash
flutter build ios
```

## Vision Backend Kurulumu

Backend klasörüne gidin:

```bash
cd backend
```

Python bağımlılıklarını yükleyin:

```bash
pip install -r requirements.txt
```

Backend servisini yerelde çalıştırın:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 7860
```

Ana endpoint:

```http
POST /api/vision/analyze
```

Docker ile çalıştırmak için:

```bash
docker build -t eatly-vision .
docker run -p 7860:7860 eatly-vision
```

## Gelecek Geliştirmeler

- Daha doğru yemek tanıma sonuçları
- Daha gelişmiş besin veritabanı entegrasyonu
- Barkod okuma desteği
- Daha detaylı grafikler ve istatistikler
- Başarım ve rozet sistemi
- Çoklu dil desteğinin geliştirilmesi
- Otomatik testler
- Daha gelişmiş hata yönetimi ve API yapılandırması

## Katkıda Bulunma

Katkılar memnuniyetle karşılanır. Katkıda bulunmak için:

```bash
git checkout -b feature/yeni-ozellik
git add .
git commit -m "feat: yeni özellik eklendi"
git push origin feature/yeni-ozellik
```

Daha sonra pull request oluşturabilirsiniz.

## Lisans

Bu depoda şu anda açık bir lisans dosyası bulunmamaktadır. Projeyi ticari amaçla kullanmadan veya dağıtmadan önce depo sahibiyle iletişime geçmeniz önerilir.

## Geliştirici

**Dursun Özer**  
GitHub: [@dursunozer](https://github.com/dursunozer)
