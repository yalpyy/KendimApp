/// All user-facing strings in Turkish.
class AppStrings {
  AppStrings._();

  // Main
  static const String mainQuestion = 'Bugün kendin için ne yaptın?';
  static const String writeButton = 'Yazdım';
  static const String entryPlaceholder = 'Bugün ne oldu...';

  // Days
  static const List<String> dayNames = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  static const List<String> monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  // Sunday / Reflection
  static const String seeThisWeek = 'Bu haftayı gör';
  static const String reflectionLoading =
      'Haftanı bir araya getiriyorum.\nHemen değil.';
  static const String reflectionNotReady =
      'Yansıman hazırlanıyor. Birazdan geri dön.';
  static const String reflectionLocked =
      'Bu haftanın yansıması için tüm günleri tamamlaman gerekiyor.';

  // Strike
  static const String completeMissingDay = 'Eksik günü tamamla';
  static const String missTokensRemaining = 'Kalan hak';

  // Settings
  static const String settings = 'Ayarlar';
  static const String secureData = 'Verilerimi güvenceye al';
  static const String signInWithApple = 'Apple ile devam et';
  static const String signInWithGoogle = 'Google ile devam et';
  static const String signInWithEmail = 'E-posta ile devam et';
  static const String restorePurchase = 'Satın almayı geri yükle';
  static const String premium = 'Derinlik';
  static const String premiumMonthly = 'Aylık';
  static const String premiumYearly = 'Yıllık';

  // Errors
  static const String genericError = 'Bir şeyler ters gitti. Tekrar dene.';
  static const String networkError = 'Bağlantı sorunu. İnterneti kontrol et.';
  static const String entryTooShort = 'Biraz daha yaz.';

  // Archive
  static const String archive = 'Arşivle';
  static const String archived = 'Arşivlendi';
}
