import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =============================
/// 1) RENK SABİTLERİ
/// =============================
/// Uygulamanın kurumsal renk paleti burada.
/// Böylece her yerde sabit string yerine tek merkezden çağırabiliyorsun.
class SCColors {
  static const lavender = Color(0xFFE5819E); // primary
  static const apricot  = Color(0xFFF0827A); // secondary
  static const prim     = Color(0xFFF6E9F0); // surfaceVariant/container
  static const crusta   = Color(0xFFFA6F33); // tertiary/accent
  static const white    = Color(0xFFFFFFFF);
  static const black    = Color(0xFF1C1C1C);
}

/// =============================
/// 2) LIGHT THEME BUILDER
/// =============================
/// Uygulamanın Material3 tabanlı light temasını inşa ediyor.
/// Renkler, tipografi, input stilleri, butonlar, snackbar hepsi burada
/// merkezi olarak tanımlanıyor.
ThemeData buildLightTheme() {
  // Material3 ColorScheme — tüm renk rollerini belirtiyor.
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: SCColors.lavender,
    onPrimary: SCColors.white,
    secondary: SCColors.apricot,
    onSecondary: SCColors.white,
    tertiary: SCColors.crusta,
    onTertiary: SCColors.white,
    error: Color(0xFFB3261E),
    onError: SCColors.white,
    surface: SCColors.white,
    onSurface: SCColors.black,
    surfaceVariant: SCColors.prim,
    onSurfaceVariant: Color(0xFF4A4458),
    outline: Color(0xFF7A7086),
    outlineVariant: Color(0xFFE3D7E0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  // InputField için ortak border tanımı
  final baseInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE3D7E0)), // outlineVariant
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFFDFDFE),

    // =============================
    // 3) Tipografi (Google Fonts Roboto)
    // =============================
    textTheme: GoogleFonts.robotoTextTheme().copyWith(
      bodyMedium: GoogleFonts.roboto(fontWeight: FontWeight.w500, letterSpacing: 0),
      bodySmall:  GoogleFonts.roboto(fontWeight: FontWeight.w500, letterSpacing: 0),
      labelLarge: GoogleFonts.roboto(fontWeight: FontWeight.w600, letterSpacing: .2),
      headlineSmall: GoogleFonts.roboto(fontWeight: FontWeight.w700),
    ),

    // =============================
    // 4) Text selection
    // =============================
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: SCColors.lavender,
      selectionColor: Color(0x33B679E4),
      selectionHandleColor: SCColors.lavender,
    ),

    // =============================
    // 5) Input
    // =============================
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      fillColor: scheme.surfaceVariant,
      border: baseInputBorder,
      enabledBorder: baseInputBorder,
      focusedBorder: baseInputBorder.copyWith(
        borderSide: const BorderSide(color: SCColors.lavender, width: 2),
      ),
      errorBorder: baseInputBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFB3261E), width: 1.5),
      ),
      focusedErrorBorder: baseInputBorder.copyWith(
        borderSide: const BorderSide(color: Color(0xFFB3261E), width: 2),
      ),
      // Prefix/suffix ikonların renklerini state'e göre ayarlıyor
      prefixIconColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.error)) return const Color(0xFFB3261E);
        if (states.contains(MaterialState.focused) || states.contains(MaterialState.hovered)) {
          return SCColors.lavender;
        }
        return const Color(0xFF7A7086);
      }),
      suffixIconColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.error)) return const Color(0xFFB3261E);
        if (states.contains(MaterialState.focused) || states.contains(MaterialState.hovered)) {
          return SCColors.lavender;
        }
        return const Color(0xFF7A7086);
      }),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),

    // =============================
    // 6) Checkbox
    // =============================
    checkboxTheme: CheckboxThemeData(
      fillColor: const WidgetStatePropertyAll(SCColors.lavender),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide.none,
      // Hover/focus highlight’ı kaldır
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),

    // =============================
    // 7) FilledButton
    // =============================
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),

    // =============================
    // 8) OutlinedButton
    // =============================
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w600),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        side: WidgetStateProperty.resolveWith((states) {
          final base = scheme.outlineVariant;
          final focus = scheme.primary;
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return BorderSide(color: focus, width: 1.5);
          }
          return BorderSide(color: base, width: 1);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withOpacity(.38);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused) ||
              states.contains(WidgetState.pressed)) {
            return scheme.primary;
          }
          return scheme.onSurface;
        }),
      ),
    ),

    // =============================
    // 9) Card
    // =============================
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Divider
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),

    // =============================
    // 10) Snackbar
    // =============================
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.secondary,
      contentTextStyle: const TextStyle(color: SCColors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
