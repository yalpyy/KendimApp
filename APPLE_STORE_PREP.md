# Kendin — Apple App Store Preparation

## 1. Architecture Overview

```
lib/
├── app_init/              # Platform-specific initialization
│   ├── app_init_demo.dart       # Web (Supabase + anonymous auth)
│   └── app_init_production.dart # Native (Supabase + notifications + IAP)
├── core/
│   ├── constants/         # App config, strings, constants
│   ├── errors/            # Custom exceptions
│   ├── l10n/              # Localization (TR + EN)
│   └── theme/             # Colors, spacing, typography, theme
├── data/
│   ├── datasources/       # Supabase datasources (auth, entry, reflection)
│   ├── models/            # Data models (UserModel, EntryModel, etc.)
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Services (auth, entry, reflection, strike, premium)
└── presentation/
    ├── providers/         # Riverpod providers (platform-aware)
    ├── screens/           # All screens (home, menu, auth, premium, etc.)
    └── widgets/           # Shared widgets (button, text field, indicators)
```

**Pattern:** Clean Architecture + Riverpod
**State management:** flutter_riverpod (StateNotifier + FutureProvider)
**Backend:** Supabase (PostgreSQL, Auth, Edge Functions)
**Conditional imports:** Native vs Web via `dart.library.html`

## 2. Supabase Configuration

### Required Tables

```sql
-- users table
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  is_premium BOOLEAN DEFAULT FALSE,
  premium_miss_tokens INTEGER DEFAULT 3,
  display_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- entries table
CREATE TABLE public.entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  date DATE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- weekly_reflections table
CREATE TABLE public.weekly_reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL,
  content TEXT NOT NULL,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, week_start_date)
);
```

### Row Level Security (RLS)

All tables must have RLS enabled:

```sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.weekly_reflections ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users read own data" ON public.users
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own data" ON public.users
  FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users insert own data" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Same pattern for entries and weekly_reflections
-- (user_id = auth.uid())
```

### Auth Configuration

- **Anonymous sign-in:** Enabled
- **Email/password:** Enabled
- **PKCE flow:** Enabled (default for mobile)
- **Email confirmation:** Required for premium purchases

