import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/theme/app_theme.dart';
import 'package:kendin/data/datasources/supabase_client_setup.dart';
import 'package:kendin/domain/usecases/notification_service.dart';
import 'package:kendin/domain/usecases/premium_service.dart';
import 'package:kendin/presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Supabase.
  await SupabaseClientSetup.initialize();

  // Initialize notifications.
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize in-app purchases.
  final premiumService = PremiumService();
  await premiumService.initialize();

  runApp(
    ProviderScope(
      child: KendinApp(premiumService: premiumService),
    ),
  );
}

class KendinApp extends StatefulWidget {
  const KendinApp({super.key, required this.premiumService});

  final PremiumService premiumService;

  @override
  State<KendinApp> createState() => _KendinAppState();
}

class _KendinAppState extends State<KendinApp> {
  @override
  void dispose() {
    widget.premiumService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kendin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
