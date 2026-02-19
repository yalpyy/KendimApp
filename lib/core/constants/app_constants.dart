/// Application-wide constants for Kendin.
class AppConstants {
  AppConstants._();

  // App identity
  static const String appName = 'Kendin';
  static const String appSubtitle = 'Bugün kendin için ne yaptın?';

  // Supabase — replace with your actual values
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Strike system
  static const int writingDaysPerWeek = 6; // Mon–Sat
  static const int maxMissTokensPerMonth = 3;

  // Reflection
  static const Duration reflectionDelay = Duration(minutes: 10);
  static const String reflectionNotificationTitle = 'Kendin';
  static const String reflectionNotificationBody = 'Sana bir haberim var.';

  // Premium product IDs
  static const String monthlyProductId = 'kendin_derinlik_monthly';
  static const String yearlyProductId = 'kendin_derinlik_yearly';

  // Date
  static const int sunday = DateTime.sunday;
  static const int monday = DateTime.monday;

  // Entry constraints
  static const int minEntryLength = 1;
  static const int maxEntryLength = 2000;
}
