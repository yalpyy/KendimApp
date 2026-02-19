import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/theme/app_theme.dart';
import 'package:kendin/presentation/screens/home/home_screen.dart';

// Conditional import: production init on native, demo (no-op) on web.
import 'package:kendin/app_init/app_init_production.dart'
    if (dart.library.html) 'package:kendin/app_init/app_init_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initializes Supabase + notifications + IAP in production,
  // or does nothing in demo mode.
  final disposer = await initializeApp();

  runApp(
    ProviderScope(
      child: KendinApp(onDispose: disposer),
    ),
  );
}

/// Callback to clean up resources when the app is disposed.
typedef AppDisposer = void Function();

class KendinApp extends StatefulWidget {
  const KendinApp({super.key, required this.onDispose});

  final AppDisposer onDispose;

  @override
  State<KendinApp> createState() => _KendinAppState();
}

class _KendinAppState extends State<KendinApp> {
  @override
  void dispose() {
    widget.onDispose();
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
