import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for Vekariya Brothers - Premium Karigar & Finance Manager
class AppTheme {
  AppTheme._();

  // 🎨 PREMIUM COLOR PALETTE - Vekariya Brothers Brand
  static const Color primaryLight =
      Color(0xFF1E88E5); // Royal Blue – trust + clarity
  static const Color primaryVariantLight = Color(0xFF1565C0); // Deep Royal Blue
  static const Color secondaryLight =
      Color(0xFFFFC107); // Warm Yellow – stitching/karigar theme
  static const Color secondaryVariantLight = Color(0xFFF57F17); // Deep Yellow
  static const Color accentGreenLight =
      Color(0xFF43A047); // Green – success, paid, growth
  static const Color accentRedLight =
      Color(0xFFE53935); // Red – alerts, pending
  static const Color backgroundLight =
      Color(0xFFF7F9FC); // Ultra light ice grey
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white cards
  static const Color errorLight = Color(0xFFE53935); // Red alerts
  static const Color warningLight = Color(0xFFFFC107); // Yellow warnings
  static const Color successLight = Color(0xFF43A047); // Success green
  static const Color infoLight = Color(0xFF1E88E5); // Info blue

  // 🌈 Premium gradient colors for modern fintech feel
  static const List<Color> primaryGradient = [
    Color(0xFF1E88E5), // Royal Blue
    Color(0xFF1565C0), // Deep Blue
    Color(0xFF0D47A1), // Navy Blue
  ];

