import 'package:flutter/material.dart';

// Single place for colors and ThemeData so the whole app stays consistent (Material Design)
class AppTheme {
  AppTheme._();

  static const Color primaryBackground = Color(0xFF0D1B2A);
  static const Color primaryAccent = Color(0xFFF2C94C);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color warning = Color(0xFFDC3545);
  static const Color secondaryDark = Color(0xFF424242);
  static const Color secondaryLight = Color(0xFF9E9E9E);

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryAccent,
        onPrimary: primaryBackground,
        secondary: primaryAccent,
        onSecondary: primaryBackground,
        surface: surface,
        onSurface: primaryBackground,
        error: warning,
        onError: surface,
        surfaceContainerHighest: surfaceVariant,
        outline: secondaryDark,
        onSurfaceVariant: secondaryDark,
      ),
      scaffoldBackgroundColor: primaryBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBackground,
        foregroundColor: primaryAccent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryAccent,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryBackground,
        selectedItemColor: primaryAccent,
        unselectedItemColor: surface,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryAccent,
        foregroundColor: primaryBackground,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 10,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: primaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: primaryBackground,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: primaryBackground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: warning,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: secondaryDark,
          letterSpacing: -0.3,
        ),
        contentTextStyle: const TextStyle(fontSize: 16, color: secondaryDark),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return warning;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(surface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: warning,
        labelStyle: const TextStyle(fontSize: 14, color: secondaryDark),
        secondaryLabelStyle: const TextStyle(fontSize: 14, color: surface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: primaryBackground,
        indicatorColor: primaryAccent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryBackground);
          }
          return const IconThemeData(color: surface);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryBackground,
            );
          }
          return const TextStyle(fontSize: 12, color: surface);
        }),
        height: 80,
        elevation: 12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(color: secondaryDark),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: secondaryDark,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: secondaryDark,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: secondaryDark),
        bodyMedium: TextStyle(fontSize: 14, color: secondaryLight),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
