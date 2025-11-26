import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for Vekariya Brothers - Premium Karigar & Finance Manager
/// Designed for non-tech users with clear visual hierarchy and easy-to-read typography
class AppTheme {
  AppTheme._();

  // 🎨 USER-FRIENDLY COLOR PALETTE - Warm & Professional
  static const Color primaryLight = Color(0xFF2563EB); // Vivid Blue - trust
  static const Color primaryVariantLight = Color(0xFF1D4ED8); // Deep Blue
  static const Color secondaryLight = Color(0xFF10B981); // Emerald Green - success/money
  static const Color secondaryVariantLight = Color(0xFF059669); // Deep Emerald
  static const Color accentOrange = Color(0xFFEA580C); // Warm Orange - action
  static const Color accentGreenLight = Color(0xFF22C55E); // Success Green
  static const Color accentRedLight = Color(0xFFDC2626); // Clear Red - alerts
  static const Color backgroundLight = Color(0xFFF8FAFC); // Soft grey-blue
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white cards
  static const Color errorLight = Color(0xFFDC2626); // Red alerts
  static const Color warningLight = Color(0xFFF59E0B); // Amber warnings
  static const Color successLight = Color(0xFF22C55E); // Success green
  static const Color infoLight = Color(0xFF3B82F6); // Info blue

