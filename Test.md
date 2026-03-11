# Kendin App — Test Raporu

## Proje Mimari Ozeti

- **State Management:** Flutter Riverpod (StateNotifier)
- **Auth State:** `currentUserProvider` -> tek kaynak (duplicate yok)
- **Auth Chain:** `AuthDatasource -> AuthRepositoryImpl -> AuthService -> CurrentUserNotifier`
- **Navigation:** `Navigator.push(MaterialPageRoute(...))` — GoRouter kullanilmiyor
- **Backend:** Supabase (auth + PostgreSQL + Edge Functions)
- **Lokalizasyon:** TR + EN (`AppLocalizations`)
- **Email:** Resend (via Edge Function, server-side only)

---

## Son Guncelleme: Auth + Membership + Resend Entegrasyonu

### 1. Landing Page Auth Guncellemesi
- **Dosya:** `lib/presentation/screens/landing/landing_screen.dart` (GUNCELLENDI)
- **Yeni:** "Giris Yap" ve "Kayit Ol" linkleri landing sayfasinin altina eklendi
- "Basla" butonu hala var (anonim giris)
- Login/Signup tiklayinca `LoginScreen`'e yonlendiriyor
- Landing pref'i her iki durumda da kaydediliyor

### 2. Sifremi Unuttum Akisi
- **Yeni dosya:** `lib/presentation/screens/auth/forgot_password_screen.dart`
- **Guncellenen dosya:** `lib/presentation/screens/auth/login_screen.dart`
- Login ekraninda sifre alaninin altinda "Sifremi unuttum" linki
- Tiklayinca `ForgotPasswordScreen`'e gider
- Email girip "Sifirlama baglantisi gonder" tiklanir
- Supabase Auth `resetPasswordForEmail()` kullanir
- Basarili oldugunda onay ekrani gosterir
- **Auth chain:** `AuthDatasource.resetPassword()` -> `AuthRepositoryImpl` -> `AuthService` -> `ForgotPasswordScreen`

### 3. Membership (Uyelik) Sistemi
- **Guncellenen dosyalar:**
  - `lib/domain/entities/user_entity.dart` — `MembershipStatus` enum + `membershipStatus` computed property + `hasPremiumAccess`
  - `lib/data/models/user_model.dart` — `premiumExpiresAt` ve `premiumStartedAt` parsing
  - `lib/presentation/screens/menu/menu_screen.dart` — membership status gosterimi (free/premium/expired)
- **Uyelik durumlar:**
  - `free` — `is_premium = false`
  - `premium` — `is_premium = true` VE (`premium_expires_at` NULL VEYA gelecekte)
  - `expired` — `is_premium = true` VE `premium_expires_at` gecmiste
- **Supabase migration:** `003_add_membership_lifecycle.sql`
  - `premium_expires_at timestamptz` kolonu
  - `premium_started_at timestamptz` kolonu
  - `get_membership_status()` SQL helper fonksiyonu
  - Premium expiry indeksi

### 4. Resend Email Entegrasyonu
- **Yeni edge function:** `supabase/functions/send-email/index.ts`
- **Email tipleri:**
  - `welcome` — kayit sonrasi hos geldin emaili
  - `premium_activated` — premium baslatildiginda
  - `premium_expired` — premium suresi dolunca
- **Guvenlik:**
  - `RESEND_API_KEY` sadece Edge Function secrets'ta
  - Flutter client'ta ASLA expose edilmiyor
  - Fire-and-forget pattern (email basarisiz olursa uygulama etkilenmez)
- **Entegrasyon noktasi:** `AuthDatasource.signUp()` basarili oldugunda welcome email gonderiyor

### 5. Email Akisi Mimari

| Amaç | Yöntem | Neden |
|------|--------|-------|
| Sifre sifirlama | Supabase Auth (native) | Built-in secure flow, magic link destegi |
| Email dogrulama | Supabase Auth (native) | Built-in, PKCE compatible |
| Hos geldin emaili | Resend (Edge Function) | Ozel tasarim, brand consistency |
| Premium aktivasyon | Resend (Edge Function) | Ozel tasarim |
| Premium suresi doldu | Resend (Edge Function) | Ozel bilgilendirme |
| Gelecekte: hatirlama | Resend (Edge Function) | Ozel zamanlama gerekir |

### 6. Environment Variables

| Variable | Nerede Yasar | Public? | Nasil Set Edilir |
|----------|-------------|---------|------------------|
| `SUPABASE_URL` | Flutter `--dart-define` + Edge Function auto | Evet | `--dart-define=SUPABASE_URL=...` |
| `SUPABASE_ANON_KEY` | Flutter `--dart-define` | Evet | `--dart-define=SUPABASE_ANON_KEY=...` |
| `SUPABASE_SERVICE_ROLE_KEY` | Edge Function auto-inject | HAYIR | Otomatik |
| `OPENAI_API_KEY` | Edge Function secret | HAYIR | `supabase secrets set OPENAI_API_KEY=...` |
| `RESEND_API_KEY` | Edge Function secret | HAYIR | `supabase secrets set RESEND_API_KEY=...` |

---

## Yapilan Isler (Tum Commitler)

### Ayarlar (Menu) Sayfasi
- **Dosya:** `lib/presentation/screens/menu/menu_screen.dart`
- Kullanici bilgi karti: User ID (kopyala), Email, Hesap tipi, Uyelik durumu, Admin badge
- 3 kart: Derinlik, Dil, Hakkinda + Admin karti (admin-only)
- Giris Yap / Cikis Yap butonlari
- Debug bolumu (acilir/kapanir): Session JSON, token expiry, metadata

