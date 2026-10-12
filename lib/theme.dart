import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'widgets/glass.dart' show GlassScope;

/// FindFood design system: Plus Jakarta Sans, warm gold brand colour and
/// soft "glass" surfaces on calm light and dark backgrounds.
class AppTheme {
  static const String fontFamily = 'PlusJakartaSans';

  // --- BRAND ---
  static const Color accent     = Color(0xFFFFC21A); // warm gold
  static const Color accentDeep = Color(0xFFFF9F0A); // gradient partner
  static const Color accentDim  = Color(0x2EFFC21A);
  static const Color success    = Color(0xFF22C55E);
  static const Color warning    = Color(0xFFF59E0B);
  static const Color danger     = Color(0xFFEF4444);
  static const Color info       = Color(0xFF3B82F6);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentDeep],
  );

  // --- DARK PALETTE ---
  static const Color darkBg        = Color(0xFF0B0C10);
  static const Color darkSurface   = Color(0xFF14161C);
  static const Color darkCard      = Color(0xFF181A21);
  static const Color darkBorder    = Color(0xFF262A33);
  static const Color darkTextPri   = Color(0xFFF4F5F7);
  static const Color darkTextSec   = Color(0xFFA3A9B6);
  static const Color darkTextHint  = Color(0xFF666C79);

  // --- LIGHT PALETTE ---
  static const Color lightBg       = Color(0xFFF2F4F8);
  static const Color lightSurface  = Color(0xFFFFFFFF);
  static const Color lightCard     = Color(0xFFFFFFFF);
  static const Color lightBorder   = Color(0xFFE4E7EE);
  static const Color lightTextPri  = Color(0xFF0F172A);
  static const Color lightTextSec  = Color(0xFF526075);
  static const Color lightTextHint = Color(0xFF97A3B6);

  static ThemeData dark = _build(Brightness.dark);
  static ThemeData light = _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? darkBg : lightBg;
    final surface = isDark ? darkSurface : lightSurface;
    final card = isDark ? darkCard : lightCard;
    final border = isDark ? darkBorder : lightBorder;
    final textPri = isDark ? darkTextPri : lightTextPri;
    final textSec = isDark ? darkTextSec : lightTextSec;
    final textHint = isDark ? darkTextHint : lightTextHint;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
    );
    final textTheme = base.textTheme
        .copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1.2),
          displayMedium: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1.0),
          displaySmall: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.8),
          headlineLarge: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.8),
          headlineMedium: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.6),
          headlineSmall: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.4),
          titleLarge: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
          titleMedium: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.1),
          titleSmall: const TextStyle(fontWeight: FontWeight.w600),
          bodyLarge: const TextStyle(height: 1.45),
          bodyMedium: const TextStyle(height: 1.45),
          labelLarge: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.1),
        )
        .apply(
          fontFamily: fontFamily,
          bodyColor: textPri,
          displayColor: textPri,
        );

    final radius12 = BorderRadius.circular(12);
    final radius16 = BorderRadius.circular(16);

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      primaryColor: accent,
      canvasColor: bg,
      cardColor: card,
      dividerColor: border,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
        primary: accent,
        onPrimary: Colors.black,
        secondary: accentDeep,
        onSecondary: Colors.black,
        surface: surface,
        onSurface: textPri,
        onSurfaceVariant: textSec,
        surfaceContainerHighest: isDark ? const Color(0xFF1E2129) : const Color(0xFFF4F6FA),
        outline: border,
        outlineVariant: border,
        error: danger,
        surfaceTint: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: textPri,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPri),
      ),
      iconTheme: IconThemeData(color: textPri),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          disabledBackgroundColor: accent.withValues(alpha: 0.35),
          elevation: 0,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: const TextStyle(
              fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: const TextStyle(
              fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPri,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: const TextStyle(
              fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? accent : const Color(0xFFB7791F),
          textStyle: const TextStyle(
              fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A1D24) : const Color(0xFFF6F7FA),
        hintStyle: TextStyle(color: textHint, fontSize: 15, fontWeight: FontWeight.w500),
        labelStyle: TextStyle(color: textSec, fontWeight: FontWeight.w500),
        prefixIconColor: textHint,
        suffixIconColor: textHint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: radius16, borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: radius16, borderSide: const BorderSide(color: accent, width: 1.6)),
        errorBorder: OutlineInputBorder(
            borderRadius: radius16, borderSide: const BorderSide(color: danger)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: radius16, borderSide: const BorderSide(color: danger, width: 1.6)),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSec,
        titleTextStyle: TextStyle(
            fontFamily: fontFamily, color: textPri, fontSize: 15, fontWeight: FontWeight.w600),
        subtitleTextStyle: TextStyle(fontFamily: fontFamily, color: textSec, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: radius12),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(
            fontFamily: fontFamily, color: textPri, fontSize: 19, fontWeight: FontWeight.w800),
        contentTextStyle: TextStyle(
            fontFamily: fontFamily, color: textSec, fontSize: 14, height: 1.45),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF262A33) : const Color(0xFF111827),
        contentTextStyle: const TextStyle(
            fontFamily: fontFamily, color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: radius16),
        elevation: 6,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surface,
        selectedColor: accentDim,
        side: BorderSide(color: border),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(fontFamily: fontFamily, color: textPri, fontWeight: FontWeight.w600),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.white : textHint),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? success : border),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: accent),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius16, side: BorderSide(color: border)),
        textStyle: TextStyle(fontFamily: fontFamily, color: textPri, fontWeight: FontWeight.w600),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262A33) : const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontFamily: fontFamily, color: Colors.white, fontSize: 12),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: surface, surfaceTintColor: Colors.transparent),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      }),
    );
  }
}

