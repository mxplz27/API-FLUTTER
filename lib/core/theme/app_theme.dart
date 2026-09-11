import 'package:flutter/material.dart';

/// Paleta corporativa: grafito casi negro (solidez / discrecion) con acento
/// cobre (valor, materialidad) sobre neutros claros. Estetica boutique premium.
class AppColors {
  const AppColors._();

  static const Color graphite = Color(0xFF1C1F26);
  static const Color graphiteDark = Color(0xFF0E1014);
  static const Color graphiteSoft = Color(0xFF343943);
  static const Color copper = Color(0xFFB87333);
  static const Color copperSoft = Color(0xFFD8A66B);

  static const Color background = Color(0xFFF5F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color field = Color(0xFFF7F7F9);

  static const Color textPrimary = Color(0xFF14171C);
  static const Color textSecondary = Color(0xFF6E7480);
  static const Color border = Color(0xFFE1E3E8);

  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF1E7A5A);
}

/// Radios y medidas reutilizadas por toda la app.
class AppSizes {
  const AppSizes._();

  static const double maxContentWidth = 460;
  static const double radiusField = 14;
  static const double radiusCard = 20;
  static const double radiusSheet = 32;
  static const double buttonHeight = 54;
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.graphite,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE7E8EC),
      onPrimaryContainer: AppColors.graphite,
      secondary: AppColors.copper,
      onSecondary: AppColors.graphiteDark,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      error: AppColors.error,
      onError: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
        border: _fieldBorder(AppColors.border),
        enabledBorder: _fieldBorder(AppColors.border),
        focusedBorder: _fieldBorder(AppColors.graphite, width: 1.6),
        errorBorder: _fieldBorder(AppColors.error),
        focusedErrorBorder: _fieldBorder(AppColors.error, width: 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.graphite,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusField),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.graphite,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusField),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.graphite,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.graphite,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusField),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: AppColors.border, width: 1.6),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1.2}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.radiusField),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
