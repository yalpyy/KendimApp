import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';
import 'package:kendin/presentation/providers/providers.dart';

/// Displays the weekly reflection.
///
/// Shows a loading state initially ("Haftanı bir araya getiriyorum.
/// Hemen değil."), then polls until the reflection is ready.
///
/// The reflection reads like a calm, observational letter — no
/// advice, no motivation, no emojis.
class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  bool _isPolling = true;
  String? _reflectionContent;
  String? _reflectionId;

  @override
  void initState() {
    super.initState();
    _pollForReflection();
  }

  Future<void> _pollForReflection() async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    // Poll every 30 seconds for up to 15 minutes.
    for (var i = 0; i < 30; i++) {
      if (!mounted) return;

      final reflection =
          await ref.read(reflectionServiceProvider).getCurrentReflection(
                user.id,
              );

      if (reflection != null) {
        setState(() {
          _reflectionContent = reflection.content;
          _reflectionId = reflection.id;
          _isPolling = false;
        });
        return;
      }

      await Future.delayed(const Duration(seconds: 30));
    }

    // Timeout — still show waiting message.
    if (mounted) {
      setState(() => _isPolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final canArchive = user?.isPremium ?? false;

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
              // Back
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),

              const Spacer(flex: 2),

              if (_isPolling)
                // Loading state
                Center(
                  child: Text(
                    AppStrings.reflectionLoading,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                )
              else if (_reflectionContent != null)
                // Reflection content
                Center(
                  child: Text(
                    _reflectionContent!,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          height: 1.8,
                        ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                // Not ready yet
                Center(
                  child: Text(
                    AppStrings.reflectionNotReady,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(flex: 2),

              // Archive button (premium only, visible on Sunday)
              if (_reflectionContent != null && canArchive)
                Center(
                  child: TextButton(
                    onPressed: () => _archive(),
                    child: const Text(AppStrings.archive),
                  ),
                ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _archive() async {
    if (_reflectionId == null) return;

    try {
      await ref
          .read(reflectionServiceProvider)
          .archiveReflection(_reflectionId!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.archived),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
    }
  }
}
