import 'package:flutter/material.dart';

import 'package:kendin/core/utils/date_utils.dart';

/// Displays the current date in Turkish format.
/// e.g., "4 Şubat · Pazartesi"
class DateHeader extends StatelessWidget {
  const DateHeader({super.key, DateTime? date}) : _date = date;

  final DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final date = _date ?? DateTime.now();
    return Text(
      KendinDateUtils.formatDateTurkish(date),
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
