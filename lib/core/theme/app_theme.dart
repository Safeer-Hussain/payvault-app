import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.champagneGold,
      onPrimary: AppColors.obsidianBackground,
      primaryContainer: AppColors.champagneGoldDark,
      onPrimaryContainer: AppColors.champagneGoldLight,
      secondary: AppColors.champagneGoldLight,
      onSecondary: AppColors.obsidianBackground,
      secondaryContainer: AppColors.obsidianSurfaceContainerHighest,
      onSecondaryContainer: AppColors.champagneGoldLight,
      tertiary: AppColors.info,
      onTertiary: AppColors.obsidianBackground,
      error: AppColors.error,
      onError: AppColors.obsidianBackground,
      surface: AppColors.obsidianSurface,
      onSurface: AppColors.obsidianOnSurface,
      surfaceContainer: AppColors.obsidianSurfaceContainer,
      surfaceContainerHighest: AppColors.obsidianSurfaceContainerHighest,
      onSurfaceVariant: AppColors.obsidianOnSurfaceVariant,
      outline: AppColors.obsidianOutline,
      outlineVariant: AppColors.obsidianSurfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.obsidianBackground,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.obsidianSurface,
        foregroundColor: AppColors.obsidianOnSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.obsidianSurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.obsidianSurfaceContainerHighest,
            width: 1,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.obsidianSurface,
        modalBackgroundColor: AppColors.obsidianSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.obsidianSurfaceContainerHighest,
        thickness: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.champagneGoldDark,
      onPrimary: AppColors.ivorySurface,
      primaryContainer: AppColors.champagneGoldLight,
      onPrimaryContainer: AppColors.champagneGoldDark,
      secondary: AppColors.champagneGold,
      onSecondary: AppColors.ivoryOnSurface,
      secondaryContainer: AppColors.ivorySurfaceContainerHighest,
      onSecondaryContainer: AppColors.ivoryOnSurface,
      tertiary: AppColors.info,
      onTertiary: AppColors.ivorySurface,
      error: AppColors.error,
      onError: AppColors.ivorySurface,
      surface: AppColors.ivorySurface,
      onSurface: AppColors.ivoryOnSurface,
      surfaceContainer: AppColors.ivorySurfaceContainer,
      surfaceContainerHighest: AppColors.ivorySurfaceContainerHighest,
      onSurfaceVariant: AppColors.ivoryOnSurfaceVariant,
      outline: AppColors.ivoryOutline,
      outlineVariant: AppColors.ivorySurfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ivoryBackground,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ivorySurface,
        foregroundColor: AppColors.ivoryOnSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.ivorySurfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.ivorySurfaceContainerHighest,
            width: 1,
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.ivorySurface,
        modalBackgroundColor: AppColors.ivorySurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.ivorySurfaceContainerHighest,
        thickness: 1,
      ),
    );
  }
}
