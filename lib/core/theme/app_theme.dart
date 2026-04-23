import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const double _goldenAngle = 137.50776405003785;

  static const Color seed = Color(0xFFC66A2B);

  static const Color scaffoldBackground = Color(0xFFFFF7EF);
  static const Color appBarBackground = Color(0xFFFFE9D4);

  static const Color textPrimary = Color(0xFF5A3724);
  static const Color textSecondary = Color(0xFF80563C);
  static const Color textMuted = Color(0xFF9A7156);
  static const Color textHeadingMuted = Color(0xFF7A5138);
  static const Color textBodyStrong = Color(0xFF4F3325);

  static const Color cardBackground = Color(0xFFFFF9F3);
  static const Color cardBorder = Color(0xFFE8D7C8);
  static const Color divider = Color(0xFFE9D9CB);

  static const Color gradientStart = Color(0xFFFFF8F1);
  static const Color gradientEnd = Color(0xFFFEE9D7);
  static const Color softShadow = Color(0x221E0E00);

  static const Color primaryButton = Color(0xFFC66A2B);
  static const Color selectorBorder = Color(0xFFE2D3C6);
  static const Color selectorIcon = Color(0xFF85563D);
  static const Color quantumLabel = Color(0xFF8B5E43);

  static const Color tableHeadingBackground = Color(0xFFFFF1E4);
  static const Color tableRowBackground = Color(0xFFFFFDF9);
  static const Color deleteIcon = Color(0xFF9A6243);

  static const Color inputFill = Color(0xFFFFFBF6);
  static const Color inputBorder = Color(0xFFDCC8B8);
  static const Color inputError = Color(0xFFE35D4B);
  static const Color inputFocus = Color(0xFF8B5E43);

  static const Color queueEmptyText = Color(0xFF8A6248);
  static const Color queueCellBorder = Color(0xFFD9C6B6);
  static const Color queueTimeText = Color(0xFF4A2A16);
  static const Color queueProcessText = Color(0xFF7D553D);
  static const Color queueIdleBackground = Color(0xFFF7EADF);

  static const List<Color> queueProcessPalette = <Color>[
    Color(0xFFAED9FF),
    Color(0xFFB9F2D0),
    Color(0xFFFFC4C4),
    Color(0xFFD7C9FF),
    Color(0xFFFFE8A8),
    Color(0xFFAEEDEB),
    Color(0xFFFFC9E7),
    Color(0xFFFFD5A8),
    Color(0xFFC4E7FF),
    Color(0xFFCFF7B8),
    Color(0xFFFFD0B8),
    Color(0xFFE2D8FF),
  ];

  static Color queueProcessColorForId(String processId) {
    final Match? numericSuffix = RegExp(r'(\d+)$').firstMatch(processId);
    if (numericSuffix != null) {
      final int? parsed = int.tryParse(numericSuffix.group(1)!);
      if (parsed != null && parsed > 0) {
        return queueProcessColorForIndex(parsed - 1);
      }
    }

    final int hash = processId.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return queueProcessColorForIndex(hash);
  }

  static Color queueProcessColorForIndex(int index) {
    if (index >= 0 && index < queueProcessPalette.length) {
      return queueProcessPalette[index];
    }

    final double hue = (index * _goldenAngle) % 360;
    final double saturation = 0.45 + ((index % 3) * 0.07);
    final double lightness = 0.78 - ((index % 4) * 0.04);

    return HSLColor.fromAHSL(
      1,
      hue,
      saturation.clamp(0.35, 0.65),
      lightness.clamp(0.68, 0.84),
    ).toColor();
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: scaffoldBackground,
      fontFamily: 'Avenir',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: appBarBackground,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryButton,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
