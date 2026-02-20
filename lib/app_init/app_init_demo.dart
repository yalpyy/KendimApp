import 'package:flutter/foundation.dart';

import 'package:kendin/data/datasources/supabase_client_setup.dart';

/// Web initialization: Supabase + anonymous auth.
///
/// Skips notifications and in-app purchases (native-only plugins).
Future<void Function()> initializeApp() async {
  // 1. Initialize Supabase client (same as production).
  await SupabaseClientSetup.initialize();

  // 2. Ensure an authenticated session exists (anonymous if needed).
  final client = SupabaseClientSetup.client;
  final session = client.auth.currentSession;
  if (session == null) {
    debugPrint('[Kendin] No existing session — signing in anonymously… (web)');
    try {
      final response = await client.auth.signInAnonymously();
      debugPrint('[Kendin] Anonymous sign-in OK: uid=${response.user?.id}');
    } catch (e) {
      debugPrint('[Kendin] Anonymous sign-in FAILED: $e');
    }
  } else {
    debugPrint('[Kendin] Existing session found: uid=${session.user.id}');
  }

  // No notifications or IAP on web.
  return () {};
}
