-- Seed: Insert 20 past weekly reflections for pagination testing.
-- Replace YOUR_USER_ID with the actual user UUID before running.
--
-- Usage:
--   1. Find your user ID: SELECT id FROM public.users LIMIT 10;
--   2. Replace 'YOUR_USER_ID' below with the UUID
--   3. Run in Supabase SQL Editor
--
-- Each reflection is backdated to a different Monday, going 20 weeks back.

DO $$
DECLARE
  uid uuid := 'YOUR_USER_ID';  -- ← Replace with actual user ID
  i int;
  week_date date;
  reflection_text text;
  texts text[] := ARRAY[
    'Bu hafta sessizce ama kararlılıkla kendinle kaldın. Pazartesi günü bir duraksama vardı, sanki haftaya temkinli başladın. Salı günü biraz daha açıldın, yazdıkların daha uzundu. Hafta ortasında yine kısa cümleler geldi ama her biri bir şey anlatıyordu. Perşembe günü ilk kez kendinden başka birinden bahsettin. Cuma günü geri döndün, yine kendinle baş başaydın. Cumartesi günü haftayı kapatırken bir bütünlük hissettin gibi.',
    'Bu hafta yazılarında bir ritim oluşmuş. Bazı günler daha içe dönük, bazı günler daha hafiftin. Özellikle çarşamba günü yazdıkların diğer günlerden farklıydı. Bir şeylerin değiştiğini fark etmişsin gibi. Hafta boyunca kendine alan açmayı sürdürdün. Bu süreklilik önemli.',
    'Hafta başında enerjin yüksekti. Yazıların uzun ve detaylıydı. Ama perşembe günü bir şeyler değişti. Cümleler kısaldı, kelimeler azaldı. Belki yoruldun, belki düşüncelerin başka yerdeydi. Ama cuma günü geri döndün. Cumartesi günü haftayı güzel kapattın.',
    'Bu hafta çok az yazdın ama yazdıkların derindi. Her cümlede bir düşünce vardı, acele etmedin. Pazartesi ve salı günü sessizdin. Çarşamba günü bir cümleyle çok şey anlattın. Hafta sonuna doğru daha çok yazmaya başladın. Az ama öz bir haftaydı.',
    'Bu hafta kendine karşı daha yumuşaktın. Yazılarında bir kabul var, bir anlayış. Başlangıçta biraz mesafeliydın ama hafta ilerledikçe yakınlaştın. Perşembe günü yazdıkların özellikle dikkat çekiciydi. Kendine baktığın belli.',
    'Haftaya hızlı başladın. İlk üç gün uzun yazılar geldi, düşünceler akıyordu. Ama perşembe günü duraksadın. Cuma günü kısa bir not bıraktın. Cumartesi günü yine uzun yazdın. Bu iniş çıkışlar da bir şey anlatıyor.',
    'Bu hafta bir tema vardı yazılarında: zaman. Günlerin nasıl geçtiğinden, zamanın akışından bahsettin. Bazen hızlı geçiyor, bazen yavaş. Bu farkındalık kendine dönmenin bir parçası. Zamanı fark etmek, kendini fark etmektir.',
    'Sessiz bir haftaydı. Çok fazla kelime kullanmadın ama her gün buradaydın. Bu tutarlılık önemli. Bazen çok söze gerek yok. Var olmak, yazmak, burada olmak yeterli. Bu haftanın yansıması da sessiz ama derin.',
    'Bu hafta biraz dağınıktın. Bazı günler yazdın, bazı günler birkaç kelimeyle geçtin. Ama bu da normal. Her hafta aynı olmak zorunda değil. Önemli olan geri dönmek. Ve sen geri döndün.',
    'Hafta boyunca kendinle dürüsttün. Yazdıklarında bir samimiyet var. Ne kadar iyi hissettiğini de yazdın, ne kadar zorlandığını da. Bu denge güzel. Kendine karşı bu açıklık kolay değil.',
    'Bu hafta yazılarında bir değişim var. Haftanın başındaki sen ile sonundaki sen farklı. Bir şeyler hareket etmiş, bir şeyler yerini bulmuş. Bu dönüşümü fark etmek önemli. Hafta hafta, yavaş yavaş.',
    'Yoğun bir haftaydı. Yazıların kısa ama yoğundu. Her cümlede bir enerji vardı. Bazen dinlenmek de kendin için bir şey yapmak demektir. Ama sen yazmayı tercih ettin. Bu da bir seçim.',
    'Bu hafta doğaya, dışarıya, çevrendeki dünyaya dikkat etmişsin. Yazılarında mekanlardan, havadan, ışıktan bahsettin. Dış dünyayı fark etmek iç dünyayı da aydınlatır. Güzel bir hafta geçirmişsin.',
    'Hafta ortası bir kırılma noktası vardı. Çarşamba günü yazdıkların diğer günlerden çok farklıydı. Bir karar verdin gibi, ya da bir şeyi anladın. Bu anlar önemli. Yazarak yakalamak daha da önemli.',
    'Bu hafta kendin için somut şeyler yaptın. Yazılarında eylemler vardı, düşüncelerden çok hareketler. Yürüdün, dinledin, pişirdin, temizledin. Kendine bakmanın her hali güzel.',
    'Sakin bir haftaydı ama durgun değil. Bir akış vardı, yumuşak ve sürekli. Yazılarında acele yoktu. Her gün kendi hızında ilerledi. Bu tempoya güvenmek güzel bir şey.',
    'Bu hafta sorular sordun kendine. Yazdıklarında soru işaretleri vardı. Cevap aramak yerine soruyla kalmayı seçtin. Bu da bir bilgeliktir. Her şeyin cevabı olmak zorunda değil.',
    'Hafta boyunca insanlardan bahsettin. Yakınlarından, arkadaşlarından, bazen tanımadığın birinden. İlişkilerin sana ne hissettirdiğini yazdın. Kendini başkalarıyla olan bağlantılarında da keşfediyorsun.',
    'Bu hafta minnettardın. Yazılarında küçük şeylere teşekkür vardı. Bir kahve, bir gülümseme, bir sessiz an. Bu farkındalık güzel. Minnettarlık kendine dönmenin en yumuşak yolu.',
    'Son haftanın yazıları bir özet gibiydi. Sanki geriye baktın ve gördüklerini yazdın. Nerede olduğunu, ne hissettiğini, nereye gittiğini. Bu bakış açısı değerli. Kendinle buluşmaya devam et.'
  ];
BEGIN
  FOR i IN 1..20 LOOP
    week_date := (current_date - ((i) * 7 + (EXTRACT(ISODOW FROM current_date)::int - 1))::int)::date;
    reflection_text := texts[i];

    INSERT INTO public.weekly_reflections (user_id, week_start_date, content, is_archived, created_at)
    VALUES (uid, week_date, reflection_text, true, (week_date + 6)::date + TIME '12:00:00')
    ON CONFLICT (user_id, week_start_date) DO NOTHING;
  END LOOP;
END $$;