### Admin Paneli
- **Dosya:** `lib/presentation/screens/admin/admin_screen.dart`
- 4 istatistik karti + kullanici listesi + yansimalar debug tablosu

### Mock Test Verisi
- **Dosya:** `supabase/seed_mock_data.sql`
- Email: `admin@kendin.app` / Sifre: `Test123456`
- 3 haftalik entry + 3 yansima

---

## Aktif Sayfalar

| Sayfa | Dosya | Durum |
|-------|-------|-------|
| Landing | `screens/landing/landing_screen.dart` | CALISIYOR — auth linkleri eklendi |
| Ana Sayfa (Home) | `screens/home/home_screen.dart` | CALISIYOR |
| Ayarlar (Menu) | `screens/menu/menu_screen.dart` | CALISIYOR — membership status gosterimi |
| Giris Yap | `screens/auth/login_screen.dart` | CALISIYOR — sifremi unuttum linki |
| Sifremi Unuttum | `screens/auth/forgot_password_screen.dart` | YENI |
| Kayit Ol | login_screen icinde toggle | CALISIYOR |
| Email Dogrula | `screens/auth/verify_email_screen.dart` | CALISIYOR |
| Derinlik (Premium) | `screens/premium/premium_paywall_screen.dart` | CALISIYOR |
| Dil | `screens/language/language_screen.dart` | CALISIYOR |
| Hakkinda | `screens/about/about_screen.dart` | CALISIYOR |
| Admin Paneli | `screens/admin/admin_screen.dart` | CALISIYOR |
| Yansima | `screens/reflection/reflection_screen.dart` | CALISIYOR |
| Gizlilik | `screens/legal/privacy_policy_screen.dart` | CALISIYOR |
| Kosullar | `screens/legal/terms_of_service_screen.dart` | CALISIYOR |
| KVKK | `screens/legal/kvkk_screen.dart` | CALISIYOR |

---

## Navigation Akisi

```
main.dart
  |
  +-- LandingScreen (ilk acilis, tek sefer)
  |     |
  |     +-- "Basla" --> pushReplacement --> HomeScreen (anonim)
  |     +-- "Giris Yap" --> push --> LoginScreen
  |     +-- "Kayit Ol" --> push --> LoginScreen (signup mode)
  |
  +-- HomeScreen (ana ekran)
        |
        +-- Menu ikon (...) --> MenuScreen
              |
              +-- [Kullanici Bilgi Karti]
              +-- Derinlik --> PremiumPaywallScreen
              +-- Dil --> LanguageScreen
              +-- Hakkinda --> AboutScreen
              +-- Admin Paneli --> AdminScreen (admin only)
              +-- Giris Yap --> LoginScreen (anonim ise)
              |     +-- Sifremi Unuttum --> ForgotPasswordScreen
              |     +-- Kayit Ol (toggle)
              +-- Cikis Yap (kayitli ise)
              +-- [Debug Bolumu]
```

---

## Supabase Kurulumu

### SQL Dosyalari (sirayla calistir)
1. `supabase/migrations/001_initial_schema.sql`
2. `supabase/migrations/002_add_admin_and_display_name.sql`
3. `supabase/migrations/003_add_membership_lifecycle.sql` (YENI)
4. `supabase/seed_mock_data.sql` (test verisi)

### Edge Functions Deploy
```bash
supabase functions deploy generate-reflection
supabase functions deploy migrate-user-data
supabase functions deploy send-email    # YENI
```

### Secrets
```bash
supabase secrets set OPENAI_API_KEY=sk-...
supabase secrets set RESEND_API_KEY=re_...    # YENI
```

### Build Komutu
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://XXXXX.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJXXXXX
```

---

## Final Checklist

### Dosyalari Kontrol Et
- [ ] `lib/domain/entities/user_entity.dart` — MembershipStatus enum
- [ ] `lib/data/models/user_model.dart` — premiumExpiresAt parsing
- [ ] `lib/data/datasources/auth_datasource.dart` — resetPassword + _sendEmail
- [ ] `lib/domain/repositories/auth_repository.dart` — resetPassword contract
- [ ] `lib/data/repositories/auth_repository_impl.dart` — resetPassword impl
- [ ] `lib/domain/usecases/auth_service.dart` — resetPassword delegation
- [ ] `lib/presentation/screens/auth/login_screen.dart` — forgot password link
- [ ] `lib/presentation/screens/auth/forgot_password_screen.dart` — YENI
- [ ] `lib/presentation/screens/landing/landing_screen.dart` — auth entry points
- [ ] `lib/presentation/screens/menu/menu_screen.dart` — membership status
- [ ] `lib/core/l10n/app_localizations.dart` — yeni key'ler

### Migration'lar
- [ ] `003_add_membership_lifecycle.sql` calistir

### Environment Variables
- [ ] `RESEND_API_KEY` Supabase secrets'a ekle
- [ ] `OPENAI_API_KEY` Supabase secrets'a ekle (zaten varsa skip)

### Deploy
- [ ] `supabase functions deploy send-email`
- [ ] Resend Dashboard'da domain verify et (kendin.app)
- [ ] Supabase Auth > Email Templates'i kontrol et
