import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/screens/home/home_screen.dart';
import 'package:kendin/presentation/widgets/animated_dots.dart';
import 'package:kendin/presentation/widgets/kendin_button.dart';

/// First-launch landing screen.
///
/// Shows animated strike dots, a short ritual description,
/// and a "Başla" / "Start" button. Once tapped, sets
/// [has_seen_landing] in SharedPreferences and navigates to HomeScreen.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _prefsKey = 'has_seen_landing';

  void _onStart(BuildContext context) {
    // Save preference in the background — don't block navigation.
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_prefsKey, true);
    }).catchError((e) {
      debugPrint('[Kendin] Failed to save landing preference: $e');
    });

    // Navigate immediately.
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            children: [
              const Spacer(flex: 4),

              // Animated dots
              const AnimatedDots(),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text(
                l10n.landingTitle,
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                l10n.landingSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Start button
              SizedBox(
                width: 200,
                child: KendinButton(
                  label: l10n.landingButton,
                  onPressed: () => _onStart(context),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
