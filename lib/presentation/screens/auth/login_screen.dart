import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/l10n/app_localizations.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';
import 'package:kendin/presentation/screens/auth/verify_email_screen.dart';
import 'package:kendin/presentation/widgets/kendin_button.dart';

/// Unified auth screen with sign-in / sign-up toggle.
///
/// Sign-in: email + password.
/// Sign-up: name + email + password.
/// Subtitle: "Yazdıklarını kaybetmemek için."
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.screenVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Title
                Center(
                  child: Text(
                    _isSignUp ? l10n.signupTitle : l10n.loginTitle,
                    style: theme.textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Subtitle
                Center(
                  child: Text(
                    l10n.loginSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Name field (sign-up only)
                if (_isSignUp) ...[
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: l10n.nameHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: l10n.emailHint,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: l10n.passwordHint,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Action button
                KendinButton(
                  label: _isSignUp ? l10n.signupButton : l10n.loginButton,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : () => _submit(),
                ),

                const SizedBox(height: AppSpacing.md),

                // Toggle sign-in / sign-up
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() => _isSignUp = !_isSignUp);
                    },
                    child: Text(
                      _isSignUp ? l10n.haveAccount : l10n.noAccount,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showError(l10n.emailRequired);
      return;
    }
    if (password.isEmpty) {
      _showError(l10n.passwordRequired);
      return;
    }

    if (_isSignUp) {
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _showError(l10n.nameRequired);
        return;
      }
      if (password.length < 6) {
        _showError(l10n.passwordTooShort);
        return;
      }
      await _signUp(name, email, password);
    } else {
      await _signIn(email, password);
    }
  }

  Future<void> _signIn(String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final oldUser = ref.read(currentUserProvider).valueOrNull;
      final oldUserId = oldUser?.isAnonymous == true ? oldUser?.id : null;

      final user = await ref.read(authServiceProvider).signIn(email, password);

      if (oldUserId != null && oldUserId != user.id) {
        await ref
            .read(authServiceProvider)
            .migrateAnonymousData(oldUserId, user.id);
      }

      ref.read(currentUserProvider.notifier).setUser(user);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      _showError(AppLocalizations.of(context).genericError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp(String name, String email, String password) async {
    setState(() => _isLoading = true);
    try {
      final oldUser = ref.read(currentUserProvider).valueOrNull;
      final oldUserId = oldUser?.isAnonymous == true ? oldUser?.id : null;

      final newUser =
          await ref.read(authServiceProvider).signUp(email, password, name);

      if (oldUserId != null && oldUserId != newUser.id) {
        await ref
            .read(authServiceProvider)
            .migrateAnonymousData(oldUserId, newUser.id);
      }

      ref.read(currentUserProvider.notifier).setUser(newUser);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      _showError(AppLocalizations.of(context).genericError);
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
