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

      // Profile
      'profile_title': 'Profil',
      'profile_free': 'Ücretsiz',
      'profile_premium': 'Premium',
      'sign_out': 'Çıkış yap',

      // Language
      'language_title': 'Dil',

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

      // Profile
      'profile_title': 'Profile',
      'profile_free': 'Free',
      'profile_premium': 'Premium',
      'sign_out': 'Sign out',

      // Language
      'language_title': 'Language',

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

  // Profile
  String get profileTitle => _get('profile_title');
  String get profileFree => _get('profile_free');
  String get profilePremium => _get('profile_premium');
  String get signOut => _get('sign_out');

  // Language
  String get languageTitle => _get('language_title');

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
