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
  static const String createAccount = 'Hesap oluştur';
  static const String restorePurchase = 'Satın almayı geri yükle';
  static const String premium = 'Derinlik';
  static const String premiumMonthly = 'Aylık';
  static const String premiumYearly = 'Yıllık';
  static const String signOut = 'Çıkış yap';

  // Account gate
  static const String accountGateTitle = 'Devam etmek için\nhesap oluştur';
  static const String accountGateSubtitle =
      'Verilerini güvenceye al ve premium özelliklere eriş.';
  static const String createNewAccount = 'Hesap oluştur';
  static const String alreadyHaveAccount = 'Zaten hesabım var';

  // Signup
  static const String signUpTitle = 'Hesap oluştur';
  static const String displayNameHint = 'İsmin';
  static const String emailHint = 'E-posta';
  static const String passwordHint = 'Şifre';
  static const String signUpButton = 'Kayıt ol';

  // Login
  static const String loginTitle = 'Giriş yap';
  static const String loginButton = 'Giriş yap';
  static const String noAccountYet = 'Hesabın yok mu?';

  // Verify email
  static const String verifyEmailTitle = 'E-postanı doğrula';
  static const String verifyEmailMessage =
      'Doğrulama bağlantısı gönderildi. E-postanı kontrol et.';
  static const String resendVerification = 'Tekrar gönder';
  static const String verificationDone = 'Doğruladım';

  // Premium paywall
  static const String premiumTitle = 'Derinlik';
  static const String premiumSubtitle =
      'Eksik günleri tamamla.\nYansımalarını arşivle.\nDaha derin bir bakış.';
  static const String premiumMonthlyPrice = '49₺ / ay';
  static const String premiumYearlyPrice = '299₺ / yıl';
  static const String premiumYearlySave = 'Tasarruf et';

  // Premium CTA (after first reflection)
  static const String premiumCtaStrong =
      'Bu haftada daha fazlası vardı.\nDerinlik ile tamamını gör.';
  static const String premiumCtaSubtle = 'Daha derin bir bakış';

  // Errors
  static const String genericError = 'Bir şeyler ters gitti. Tekrar dene.';
  static const String networkError = 'Bağlantı sorunu. İnterneti kontrol et.';
  static const String entryTooShort = 'Biraz daha yaz.';
  static const String emailRequired = 'E-posta gerekli.';
  static const String passwordRequired = 'Şifre gerekli.';
  static const String displayNameRequired = 'İsim gerekli.';
  static const String passwordTooShort = 'Şifre en az 6 karakter olmalı.';
  static const String verifyEmailFirst =
      'Satın almak için önce e-postanı doğrula.';

  // Archive
  static const String archive = 'Arşivle';
  static const String archived = 'Arşivlendi';
}
