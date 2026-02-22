import 'package:flutter/material.dart';

/// Localization support for Kendin (Turkish + English).
///
/// Usage: `AppLocalizations.of(context).landingTitle`
///
/// Falls back to Turkish if the device locale is unsupported.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('tr'),
    Locale('en'),
  ];

  static final Map<String, Map<String, String>> _values = {
    'tr': {
      // Landing
      'landing_title': 'Altı gün. Bir hafta.',
      'landing_subtitle': 'Pazar günü kendinle karşılaşırsın.',
      'landing_button': 'Başla',

      // Writing
      'main_question': 'Bugün kendin için ne yaptın?',
      'write_button': 'Yazdım',
      'entry_placeholder': 'Bugün ne oldu...',
      'add_to_day': 'Güne ekle',

      // Completed
      'day_completed_message': 'Bugün kendindesin.',
      'saturday_completed_title': 'Altı gün bitti.',
      'saturday_completed_subtitle': 'Yarın öğlen kendinle buluş.',

      // Sunday
      'see_this_week': 'Bu haftayı gör',

      // Menu
      'menu_premium_title': 'Derinlik',
      'menu_premium_subtitle': 'Haftanı sakla, daha derin gör.',
      'menu_account_title': 'Hesap',
      'menu_account_subtitle_anon':
          'Verilerini kaybetmemek için hesap oluştur.',
      'menu_account_subtitle_auth': 'Hesap bilgilerini gör.',
      'menu_language_title': 'Dil',
      'menu_about_title': 'Hakkında',

      // Premium
      'premium_title': 'Derinlik',
      'premium_subtitle':
          'Eksik günleri tamamla.\nYansımalarını arşivle.\nDaha derin bir bakış.',
      'premium_unlock': 'Derinliği Aç',
      'premium_monthly': 'Aylık — 49₺ / ay',
      'premium_yearly': 'Yıllık — 299₺ / yıl',
      'premium_yearly_save': 'Tasarruf et',
      'premium_restore': 'Satın almayı geri yükle',
      'premium_explanation':
          'Her hafta yazdıklarının bir yansımasını alırsın.\n'
          'Derinlik ile eksik günleri tamamlayabilir,\n'
          'yansımalarını arşivleyebilirsin.',
      'premium_advantage_1': 'Eksik günleri tamamla',
      'premium_advantage_2': 'Yansımalarını arşivle',
      'premium_advantage_3': 'Geçmiş haftalara dön',
      'premium_timeline_title': 'Yansımalar',
      'premium_no_reflections': 'Henüz yansıman yok.',

      // Auth
      'login_title': 'Giriş yap',
      'signup_title': 'Hesap oluştur',
      'login_subtitle': 'Yazdıklarını kaybetmemek için.',
      'email_hint': 'E-posta',
      'password_hint': 'Şifre',
      'name_hint': 'İsmin',
      'login_button': 'Giriş yap',
      'signup_button': 'Kayıt ol',
      'no_account': 'Hesabın yok mu?',
      'have_account': 'Zaten hesabın var mı?',
      'verify_email_title': 'E-postanı doğrula',
      'verify_email_message':
          'Doğrulama bağlantısı gönderildi. E-postanı kontrol et.',
      'verify_email_done': 'Doğruladım',
      'verify_email_resend': 'Tekrar gönder',
      'create_account': 'Hesap oluştur',
      'verify_first': 'Satın almak için önce e-postanı doğrula.',
      'legal_accept_required':
          'Devam etmek için koşulları kabul etmelisin.',
      'legal_accept_prefix': 'Kabul ediyorum: ',
      'privacy_policy': 'Gizlilik Politikası',
      'terms_of_service': 'Kullanım Koşulları',
      'kvkk_notice': 'KVKK Aydınlatma Metni',

      // Profile
      'profile_title': 'Profil',
      'profile_free': 'Ücretsiz',
      'profile_premium': 'Premium',
      'sign_out': 'Çıkış yap',
      'delete_account': 'Hesabı Sil',
      'delete_account_confirm_title': 'Hesabını silmek istediğinden emin misin?',
      'delete_account_confirm_body':
          'Tüm yazıların, yansımaların ve hesap bilgilerin kalıcı olarak silinecek. Bu işlem geri alınamaz.',
      'delete_account_confirm_button': 'Evet, hesabımı sil',
      'cancel': 'Vazgeç',
      'account_deleted': 'Hesabın silindi.',

      // Language
      'language_title': 'Dil',

      // About
      'about_title': 'Hakkında',
      'about_purpose_title': 'Amaç',
      'about_purpose_body':
          'Kendin, her gün kendine bir soru sormanı sağlar. '
          'Cevap vermek zorunda değilsin. Ama yazarsan, '
          'haftanın sonunda kendinle karşılaşırsın.',
      'about_awareness_title': 'Farkındalık',
      'about_awareness_body':
          'Bu uygulama bir günlük değil. Bir ayna. '
          'Altı gün yazarsın, pazar günü yapay zeka '
          'yazdıklarından bir yansıma oluşturur. '
          'Seni yargılamaz, sadece gösterir.',
      'about_reflection_title': 'Haftalık Yansıma',
      'about_reflection_body':
          'Her hafta pazartesiden cumartesiye kadar yazarsın. '
          'Pazar günü yazdıkların bir araya getirilir ve '
          'kişisel bir yansıma olarak sana sunulur. '
          'Bu yansıma sadece sana aittir.',
      'about_premium_title': 'Derinlik',
      'about_premium_body':
          'Premium ile eksik günleri tamamlayabilir, '
          'yansımalarını arşivleyebilir ve geçmiş '
          'haftalara geri dönebilirsin. '
          'Daha derin bir bakış.',

      // 23:30 notice
      'day_closing_notice': 'Gün kapanıyor.',

      // Reflection
      'reflection_loading': 'Haftanı bir araya getiriyorum.\nHemen değil.',
      'reflection_not_ready':
          'Yansıman hazırlanıyor. Birazdan geri dön.',
      'premium_cta_strong':
          'Bu haftada daha fazlası vardı.\nDerinlik ile tamamını gör.',
      'premium_monthly_price': '49₺ / ay',
      'archive': 'Arşivle',
      'archived': 'Arşivlendi',

      // Settings
      'settings_title': 'Ayarlar',
      'restore_purchase': 'Satın almayı geri yükle',

      // Errors
      'generic_error': 'Bir şeyler ters gitti. Tekrar dene.',
      'email_required': 'E-posta gerekli.',
      'password_required': 'Şifre gerekli.',
      'name_required': 'İsim gerekli.',
      'password_too_short': 'Şifre en az 6 karakter olmalı.',
    },
    'en': {
      // Landing
      'landing_title': 'Six days. One week.',
      'landing_subtitle': 'On Sunday, you meet yourself.',
      'landing_button': 'Start',

      // Writing
      'main_question': 'What did you do for yourself today?',
      'write_button': 'Done',
      'entry_placeholder': 'What happened today...',
      'add_to_day': 'Add to day',

      // Completed
      'day_completed_message': 'You are present today.',
      'saturday_completed_title': 'Six days are done.',
      'saturday_completed_subtitle': 'Tomorrow at noon, meet yourself.',

      // Sunday
      'see_this_week': 'See this week',

      // Menu
      'menu_premium_title': 'Depth',
      'menu_premium_subtitle': 'Keep your week, see deeper.',
      'menu_account_title': 'Account',
      'menu_account_subtitle_anon':
          'Create an account to keep your data.',
      'menu_account_subtitle_auth': 'View account details.',
      'menu_language_title': 'Language',
      'menu_about_title': 'About',

      // Premium
      'premium_title': 'Depth',
      'premium_subtitle':
          'Complete missing days.\nArchive your reflections.\nA deeper look.',
      'premium_unlock': 'Unlock Depth',
      'premium_monthly': 'Monthly — 49₺ / mo',
      'premium_yearly': 'Yearly — 299₺ / yr',
      'premium_yearly_save': 'Save',
      'premium_restore': 'Restore purchase',
      'premium_explanation':
          'Each week you get a reflection of what you wrote.\n'
          'With Depth you can complete missed days\n'
          'and archive your reflections.',
      'premium_advantage_1': 'Complete missed days',
      'premium_advantage_2': 'Archive your reflections',
      'premium_advantage_3': 'Return to past weeks',
      'premium_timeline_title': 'Reflections',
      'premium_no_reflections': 'No reflections yet.',

      // Auth
      'login_title': 'Sign in',
      'signup_title': 'Create account',
      'login_subtitle': 'To not lose what you\'ve written.',
      'email_hint': 'Email',
      'password_hint': 'Password',
      'name_hint': 'Your name',
      'login_button': 'Sign in',
      'signup_button': 'Sign up',
      'no_account': 'Don\'t have an account?',
      'have_account': 'Already have an account?',
      'verify_email_title': 'Verify your email',
      'verify_email_message':
          'Verification link sent. Check your email.',
      'verify_email_done': 'I verified',
      'verify_email_resend': 'Resend',
      'create_account': 'Create account',
      'verify_first': 'Verify your email first to purchase.',
      'legal_accept_required':
          'You must accept the terms to continue.',
      'legal_accept_prefix': 'I accept: ',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'kvkk_notice': 'KVKK Disclosure',

      // Profile
      'profile_title': 'Profile',
      'profile_free': 'Free',
      'profile_premium': 'Premium',
      'sign_out': 'Sign out',
      'delete_account': 'Delete Account',
      'delete_account_confirm_title': 'Are you sure you want to delete your account?',
      'delete_account_confirm_body':
          'All your entries, reflections, and account information will be permanently deleted. This action cannot be undone.',
      'delete_account_confirm_button': 'Yes, delete my account',
      'cancel': 'Cancel',
      'account_deleted': 'Your account has been deleted.',

      // Language
      'language_title': 'Language',

      // About
      'about_title': 'About',
      'about_purpose_title': 'Purpose',
      'about_purpose_body':
          'Kendin asks you one question every day. '
          'You don\'t have to answer. But if you write, '
          'you\'ll meet yourself at the end of the week.',
      'about_awareness_title': 'Awareness',
      'about_awareness_body':
          'This app is not a diary. It\'s a mirror. '
          'You write for six days, and on Sunday '
          'AI creates a reflection from your writing. '
          'It doesn\'t judge, it just shows.',
      'about_reflection_title': 'Weekly Reflection',
      'about_reflection_body':
          'You write from Monday to Saturday each week. '
          'On Sunday, your entries are compiled into '
          'a personal reflection just for you. '
          'This reflection belongs only to you.',
      'about_premium_title': 'Depth',
      'about_premium_body':
          'With Premium you can complete missed days, '
          'archive your reflections, and return to '
          'past weeks. A deeper look.',

      // 23:30 notice
      'day_closing_notice': 'Day is closing.',

      // Reflection
      'reflection_loading':
          'Putting your week together.\nNot right now.',
      'reflection_not_ready':
          'Your reflection is being prepared. Come back soon.',
      'premium_cta_strong':
          'There was more this week.\nSee the full picture with Depth.',
      'premium_monthly_price': '49₺ / mo',
      'archive': 'Archive',
      'archived': 'Archived',

      // Settings
      'settings_title': 'Settings',
      'restore_purchase': 'Restore purchase',

      // Errors
      'generic_error': 'Something went wrong. Try again.',
      'email_required': 'Email is required.',
      'password_required': 'Password is required.',
      'name_required': 'Name is required.',
      'password_too_short': 'Password must be at least 6 characters.',
    },
  };

  String _get(String key) {
    return _values[locale.languageCode]?[key] ?? _values['tr']![key]!;
  }

  // Landing
  String get landingTitle => _get('landing_title');
  String get landingSubtitle => _get('landing_subtitle');
  String get landingButton => _get('landing_button');

  // Writing
  String get mainQuestion => _get('main_question');
  String get writeButton => _get('write_button');
  String get entryPlaceholder => _get('entry_placeholder');
  String get addToDay => _get('add_to_day');

  // Completed
  String get dayCompletedMessage => _get('day_completed_message');
  String get saturdayCompletedTitle => _get('saturday_completed_title');
  String get saturdayCompletedSubtitle => _get('saturday_completed_subtitle');

  // Sunday
  String get seeThisWeek => _get('see_this_week');

  // Menu
  String get menuPremiumTitle => _get('menu_premium_title');
  String get menuPremiumSubtitle => _get('menu_premium_subtitle');
  String get menuAccountTitle => _get('menu_account_title');
  String get menuAccountSubtitleAnon => _get('menu_account_subtitle_anon');
  String get menuAccountSubtitleAuth => _get('menu_account_subtitle_auth');
  String get menuLanguageTitle => _get('menu_language_title');
  String get menuAboutTitle => _get('menu_about_title');

  // Premium
  String get premiumTitle => _get('premium_title');
  String get premiumSubtitle => _get('premium_subtitle');
  String get premiumUnlock => _get('premium_unlock');
  String get premiumMonthly => _get('premium_monthly');
  String get premiumYearly => _get('premium_yearly');
  String get premiumYearlySave => _get('premium_yearly_save');
  String get premiumRestore => _get('premium_restore');
  String get premiumExplanation => _get('premium_explanation');
  String get premiumAdvantage1 => _get('premium_advantage_1');
  String get premiumAdvantage2 => _get('premium_advantage_2');
  String get premiumAdvantage3 => _get('premium_advantage_3');
  String get premiumTimelineTitle => _get('premium_timeline_title');
  String get premiumNoReflections => _get('premium_no_reflections');

  // Auth
  String get loginTitle => _get('login_title');
  String get signupTitle => _get('signup_title');
  String get loginSubtitle => _get('login_subtitle');
  String get emailHint => _get('email_hint');
  String get passwordHint => _get('password_hint');
  String get nameHint => _get('name_hint');
  String get loginButton => _get('login_button');
  String get signupButton => _get('signup_button');
  String get noAccount => _get('no_account');
  String get haveAccount => _get('have_account');
  String get verifyEmailTitle => _get('verify_email_title');
  String get verifyEmailMessage => _get('verify_email_message');
  String get verifyEmailDone => _get('verify_email_done');
  String get verifyEmailResend => _get('verify_email_resend');
  String get createAccount => _get('create_account');
  String get verifyFirst => _get('verify_first');
  String get legalAcceptRequired => _get('legal_accept_required');
  String get legalAcceptPrefix => _get('legal_accept_prefix');
  String get privacyPolicy => _get('privacy_policy');
  String get termsOfService => _get('terms_of_service');
  String get kvkkNotice => _get('kvkk_notice');

  // Profile
  String get profileTitle => _get('profile_title');
  String get profileFree => _get('profile_free');
  String get profilePremium => _get('profile_premium');
  String get signOut => _get('sign_out');
  String get deleteAccount => _get('delete_account');
  String get deleteAccountConfirmTitle => _get('delete_account_confirm_title');
  String get deleteAccountConfirmBody => _get('delete_account_confirm_body');
  String get deleteAccountConfirmButton => _get('delete_account_confirm_button');
  String get cancel => _get('cancel');
  String get accountDeleted => _get('account_deleted');

  // Language
  String get languageTitle => _get('language_title');

  // About
  String get aboutTitle => _get('about_title');
  String get aboutPurposeTitle => _get('about_purpose_title');
  String get aboutPurposeBody => _get('about_purpose_body');
  String get aboutAwarenessTitle => _get('about_awareness_title');
  String get aboutAwarenessBody => _get('about_awareness_body');
  String get aboutReflectionTitle => _get('about_reflection_title');
  String get aboutReflectionBody => _get('about_reflection_body');
  String get aboutPremiumTitle => _get('about_premium_title');
  String get aboutPremiumBody => _get('about_premium_body');

  // 23:30 notice
  String get dayClosingNotice => _get('day_closing_notice');

  // Reflection
  String get reflectionLoading => _get('reflection_loading');
  String get reflectionNotReady => _get('reflection_not_ready');
  String get premiumCtaStrong => _get('premium_cta_strong');
  String get premiumMonthlyPrice => _get('premium_monthly_price');
  String get archive => _get('archive');
  String get archived => _get('archived');

  // Settings
  String get settingsTitle => _get('settings_title');
  String get restorePurchase => _get('restore_purchase');

  // Errors
  String get genericError => _get('generic_error');
  String get emailRequired => _get('email_required');
  String get passwordRequired => _get('password_required');
  String get nameRequired => _get('name_required');
  String get passwordTooShort => _get('password_too_short');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
