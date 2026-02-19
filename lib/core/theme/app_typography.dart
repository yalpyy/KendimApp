import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography scale (8pt grid aligned).
///
/// Hierarchy:
///   displayLarge  — main question (24sp, serif, medium)
///   titleMedium   — date header (16sp, sans, medium)
///   bodyLarge     — entry text (16sp, sans, regular)
///   bodyMedium    — secondary content (14sp, sans, regular)
///   bodySmall     — captions, hints (12sp, sans, regular)
///   labelMedium   — buttons (14sp, sans, medium)
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color primary, Color secondary) {
    final serif = GoogleFonts.notoSerif;
    final sans = GoogleFonts.inter;

    return TextTheme(
      displayLarge: serif(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: primary,
        letterSpacing: -0.2,
      ),
      titleMedium: sans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: secondary,
      ),
      bodyLarge: sans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: primary,
      ),
      bodyMedium: sans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: secondary,
      ),
      bodySmall: sans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondary,
      ),
      labelMedium: sans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: primary,
      ),
    );
  }
}
