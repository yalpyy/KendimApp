import 'package:flutter/foundation.dart';

import 'package:kendin/data/datasources/supabase_client_setup.dart';
import 'package:kendin/domain/usecases/notification_service.dart';
import 'package:kendin/domain/usecases/premium_service.dart';
import 'package:kendin/domain/usecases/push_notification_service.dart';

/// Production initialization: Supabase, notifications, in-app purchases, push.
Future<void Function()> initializeApp() async {
  // 1. Initialize Supabase client.
  await SupabaseClientSetup.initialize();

  // 2. Local notifications.
  final notificationService = NotificationService();
  await notificationService.initialize();

  // 3. In-app purchases.
  final premiumService = PremiumService();
  await premiumService.initialize();

  // 4. Push notifications (Firebase + FCM).
  final pushService = PushNotificationService();
  await pushService.initialize();

  return premiumService.dispose;
}
