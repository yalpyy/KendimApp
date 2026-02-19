import 'package:kendin/data/datasources/supabase_client_setup.dart';
import 'package:kendin/domain/usecases/notification_service.dart';
import 'package:kendin/domain/usecases/premium_service.dart';

/// Production initialization: Supabase, notifications, in-app purchases.
Future<void Function()> initializeApp() async {
  await SupabaseClientSetup.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  final premiumService = PremiumService();
  await premiumService.initialize();

  return premiumService.dispose;
}
