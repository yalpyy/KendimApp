import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/widgets/kendin_button.dart';

/// Email verification screen.
///
/// Shown after signup. User must verify their email before
/// purchasing premium.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isChecking = false;
  bool _isResending = false;

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

              // Title
              Center(
                child: Text(
                  l10n.verifyEmailTitle,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Message
              Center(
                child: Text(
                  l10n.verifyEmailMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // "I've verified" button
              KendinButton(
                label: l10n.verifyEmailDone,
                isLoading: _isChecking,
                onPressed: _isChecking ? null : () => _checkVerification(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Resend link
              Center(
                child: TextButton(
                  onPressed: _isResending ? null : () => _resend(),
                  child: _isResending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.verifyEmailResend),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    try {
      final verified =
          await ref.read(authServiceProvider).isEmailVerified();

      if (verified) {
        await ref.read(currentUserProvider.notifier).refresh();

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.verifyEmailMessage),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.genericError),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authServiceProvider).resendVerificationEmail();
    } catch (_) {
      // Silently ignore — user can try again.
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }
}
