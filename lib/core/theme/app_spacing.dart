/// 8pt grid spacing system.
///
/// All spacing values are multiples of 8.
/// This ensures visual rhythm and alignment throughout the UI.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Screen padding
  static const double screenHorizontal = 24;
  static const double screenVertical = 32;

  // Component-specific
  static const double cardPadding = 16;
  static const double cardRadius = 12;
  static const double buttonRadius = 10;
  static const double buttonHeight = 48;
  static const double inputRadius = 10;
  static const double strikeDotSize = 8;
  static const double strikeDotSpacing = 6;
}
