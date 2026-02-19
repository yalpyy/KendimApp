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
      'landing_title': 'Altı gün. Bir hafta.',
      'landing_subtitle': 'Pazar günü kendinle karşılaşırsın.',
      'landing_button': 'Başla',
      'day_completed_message': 'Bugün kendindesin.',
      'saturday_completed_title': 'Altı gün bitti.',
      'saturday_completed_subtitle': 'Yarın öğlen kendinle buluş.',
    },
    'en': {
      'landing_title': 'Six days. One week.',
      'landing_subtitle': 'On Sunday, you meet yourself.',
      'landing_button': 'Start',
      'day_completed_message': 'You are present today.',
      'saturday_completed_title': 'Six days are done.',
      'saturday_completed_subtitle': 'Tomorrow at noon, meet yourself.',
    },
  };

  String _get(String key) {
    return _values[locale.languageCode]?[key] ?? _values['tr']![key]!;
  }

  String get landingTitle => _get('landing_title');
  String get landingSubtitle => _get('landing_subtitle');
  String get landingButton => _get('landing_button');
  String get dayCompletedMessage => _get('day_completed_message');
  String get saturdayCompletedTitle => _get('saturday_completed_title');
  String get saturdayCompletedSubtitle => _get('saturday_completed_subtitle');
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
