import 'package:flutter/material.dart';

/// Kendin color palette.
///
/// Light theme: warm paper tones, muted earth.
/// Dark theme: deep charcoal, soft amber accents.
///
/// Design rationale:
/// - No saturated or neon colors
/// - Backgrounds are slightly warm, never pure white/black
/// - Accent is understated — guides the eye, never shouts
/// - Text is high-contrast but not harsh
class AppColors {
  AppColors._();

  // ─── Light Theme ───────────────────────────────────

  static const Color lightBackground = Color(0xFFF7F5F0); // warm paper
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0EDE6);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6560);
  static const Color lightTextTertiary = Color(0xFFA39E96);
  static const Color lightAccent = Color(0xFF8B7355); // muted bronze
  static const Color lightDivider = Color(0xFFE5E0D8);
  static const Color lightStrikeFilled = Color(0xFF8B7355);
  static const Color lightStrikeEmpty = Color(0xFFDDD8CF);
  static const Color lightError = Color(0xFFB05050);

  // ─── Dark Theme ────────────────────────────────────

  static const Color darkBackground = Color(0xFF141210); // deep warm black
  static const Color darkSurface = Color(0xFF1E1C19);
  static const Color darkSurfaceVariant = Color(0xFF272420);
  static const Color darkTextPrimary = Color(0xFFE8E4DC);
  static const Color darkTextSecondary = Color(0xFF9A948B);
  static const Color darkTextTertiary = Color(0xFF5C5750);
  static const Color darkAccent = Color(0xFFCBB48C); // soft amber
  static const Color darkDivider = Color(0xFF2E2B26);
  static const Color darkStrikeFilled = Color(0xFFCBB48C);
  static const Color darkStrikeEmpty = Color(0xFF3A362F);
  static const Color darkError = Color(0xFFCF6B6B);
}