  static const List<Color> successGradient = [
    Color(0xFF43A047), // Success Green
    Color(0xFF388E3C), // Deep Green
    Color(0xFF2E7D32), // Forest Green
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFFC107), // Warm Yellow
    Color(0xFFF57C00), // Orange Yellow
    Color(0xFFE65100), // Deep Orange
  ];

  static const List<Color> accentGradient = [
    Color(0xFF1E88E5), // Royal Blue
    Color(0xFF43A047), // Success Green
  ];

  // 📝 Premium Text Colors - Crystal Clear Typography
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFF1A1A1A);
  static const Color onBackgroundLight = Color(0xFF1A1A1A);
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  static const Color textPrimaryLight = Color(0xFF1A1A1A); // Primary text
  static const Color textSecondaryLight = Color(0xFF505050); // Secondary text
  static const Color textLabelLight = Color(0xFF8A8A8A); // Labels
  static const Color textDisabledLight = Color(0xFFBDBDBD);

  // Dark theme colors (keeping existing structure for consistency)
  static const Color primaryDark = Color(0xFF42A5F5);
  static const Color primaryVariantDark = Color(0xFF1976D2);
  static const Color secondaryDark = Color(0xFFFFD54F);
  static const Color secondaryVariantDark = Color(0xFFF57F17);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color successDark = Color(0xFF66BB6A);

  // 🎯 Enhanced UI element colors for premium feel
  static const Color cardLight = Color(0xFFFFFFFF); // Pure white cards
  static const Color cardDark = Color(0xFF2D2D2D);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF2D2D2D);

  // 💎 Soft shadows for premium look (5% opacity)
  static const Color shadowLight = Color(0x0D000000); // 5% black shadow
  static const Color shadowDark = Color(0x0DFFFFFF);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFF000000);

  /// 🚀 Premium Light Theme - Modern Fintech + Admin App Feel
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryLight,
      onPrimary: onPrimaryLight,
      primaryContainer: Color(0xFFE3F2FD), // Light blue container
      onPrimaryContainer: Color(0xFF0D47A1),
      secondary: secondaryLight,
      onSecondary: onSecondaryLight,
      secondaryContainer: Color(0xFFFFF8E1), // Light yellow container
      onSecondaryContainer: Color(0xFFE65100),
      tertiary: accentGreenLight,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFE8F5E8), // Light green container
      onTertiaryContainer: Color(0xFF1B5E20),
      error: errorLight,
      onError: onErrorLight,
      surface: surfaceLight,
      onSurface: onSurfaceLight,
      onSurfaceVariant: textSecondaryLight,
      outline: dividerLight,
      outlineVariant: Color(0xFFE0E0E0),
      shadow: shadowLight,
      scrim: Color(0x0D000000),
      inverseSurface: surfaceDark,
      onInverseSurface: onSurfaceDark,
      inversePrimary: primaryDark,
      surfaceTint: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundLight, // Ultra light ice grey
    cardColor: cardLight,
    dividerColor: dividerLight,

    // 📱 Premium AppBar - Transparent with clean typography
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: textPrimaryLight, size: 24),
    ),

    // 🎴 Premium Card Theme - Rounded (20px) + Soft Shadow
    cardTheme: CardTheme(
      color: cardLight,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Premium rounded cards
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // 🎯 Premium FAB Theme with Better Size
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentGreenLight,
      foregroundColor: onPrimaryLight,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      iconSize: 28, // Larger icon for better visibility
      sizeConstraints: BoxConstraints.tightFor(
        width: 64.0, // Larger FAB for easier tapping
        height: 64.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),

    // 🔘 Premium Button Themes - Modern Interactions with Better Touch Targets
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryLight,
        backgroundColor: primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18), // Increased for better touch
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: Size(120, 54), // Minimum size for accessibility
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700, // Bolder for better readability
          letterSpacing: -0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        minimumSize: Size(120, 54), // Better touch target
        side: BorderSide(color: primaryLight, width: 2), // Thicker border for visibility
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: Size(80, 48), // Better touch target
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // 📝 Premium Typography - Inter Font for Modern Feel
    textTheme: _buildPremiumTextTheme(isLight: true),

    // 📝 Premium Input Decoration - Clean + Focused
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceLight,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: dividerLight, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: dividerLight, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: primaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: errorLight, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: errorLight, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textLabelLight,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
      hintStyle: GoogleFonts.inter(
        color: textLabelLight,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
      ),
    ),

    // 📑 Premium Tab Bar Theme
    tabBarTheme: TabBarTheme(
      labelColor: primaryLight,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: primaryLight,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
    ),

    // 🧭 Bottom Navigation - Quick Access Design
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
    ),

    // Toggle switches with brand colors
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Color(0xFFBDBDBD);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.3);
        }
        return Color(0xFFE0E0E0);
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
      side: BorderSide(color: dividerLight, width: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
    ),

    // Radio with brand colors
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textSecondaryLight;
      }),
    ),

    // Progress indicators
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryLight,
      linearTrackColor: dividerLight,
      circularTrackColor: dividerLight,
    ),

    // Sliders
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      thumbColor: primaryLight,
      overlayColor: primaryLight.withValues(alpha: 0.2),
      inactiveTrackColor: dividerLight,
      valueIndicatorColor: primaryLight,
    ),

    // Tooltips
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimaryLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        color: surfaceLight,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
    ),

    // 🔔 Premium SnackBar - Modern Feedback
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryLight,
      contentTextStyle: GoogleFonts.inter(
        color: surfaceLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
      actionTextColor: secondaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
    ),

    // 📝 List Tiles
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      titleTextStyle: GoogleFonts.inter(
        color: textPrimaryLight,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        color: textSecondaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
    ),

    // 🏷️ Premium Chip Theme - Rounded Tags
    chipTheme: ChipThemeData(
      backgroundColor: dividerLight.withValues(alpha: 0.3),
      selectedColor: primaryLight.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.inter(
        color: textPrimaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: dialogLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
  );

  /// Dark theme maintaining brand consistency
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: onPrimaryDark,
      primaryContainer: primaryVariantDark,
      onPrimaryContainer: onPrimaryDark,
      secondary: secondaryDark,
      onSecondary: onSecondaryDark,
      secondaryContainer: secondaryVariantDark,
      onSecondaryContainer: onSecondaryDark,
      tertiary: warningDark,
      onTertiary: Color(0xFF000000),
      tertiaryContainer: warningDark.withValues(alpha: 0.2),
      onTertiaryContainer: warningDark,
      error: errorDark,
      onError: onErrorDark,
      surface: surfaceDark,
      onSurface: onSurfaceDark,
      onSurfaceVariant: textSecondaryDark,
      outline: dividerDark,
      outlineVariant: dividerDark.withValues(alpha: 0.5),
      shadow: shadowDark,
      scrim: shadowDark,
      inverseSurface: surfaceLight,
      onInverseSurface: onSurfaceLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: cardDark,
    dividerColor: dividerDark,

    // AppBar theme for dark mode
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: onSurfaceDark,
      elevation: 1.0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurfaceDark,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: onSurfaceDark, size: 24),
    ),

    // Card theme for dark mode
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 1.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // FAB theme for dark mode
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: secondaryDark,
      foregroundColor: onSecondaryDark,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),

    // Button themes for dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: onPrimaryDark,
        backgroundColor: primaryDark,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Typography for dark mode
    textTheme: _buildPremiumTextTheme(isLight: false),

    // Input decoration for dark mode
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceDark,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: dividerDark, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: dividerDark, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: primaryDark, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: errorDark, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: errorDark, width: 2.0),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabledDark,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.2,
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: dialogDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
  );

  /// 🎨 Premium Text Theme - Inter Font for Crystal Clear Readability
  static TextTheme _buildPremiumTextTheme({required bool isLight}) {
    final Color textPrimary = isLight ? textPrimaryLight : textPrimaryDark;
    final Color textSecondary =
        isLight ? textSecondaryLight : textSecondaryDark;
    final Color textLabel = isLight ? textLabelLight : textSecondaryDark;

    return TextTheme(
      // Display styles - Large headings
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -1.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -1.0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.75,
        height: 1.22,
      ),

      // Headlines - Section headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.33,
      ),

      // Titles - Card headers, screen titles
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
        height: 1.43,
      ),

      // Body text - Main content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: -0.2,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: -0.1,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: -0.1,
        height: 1.33,
      ),

      // Labels - Form labels, small text
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textLabel,
        letterSpacing: -0.1,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textLabel,
        letterSpacing: 0,
        height: 1.45,
      ),
    );
  }

  /// 💰 Financial Data Text Style - Monospace for Numbers
  static TextStyle financialTextStyle({
    required bool isLight,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isLight ? textPrimaryLight : textPrimaryDark,
      letterSpacing: 0.5,
    );
  }

  /// 🎯 Status Color Helper - Karigar Workflow States
  static Color getStatusColor(String status, {bool isLight = true}) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'success':
      case 'active':
        return isLight ? successLight : successDark;
      case 'pending':
      case 'in_progress':
      case 'warning':
      case 'partial':
        return isLight ? warningLight : warningDark;
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

  /// 🌈 Premium Gradient Utilities
  static LinearGradient getPrimaryGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: primaryGradient,
      stops: [0.0, 0.5, 1.0],
    );
  }

  static LinearGradient getSuccessGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: successGradient,
      stops: [0.0, 0.5, 1.0],
    );
  }

  static LinearGradient getWarningGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: warningGradient,
      stops: [0.0, 0.5, 1.0],
    );
  }

  static LinearGradient getAccentGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: accentGradient,
      stops: [0.0, 1.0],
    );
  }

  /// 💎 Premium Shadow Utilities - Soft 5% Opacity
  static List<BoxShadow> getSoftShadow({Color? color, double opacity = 0.05}) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withValues(alpha: opacity),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        offset: Offset(0, 2),
        blurRadius: 6,
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> getElevatedShadow(
      {Color? color, double opacity = 0.08}) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withValues(alpha: opacity),
        offset: Offset(0, 8),
        blurRadius: 24,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        offset: Offset(0, 4),
        blurRadius: 12,
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