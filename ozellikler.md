# Kendin — Özellikler ve Proje Açıklaması

> **"Bugün kendin için ne yaptın?"**
> Sessiz bir haftalık yansıma ritüeli.

---

## Uygulama Nedir?

Kendin, kullanıcıların haftanın 6 günü (Pazartesi–Cumartesi) kendileri için ne yaptıklarını yazdığı, Pazar günü ise yapay zeka destekli haftalık bir yansıma aldıkları bir günlük uygulamasıdır.

Temel felsefe: minimal, sakin, yargısız.

---

## Temel Özellikler

### 1. Günlük Yazma (Pazartesi–Cumartesi)
- Her gün tek bir soru: "Bugün kendin için ne yaptın?"
- Minimal text alanı, karakter sayacı yok, validasyon göstergesi yok
- Günde bir entry, güncelleme imkanı ("Güne ekle")
- Maks 2000 karakter

### 2. Strike Sistemi (Haftalık Takip)
- 6 nokta ile haftalık ilerleme gösterimi (Pzt–Cmt)
- Dolu nokta = o gün entry yazılmış
- Tüm 6 gün tamamlanınca Pazar yansıması açılır
- Premium kullanıcılar miss token ile eksik günleri tamamlayabilir

### 3. Pazar Yansıması (AI-Destekli)
- Haftalık entry'ler OpenAI GPT-4o-mini ile analiz edilir
- Supabase Edge Function üzerinden üretilir
- Ücretsiz: 5 cümle yansıma
- Premium: 8–12 cümle, daha derin bakış
- 10 dakika gecikmeyle bildirim gönderilir
- Premium kullanıcılar yansımalarını arşivleyebilir

### 4. Anonim Başlangıç
- İlk açılışta otomatik anonim oturum oluşturulur
- Hesap oluşturmadan hemen yazmaya başlanabilir
- Daha sonra e-posta hesabı oluşturulabilir
- Anonim verileri yeni hesaba otomatik taşınır (Edge Function)

### 5. Hesap Sistemi
- Anonim → E-posta/şifre hesabına geçiş
- E-posta doğrulama akışı
- Giriş / Kayıt (toggle ile tek ekran)
- Çıkış yapıldığında yeni anonim oturum oluşur

### 6. Premium ("Derinlik")
- Aylık (49₺/ay) ve Yıllık (299₺/yıl) abonelik
- iOS ve Android in-app purchase desteği
- Sunucu taraflı makbuz doğrulama (Edge Function)
- Premium özellikleri:
  - Miss token: Ayda 3 hak, eksik günleri tamamla
  - Yansıma arşivi: Geçmiş haftaları sakla
  - Daha derin yansıma: 8–12 cümle

### 7. Çoklu Dil Desteği
- Türkçe (varsayılan)
- İngilizce
- Anlık dil değişimi, tercih SharedPreferences'a kaydedilir

### 8. Landing (Karşılama) Ekranı
- İlk açılışta gösterilir
- Animasyonlu 6 nokta
- "Altı gün. Bir hafta." + "Başla" butonu
- Bir kez gösterildikten sonra tekrar gösterilmez

---

## Ekranlar

| Ekran | Açıklama |
|-------|----------|
| `LandingScreen` | İlk karşılama, animasyonlu noktalar, "Başla" butonu |
| `HomeScreen` | Ana ekran — yazma, tamamlama, Pazar yansıma tetikleyici |
| `MenuScreen` | Kart bazlı menü — Derinlik, Hesap, Dil, Hakkında |
| `ReflectionScreen` | Haftalık yansıma görüntüleme, arşivleme |
| `LoginScreen` | Giriş / Kayıt toggle (e-posta + şifre) |
| `AccountGateScreen` | Anonim kullanıcı için hesap oluşturma yönlendirmesi |
| `VerifyEmailScreen` | E-posta doğrulama akışı |
| `ProfileScreen` | Kullanıcı bilgileri, premium durumu |
| `PremiumPaywallScreen` | Premium abonelik satın alma ekranı |
| `LanguageScreen` | Dil seçimi (Türkçe / English) |

---

## Teknik Altyapı

### Frontend
- **Flutter** 3.24 (Dart SDK ≥3.2.0)
- **Riverpod** — reaktif state management
- **Google Fonts** — Noto Serif (başlıklar) + Inter (gövde)
- **flutter_animate** — animasyonlar
- **shared_preferences** — yerel tercih saklama

### Backend (Supabase)
- **PostgreSQL** — entries, users, weekly_reflections tabloları
- **Row Level Security** — her kullanıcı sadece kendi verisini görür
- **Supabase Auth** — anonim + e-posta/şifre
- **Edge Functions** (Deno/TypeScript):
  - `generate-reflection` — OpenAI GPT-4o-mini ile yansıma üretimi
  - `migrate-user-data` — anonim → e-posta veri taşıma
  - `verify-purchase` — makbuz doğrulama

### Veritabanı Tabloları
- **users** — is_premium, premium_miss_tokens, display_name
- **entries** — user_id, text, created_at (günde bir)
- **weekly_reflections** — user_id, week_start_date, content, is_archived

### Mimari
- **Clean Architecture** — domain / data / presentation katmanları
- **Repository Pattern** — soyut veri erişimi
- **Conditional Init** — native: tam özellik, web: notification/IAP hariç
- **Providers** — Riverpod ile dependency injection

### Deploy
- **Web**: GitHub Actions → GitHub Pages (`/KendimApp/`)
- **Mobil**: iOS + Android hazır (in-app purchase entegrasyonu)

---

## Tema ve Tasarım

- 8pt grid sistemi
- Sıcak kağıt tonları (light), derin kömür (dark)
- Neon renk yok, doygun renk yok
- Accent: mat bronz (light) / yumuşak amber (dark)
- Minimal, sakin, yargısız hissiyat

---

## Proje Dizin Yapısı

```
lib/
├── app_init/                  # Uygulama başlatma (production / web)
├── core/
│   ├── constants/             # Sabitler, Supabase config
│   ├── errors/                # Hata sınıfları
│   ├── l10n/                  # Çoklu dil (TR + EN)
│   ├── theme/                 # Renk, tipografi, spacing
│   └── utils/                 # Tarih yardımcıları
├── data/
│   ├── datasources/           # Supabase veri kaynakları
│   │   └── demo/              # Demo/web stub'ları
│   ├── models/                # JSON serileştirme modelleri
│   └── repositories/          # Repository implementasyonları
├── domain/
│   ├── entities/              # İş nesneleri (User, Entry, Reflection)
│   ├── repositories/          # Soyut repository arayüzleri
│   └── usecases/              # Servisler (Auth, Entry, Reflection, Strike, Premium, Notification)
└── presentation/
    ├── providers/             # Riverpod provider tanımları
    ├── screens/               # Uygulama ekranları
    └── widgets/               # Özel widget'lar (Button, TextField, StrikeIndicator, AnimatedDots)

supabase/
├── migrations/                # SQL şema tanımları
└── functions/                 # Edge function'lar (TypeScript)
```
