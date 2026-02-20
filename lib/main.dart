import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_theme.dart';
import 'package:kendin/presentation/providers/locale_provider.dart';
import 'package:kendin/presentation/screens/home/home_screen.dart';
import 'package:kendin/presentation/screens/landing/landing_screen.dart';

// Conditional import: production init on native, web init on web.
import 'package:kendin/app_init/app_init_production.dart'
    if (dart.library.html) 'package:kendin/app_init/app_init_demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Supabase + services. Wrapped in try/catch so the app
  // still starts if Supabase init fails (e.g. empty URL on web).
  AppDisposer disposer = () {};
  try {
    disposer = await initializeApp();
  } catch (e) {
    debugPrint('[Kendin] initializeApp failed: $e');
  }

  // Check if user has seen the landing screen.
  final prefs = await SharedPreferences.getInstance();
  final hasSeenLanding = prefs.getBool('has_seen_landing') ?? false;

  // Load saved locale preference.
  final savedLocale = prefs.getString('app_locale');

  runApp(
    ProviderScope(
      child: KendinApp(
        onDispose: disposer,
        showLanding: !hasSeenLanding,
        initialLocale:
            savedLocale != null ? Locale(savedLocale) : null,
      ),
    ),
  );
}

/// Callback to clean up resources when the app is disposed.
typedef AppDisposer = void Function();

class KendinApp extends ConsumerStatefulWidget {
  const KendinApp({
    super.key,
    required this.onDispose,
    required this.showLanding,
    this.initialLocale,
  });

  final AppDisposer onDispose;
  final bool showLanding;
  final Locale? initialLocale;

  @override
  ConsumerState<KendinApp> createState() => _KendinAppState();
}

class _KendinAppState extends ConsumerState<KendinApp> {
  @override
  void initState() {
    super.initState();
    // Apply saved locale on startup.
    if (widget.initialLocale != null) {
      Future.microtask(() {
        ref.read(localeProvider.notifier).state = widget.initialLocale;
      });
    }
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Kendin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: selectedLocale,
      home: widget.showLanding ? const LandingScreen() : const HomeScreen(),
    );
  }
}
