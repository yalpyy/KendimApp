import 'package:flutter/material.dart';

import 'package:kendin/core/theme/app_colors.dart';
import 'package:kendin/core/theme/app_spacing.dart';

/// Six dots that fill sequentially in a calm, looping animation.
///
/// Cycle (4 seconds):
///   0.0–0.6   Dots fill one by one (subtle opacity)
///   0.6–0.75  Hold all filled
///   0.75–0.9  All fade out together
///   0.9–1.0   Pause (all empty)
class AnimatedDots extends StatefulWidget {
  const AnimatedDots({super.key});

  @override
  State<AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _dotCount = 6;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns 0.0–1.0 fill amount for a dot at [index] given overall [progress].
  double _dotFill(int index, double progress) {
    // Phase 1: sequential fill (0.0 → 0.6)
    final fillStart = index * 0.1; // 0.0, 0.1, 0.2, 0.3, 0.4, 0.5
    final fillEnd = fillStart + 0.08;

    // Phase 2: hold (0.6 → 0.75) — all stay filled
    // Phase 3: fade out (0.75 → 0.9)
    const fadeStart = 0.75;
    const fadeEnd = 0.9;

    if (progress < fillStart) return 0.0;
    if (progress < fillEnd) {
      return Curves.easeIn
          .transform((progress - fillStart) / (fillEnd - fillStart));
    }
    if (progress < fadeStart) return 1.0;
    if (progress < fadeEnd) {
      return 1.0 -
          Curves.easeOut
              .transform((progress - fadeStart) / (fadeEnd - fadeStart));
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filledColor =
        isDark ? AppColors.darkStrikeFilled : AppColors.lightStrikeFilled;
    final emptyColor =
        isDark ? AppColors.darkStrikeEmpty : AppColors.lightStrikeEmpty;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_dotCount, (index) {
            final fill = _dotFill(index, _controller.value);
            final color = Color.lerp(emptyColor, filledColor, fill)!;

            return Padding(
              padding: EdgeInsets.only(
                right: index < _dotCount - 1
                    ? AppSpacing.strikeDotSpacing
                    : 0,
              ),
              child: Container(
                width: AppSpacing.strikeDotSize,
                height: AppSpacing.strikeDotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
