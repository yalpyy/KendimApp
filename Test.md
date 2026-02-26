# Kendin App — Test Raporu

## Yapilan Isler

### 1. Ayarlar (Menu) Sayfasi
- **Dosya:** `lib/presentation/screens/menu/menu_screen.dart`
- **Durum:** TAMAMLANDI
- Ust kisim: Kullanici adi (buyuk) + hesap durumu (Free/Premium)
- 3 kart: **Derinlik**, **Dil**, **Hakkinda**
- Alt kisim: **Giris Yap** (anonim) / **Cikis Yap** (kayitli)
- Admin kullanicilara ozel: **Admin Paneli** karti
- Navigation: HomeScreen > Menu ikon (sag ust `...`) > MenuScreen

### 2. Admin Paneli
- **Dosya:** `lib/presentation/screens/admin/admin_screen.dart` (YENI)
- **Durum:** TAMAMLANDI
- 4 istatistik karti: Toplam Kullanici, Premium Kullanici, Toplam Yazi, Toplam Yansima
- Kullanici listesi: Isim + tarih + Premium/Admin/Ucretsiz badge
- Pull-to-refresh + yenile butonu
- Sadece `is_admin = true` kullanicilara gorunur
- TR/EN lokalizasyon tam

### 3. Admin Data Modeli
- **UserEntity:** `isAdmin` field eklendi
- **UserModel:** `is_admin` JSON alanini okuyor
- **AuthDatasource:** `getAdminStats()` + `getAllUsers()` metodlari eklendi
- **Migration:** `supabase/migrations/002_add_admin_and_display_name.sql`
  - `is_admin boolean` kolonu
  - `display_name text` kolonu
  - Admin RLS politikalari (tum tablolari okuma izni)

### 4. Mock Test Verisi
- **Dosya:** `supabase/seed_mock_data.sql`
- **Durum:** TAMAMLANDI
- `auth.users` + `auth.identities` satirlarini otomatik olusturur
- Email: `admin@kendin.app` / Sifre: `Test123456`
- 3 haftalik gunluk yazilar (18 entry)
- 3 haftalik yansimalar (2 arsivli + 1 aktif)
- `is_premium = true`, `is_admin = true`

### 5. Lokalizasyon
- **Dosya:** `lib/core/l10n/app_localizations.dart`
- TR + EN tam destek
- Admin paneli icin 11 yeni key

### 6. Onceki Commitlerde Yapilanlar
- Turk dili input fix (`flutter_localizations`)
- Anonim auth fix (`.maybeSingle()` + auto-upsert)
- Strike noktalar fix
- Menu, Derinlik, Hesap, Hakkinda, Legal sayfalari
- 23:30 "Gun kapaniyor" banner
- Strike nokta fade animasyonu
- Hesap silme (full chain)
- APPLE_STORE_PREP.md

---

## Mevcut Sayfalar ve Durumu

| Sayfa | Dosya | Durum |
|-------|-------|-------|
| Landing | `screens/landing/landing_screen.dart` | CALISIYOR |
| Ana Sayfa (Home) | `screens/home/home_screen.dart` | CALISIYOR |
| Ayarlar (Menu) | `screens/menu/menu_screen.dart` | CALISIYOR |
| Derinlik (Premium) | `screens/premium/premium_paywall_screen.dart` | CALISIYOR |
| Dil | `screens/language/language_screen.dart` | CALISIYOR |
| Hakkinda | `screens/about/about_screen.dart` | CALISIYOR |
| Admin Paneli | `screens/admin/admin_screen.dart` | CALISIYOR |
| Giris Yap | `screens/auth/login_screen.dart` | CALISIYOR |
| Kayit Ol | `screens/auth/signup_screen.dart` | CALISIYOR |
| Email Dogrula | `screens/auth/verify_email_screen.dart` | CALISIYOR |
| Hesap Gate | `screens/auth/account_gate_screen.dart` | CALISIYOR |
| Profil | `screens/profile/profile_screen.dart` | CALISIYOR |
| Yansima | `screens/reflection/reflection_screen.dart` | CALISIYOR |
| Gizlilik Politikasi | `screens/legal/privacy_policy_screen.dart` | CALISIYOR |
| Kullanim Kosullari | `screens/legal/terms_of_service_screen.dart` | CALISIYOR |
| KVKK | `screens/legal/kvkk_screen.dart` | CALISIYOR |
| Ayarlar (eski) | `screens/settings/settings_screen.dart` | KULLANILMIYOR (menu_screen ile degistirildi) |

