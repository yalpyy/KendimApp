import 'package:flutter/material.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/screens/auth/login_screen.dart';
import 'package:kendin/presentation/widgets/kendin_button.dart';

/// Gate screen shown when an anonymous user tries to access
/// premium features or wants to secure their data.
///
/// Navigates to LoginScreen (which has sign-in/sign-up toggle).
class AccountGateScreen extends StatelessWidget {
  const AccountGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.screenVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),

              const Spacer(flex: 2),

              // Subtitle
              Center(
                child: Text(
                  l10n.loginSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Create account button → goes to LoginScreen
              KendinButton(
                label: l10n.createAccount,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Already have account
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(l10n.haveAccount),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
