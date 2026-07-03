# Eatly – Kişisel Sağlık ve Beslenme Takip Uygulaması

![Eatly uygulaması görseli]({{file:file-DpY4eNxRPWbdUYtQVZtY3E}})

Eatly, kullanıcıların sağlıklı yaşam hedeflerine ulaşmalarına yardımcı olmak için tasarlanmış kapsamlı bir **mobil sağlık ve beslenme takip uygulamasıdır**. Flutter ve Supabase teknolojileri kullanılarak geliştirilen uygulama; öğünleri fotoğraflayarak analiz edebilme, günlük beslenme ve su tüketimini izleme, spor aktivitelerini kaydetme, kalori ihtiyacını hesaplama ve kişiselleştirilmiş öneriler sunma gibi birçok özelliği bir araya getirir. Proje, FastAPI ve Hugging Face modelleri üzerine kurulmuş bir görsel analiz servisini de içerir【437582640382414†L0-L4】.

## Proje Hakkında

Eatly’nin amacı, kullanıcıların **daha bilinçli beslenmelerini ve aktif kalmalarını** kolaylaştırmaktır. Uygulama, Supabase ile bulut tarafında kimlik doğrulama ve veri yönetimi sağlayarak çevrimdışı senkronizasyona olanak tanır. Uygulamanın çekirdeğinde çok sayıda servis (beslenme, spor, analiz, görüntü işleme, su takibi vb.) bulunur. Bu servisler, kullanıcıların günlük aktivitelerini kaydetmesini, kalorilerini otomatik olarak hesaplamasını ve kişisel hedeflerine göre tavsiyeler almasını sağlar【497633382069726†L50-L70】【196872517197012†L85-L96】.

## Temel Özellikler

- **Kullanıcı Girişi ve Kayıt:** Uygulama, Supabase kimlik doğrulaması ile güvenli şekilde hesap oluşturma, oturum açma ve şifre sıfırlama imkânı sunar. Onboarding ve başlangıç ekranları sayesinde yeni kullanıcılar için rehberlik sağlar.

- **Yemek Fotoğraf Analizi:** Eatly Vision Backend, FastAPI üzerine kuruludur ve `/api/vision/analyze` uç noktası ile gelen resim verilerini etiketleme veya nesne algılama işlemleri yapar; `features` parametresi ile **labels** ve/veya **objects** sonucu döndürür, `threshold` parametresi ile güven eşik değeri ayarlanabilir【437582640382414†L0-L4】. Servis, Docker üzerinden çalıştırılabilir ve Hugging Face Spaces üzerinde GPU donanımla dağıtılabilir【437582640382414†L6-L10】【437582640382414†L12-L15】.

- **Beslenme Takibi:** Kullanıcılar öğünlerini uygulamaya ekleyebilir. Örneğin örnek servis kodu yumurta ve ekmek gibi yiyecekleri porsiyon, kalori, protein, karbonhidrat ve yağ bilgileriy­le beraber kaydetmektedir【497633382069726†L14-L41】. Uygulama, gün içinde alınan toplam kalori ve makro besinleri toplayarak günlük özet oluşturur ve kullanıcının hedef değerleri ile karşılaştırır【497633382069726†L50-L70】. Beslenme önerileri (örneğin “Günde en az 2 litre su için” ve “Renkli sebze ve meyveler tercih edin”) servis aracılığıyla gösterilir【497633382069726†L91-L99】.

- **Kalori ve BMR/TDEE Hesaplama:** Uygulama, kullanıcının yaş, cinsiyet, boy ve kilo bilgilerine göre **Harris‑Benedict** formülü ile bazal metabolizma hızını (BMR) hesaplar ve aktivite seviyesine göre toplam günlük enerji ihtiyacını (TDEE) belirler【497633382069726†L101-L131】. Sedanter, hafif aktif, orta derecede aktif ve çok aktif seçenekleri desteklenir.

- **Spor Aktiviteleri:** Koşu, yürüyüş, bisiklet, yüzme, HIIT, yoga ve serbest antrenman gibi birçok aktivite tipi desteklenir. `addActivity` fonksiyonu aktivitenin adı, süresi ve tarihini alır; kalori hesabı _running = 10 kcal/dk, walking = 4 kcal/dk, cycling = 7 kcal/dk, swimming = 8 kcal/dk, workout = 6 kcal/dk, yoga = 3 kcal/dk, hiit = 12 kcal/dk, other = 5 kcal/dk_ katsayılarına göre otomatik yapılır【196872517197012†L11-L37】【196872517197012†L85-L96】. Kullanıcılar önceki aktivitelerini görüntüleyebilir veya silebilir.

- **Su Tüketimi ve Hedefler:** Uygulama, günlük su tüketimini mililitre cinsinden kaydeder ve toplam miktarı hesaplar【196872517197012†L101-L131】. Ayrıca kişisel günlük hedef belirleme ve su hedefini güncelleme özellikleri vardır【196872517197012†L134-L151】. Haftalık su verileri de analiz edilerek kullanıcının ilerlemesini gösterir【196872517197012†L159-L177】.

- **Analiz ve Öneriler:** `AnalysisService`, telefonun yerel deposunda bekleyen fotoğrafları düzenli aralıklarla analiz etmek için FatSecret ve Hugging Face servislerini kullanır; tanınan gıdaların besin değerlerini çıkarır ve uygulama arayüzüne gönderir【702634193166719†L20-L65】.

