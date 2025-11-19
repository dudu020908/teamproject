import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/main.dart';

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // 현재 다크모드 여부 감지
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
        icon: Icon(
          // 다크모드 상태에 따라 아이콘 변경
          isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          color: isDark ? Colors.white70 : Colors.black87,
          size: 28,
        ),
        // 클릭 시 전역 ThemeModeNotifier 토글 호출
        onPressed: () {
          context.read<ThemeModeNotifier>().toggle();
        },
        tooltip: isDark ? "라이트 모드로 전환" : "다크 모드로 전환",
      );
  }
}
