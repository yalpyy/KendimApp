import 'package:flutter/foundation.dart';

import 'package:kendin/data/datasources/supabase_client_setup.dart';
import 'package:kendin/domain/usecases/notification_service.dart';
import 'package:kendin/domain/usecases/premium_service.dart';

/// Production initialization: Supabase, anonymous auth, notifications, in-app purchases.
Future<void Function()> initializeApp() async {
  // 1. Initialize Supabase client.
  await SupabaseClientSetup.initialize();

  // 2. Ensure an authenticated session exists (anonymous if needed).
  final client = SupabaseClientSetup.client;
  final session = client.auth.currentSession;
  if (session == null) {
    debugPrint('[Kendin] No existing session — signing in anonymously…');
    try {
      final response = await client.auth.signInAnonymously();
      debugPrint('[Kendin] Anonymous sign-in OK: uid=${response.user?.id}');
    } catch (e) {
      debugPrint('[Kendin] Anonymous sign-in FAILED: $e');
    }
  } else {
    debugPrint('[Kendin] Existing session found: uid=${session.user.id}');
  }

  // 3. Notifications.
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 4. In-app purchases.
  final premiumService = PremiumService();
  await premiumService.initialize();

  return premiumService.dispose;
}