- **İstatistikler ve Başarımlar:** Günlük/haftalık özet ekranları sayesinde kalori alımı, makro besin dağılımı, su tüketimi ve spor aktiviteleri grafiklerle görselleştirilir. Ayrıca kullanıcıların hedeflerine ulaştıklarında rozetler ve başarımlar kazanabilecekleri bir sistem planlanmıştır.

- **Çoklu Dil ve Temalar:** Uygulama çoklu dil desteğine sahiptir ve hem açık hem koyu tema ile kullanılabilir. Stacked mimarisi ve servis yönelimli yapı ile modüler tasarlanmıştır.

## Kurulum

### Mobil Uygulama

1. Flutter SDK ve Android/iOS geliştirme ortamını kurun. Ayrıntılar için [Flutter resmi belgelerine](https://docs.flutter.dev/get-started/install) bakabilirsiniz.
2. Depoyu yerel makinenize klonlayın:
   ```bash
   git clone https://github.com/dursunozer/eatly.git
   cd eatly/eatly
   ```
3. Proje bağımlılıklarını yükleyin:
   ```bash
   flutter pub get
   ```
4. Supabase projesi oluşturun ve `lib/core/config` altında kullanılan API URL ve anon anahtarlarını kendi değerlerinizle güncelleyin. Ayrıca uygulama için **Hugging Face** API anahtarları veya FatSecret API bilgilerini `.env` dosyasına eklemeniz gerekebilir.
5. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```
6. iOS veya Android için üretim versiyonu derlemek isterseniz `flutter build ios` veya `flutter build apk` komutlarını kullanabilirsiniz.

### Vision Backend

Backend, FastAPI ile yazılmış ve görsel analiz için Hugging Face modellerini kullanan bir servistir. Geliştirme ortamında doğrudan Python ile veya Docker üzerinden çalıştırabilirsiniz.

**Kurulum (Python):**

1. Python 3.11 veya üzeri bir sürüm kurulu olmalıdır.
2. `backend` klasörüne gidin ve bağımlılıkları yükleyin:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```
3. Servisi çalıştırın:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 7860
   ```
   Ardından `POST /api/vision/analyze` uç noktasına resim bytes göndererek etiket/nesne sonucu alabilirsiniz【437582640382414†L0-L4】.

**Kurulum (Docker):**

Uygulamayı Docker ile izole bir şekilde çalıştırmak için backend klasöründe şu komutları çalıştırabilirsiniz:
```bash
docker build -t eatly-vision .
docker run -p 7860:7860 eatly-vision
```
Bu adımlar, backend’in doğru şekilde yapılandırıldığında otomatik olarak FastAPI sunucusunu başlatır【437582640382414†L6-L10】. Hugging Face Spaces üzerinde dağıtmak için alan türünü “Docker” olarak ayarlayıp GPU’lu bir donanım seçerek aynı giriş noktasını (`uvicorn app.main:app`) kullanabilirsiniz【437582640382414†L12-L15】.

## Kullanılan Teknolojiler

| Teknoloji | Açıklama |
|-----------|---------|
| **Flutter & Dart** | Çapraz platform mobil uygulama geliştirme çerçevesi; Stacked mimarisi ve servis odaklı yapıyla modüler ve okunabilir kod sağlar. |
| **Supabase** | Açık kaynaklı backend platformu; kimlik doğrulama, veritabanı, depolama ve gerçek zamanlı özellikler sunar. PowerSync ile çevrimdışı senkronizasyon desteklenir. |
| **FastAPI** | Vision backend için modern, hızlı bir web çerçevesi; REST API oluşturur ve Docker üzerinde çalıştırılabilir. |
| **Hugging Face Transformers** | Görüntü sınıflandırma ve nesne algılama gibi yapay zekâ görevleri için model sağlar; API’den gelen sonuçlar besin analizi için kullanılır. |
| **FatSecret API** | Fotoğraflardan tanınan yiyecekler için besin değerlerini almak amacıyla kullanılır; `AnalysisService` bu API’yi entegre eder【702634193166719†L20-L65】. |
| **Docker** | Backend’in konteynerleştirilmesi ve taşınabilir ortamda çalıştırılması. |

## Katkıda Bulunma

Katkılarınızı memnuniyetle karşılıyoruz! Hataları veya iyileştirme önerilerinizi **Issues** bölümünde bildirebilir veya doğrudan **Pull Request** oluşturabilirsiniz. Kod katkıları yaparken aşağıdaki noktalara dikkat edin:

1. Değişikliklerinizin başka özellikleri bozmamasına dikkat edin; test edilebilir bir mimari tercih edin.
2. Clear, kısa açıklamalarla commit mesajları yazın.
3. Kod stiline ve projenin dosya yapısına uyum sağlayın; servis temelli yapı ve Stacked mimarisi içinde yeni servisler ekleyin veya mevcut olanları genişletin.
4. Gerekli durumlarda yeni bağımlılıkları ve API anahtarlarını dokümantasyonda belirtin.

## Lisans

Bu depoda henüz açık bir lisans dosyası bulunmadığından, projenin kullanım koşulları geliştirici tarafından belirlenir. Kişisel kullanım veya eğitim amaçlı denemelerde kullanabilirsiniz; ticari veya yaygın dağıtım durumlarında lütfen depoyu oluşturan geliştirici ile iletişime geçin.
