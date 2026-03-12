-- ═══════════════════════════════════════════════════════
-- Kendin App — Mock Depth (Derinlik) Data
-- ═══════════════════════════════════════════════════════
--
-- Inserts sample entries and a weekly reflection for user
-- b258bbfa-9bef-4d41-b027-45fdb44645b8 to demonstrate the
-- Depth (Derinlik) feature.
--
-- Run in Supabase SQL Editor (requires service_role access).
-- ───────────────────────────────────────────────────────

DO $$
DECLARE
  target_user_id uuid := 'b258bbfa-9bef-4d41-b027-45fdb44645b8';
  week_start date;
BEGIN

  -- Use last week's Monday as the week start
  week_start := date_trunc('week', current_date - interval '7 days')::date;

  -- Ensure user exists in public.users
  INSERT INTO public.users (id, is_premium, is_admin, premium_miss_tokens, display_name, created_at, updated_at)
  VALUES (
    target_user_id,
    true,
    false,
    3,
    NULL,
    now() - interval '14 days',
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    is_premium = true,
    updated_at = now();

  -- ─── Entries (Mon–Sat of last week) ─────────────────

  -- Monday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (target_user_id,
    'Bugün kendime uzun bir yürüyüş hediye ettim. Kafamı boşaltmam gerekiyordu ve doğa tam da bunu yaptı.',
    week_start,
    week_start + time '10:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Tuesday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (target_user_id,
    'Sabah erken kalktım ve sessizce kahvemi içtim. Kimseyle konuşmadım, sadece dinledim.',
    week_start + 1,
    (week_start + 1) + time '08:30')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Wednesday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (target_user_id,
    'Bir arkadaşımla dertleştim. Onun da benzer şeyler hissettiğini öğrenmek rahatlatıcıydı.',
    week_start + 2,
    (week_start + 2) + time '19:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Thursday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (target_user_id,
    'Bugün resim çizmeye başladım. Yıllardır yapmadığım bir şey, ellerimin hatırlaması hoşuma gitti.',
    week_start + 3,
    (week_start + 3) + time '21:15')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Friday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (target_user_id,
    'Kendime yeni bir kitap aldım ve akşam iki saat okudum. Ekrandan uzak kalmak iyi geldi.',
    week_start + 4,
    (week_start + 4) + time '22:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Saturday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (target_user_id,
    'Bugün hiçbir şey planlamadım. Sadece anın içinde kaldım ve bu yeterli geldi.',
    week_start + 5,
    (week_start + 5) + time '16:30')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- ─── Weekly Reflection ──────────────────────────────
  INSERT INTO public.weekly_reflections (user_id, week_start_date, content, is_archived, created_at)
  VALUES (
    target_user_id,
    week_start,
    'Bu hafta sessizliğin gücünü yeniden keşfettin. '
    'Pazartesi doğayla başlayan hafta, salah sabahın sessiz kahvesiyle derinleşti. '
    'Çarşamba günü bir arkadaşınla paylaşım yapman dikkat çekici — yalnız olmadığını hatırladın. '
    'Perşembe günü resim çizmek, ellerinin hafızasına güvenmek demek; '
    'bu belki de haftanın en cesur anıydı. '
    'Cuma akşamı kitapla geçen saatler ve cumartesi günü hiçbir şey planlamamak — '
    'ikisi de aynı şeyi söylüyor: kontrol etmeden, sadece olmayı seçtin. '
    'Bu hafta kendine alan açtın ve o alan seni karşıladı.',
    false,
    (week_start + 6) + time '12:00'
  )
  ON CONFLICT (user_id, week_start_date) DO NOTHING;

  RAISE NOTICE '──────────────────────────────────────────';
  RAISE NOTICE 'Mock depth data inserted for user: %', target_user_id;
  RAISE NOTICE 'Week start: %', week_start;
  RAISE NOTICE '──────────────────────────────────────────';

END $$;
