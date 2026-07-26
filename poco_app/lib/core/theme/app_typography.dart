import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 48, height: 56/48, fontWeight: FontWeight.w700,
      letterSpacing: -0.02,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 32, height: 40/32, fontWeight: FontWeight.w600,
      letterSpacing: -0.01,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 24, height: 32/24, fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 28, height: 36/28, fontWeight: FontWeight.w600,
      letterSpacing: -0.01,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 18, height: 28/18, fontWeight: FontWeight.w400,
      letterSpacing: 0.01,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 16, height: 24/16, fontWeight: FontWeight.w400,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14, height: 20/14, fontWeight: FontWeight.w600,
      letterSpacing: 0.05,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12, height: 16/12, fontWeight: FontWeight.w400,
    ),
  );
}
