/// Demo mode configuration.
///
/// When [kDemoMode] is true:
/// - Supabase is not initialized.
/// - Auth, entries, and reflections use in-memory storage.
/// - No Edge Function or OpenAI calls.
/// - No in-app purchase or notification dependencies.
/// - The app runs fully on Flutter Web (GitHub Pages).
///
/// To switch to production:
///   Set kDemoMode = false and ensure Supabase credentials
///   are configured in [AppConstants].
const bool kDemoMode = true;
