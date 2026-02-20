# Yapılanlar — Kendin App

## 1. Supabase Bağlantısı (Kritik)

### Sorun
- Web build'de `app_init_demo.dart` tamamen boştu — Supabase hiç başlatılmıyordu.
- `providers_demo.dart` in-memory demo repository'ler kullanıyordu — gerçek Supabase'e hiç bağlanmıyordu.
- Ne production ne de web tarafında `signInAnonymously()` startup'ta çağrılmıyordu.
- Sonuç: `auth.users` boş, `users` tablosu boş, anonim kullanıcı oluşmuyor.

### Düzeltme
- `app_init_demo.dart`: Supabase.initialize + signInAnonymously eklendi.
- `app_init_production.dart`: signInAnonymously eklendi.
- `providers_demo.dart`: Demo repo'lar yerine gerçek Supabase repo'ları kullanılıyor (AuthDatasource, EntryDatasource, ReflectionDatasource). Sadece NotificationService ve PremiumService demo kaldı (native-only plugin'ler).
- `supabase_client_setup.dart`: Debug print'ler eklendi (URL/Key durumu, init onay).

### Dosyalar
- `lib/app_init/app_init_demo.dart`
- `lib/app_init/app_init_production.dart`
- `lib/data/datasources/supabase_client_setup.dart`
- `lib/presentation/providers/providers_demo.dart`

---

## 2. Build Hataları

### `withValues` hatası
- `Color.withValues(alpha:)` Flutter 3.24'te yok.
- `withOpacity(0.1)` ile değiştirildi.
- Dosya: `lib/presentation/screens/language/language_screen.dart`

### `AuthException` isim çakışması
- `supabase_flutter` paketi gotrue'dan `AuthException` export ediyor.
- `app_exception.dart` da kendi `AuthException`'ını tanımlıyor.
- dart2js (web compiler) bu çakışmayı hata olarak veriyor.
- Çözüm: `import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;`
- Dosya: `lib/data/datasources/auth_datasource.dart`

---

## 3. App Crash Koruması

### Sorun
- `main()` içinde `initializeApp()` try/catch olmadan çağrılıyordu.
- Supabase init başarısız olursa (boş URL, ağ hatası), app hiç açılmıyordu.
- Landing page dahil hiçbir şey render edilemiyordu.

### Düzeltme
- `main.dart`: `initializeApp()` try/catch ile sarıldı.
- Hata durumunda app yine de başlıyor, debug log basılıyor.
- Dosya: `lib/main.dart`

---

## 4. Input Alanları — Sessiz Hata

### Sorun
- HomeScreen'de entry submit edilirken `user == null` kontrolü sessizce return ediyordu.
- Kullanıcı yazar, "Yazdım" butonuna basar, hiçbir şey olmaz — hata mesajı yok.
- Bu durum auth başarısız olduğunda gerçekleşiyor.

### Düzeltme
- `_submitEntry()`: user null olduğunda SnackBar ile hata mesajı gösteriliyor.
- Debug print eklendi.
- Dosya: `lib/presentation/screens/home/home_screen.dart`

---

## 5. Lokalizasyon Eksiklikleri

### Sorun
- `ReflectionScreen` hardcoded `AppStrings` (sadece Türkçe) kullanıyordu.
- Dil değişikliği bu ekrana uygulanmıyordu.
- `AppLocalizations`'da reflection, archive ve settings string'leri yoktu.

### Düzeltme
- `AppLocalizations`'a eklenen key'ler:
  - `reflectionLoading`, `reflectionNotReady` (TR + EN)
  - `premiumCtaStrong`, `premiumMonthlyPrice` (TR + EN)
  - `archive`, `archived` (TR + EN)
  - `settingsTitle`, `restorePurchase` (TR + EN)
- `ReflectionScreen`: `AppStrings` yerine `AppLocalizations` kullanılıyor.
- Dosyalar:
  - `lib/core/l10n/app_localizations.dart`
  - `lib/presentation/screens/reflection/reflection_screen.dart`

---

## Bilinen Durumlar (Henüz Değiştirilmedi)

| Durum | Açıklama |
|-------|----------|
| `SignupScreen` | Ölü kod — hiçbir ekran buraya navigate etmiyor. `LoginScreen` zaten sign-in/sign-up toggle içeriyor. |
| `SettingsScreen` | Ölü kod — `MenuScreen`'den buraya navigation yok. |
| `premium_screen.dart` | Sadece `premium_paywall_screen.dart` re-export ediyor. |
| `go_router` bağımlılığı | `pubspec.yaml`'da var ama projede hiç kullanılmıyor. |
| `KendinTextField.onSubmitted` | Parametre tanımlı ama widget içinde kullanılmıyor. |
| `SettingsScreen` AppStrings | Hardcoded Türkçe string'ler kullanıyor (ekran aktif değil). |