  // Premium gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF2563EB), // Deep Blue
  ];

  static const List<Color> successGradient = [
    Color(0xFF22C55E),
    Color(0xFF16A34A),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];

  // 📝 Text Colors - High Contrast for Readability
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight = Color(0xFF0F172A); // Slate 900
  static const Color onSurfaceLight = Color(0xFF1E293B); // Slate 800

  static const Color textPrimaryLight = Color(0xFF0F172A); // Very dark - easy to read
  static const Color textSecondaryLight = Color(0xFF475569); // Medium grey
  static const Color textLabelLight = Color(0xFF64748B); // Label grey
  static const Color textDisabledLight = Color(0xFF94A3B8);

  // Dark theme colors
  static const Color primaryDark = Color(0xFF60A5FA);
  static const Color primaryVariantDark = Color(0xFF3B82F6);
  static const Color secondaryDark = Color(0xFF34D399);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color errorDark = Color(0xFFF87171);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);

  // UI element colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color shadowLight = Color(0x1A000000); // 10% black shadow
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);

  /// 🚀 Premium Light Theme - User-Friendly Design
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: Color(0xFFDBEAFE),
      onPrimaryContainer: Color(0xFF1E3A8A),
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: Color(0xFFD1FAE5),
      onSecondaryContainer: Color(0xFF065F46),
      tertiary: warningLight,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFEF3C7),
      onTertiaryContainer: Color(0xFF92400E),
      error: errorLight,
      onError: onPrimaryLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textSecondaryLight,
      outline: dividerLight,
      outlineVariant: Color(0xFFE2E8F0),
      shadow: shadowLight,
      scrim: Color(0x1A000000),
      inverseSurface: surfaceDark,
      onInverseSurface: textPrimaryDark,
      inversePrimary: primaryDark,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: cardLight,
    dividerColor: dividerLight,

    // 📱 Clean AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: textPrimaryLight, size: 24),
    ),

    // 🎴 Clean Card Theme - Larger radius for friendly look
    cardTheme: CardTheme(
      color: cardLight,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: dividerLight, width: 1),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 🎯 Prominent FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: onPrimaryLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),

    // 🔘 Large, Easy-to-Tap Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryLight,
        backgroundColor: primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        elevation: 2,
        shadowColor: primaryLight.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        minimumSize: Size(double.infinity, 54), // Large touch target
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        side: BorderSide(color: primaryLight, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        minimumSize: Size(double.infinity, 54),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // 📝 Clean, Readable Typography
    textTheme: _buildCleanTextTheme(isLight: true),

    // 📝 User-Friendly Input Fields
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceLight,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: dividerLight, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: dividerLight, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: primaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: errorLight, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.0),
        borderSide: BorderSide(color: errorLight, width: 2.0),
      ),
      labelStyle: GoogleFonts.poppins(
        color: textSecondaryLight,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.poppins(
        color: textLabelLight,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      errorStyle: GoogleFonts.poppins(
        color: errorLight,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: textSecondaryLight,
      suffixIconColor: textSecondaryLight,
    ),

    // Tab bar
    tabBarTheme: TabBarTheme(
      labelColor: primaryLight,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: primaryLight,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 🧭 Bottom Navigation - Easy Access Design
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Switch theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Color(0xFFCBD5E1);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.4);
        }
        return Color(0xFFE2E8F0);
      }),
    ),

    // Checkbox with brand colors
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(onPrimaryLight),
      side: BorderSide(color: textSecondaryLight, width: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),

    // Progress indicators
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: dividerLight,
      circularTrackColor: dividerLight,
    ),

    // SnackBar - Clear feedback
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryLight,
      contentTextStyle: GoogleFonts.poppins(
        color: surfaceLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor: secondaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
    ),

    // List Tiles - Larger touch targets
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      minVerticalPadding: 12,
      titleTextStyle: GoogleFonts.poppins(
        color: textPrimaryLight,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      subtitleTextStyle: GoogleFonts.poppins(
        color: textSecondaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: backgroundLight,
      selectedColor: primaryLight.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.poppins(
        color: textPrimaryLight,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: dividerLight),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      titleTextStyle: GoogleFonts.poppins(
        color: textPrimaryLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: GoogleFonts.poppins(
        color: textSecondaryLight,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Bottom sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );

  /// Dark theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: Color(0xFF0F172A),
      primaryContainer: primaryVariantDark,
      onPrimaryContainer: Color(0xFFDBEAFE),
      secondary: secondaryDark,
      onSecondary: Color(0xFF0F172A),
      secondaryContainer: Color(0xFF065F46),
      onSecondaryContainer: Color(0xFFD1FAE5),
      tertiary: Color(0xFFFBBF24),
      onTertiary: Color(0xFF0F172A),
      tertiaryContainer: Color(0xFF92400E),
      onTertiaryContainer: Color(0xFFFEF3C7),
      error: errorDark,
      onError: Color(0xFF0F172A),
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      onSurfaceVariant: textSecondaryDark,
      outline: dividerDark,
      outlineVariant: dividerDark.withValues(alpha: 0.5),
      shadow: Color(0x40000000),
      scrim: Color(0x40000000),
      inverseSurface: surfaceLight,
      onInverseSurface: textPrimaryLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    dividerColor: dividerDark,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
      ),
      iconTheme: IconThemeData(color: textPrimaryDark, size: 24),
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: dividerDark, width: 1),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    textTheme: _buildCleanTextTheme(isLight: false),
    dialogTheme: DialogThemeData(
      backgroundColor: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
  );

  /// 🎨 Clean, Readable Text Theme using Poppins for friendly feel
  static TextTheme _buildCleanTextTheme({required bool isLight}) {
    final Color textPrimary = isLight ? textPrimaryLight : textPrimaryDark;
    final Color textSecondary = isLight ? textSecondaryLight : textSecondaryDark;
    final Color textLabel = isLight ? textLabelLight : textSecondaryDark;

    return TextTheme(
      // Display styles - Big headings
      displayLarge: GoogleFonts.poppins(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -1.5,
        height: 1.15,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.25,
      ),

      // Headlines - Section headers
      headlineLarge: GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.4,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.3,
        height: 1.35,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.4,
      ),

      // Titles
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
        height: 1.45,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.5,
      ),

      // Body text - Main content
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0,
        height: 1.5,
      ),

      // Labels
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textLabel,
        letterSpacing: 0,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textLabel,
        letterSpacing: 0,
        height: 1.4,
      ),
    );
  }

  /// 💰 Financial Data Text Style - Monospace for Numbers
  static TextStyle financialTextStyle({
    required bool isLight,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isLight ? textPrimaryLight : textPrimaryDark,
      letterSpacing: 0.5,
    );
  }

  /// 🎯 Status Color Helper
  static Color getStatusColor(String status, {bool isLight = true}) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'success':
      case 'active':
        return isLight ? successLight : secondaryDark;
      case 'pending':
      case 'in_progress':
      case 'warning':
      case 'partial':
        return isLight ? warningLight : Color(0xFFFBBF24);
      case 'failed':
      case 'unpaid':
      case 'error':
      case 'inactive':
        return isLight ? errorLight : errorDark;
      case 'info':
      case 'default':
        return isLight ? infoLight : primaryDark;
      default:
        return isLight ? textSecondaryLight : textSecondaryDark;
    }
  }

  /// 🌈 Gradient Utilities
  static LinearGradient getPrimaryGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: primaryGradient,
    );
  }

  static LinearGradient getSuccessGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: successGradient,
    );
  }

  static LinearGradient getWarningGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: warningGradient,
    );
  }

  /// 💎 Clean Shadow Utilities
  static List<BoxShadow> getSoftShadow({Color? color, double opacity = 0.08}) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withValues(alpha: opacity),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> getElevatedShadow({Color? color, double opacity = 0.12}) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withValues(alpha: opacity),
        offset: Offset(0, 8),
        blurRadius: 24,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: (color ?? Colors.black).withValues(alpha: 0.04),
        offset: Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];
  }

  /// 🎨 Brand Color Getters
  static Color get primaryColor => primaryLight;
  static Color get secondaryColor => secondaryLight;
  static Color get successColor => accentGreenLight;
  static Color get errorColor => accentRedLight;
  static Color get warningColor => warningLight;
  static Color get backgroundColor => backgroundLight;
  static Color get surfaceColor => surfaceLight;
}
