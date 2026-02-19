import 'package:flutter/material.dart';

import 'package:kendin/core/constants/app_strings.dart';
import 'package:kendin/core/theme/app_spacing.dart';

/// Multi-line text field for daily entries.
///
/// Designed to feel spacious and unhurried.
/// No character counter, no validation indicators.
class KendinTextField extends StatelessWidget {
  const KendinTextField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: 8,
      minLines: 4,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: AppStrings.entryPlaceholder,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
      ),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
