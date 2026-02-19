import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/auth/verify_email_screen.dart';
import 'package:kendin/presentation/widgets/kendin_button.dart';

/// Email/password signup screen.
///
/// Fields: display name, email, password.
/// After signup, navigates to VerifyEmailScreen.
/// If the current user is anonymous, migrates their data.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                  AppStrings.signUpTitle,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Display name field
              TextField(
                controller: _displayNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: AppStrings.displayNameHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: AppStrings.emailHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: AppStrings.passwordHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Signup button
              KendinButton(
                label: AppStrings.signUpButton,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : () => _signUp(),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (displayName.isEmpty) {
      _showError(AppStrings.displayNameRequired);
      return;
    }
    if (email.isEmpty) {
      _showError(AppStrings.emailRequired);
      return;
    }
    if (password.length < 6) {
      _showError(AppStrings.passwordTooShort);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Remember the old anonymous user ID for migration.
      final oldUser = ref.read(currentUserProvider).valueOrNull;
      final oldUserId = oldUser?.isAnonymous == true ? oldUser?.id : null;

      // Create new email account.
      final newUser = await ref
          .read(authServiceProvider)
          .signUp(email, password, displayName);

      // Migrate anonymous data if applicable.
      if (oldUserId != null && oldUserId != newUser.id) {
        await ref
            .read(authServiceProvider)
            .migrateAnonymousData(oldUserId, newUser.id);
      }

      // Update the current user.
      ref.read(currentUserProvider.notifier).setUser(newUser);

      if (mounted) {
        // Navigate to email verification screen, replacing the auth flow.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      _showError(AppStrings.genericError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
