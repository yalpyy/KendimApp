# Kendin App — Test Raporu

## Proje Mimari Ozeti

- **State Management:** Flutter Riverpod (StateNotifier)
- **Auth State:** `currentUserProvider` → tek kaynak (duplicate yok)
- **Auth Chain:** `AuthDatasource → AuthRepositoryImpl → AuthService → CurrentUserNotifier`
- **Navigation:** `Navigator.push(MaterialPageRoute(...))` — GoRouter kullanilmiyor (pubspec'te var ama bagli degil)
- **Backend:** Supabase (auth + PostgreSQL + Edge Functions)
- **Lokalizasyon:** TR + EN (`AppLocalizations`)

---

## Yapilan Isler

### 1. Ayarlar (Menu) Sayfasi — YENIDEN YAZILDI
- **Dosya:** `lib/presentation/screens/menu/menu_screen.dart`
- **Durum:** TAMAMLANDI
- **Yeni Ozellikler:**
  - **Kullanici Bilgi Karti:** User ID (kopyala butonu), E-posta, Hesap tipi (Anonim/Kayitli), Premium durumu, Admin badge
  - **3 kart:** Derinlik, Dil, Hakkinda
  - **Admin karti:** Sadece `is_admin = true` kullanicilara gorunur
  - **Giris Yap butonu:** Anonim kullanicilar icin (OutlinedButton)
  - **Cikis Yap butonu:** Kayitli kullanicilar icin (OutlinedButton)
  - **Debug Bolumu:** Acilir/kapanir — Supabase session JSON, token expiry, user metadata
- **Navigation:** HomeScreen > Menu ikon (sag ust `...`) > MenuScreen

### 2. Admin Paneli — GUNCELENDI
- **Dosya:** `lib/presentation/screens/admin/admin_screen.dart`
- **Durum:** TAMAMLANDI
- **Ozellikler:**
  - 4 istatistik karti: Toplam Kullanici, Premium Kullanici, Toplam Yazi, Toplam Yansima
  - Kullanici listesi: Isim + tarih + Premium/Admin/Ucretsiz badge
  - **YENI: Yansimalar Debug Tablosu:** reflection_id, user_id, week_start, sentence_count, created_at, archived badge
  - Pull-to-refresh + yenile butonu
  - Sadece `is_admin = true` kullanicilara gorunur

### 3. Admin Data Modeli
- **UserEntity:** `isAdmin` field
- **UserModel:** `is_admin` JSON alanini okuyor
- **AuthDatasource:** `getAdminStats()` + `getAllUsers()` + `getAllReflections()` metodlari
- **Migration:** `supabase/migrations/002_add_admin_and_display_name.sql`

### 4. Mock Test Verisi
- **Dosya:** `supabase/seed_mock_data.sql`
- **Durum:** TAMAMLANDI
- `auth.users` + `auth.identities` satirlarini olusturur (FK fix)
- Email: `admin@kendin.app` / Sifre: `Test123456`
- 3 haftalik gunluk yazilar (18 entry)
- 3 haftalik yansimalar (2 arsivli + 1 aktif)
- `is_premium = true`, `is_admin = true`

### 5. Lokalizasyon
- **Dosya:** `lib/core/l10n/app_localizations.dart`
- TR + EN tam destek
- Yeni key'ler: kullanici bilgi karti, debug bolumu, admin yansimalar tablosu

### 6. Onceki Commitlerde Yapilanlar
- Turk dili input fix (`flutter_localizations`)
- Anonim auth fix (`.maybeSingle()` + auto-upsert)
- Strike noktalar fix + fade animasyonu
- Menu, Derinlik, Hesap, Hakkinda, Legal sayfalari
- 23:30 "Gun kapaniyor" banner
- Hesap silme (full chain)
- APPLE_STORE_PREP.md

---

## Mimari Audit Sonuclari

### Tek Kaynak Auth Sistemi (Duplicate YOK)
- `CurrentUserNotifier` (StateNotifier) → `currentUserProvider`
- Ayri AuthController/SessionProvider **yok**
- Demo mod ayni interface'i kullaniyor (`DemoAuthRepository`)

### GoRouter Durumu
- `pubspec.yaml`'da `go_router: ^13.1.0` var ama **hicbir yerde kullanilmiyor**
- Tum navigation `Navigator.of(context).push(MaterialPageRoute(...))`

### Orphaned (Kullanilmayan) Ekranlar
| Ekran | Dosya | Durum |
|-------|-------|-------|
| SettingsScreen | `settings/settings_screen.dart` | ORPHANED — menu_screen ile degistirildi |
| ProfileScreen | `profile/profile_screen.dart` | ORPHANED — menu_screen'e tasinmis |
| SignupScreen | `auth/signup_screen.dart` | ORPHANED — login_screen icinde toggle var |

### Router Akisi (Dogrulanmis)
- Landing → `has_seen_landing` pref → tek sefer gosterilir
- Landing → `pushReplacement` → HomeScreen (geri donus yok)
- HomeScreen → Menu → LoginScreen → `popUntil(isFirst)` → HomeScreen
- **Dongü yok, loop yok**

---

## Aktif Sayfalar ve Durumu

| Sayfa | Dosya | Durum |
|-------|-------|-------|
| Landing | `screens/landing/landing_screen.dart` | CALISIYOR |
| Ana Sayfa (Home) | `screens/home/home_screen.dart` | CALISIYOR |
| Ayarlar (Menu) | `screens/menu/menu_screen.dart` | CALISIYOR — kullanici bilgi + debug eklendi |
| Derinlik (Premium) | `screens/premium/premium_paywall_screen.dart` | CALISIYOR |
| Dil | `screens/language/language_screen.dart` | CALISIYOR |
| Hakkinda | `screens/about/about_screen.dart` | CALISIYOR |
| Admin Paneli | `screens/admin/admin_screen.dart` | CALISIYOR — yansimalar tablosu eklendi |
| Giris Yap | `screens/auth/login_screen.dart` | CALISIYOR |
| Kayit Ol | login_screen icinde toggle | CALISIYOR |
| Email Dogrula | `screens/auth/verify_email_screen.dart` | CALISIYOR |
| Hesap Gate | `screens/auth/account_gate_screen.dart` | CALISIYOR |
| Yansima | `screens/reflection/reflection_screen.dart` | CALISIYOR |
| Gizlilik Politikasi | `screens/legal/privacy_policy_screen.dart` | CALISIYOR |
| Kullanim Kosullari | `screens/legal/terms_of_service_screen.dart` | CALISIYOR |
| KVKK | `screens/legal/kvkk_screen.dart` | CALISIYOR |

---

## Navigation Akisi

```
main.dart
  |
  +-- LandingScreen (ilk acilis, tek sefer)
  |     |
  |     +-- "Basla" --> pushReplacement --> HomeScreen
  |
  +-- HomeScreen (ana ekran)
        |
        +-- Menu ikonu (...) --> MenuScreen
        |     |
        |     +-- [Kullanici Bilgi Karti]
        |     |     +-- User ID (kopyala butonu)
        |     |     +-- Email
        |     |     +-- Hesap Tipi (Anonim/Kayitli)
        |     |     +-- Premium Durumu
        |     |
        |     +-- Derinlik --> PremiumPaywallScreen
        |     +-- Dil --> LanguageScreen
        |     +-- Hakkinda --> AboutScreen
        |     +-- Admin Paneli --> AdminScreen (admin only)
        |     |     +-- Istatistikler (4 kart)
        |     |     +-- Kullanici listesi
        |     |     +-- Yansimalar debug tablosu
        |     |
        |     +-- Giris Yap --> LoginScreen (anonim ise)
        |     |     +-- Sign In / Sign Up toggle
        |     |     +-- Basarili → popUntil(isFirst) → HomeScreen
        |     |
        |     +-- Cikis Yap → signOut → initialize → HomeScreen (kayitli ise)
        |     |
        |     +-- [Debug Bolumu] (acilir/kapanir)
        |           +-- Token Expiry
        |           +-- User Metadata JSON
        |           +-- Session Summary JSON
        |
        +-- Pazar gunu --> ReflectionScreen
```

---

## Supabase Kurulumu

### Gerekli SQL Dosyalari (sirayla calistir)
1. `supabase/migrations/001_initial_schema.sql` — tablolar + RLS
2. `supabase/migrations/002_add_admin_and_display_name.sql` — admin + display_name
3. `supabase/seed_mock_data.sql` — test kullanici + veri

### Build Komutu
```bash
# ONEMLI: SUPABASE_URL ve SUPABASE_ANON_KEY olmadan Supabase calismaz!

# Web build
flutter build web --release --base-href "/KendimApp/" \
  --dart-define=SUPABASE_URL=https://XXXXX.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJXXXXX

# iOS build
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://XXXXX.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJXXXXX

# Gelistirme (debug)
flutter run \
  --dart-define=SUPABASE_URL=https://XXXXX.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJXXXXX
```

### Supabase Baglantisi
- `--dart-define` olmadan build edersen Supabase URL **bos** kalir
- Uygulama acilir ama **auth basarisiz** olur, veri yazma calismaz
- Supabase Dashboard > Settings > API > URL ve anon key

---

## Bilinen Sorunlar / Yapilacaklar

| # | Konu | Durum | Not |
|---|------|-------|-----|
| 1 | Supabase baglantisi | KONTROL ET | `--dart-define` ile URL ve KEY verilmeli |
| 2 | Auth calisiyor mu | KONTROL ET | Console'da `[Kendin] Anonymous sign-in OK` gorunmeli |
| 3 | Admin gorunuyor mu | KONTROL ET | `is_admin = true` olan kullanici ile giris yap |
| 4 | Mock data yuklendi mi | KONTROL ET | SQL Editor'da `seed_mock_data.sql` calistir |
| 5 | Derinlik timeline | KONTROL ET | Premium kullanici ile gorulur |
| 6 | `delete-user` edge function | YAPILACAK | Supabase Edge Functions'da deploy edilmeli |
| 7 | `migrate-user-data` edge function | YAPILACAK | Anonim -> email gecis icin |
| 8 | IAP (In-App Purchase) | YAPILACAK | App Store Connect'te urun tanimla |
| 9 | Push notifications | YAPILACAK | iOS permission + APN sertifikasi |
| 10 | GoRouter kaldir veya bagla | ONERILIR | pubspec'te var ama kullanilmiyor |
| 11 | Orphaned ekranlari temizle | ONERILIR | settings_screen, profile_screen, signup_screen |
