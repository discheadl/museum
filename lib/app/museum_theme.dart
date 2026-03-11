import 'package:flutter/material.dart';

class MuseumTheme {
  static const Color _seed = Color(0xFF7F5539); // madera/arcilla
  static const Color _paper = Color(0xFFF3EEE6); // papel
  static const Color _ink = Color(0xFF1F1B16); // tinta

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      surface: _paper,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(onSurface: _ink),
      scaffoldBackgroundColor: _paper,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: base.cardTheme.copyWith(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.25),
      ),
    );
  }
}
