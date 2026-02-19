/// Demo initialization: no external services.
///
/// Skips Supabase, notifications, and in-app purchases.
/// The app runs entirely with in-memory data.
Future<void Function()> initializeApp() async {
  // Nothing to initialize in demo mode.
  return () {};
}
