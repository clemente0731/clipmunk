import 'dart:io';
import 'package:flutter/material.dart';

// =============================================================================
// retro-futurism 16-bit dot-matrix design system
//
// pixel grid: 4px base unit, all spacing snaps to multiples of 4
// palette: CRT phosphor-inspired - deep blue-black, cyan accent, amber warm
// typography: monospace only (Menlo/Consolas/monospace)
// borders: 1px sharp, 0 radius (pixel-perfect)
// no shadows, no blur, no rounded corners
// =============================================================================

/// 4px grid-aligned spacing constants
class Grid {
  Grid._();

  static const double unit = 4.0;

  // common multiples
  static const double x1 = 4.0;
  static const double x2 = 8.0;
  static const double x3 = 12.0;
  static const double x4 = 16.0;
  static const double x5 = 20.0;
  static const double x6 = 24.0;
  static const double x8 = 32.0;
  static const double x10 = 40.0;
  static const double x12 = 48.0;
}

/// CRT phosphor-inspired color palette
class Palette {
  Palette._();

  // background layers (deep blue-black)
  static const Color bg = Color(0xFF080C12);
  static const Color bgPanel = Color(0xFF0E1319);
  static const Color bgElevated = Color(0xFF141A22);
  static const Color bgInput = Color(0xFF0A0F16);

  // borders and lines
  static const Color border = Color(0xFF1C2430);
  static const Color borderActive = Color(0xFF2A3545);
  static const Color borderAccent = Color(0xFF00B8D4);

  // accent - phosphor cyan (primary interactive)
  static const Color cyan = Color(0xFF00D4E8);
  static const Color cyanDim = Color(0xFF006674);
  static const Color cyanGlow = Color(0xFF00E5FF);
  static const Color cyanMuted = Color(0xFF003D47);

  // warm accent - amber (secondary, warnings, highlights)
  static const Color amber = Color(0xFFE8A800);
  static const Color amberDim = Color(0xFF7A5800);
  static const Color amberMuted = Color(0xFF3D2E00);

  // text
  static const Color textPrimary = Color(0xFFD0D8E0);
  static const Color textSecondary = Color(0xFF6B7A8D);
  static const Color textTertiary = Color(0xFF3C4A5C);
  static const Color textAccent = Color(0xFF00D4E8);
  static const Color textAmber = Color(0xFFE8A800);

  // status indicators
  static const Color statusActive = Color(0xFF00D47E);
  static const Color statusInactive = Color(0xFF2A3545);
  static const Color statusError = Color(0xFFE84040);
  static const Color statusWarning = Color(0xFFE8A800);

  // scanline / subtle pattern
  static const Color scanline = Color(0x08FFFFFF);
}

/// monospace typography (system mono fonts)
class Typo {
  Typo._();

  static String get monoFamily {
    if (Platform.isMacOS) return 'Menlo';
    if (Platform.isWindows) return 'Consolas';
    return 'monospace';
  }

  static TextStyle get heading => TextStyle(
    fontFamily: monoFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.4,
    color: Palette.textPrimary,
  );

  static TextStyle get label => TextStyle(
    fontFamily: monoFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.4,
    color: Palette.textPrimary,
  );

  static TextStyle get body => TextStyle(
    fontFamily: monoFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.5,
    color: Palette.textPrimary,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: monoFamily,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.4,
    color: Palette.textSecondary,
  );

  static TextStyle get tiny => TextStyle(
    fontFamily: monoFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    height: 1.3,
    color: Palette.textTertiary,
  );

  static TextStyle get badge => TextStyle(
    fontFamily: monoFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    height: 1.2,
    color: Palette.cyan,
  );
}

/// app metadata
class AppMeta {
  AppMeta._();

  static const String version = '1.0.0';
}

/// window configuration
class WindowConfig {
  WindowConfig._();

  static const double width = 520;
  static const double height = 460;
  static const double minWidth = 420;
  static const double minHeight = 360;
}
