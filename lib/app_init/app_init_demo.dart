import 'package:flutter/foundation.dart';

import 'package:kendin/data/datasources/supabase_client_setup.dart';

/// Web initialization: Supabase only.
///
/// Skips notifications and in-app purchases (native-only plugins).
Future<void Function()> initializeApp() async {
  // Initialize Supabase client.
  await SupabaseClientSetup.initialize();

  // No notifications or IAP on web.
  return () {};
}
