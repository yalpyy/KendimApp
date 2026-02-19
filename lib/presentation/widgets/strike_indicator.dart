import 'package:flutter/material.dart';

import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';

/// Subtle dot-based strike indicator showing weekly progress.
///
/// 6 dots, one for each writing day (Mon–Sat).
/// Filled = entry exists, empty = no entry yet.
class StrikeIndicator extends StatelessWidget {
  const StrikeIndicator({
    super.key,
    required this.completedDays,
    required this.daysWithEntries,
    this.totalDays = 6,
  });

  final int completedDays;
  final Set<int> daysWithEntries;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filledColor =
        isDark ? AppColors.darkStrikeFilled : AppColors.lightStrikeFilled;
    final emptyColor =
        isDark ? AppColors.darkStrikeEmpty : AppColors.lightStrikeEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalDays, (index) {
        final dayNumber = index + 1; // 1=Mon, 6=Sat
        final isFilled = daysWithEntries.contains(dayNumber);

        return Padding(
          padding: EdgeInsets.only(
            right: index < totalDays - 1 ? AppSpacing.strikeDotSpacing : 0,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: AppSpacing.strikeDotSize,
            height: AppSpacing.strikeDotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? filledColor : emptyColor,
            ),
          ),
        );
      }),
    );
  }
}