// --- DYNAMIC COLORS (reads current brightness) ---
class AppColors {
  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Page background. Transparent inside a [GlassScope] so the backdrop
  /// shows through; use [baseBg] for the always-opaque colour.
  static Color bg(BuildContext context) =>
      GlassScope.isActive(context) ? Colors.transparent : baseBg(context);
  static Color baseBg(BuildContext context) =>
      _dark(context) ? AppTheme.darkBg : AppTheme.lightBg;
  static Color surface(BuildContext context) =>
      _dark(context) ? const Color(0xFF1A1D24) : const Color(0xFFF4F6FA);
  static Color card(BuildContext context) {
    if (GlassScope.isActive(context)) {
      // Slightly translucent so cards pick up the backdrop's colour.
      return _dark(context) ? const Color(0xE0181A21) : const Color(0xE6FFFFFF);
    }
    return _dark(context) ? AppTheme.darkCard : AppTheme.lightCard;
  }
  static Color border(BuildContext context) =>
      _dark(context) ? AppTheme.darkBorder : AppTheme.lightBorder;
  static Color textPrimary(BuildContext context) =>
      _dark(context) ? AppTheme.darkTextPri : AppTheme.lightTextPri;
  static Color textSecondary(BuildContext context) =>
      _dark(context) ? AppTheme.darkTextSec : AppTheme.lightTextSec;
  static Color textHint(BuildContext context) =>
      _dark(context) ? AppTheme.darkTextHint : AppTheme.lightTextHint;

  /// Gold for text and icons on cards: deeper in light mode for contrast.
  static Color accentText(BuildContext context) =>
      _dark(context) ? AppTheme.accent : const Color(0xFFA86400);

  /// Translucent fill for frosted-glass panels.
  static Color glass(BuildContext context) => _dark(context)
      ? const Color(0xE61A1D24)
      : const Color(0xEBFFFFFF);
  static Color glassBorder(BuildContext context) => _dark(context)
      ? const Color(0x1FFFFFFF)
      : const Color(0xB3FFFFFF);
  static List<BoxShadow> softShadow(BuildContext context) => [
        BoxShadow(
          color: _dark(context) ? const Color(0x66000000) : const Color(0x14223047),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}

// --- TEXT STYLES ---
class AppText {
  static const display = TextStyle(
      fontFamily: AppTheme.fontFamily, fontSize: 28, fontWeight: FontWeight.w800,
      letterSpacing: -0.8, height: 1.15);
  static const heading = TextStyle(
      fontFamily: AppTheme.fontFamily, fontSize: 20, fontWeight: FontWeight.w700,
      letterSpacing: -0.4);
  static const title = TextStyle(
      fontFamily: AppTheme.fontFamily, fontSize: 16, fontWeight: FontWeight.w700,
      letterSpacing: -0.1);
  static const body = TextStyle(
      fontFamily: AppTheme.fontFamily, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5);
  static const caption = TextStyle(
      fontFamily: AppTheme.fontFamily, fontSize: 12, fontWeight: FontWeight.w500);
  static const label = TextStyle(
      fontFamily: AppTheme.fontFamily, fontSize: 13, fontWeight: FontWeight.w600);
}
