import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/widgets/kendin_button.dart';

/// Email verification screen.
///
/// Shown after signup. User must verify their email before
/// purchasing premium. Shows a "Tekrar gönder" button and
/// a "Doğruladım" button to check verification status.
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
                  AppStrings.verifyEmailTitle,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Message
              Center(
                child: Text(
                  AppStrings.verifyEmailMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // "I've verified" button
              KendinButton(
                label: AppStrings.verificationDone,
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
                      : const Text(AppStrings.resendVerification),
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
        // Refresh user state.
        await ref.read(currentUserProvider.notifier).refresh();

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.verifyEmailMessage),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.genericError),
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
