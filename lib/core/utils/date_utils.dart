import 'package:kendin/core/constants/app_strings.dart';

/// Date helpers for the Kendin weekly cycle.
class KendinDateUtils {
  KendinDateUtils._();

  /// Returns the Monday of the week containing [date].
  static DateTime weekStart(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  /// Returns true if [date] is Sunday.
  static bool isSunday(DateTime date) => date.weekday == DateTime.sunday;

  /// Returns true if [date] is a writing day (Mon–Sat).
  static bool isWritingDay(DateTime date) => !isSunday(date);

  /// Returns all writing days (Mon–Sat) for the week containing [date].
  static List<DateTime> writingDaysForWeek(DateTime date) {
    final monday = weekStart(date);
    return List.generate(6, (i) => monday.add(Duration(days: i)));
  }

  /// Formats date as "4 Şubat · Pazartesi".
  static String formatDateTurkish(DateTime date) {
    final day = date.day;
    final month = AppStrings.monthNames[date.month - 1];
    final weekday = AppStrings.dayNames[date.weekday - 1];
    return '$day $month · $weekday';
  }

  /// Returns true if [a] and [b] are the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Returns the start of the current month.
  static DateTime monthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
}