### Environment Variables

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
OPENAI_API_KEY=your-openai-key (for Edge Functions)
```

## 3. AI Connection

### How Reflections Work

1. User writes entries Mon–Sat
2. On Sunday, user taps "Bu haftayı gör"
3. App calls Supabase Edge Function `generate-reflection`
4. Edge Function:
   - Fetches user's entries for the week
   - Sends entries to OpenAI API (GPT-4o-mini)
   - System prompt: awareness-based, non-judgmental reflection
   - Saves reflection to `weekly_reflections` table
5. App polls for reflection every 30 seconds

### AI Provider

- **Current:** OpenAI (GPT-4o-mini)
- **Fallback:** Anthropic Claude Haiku
- **Prompt language:** Turkish (default), English (based on user locale)
- **Data handling:** Entries sent only for reflection generation, not stored by AI provider

## 4. Apple App Store Checklist

### Privacy Nutrition Labels

| Data Type | Collected | Linked to Identity | Used for Tracking |
|-----------|-----------|-------------------|-------------------|
| Email Address | Yes (optional) | Yes | No |
| User ID | Yes (anonymous UUID) | No | No |
| User Content (entries) | Yes | Yes | No |
| Purchase History | Yes | Yes | No |

### App Tracking Transparency

- **ATT required:** No
- **No third-party analytics**
- **No advertising SDKs**
- **No tracking across apps**

### In-App Purchase Configuration

| Product ID | Type | Price | Duration |
|-----------|------|-------|----------|
| `kendin.premium.monthly` | Auto-renewable subscription | 49₺ | 1 month |
| `kendin.premium.yearly` | Auto-renewable subscription | 299₺ | 1 year |

**Subscription Group:** `kendin_premium`
**Free trial:** None (v1.0)
**Introductory offer:** None (v1.0)

### Restore Purchases

- Implemented via `premiumServiceProvider.restorePurchases()`
- Accessible from: Menu → Derinlik → "Satın almayı geri yükle"
- Also accessible during purchase flow

### Required App Store Assets

- [ ] App icon (1024x1024)
- [ ] Screenshots (6.7", 6.5", 5.5")
- [ ] App description (TR + EN)
- [ ] Privacy policy URL
- [ ] Terms of service URL
- [ ] Support URL
- [ ] Marketing URL (optional)

## 5. Data Deletion Procedure

### User-Initiated Deletion

1. User navigates to Menu → Hesap → Profile
2. Taps "Hesabı Sil" button
3. Confirmation dialog shown with warning text
4. Cascade delete removes all data from:
   - `public.users`
   - `public.entries`
   - `public.weekly_reflections`
   - `auth.users`
5. Confirmation shown to user

### Automated Cleanup

- Anonymous accounts inactive for 12 months → auto-delete via Supabase Edge Function (cron)
- Deleted account data purged within 30 days

### Apple Compliance

- Account deletion available in-app (required by Apple)
- Deletion must be as easy as account creation
- Must delete data from all third-party services

## 6. Account Deletion Procedure

```
POST /auth/v1/admin/users/{user_id} → DELETE
```

Steps (implemented in `AuthDatasource.deleteAccount`):
1. Delete from `weekly_reflections` (user_id)
2. Delete from `entries` (user_id)
3. Delete from `users` (id)
4. Call `delete-user` edge function (deletes auth record)
5. Sign out locally
6. Re-initialize with fresh anonymous session
7. Show confirmation SnackBar + navigate to home

## 7. AI Cost Estimation Per User

### Assumptions

- Average entries per week: 5
- Average entry length: 100 words
- Reflection generation: 1 per week per user
- Model: GPT-4o-mini

### Cost Breakdown

| Component | Tokens | Cost (per user/month) |
|-----------|--------|----------------------|
| Input (5 entries × 100 words) | ~2,500 tokens | ~$0.0004 |
| System prompt | ~500 tokens | ~$0.00008 |
| Output (reflection) | ~500 tokens | ~$0.0008 |
| **Monthly total** | | **~$0.005** |

### At Scale

| Users | Monthly AI Cost | Annual AI Cost |
|-------|----------------|----------------|
| 1,000 | ~$5 | ~$60 |
| 10,000 | ~$50 | ~$600 |
| 100,000 | ~$500 | ~$6,000 |

**Note:** Supabase costs (database, auth, storage) scale separately. Free tier covers ~50,000 MAU.

## 8. Risk Analysis

### Technical Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Supabase outage | Medium | Graceful offline mode, local cache |
| AI API failure | Medium | Retry logic, fallback provider |
| Anonymous data loss | Low | Prompt to create account |
| Subscription sync failure | Medium | Restore purchases, server-side verification |

### Business Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Low conversion to premium | High | Strong value proposition, trial period |
| Apple review rejection | Medium | Full compliance, legal pages, ATT |
| KVKK non-compliance | High | Legal review, KVKK disclosure, data deletion |
| AI content quality | Medium | Prompt engineering, content moderation |

### Security Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Data breach | High | RLS, encrypted transit, minimal data |
| Auth bypass | Medium | Supabase managed auth, PKCE flow |
| Prompt injection | Low | Server-side prompt, input sanitization |

## 9. Roadmap

### v1.0 — Store Launch

- [x] Core writing flow (Mon–Sat)
- [x] Sunday reflection
- [x] Anonymous auth + email signup
- [x] Premium subscription (monthly/yearly)
- [x] Strike system (6 dots)
- [x] Multi-language (TR/EN)
- [x] Legal pages (KVKK, Privacy, Terms)
- [x] Legal acceptance on signup
- [x] About screen
- [x] Account deletion (confirmation dialog + full data wipe)
- [ ] App Store submission

### v1.1 — Stability

- [ ] Offline entry caching
- [ ] Subscription receipt validation (server-side)
- [ ] Error reporting (Sentry/Crashlytics)
- [ ] Onboarding improvements
- [ ] Push notification for daily reminder (opt-in)

### v1.2 — Depth

- [ ] Reflection archive timeline (Premium)
- [ ] Export entries as PDF
- [ ] Themes (light/dark toggle in settings)
- [ ] Widget (iOS home screen)

### v1.3 — Growth

- [ ] Social sharing (reflection snippets)
- [ ] Streak achievements (subtle, awareness-based)
- [ ] Family plan
- [ ] Localization: German, French, Spanish
- [ ] Apple Watch companion (quick entry)
