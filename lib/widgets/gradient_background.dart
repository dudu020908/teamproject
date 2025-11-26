import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    // 라이트 모드는 거의 흰색만 사용 (절대 어둡지 않게)
    final colors = isDark
        ? <Color>[
            const Color(0xFF020617), // 아주 어두운 남색 배경
            const Color(0xFF0F172A), // surface
            const Color(0xFF111827), // 살짝만 차이
          ]
        : <Color>[
            const Color(0xFFEEDDFF), // 완전 흰색
            const Color(0xFFDDFBFF), // 아주 옅은 파란빛 흰색
            const Color(0xFFFFFFFF), // 다시 흰색
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      // SafeArea는 각 화면에서 감싸는 구조 유지
      child: child,
    );
  }
}
