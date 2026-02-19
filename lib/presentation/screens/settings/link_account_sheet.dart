import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';

/// Bottom sheet for linking an anonymous account.
///
/// Options:
/// - Apple
/// - Google
/// - Email
class LinkAccountSheet extends ConsumerStatefulWidget {
  const LinkAccountSheet({super.key});

  @override
  ConsumerState<LinkAccountSheet> createState() => _LinkAccountSheetState();
}

class _LinkAccountSheetState extends ConsumerState<LinkAccountSheet> {
  bool _isLoading = false;
  bool _showEmailForm = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenHorizontal,
        right: AppSpacing.screenHorizontal,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.secureData,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: AppSpacing.xxl),

          if (!_showEmailForm) ...[
            // Apple
            _LinkButton(
              label: AppStrings.signInWithApple,
              icon: Icons.apple,
              isLoading: _isLoading,
              onPressed: () => _linkApple(),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Google
            _LinkButton(
              label: AppStrings.signInWithGoogle,
              icon: Icons.g_mobiledata,
              isLoading: _isLoading,
              onPressed: () => _linkGoogle(),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Email
            _LinkButton(
              label: AppStrings.signInWithEmail,
              icon: Icons.email_outlined,
              isLoading: _isLoading,
              onPressed: () => setState(() => _showEmailForm = true),
            ),
          ] else ...[
            // Email form
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'E-posta',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Şifre',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _linkEmail(),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(AppStrings.signInWithEmail),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => setState(() => _showEmailForm = false),
              child: const Text('Geri'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _linkApple() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authServiceProvider).linkWithApple();
      ref.read(currentUserProvider.notifier).setUser(user);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authServiceProvider).linkWithGoogle();
      ref.read(currentUserProvider.notifier).setUser(user);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _linkEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = await ref
          .read(authServiceProvider)
          .linkWithEmail(email, password);
      ref.read(currentUserProvider.notifier).setUser(user);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showError();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.genericError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
    );
  }
}
