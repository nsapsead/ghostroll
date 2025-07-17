import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mood-based color themes
enum GhostTheme {
  flow,      // Blue - calm, technical training
  hardRounds, // Red - intense, competitive
  recovery,   // Green - light, restorative
  ghost,      // Purple - mysterious, advanced
  sunrise,    // Orange - morning energy
  midnight    // Dark - late night sessions
}

class GhostThemeData {
  final String name;
  final String description;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final LinearGradient gradient;
  final String emoji;

  const GhostThemeData({
    required this.name,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.gradient,
    required this.emoji,
  });
}

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF0A0A0A);
  static const Color secondary = Color(0xFF1A1A1A);
  static const Color tertiary = Color(0xFF2A2A2A);
  static const Color surface = Color(0xFF1F1F1F);
  
  // Accent colors
  static const Color accent = Color(0xFF6366F1);
  static const Color accentLight = Color(0xFF818CF8);
  static const Color accentDark = Color(0xFF4F46E5);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Text colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFF4B5563);
  
  // Overlay colors
  static const Color overlayLight = Color(0x1AFFFFFF);
  static const Color overlayMedium = Color(0x33FFFFFF);
  static const Color overlayDark = Color(0x66FFFFFF);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF0A0A0A),
    Color(0xFF1A1A1A),
    Color(0xFF0F0F0F),
  ];
  
  static const List<Color> cardGradient = [
    Color(0x1AFFFFFF),
    Color(0x0DFFFFFF),
  ];
  
  static const List<Color> buttonGradient = [
    Colors.white,
    Color(0xFFF3F4F6),
  ];
}

class AppSpacing {
  const AppSpacing();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;
  static const double huge = 64.0;
}

class AppRadius {
  const AppRadius();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double round = 50.0;
}

class AppTextStyles {
  const AppTextStyles();
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}

class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x33FFFFFF),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];
}

class AppTheme {
  static const String _themeKey = 'ghost_theme';
  
  static final Map<GhostTheme, GhostThemeData> themes = {
    GhostTheme.flow: GhostThemeData(
      name: 'Flow',
      description: 'Smooth, technical training',
      primary: Color(0xFF1E3A8A),
      secondary: Color(0xFF3B82F6),
      accent: Color(0xFF60A5FA),
      background: Color(0xFF1F2937),
      surface: Color(0xFF374151),
      text: Color(0xFFF9FAFB),
      textSecondary: Color(0xFFD1D5DB),
      gradient: LinearGradient(
        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      emoji: '🌊',
    ),
    GhostTheme.hardRounds: GhostThemeData(
      name: 'Hard Rounds',
      description: 'Intense, competitive training',
      primary: Color(0xFF991B1B),
      secondary: Color(0xFFDC2626),
      accent: Color(0xFFEF4444),
      background: Color(0xFF171717),
      surface: Color(0xFF262626),
      text: Color(0xFFF9FAFB),
      textSecondary: Color(0xFF9CA3AF),
      gradient: LinearGradient(
        colors: [Color(0xFF991B1B), Color(0xFFDC2626), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      emoji: '🔥',
    ),
    GhostTheme.recovery: GhostThemeData(
      name: 'Recovery',
      description: 'Light, restorative training',
      primary: Color(0xFF166534),
      secondary: Color(0xFF16A34A),
      accent: Color(0xFF4ADE80),
      background: Color(0xFF1F2937),
      surface: Color(0xFF374151),
      text: Color(0xFFF9FAFB),
      textSecondary: Color(0xFFD1D5DB),
      gradient: LinearGradient(
        colors: [Color(0xFF166534), Color(0xFF16A34A), Color(0xFF4ADE80)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      emoji: '🌱',
    ),
    GhostTheme.ghost: GhostThemeData(
      name: 'Ghost',
      description: 'Mysterious, advanced training',
      primary: Color(0xFF581C87),
      secondary: Color(0xFF7C3ED),
      accent: Color(0xFFA78BFA),
      background: Color(0xFF232736),
      surface: Color(0xFF313847),
      text: Color(0xFFF9FAFB),
      textSecondary: Color(0xFFD1D5DB),
      gradient: LinearGradient(
        colors: [Color(0xFF581C87), Color(0xFF7C3ED), Color(0xFFA78BFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      emoji: '👻',
    ),
    GhostTheme.sunrise: GhostThemeData(
      name: 'Sunrise',
      description: 'Morning energy training',
      primary: Color(0xFFC2410C),
      secondary: Color(0xFFEA580C),
      accent: Color(0xFFFB923C),
      background: Color(0xFF171717),
      surface: Color(0xFF262626),
      text: Color(0xFFF9FAFB),
      textSecondary: Color(0xFFD1D5DB),
      gradient: LinearGradient(
        colors: [Color(0xFFC2410C), Color(0xFFEA580C), Color(0xFFFB923C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      emoji: '🌅',
    ),
    GhostTheme.midnight: GhostThemeData(
      name: 'Midnight',
      description: 'Late night sessions',
      primary: Color(0xFF1F2937),
      secondary: Color(0xFF374151),
      accent: Color(0xFF6B7280),
      background: Color(0xFF000000),
      surface: Color(0xFF111827),
      text: Color(0xFFF9FAFB),
      textSecondary: Color(0xFFD1D5DB),
      gradient: LinearGradient(
        colors: [Color(0xFF1F2937), Color(0xFF374151), Color(0xFF6B7280)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      emoji: '🌙',
    ),
  };

  static GhostTheme _currentTheme = GhostTheme.ghost;

  static GhostTheme get currentTheme => _currentTheme;
  static GhostThemeData get currentThemeData => themes[_currentTheme]!;

  // Initialize theme from preferences
  static Future<void> initializeTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? GhostTheme.ghost.index;
    _currentTheme = GhostTheme.values[themeIndex];
  }

  // Save theme to preferences
  static Future<void> setTheme(GhostTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
    _currentTheme = theme;
  }

  // Get theme data
  static GhostThemeData getThemeData(GhostTheme theme) => themes[theme]!;

  // Main app theme
  static ThemeData get darkTheme {
    final themeData = currentThemeData;
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: themeData.primary,
        secondary: themeData.secondary,
        surface: themeData.surface,
        background: themeData.background,
        onPrimary: themeData.text,
        onSecondary: themeData.text,
        onSurface: themeData.text,
        onBackground: themeData.text,
      ),
      scaffoldBackgroundColor: themeData.background,
      cardTheme: CardThemeData(
        color: themeData.surface,
        elevation: 8,
        shadowColor: themeData.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: themeData.text,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: themeData.text,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: themeData.text,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: themeData.text,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: themeData.text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: themeData.text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: themeData.text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: themeData.text,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: themeData.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: themeData.text,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: themeData.text,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: themeData.textSecondary,
          fontSize: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeData.primary,
          foregroundColor: themeData.text,
          elevation: 4,
          shadowColor: themeData.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: themeData.accent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: themeData.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: themeData.primary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: themeData.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: themeData.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: TextStyle(
          color: themeData.textSecondary.withOpacity(0.7),
          fontSize: 16,
        ),
        labelStyle: TextStyle(color: themeData.textSecondary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: themeData.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
} 