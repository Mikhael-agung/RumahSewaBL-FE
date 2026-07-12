import 'package:flutter/material.dart';

/// Palet warna & tema khusus modul Admin, diambil dari design token
/// (Tailwind/Material 3) mockup UI Admin.
/// Terpisah dari [ConstantColor] (dipakai Manager) supaya theming
/// Admin bisa dikembangkan sendiri tanpa mengganggu tampilan Manager.
class AdminColors {
  AdminColors._();

  static const primary = Color(0xFF00456C);
  static const primaryContainer = Color(0xFF005D90);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFFA8D4FF);
  static const primaryFixed = Color(0xFFCDE5FF);
  static const primaryFixedDim = Color(0xFF95CCFF);

  static const secondary = Color(0xFF585F68);
  static const secondaryContainer = Color(0xFFDDE3EE);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF5E656E);

  static const tertiary = Color(0xFF643600);
  static const tertiaryContainer = Color(0xFF854A00);
  static const onTertiary = Color(0xFFFFFFFF);
  static const onTertiaryContainer = Color(0xFFFFC491);

  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onError = Color(0xFFFFFFFF);
  static const onErrorContainer = Color(0xFF93000A);

  static const background = Color(0xFFF8F9FF);
  static const onBackground = Color(0xFF191C20);

  static const surface = Color(0xFFF8F9FF);
  static const surfaceDim = Color(0xFFD8DAE0);
  static const surfaceBright = Color(0xFFF8F9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F3F9);
  static const surfaceContainer = Color(0xFFECEEF3);
  static const surfaceContainerHigh = Color(0xFFE7E8EE);
  static const surfaceContainerHighest = Color(0xFFE1E2E8);
  static const surfaceVariant = Color(0xFFE1E2E8);
  static const onSurface = Color(0xFF191C20);
  static const onSurfaceVariant = Color(0xFF41474F);

  static const outline = Color(0xFF717880);
  static const outlineVariant = Color(0xFFC0C7D0);

  // Warna status non-Material-token, dipakai buat badge/chip aktivitas
  static const success = Color(0xFF0F8C53);
  static const successContainer = Color(0xFFD1FAE5);
  static const warning = Color(0xFFD97706);
  static const warningContainer = Color(0xFFFEF3C7);
}