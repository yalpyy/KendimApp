import 'package:flutter/material.dart';

import 'package:kendin/core/utils/date_utils.dart';

/// Displays the current date in locale-aware format.
/// e.g., "4 Şubat · Pazartesi" (tr) or "4 February · Monday" (en)
class DateHeader extends StatelessWidget {
  const DateHeader({super.key, DateTime? date}) : _date = date;

  final DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final date = _date ?? DateTime.now();
    final locale = Localizations.localeOf(context);
    return Text(
      KendinDateUtils.formatDate(date, locale: locale),
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
