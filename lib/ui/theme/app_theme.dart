import 'package:flutter/material.dart';

const _fontFamily = 'SourceHanSans';

// Palette anchors
const _halumiCyan = Color(0xFF459CF6);
const _primaryHover = Color(0xFF5FB4FF);
const _primaryPressed = Color(0xFF357DCA);
const _deepNavy = Color(0xFF030E20);
const _darkSurface = Color(0xFF121A2B);
const _surfaceHover = Color(0xFF1A2434);
const _borderBlue = Color(0xFF1F2A3C);
const _textPrimary = Color(0xFFE6EDF7);
const _textDisabled = Color(0xFF5F6B85);
const _success = Color(0xFF3DDC97);
const _warning = Color(0xFFF5B94A);
const _error = Color(0xFFFF6B6B);

class HalumiPalette extends ThemeExtension<HalumiPalette> {
  const HalumiPalette({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.border,
  });

  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color border;

  @override
  HalumiPalette copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? border,
  }) {
    return HalumiPalette(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      border: border ?? this.border,
    );
  }

  @override
  HalumiPalette lerp(ThemeExtension<HalumiPalette>? other, double t) {
    if (other is! HalumiPalette) return this;
    return HalumiPalette(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,
      border: Color.lerp(border, other.border, t) ?? border,
    );
  }
}

ThemeMode themeModeFromString(String value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

ThemeData buildLightTheme() {
  const scheme = ColorScheme.light(
    primary: _halumiCyan,
    onPrimary: _textPrimary,
    secondary: _halumiCyan,
    onSecondary: _textPrimary,
    error: _error,
    onError: _deepNavy,
    surface: Colors.white,
    onSurface: Color(0xFF0E1524),
    surfaceContainerHighest: Color(0xFFE5E9F2),
    outline: Color(0xFFCBD5E0),
    surfaceTint: _halumiCyan,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    filledButtonTheme: _filledButtonTheme(scheme),
    outlinedButtonTheme: _outlinedButtonTheme(scheme),
    fontFamily: _fontFamily,
    textTheme: _buildTextTheme(scheme),
    extensions: const [
      HalumiPalette(
        success: _success,
        warning: _warning,
        error: _error,
        info: _halumiCyan,
        border: _borderBlue,
      ),
    ],
  );
}

ThemeData buildDarkTheme() {
  const scheme = ColorScheme.dark(
    primary: _halumiCyan,
    onPrimary: _textPrimary,
    secondary: _halumiCyan,
    onSecondary: _textPrimary,
    error: _error,
    onError: _deepNavy,
    surface: _darkSurface,
    onSurface: _textPrimary,
    surfaceContainerHighest: _surfaceHover,
    outline: _borderBlue,
    surfaceTint: _halumiCyan,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: _deepNavy,
    filledButtonTheme: _filledButtonTheme(scheme),
    outlinedButtonTheme: _outlinedButtonTheme(scheme),
    fontFamily: _fontFamily,
    textTheme: _buildTextTheme(scheme),
    extensions: const [
      HalumiPalette(
        success: _success,
        warning: _warning,
        error: _error,
        info: _halumiCyan,
        border: _borderBlue,
      ),
    ],
  );
}

FilledButtonThemeData _filledButtonTheme(ColorScheme scheme) {
  final isLight = scheme.brightness == Brightness.light;
  return FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return isLight ? scheme.surfaceContainerHighest : _surfaceHover;
        }
        if (states.contains(WidgetState.pressed)) {
          return _primaryPressed;
        }
        if (states.contains(WidgetState.hovered)) {
          return _primaryHover;
        }
        return _halumiCyan;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _textDisabled;
        }
        return scheme.onPrimary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return scheme.onPrimary.withValues(alpha: isLight ? 0.12 : 0.18);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return scheme.onPrimary.withValues(alpha: 0.08);
        }
        return Colors.transparent;
      }),
    ),
  );
}

OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) {
  final isLight = scheme.brightness == Brightness.light;
  final hoverBackground = isLight ? scheme.surfaceContainerHighest : _surfaceHover;
  final pressedBackground = isLight
      ? scheme.surfaceContainerHighest.withValues(alpha: 0.9)
      : _deepNavy;
  final disabledBackground =
      isLight ? scheme.surfaceContainerHighest : _surfaceHover;
  final hoverBorder = isLight ? scheme.primary : _halumiCyan;
  final defaultBorder = scheme.outline;
  return OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledBackground;
        }
        if (states.contains(WidgetState.pressed)) {
          return pressedBackground;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return hoverBackground;
        }
        return scheme.surface;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _textDisabled;
        }
        return scheme.onSurface;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: defaultBorder.withValues(alpha: 0.6));
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return BorderSide(color: hoverBorder);
        }
        return BorderSide(color: defaultBorder);
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return scheme.primary.withValues(alpha: isLight ? 0.08 : 0.16);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return scheme.primary.withValues(alpha: isLight ? 0.06 : 0.12);
        }
        return Colors.transparent;
      }),
    ),
  );
}

TextTheme _buildTextTheme(ColorScheme scheme) {
  return TextTheme(
    headlineSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: scheme.onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: scheme.onSurface,
    ),
    titleSmall: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    bodyLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
    ),
    labelLarge: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: scheme.onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: _fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant,
    ),
  );
}
