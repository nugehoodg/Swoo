import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Feminine color palette
  static const Color primaryPink = Color(0xFFF06292); // Pink 300
  static const Color secondaryLavender = Color(0xFFBA68C8); // Purple 300
  static const Color follicularBlue = Color(0xFFB3E5FC);
  static const Color ovulationGold = Color(0xFFFFB74D);
  static const Color lutealYellow = Color(0xFFFFF59D);
  static const Color backgroundPeach = Color(0xFFFCE4EC); // Pink 50 (warm background)
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF424242); // Grey 800

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundPeach,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        primary: primaryPink,
        secondary: secondaryLavender,
        surface: surfaceWhite,
        background: backgroundPeach,
      ),
      textTheme: GoogleFonts.nunitoTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceWhite,
        indicatorColor: primaryPink.withOpacity(0.2),
        labelTextStyle: MaterialStateProperty.all(
          GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.bold, color: textDark),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: primaryPink);
          }
          return IconThemeData(color: Colors.grey);
        }),
      ),
    );
  }
}
