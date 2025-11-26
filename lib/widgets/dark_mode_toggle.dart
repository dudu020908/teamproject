import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/main.dart'; 

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // 전역 ThemeModeNotifier 구독
    final themeNotifier = context.watch<ThemeModeNotifier>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = themeNotifier.mode == ThemeMode.dark;

    return IconButton(
      icon: Icon(
        isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
        color: scheme.onSurfaceVariant,
        size: 28,
      ),
      onPressed: themeNotifier.toggle,
      tooltip: isDark ? "라이트 모드로 전환" : "다크 모드로 전환",
    );
  }
}
