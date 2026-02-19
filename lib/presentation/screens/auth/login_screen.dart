import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/auth/signup_screen.dart';
import 'package:kendin/presentation/widgets/kendin_button.dart';

/// Email/password login screen.
///
/// Fields: email, password.
/// After login, pops back to the previous screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
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
                  AppStrings.loginTitle,
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

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

              // Login button
              KendinButton(
                label: AppStrings.loginButton,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : () => _login(),
              ),

              const SizedBox(height: AppSpacing.md),

              // No account yet?
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: const Text(AppStrings.noAccountYet),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showError(AppStrings.emailRequired);
      return;
    }
    if (password.isEmpty) {
      _showError(AppStrings.passwordRequired);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Remember old anonymous user ID for potential migration.
      final oldUser = ref.read(currentUserProvider).valueOrNull;
      final oldUserId = oldUser?.isAnonymous == true ? oldUser?.id : null;

      final user = await ref
          .read(authServiceProvider)
          .signIn(email, password);

      // Migrate anonymous data if applicable.
      if (oldUserId != null && oldUserId != user.id) {
        await ref
            .read(authServiceProvider)
            .migrateAnonymousData(oldUserId, user.id);
      }

      ref.read(currentUserProvider.notifier).setUser(user);

      if (mounted) {
        // Pop back to the root.
        Navigator.of(context).popUntil((route) => route.isFirst);
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
