import 'package:flutter/material.dart';

class AppTheme {
  static const _seed = Colors.blue;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ).copyWith(
      primary: Colors.blue.shade700,
      onPrimary: Colors.white,
      secondary: Colors.pink.shade700,
      onSecondary: Colors.white,
      surface: Colors.white, // 거의 흰색
      onSurface: Colors.black87,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: ThemeData.light()
          .textTheme
          .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ).copyWith(
      primary: Colors.blueAccent.shade100,
      onPrimary: Colors.black,
      secondary: Colors.pinkAccent.shade100,
      onSecondary: Colors.black,
      surface: const Color(0xFF0F172A),
      onSurface: Colors.white70,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: ThemeData.dark()
          .textTheme
          .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
    );
  }
}
