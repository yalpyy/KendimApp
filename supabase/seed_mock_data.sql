-- ═══════════════════════════════════════════════════════
-- Kendin App — Mock Data for Testing
-- ═══════════════════════════════════════════════════════
--
-- Prerequisites:
--   1. Run 001_initial_schema.sql first
--   2. Run 002_add_admin_and_display_name.sql
--   3. Create a test user in Supabase Auth:
--      Email: admin@kendin.app  Password: Test123456
--      (use Supabase Dashboard → Authentication → Create User)
--   4. Copy the auth user UUID and replace the placeholder below.
--
-- After creating the auth user, replace this UUID:
-- ───────────────────────────────────────────────────────

-- STEP 1: Set the test user UUID here
-- Replace 'YOUR_AUTH_USER_UUID_HERE' with the actual UUID from Supabase Auth.
DO $$
DECLARE
  test_user_id uuid := 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'; -- REPLACE THIS
  week1_start date;
  week2_start date;
  week3_start date;
  current_week_start date;
BEGIN

  -- ─── Calculate week starts (Monday-based) ─────────
  current_week_start := date_trunc('week', current_date)::date;
  week1_start := current_week_start - interval '21 days'; -- 3 weeks ago
  week2_start := current_week_start - interval '14 days'; -- 2 weeks ago
  week3_start := current_week_start - interval '7 days';  -- 1 week ago

  -- ─── STEP 2: Create user row ──────────────────────
  INSERT INTO public.users (id, is_premium, is_admin, premium_miss_tokens, display_name, created_at, updated_at)
  VALUES (
    test_user_id,
    true,                        -- is_premium
    true,                        -- is_admin
    3,                           -- premium_miss_tokens
    'Test Admin',                -- display_name
    now() - interval '30 days',  -- created_at
    now()                        -- updated_at
  )
  ON CONFLICT (id) DO UPDATE SET
    is_premium = true,
    is_admin = true,
    display_name = 'Test Admin',
    updated_at = now();

  -- ─── STEP 3: Entries — Week 1 (3 weeks ago) ───────
  -- Monday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Bugün sabah erken kalktım ve 30 dakika yürüyüş yaptım. Zihinim daha berrak hissetti.',
    week1_start,
    week1_start + time '09:30')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Tuesday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Kendime bir kahve aldım ve parkta oturdum. Hiçbir şey yapmadan 20 dakika geçirdim.',
    week1_start + 1,
    (week1_start + 1) + time '14:15')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Wednesday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Eski bir arkadaşımı aradım. Uzun süredir konuşmamıştık, iyi geldi.',
    week1_start + 2,
    (week1_start + 2) + time '20:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Thursday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Bugün kendime vakit ayıramadım ama fark ettim ki bu da bir farkındalık.',
    week1_start + 3,
    (week1_start + 3) + time '22:45')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Friday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Yeni bir kitap almaya gittim. Uzun süredir kitapçıya girmemiştim.',
    week1_start + 4,
    (week1_start + 4) + time '17:30')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Saturday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Sabah meditasyon yaptım. 10 dakika bile olsa fark yaratıyor.',
    week1_start + 5,
    (week1_start + 5) + time '08:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- ─── STEP 4: Entries — Week 2 (2 weeks ago) ───────
  -- Monday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'İş yerinde zor bir gündü ama öğle molasında dışarı çıkıp yürüdüm.',
    week2_start,
    week2_start + time '13:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Tuesday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Bugün pişirmeye vakit ayırdım. Uzun süredir yapmadığım bir tarif denedim.',
    week2_start + 1,
    (week2_start + 1) + time '19:30')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Wednesday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Günlüğümü okudum ve geçen yıl ne kadar farklı hissettiğimi fark ettim.',
    week2_start + 2,
    (week2_start + 2) + time '21:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Thursday (skipped — simulates an incomplete week)

  -- Friday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Kendime bir söz verdim: haftada en az bir kere doğada vakit geçireceğim.',
    week2_start + 4,
    (week2_start + 4) + time '16:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Saturday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Sabah koşusu yaptım. Vücudumun ne kadar hareket etmeye ihtiyacı olduğunu hissettim.',
    week2_start + 5,
    (week2_start + 5) + time '07:45')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- ─── STEP 5: Entries — Week 3 (last week) ─────────
  -- Monday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Bu hafta daha bilinçli olmaya karar verdim. Telefonumu yatmadan önce bırakacağım.',
    week3_start,
    week3_start + time '22:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Tuesday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Bugün iş arkadaşıma teşekkür ettim. Küçük bir şey ama onu mutlu etti.',
    week3_start + 1,
    (week3_start + 1) + time '18:30')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Wednesday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Müzik dinleyerek yürüdüm. Şehrin seslerini fark etmek için kulaklığı çıkardım.',
    week3_start + 2,
    (week3_start + 2) + time '17:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Thursday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Kendime yeni bir şey öğretmeye başladım. Gitar çalmayı deniyorum.',
    week3_start + 3,
    (week3_start + 3) + time '20:15')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Friday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Annemi aradım. Sesini duymak iyi geldi.',
    week3_start + 4,
    (week3_start + 4) + time '19:00')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- Saturday
  INSERT INTO public.entries (user_id, text, entry_date, created_at)
  VALUES (test_user_id,
    'Bugün hiçbir plan yapmadım. Sadece akışına bıraktım ve güzel geçti.',
    week3_start + 5,
    (week3_start + 5) + time '21:30')
  ON CONFLICT (user_id, entry_date) DO NOTHING;

  -- ─── STEP 6: Weekly Reflections ───────────────────
  -- Week 1 reflection (archived)
  INSERT INTO public.weekly_reflections (user_id, week_start_date, content, is_archived, created_at)
  VALUES (
    test_user_id,
    week1_start,
    'Bu hafta kendine küçük ama anlamlı alanlar açtın. Sabah yürüyüşleriyle başlayan hafta, '
    'eski bir arkadaşla bağlantı kurmaya ve kitapçıda kaybolmaya uzandı. '
    'Dikkat çeken bir şey var: kendin için zaman ayırdığında, bunun "büyük" olmasına gerek yok — '
    'bir kahve, bir yürüyüş, bir telefon. Perşembe günü yazdığın "vakit ayıramadım ama fark ettim" '
    'cümlesi belki de haftanın en güçlü cümlesi. Farkındalık her zaman eylemde değil, '
    'bazen duraksadığında da ortaya çıkıyor.',
    true,  -- archived
    (week1_start + 6) + time '12:00'
  )
  ON CONFLICT (user_id, week_start_date) DO NOTHING;

  -- Week 2 reflection (archived)
  INSERT INTO public.weekly_reflections (user_id, week_start_date, content, is_archived, created_at)
  VALUES (
    test_user_id,
    week2_start,
    'Bu hafta bedenine ve geçmişine döndün. Yürüyüş, yemek pişirme, koşu — hepsi bedensel. '
    'Günlüğünü okuyup geçen yıla bakman ise zamanda bir yolculuk. '
    'Perşembe günü yazmamış olman, belki de o gün kendine başka bir şekilde vakit ayırdığının işareti. '
    'Doğada vakit geçirme sözün dikkat çekici — kendine verdiğin sözler, '
    'genellikle neye ihtiyacın olduğunu zaten bildiğini gösteriyor.',
    true,  -- archived
    (week2_start + 6) + time '12:00'
  )
  ON CONFLICT (user_id, week_start_date) DO NOTHING;

  -- Week 3 reflection (current — not archived)
  INSERT INTO public.weekly_reflections (user_id, week_start_date, content, is_archived, created_at)
  VALUES (
    test_user_id,
    week3_start,
    'Bu hafta bir dönüm noktası gibi görünüyor. Telefonunu bırakma kararı, '
    'iş arkadaşına teşekkür etme, kulaklığı çıkarıp şehri dinleme — '
    'hepsi aynı şeyi işaret ediyor: daha fazla burada olmak istiyorsun. '
    'Gitar çalmaya başlaman özellikle ilginç — kendine yeni bir dil öğretiyorsun. '
    'Cumartesi günü "akışına bıraktım" yazman, belki de haftanın özeti: '
    'kontrol etmeden, planlamadan, sadece olmak. Bu haftanın en güzel yanı, '
    'her günün biraz daha bilinçli geçmiş olması.',
    false,  -- not archived (current week)
    (week3_start + 6) + time '12:00'
  )
  ON CONFLICT (user_id, week_start_date) DO NOTHING;

  RAISE NOTICE 'Mock data inserted for user %', test_user_id;

END $$;

-- ─── QUICK VERIFICATION ──────────────────────────────
-- Run these queries to verify the data:
--
-- SELECT * FROM public.users WHERE display_name = 'Test Admin';
-- SELECT count(*) FROM public.entries WHERE user_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
-- SELECT * FROM public.weekly_reflections WHERE user_id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
