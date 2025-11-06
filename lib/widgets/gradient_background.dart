import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDFBFB), // 밝은 흰색
            Color(0xFFE3F0FF), // 파스텔 하늘색
            Color(0xFFFFE4EC), // 연핑크
          ],
          stops: [0.1, 0.6, 1.0],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