---

## Navigation Akisi

```
main.dart
  |
  +-- LandingScreen (ilk acilis)
  |     |
  |     +-- "Basla" --> HomeScreen
  |
  +-- HomeScreen (ana ekran)
        |
        +-- Menu ikonu (...) --> MenuScreen
        |     |
        |     +-- Derinlik --> PremiumPaywallScreen
        |     |     +-- Free: Paywall (fiyatlar + avantajlar)
        |     |     +-- Premium: Timeline (yansimalar)
        |     |
        |     +-- Dil --> LanguageScreen (Turkce/English)
        |     |
        |     +-- Hakkinda --> AboutScreen
        |     |     +-- Gizlilik Politikasi
        |     |     +-- Kullanim Kosullari
        |     |     +-- KVKK
        |     |
        |     +-- Admin Paneli --> AdminScreen (sadece admin)
        |     |     +-- Istatistikler (4 kart)
        |     |     +-- Kullanici listesi
        |     |
        |     +-- Giris Yap --> LoginScreen (anonim ise)
        |     +-- Cikis Yap (kayitli ise)
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
# Web build
flutter build web --release --base-href "/KendimApp/" \
  --dart-define=SUPABASE_URL=https://XXXXX.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJXXXXX

# iOS build
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://XXXXX.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJXXXXX
```

### Onemli: SUPABASE_URL ve SUPABASE_ANON_KEY
- `--dart-define` olmadan build edersen Supabase baglantisi **bos** kalir
- Uygulama acilir ama **auth basarisiz** olur, yazma calismaz
- Supabase Dashboard > Settings > API > URL ve anon key

---

## Bilinen Sorunlar / Kontrol Edilecekler

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

---

## Dosya Yapisi

```
lib/
├── app_init/
│   ├── app_init_demo.dart          (web init)
│   └── app_init_production.dart    (native init)
├── core/
│   ├── constants/
│   │   ├── app_config.dart
│   │   ├── app_constants.dart      (Supabase URL/KEY --dart-define)
│   │   └── app_strings.dart        (eski statik Turkce stringler)
│   ├── errors/app_exception.dart
│   ├── l10n/app_localizations.dart (TR + EN lokalizasyon)
│   ├── theme/                      (renk, spacing, tema)
│   └── utils/date_utils.dart
├── data/
│   ├── datasources/
│   │   ├── auth_datasource.dart    (Supabase auth + admin queries)
│   │   ├── entry_datasource.dart
│   │   ├── reflection_datasource.dart
│   │   ├── supabase_client_setup.dart
│   │   └── demo/                   (web demo implementations)
│   ├── models/
│   │   ├── entry_model.dart
│   │   ├── user_model.dart         (isAdmin eklendi)
│   │   └── weekly_reflection_model.dart
│   └── repositories/
├── domain/
│   ├── entities/
│   │   ├── entry_entity.dart
│   │   ├── user_entity.dart        (isAdmin eklendi)
│   │   └── weekly_reflection_entity.dart
│   ├── repositories/
│   └── usecases/
├── main.dart
└── presentation/
    ├── providers/
    │   ├── locale_provider.dart
    │   ├── providers.dart          (conditional import)
    │   ├── providers_demo.dart     (web)
    │   └── providers_production.dart (native)
    ├── screens/
    │   ├── about/about_screen.dart
    │   ├── admin/admin_screen.dart  (YENI)
    │   ├── auth/
    │   │   ├── account_gate_screen.dart
    │   │   ├── login_screen.dart
    │   │   ├── signup_screen.dart
    │   │   └── verify_email_screen.dart
    │   ├── home/home_screen.dart
    │   ├── landing/landing_screen.dart
    │   ├── language/language_screen.dart
    │   ├── legal/
    │   │   ├── kvkk_screen.dart
    │   │   ├── privacy_policy_screen.dart
    │   │   └── terms_of_service_screen.dart
    │   ├── menu/menu_screen.dart    (YENIDEN YAZILDI)
    │   ├── premium/premium_paywall_screen.dart
    │   ├── profile/profile_screen.dart
    │   ├── reflection/reflection_screen.dart
    │   └── settings/settings_screen.dart (kullanilmiyor)
    └── widgets/
```
