import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teamproject/main.dart';
import 'package:teamproject/screens/user_info_screen.dart';
import 'package:teamproject/widgets/dark_mode_toggle.dart';
import 'package:teamproject/widgets/gradient_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim1;
  late Animation<double> _scaleAnim2;
  late Animation<double> _fadeAnim1;
  late Animation<double> _fadeAnim2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _scaleAnim1 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _scaleAnim2 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
    );

    _fadeAnim1 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
    );

    _fadeAnim2 = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 페이드 전환용 함수 user_info_screen으로 넘어가는 애니메이션 효과
  void _navigateWithFade(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) =>
            FadeTransition(opacity: animation, child: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // 상단 다크모드 토글 버튼 (공통 위젯)
              const DarkModeToggle(),

              // 메인 콘텐츠
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 왕관 원형 등장 애니메이션
                    ScaleTransition(
                      scale: _scaleAnim1,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 4,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.emoji_events,
                            size: 64,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // My Pick 텍스트 (페이드 인)
                    FadeTransition(
                      opacity: _fadeAnim1,
                      child: Text(
                        "My Pick",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 부제 텍스트
                    FadeTransition(
                      opacity: _fadeAnim2,
                      child: Text(
                        "당신의 선택이 당신을 말해줍니다",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[300] : Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // 시작하기 버튼
                    ScaleTransition(
                      scale: _scaleAnim2,
                      child: ElevatedButton(
                        onPressed: () {
                          _navigateWithFade(context, const UserInfoScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.blueGrey[700]
                              : const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "시작하기",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
