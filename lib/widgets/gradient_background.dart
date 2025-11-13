import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700), // 부드러운 전환
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // 테마에 따라 자동 색상 전환
          colors: isDark
              ? [
                  const Color(0xFF0D0D0D), // 거의 검정색
                  const Color(0xFF1E1E1E), // 짙은 회색
                  const Color(0xFF2C2C2C), // 중간 회색
                ]
              : [
                  const Color(0xFFE3F0FF), // 파스텔 하늘색
                  const Color(0xFFFDFBFB), // 밝은 흰색
                  const Color(0xFFFFE4EC), // 연한 핑크
                ],
          stops: const [0.1, 0.6, 1.0],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
