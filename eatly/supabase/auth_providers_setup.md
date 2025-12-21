# Supabase Auth Providers Kurulum Rehberi

Bu rehber, uygulamanın yeni kayıt akışı için gerekli Supabase ve Google Cloud ayarlarını içerir.

---

## 1. Anonymous Auth (Anonim Giriş) Aktifleştirme

Anonim giriş, kullanıcıların hesap oluşturmadan önce onboarding sürecini tamamlamasını sağlar.

### Adımlar:

1. [Supabase Dashboard](https://supabase.com/dashboard) → Projenizi seçin
2. Sol menüden **Authentication** → **Providers** sekmesine gidin
3. **Anonymous Sign-ins** bölümünü bulun
4. **Enable Anonymous Sign-ins** seçeneğini **ON** yapın
5. **Save** butonuna tıklayın

> ✅ Bu ayar aktifleştirildikten sonra uygulama anonim oturum oluşturabilir.

---

## 2. Google OAuth Aktifleştirme

Google ile giriş için hem Google Cloud Console hem de Supabase ayarları gereklidir.

### A. Google Cloud Console Ayarları

1. [Google Cloud Console](https://console.cloud.google.com/) → Yeni proje oluşturun veya mevcut projeyi seçin

2. **APIs & Services** → **OAuth consent screen** → **External** seçin ve kaydedin
   - App name: `Eatly`
   - User support email: E-posta adresiniz
   - Developer contact: E-posta adresiniz

3. **APIs & Services** → **Credentials** → **Create Credentials** → **OAuth client ID**

4. **Android için** (varsa):
   - Application type: `Android`
   - Package name: `com.example.eatly` (AndroidManifest.xml'den kontrol edin)
   - SHA-1 fingerprint:
     ```bash
     # Debug için:
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     
     # Windows için:
     keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```

5. **iOS için** (varsa):
   - Application type: `iOS`
   - Bundle ID: `com.example.eatly` (Info.plist'ten kontrol edin)

6. **Web için**:
   - Application type: `Web application`
   - Authorized redirect URIs:
     ```
     https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback
     ```
   - `YOUR_PROJECT_REF` değerini Supabase Dashboard → Settings → General'den alın

7. **Client ID** ve **Client Secret** değerlerini kaydedin

### B. Supabase Ayarları

1. [Supabase Dashboard](https://supabase.com/dashboard) → Projenizi seçin
2. **Authentication** → **Providers** → **Google**
3. **Enable Sign in with Google** seçeneğini **ON** yapın
4. Google Cloud Console'dan aldığınız değerleri girin:
   - **Client ID**: Web client ID
   - **Client Secret**: Web client secret
5. **Save** butonuna tıklayın

### C. Flutter Uygulamasında Güncelleme

`lib/core/services/auth_service.dart` dosyasında `YOUR_WEB_CLIENT_ID` değerini güncelleyin:

```dart
const webClientId = 'YOUR_ACTUAL_WEB_CLIENT_ID.apps.googleusercontent.com';
```

### D. Android Yapılandırması

`android/app/build.gradle` dosyasında:

```gradle
android {
    defaultConfig {
        // ...
        minSdkVersion 21  // Google Sign-In için minimum 21 gerekli
    }
}
```

### E. iOS Yapılandırması (Opsiyonel)

`ios/Runner/Info.plist` dosyasına ekleyin:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reversed client ID - Google Cloud Console'dan alın -->
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

---

## 3. E-posta Ayarları (Opsiyonel)

E-posta doğrulama ve şifre sıfırlama için:

1. **Supabase Dashboard** → **Authentication** → **Email Templates**
2. İstediğiniz şablonları Türkçe olarak özelleştirin:
   - Confirm signup
   - Reset password
   - Magic link

### SMTP Ayarları (Özel domain için):

1. **Project Settings** → **Auth** → **SMTP Settings**
2. Kendi SMTP sunucunuzu yapılandırın

---

## 4. RLS (Row Level Security) Politikaları

Profiles tablosu için RLS politikalarını kontrol edin:

```sql
-- Kullanıcılar kendi profillerini okuyabilir
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- Kullanıcılar kendi profillerini güncelleyebilir
CREATE POLICY "Users can update own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);

-- Yeni kullanıcılar profil oluşturabilir
CREATE POLICY "Users can insert own profile"
ON profiles FOR INSERT
WITH CHECK (auth.uid() = id);

-- Anonim kullanıcılar da profil oluşturabilir
CREATE POLICY "Anonymous users can create profile"
ON profiles FOR INSERT
WITH CHECK (auth.uid() = id);
```

---

## 5. Test Etme

1. Uygulamayı çalıştırın: `flutter run`
2. "Başla" butonuna tıklayın
3. Onboarding adımlarını tamamlayın
4. Son ekranda:
   - **Google ile devam et** → Google hesabınızla giriş yapın
   - **E-posta ile devam et** → E-posta ve şifre girin

---

## Sorun Giderme

### "Google Sign-In failed" hatası
- Client ID'nin doğru olduğundan emin olun
- SHA-1 fingerprint'in doğru eklendiğinden emin olun
- Redirect URI'nin doğru yapılandırıldığından emin olun

### "Anonymous sign-in not enabled" hatası
- Supabase Dashboard'da Anonymous Sign-ins'in aktif olduğundan emin olun

### Profil kaydedilemiyor hatası
- RLS politikalarının doğru yapılandırıldığından emin olun
- Profiles tablosunda gerekli alanların olduğundan emin olun:
  ```sql
  -- Bu SQL'i daha önce çalıştırdıysanız tekrar çalıştırmanıza gerek yok
  -- supabase/profiles_onboarding_fields.sql dosyasına bakın
  ```

---

## Kontrol Listesi

- [ ] Anonymous Auth aktifleştirildi
- [ ] Google OAuth (opsiyonel):
  - [ ] Google Cloud Console'da OAuth credentials oluşturuldu
  - [ ] Supabase'de Google provider aktifleştirildi
  - [ ] Flutter kodunda Client ID güncellendi
- [ ] Profiles tablosu alanları eklendi
- [ ] RLS politikaları kontrol edildi
- [ ] Uygulama test edildi

